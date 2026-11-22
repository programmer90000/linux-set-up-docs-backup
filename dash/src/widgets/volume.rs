//! Volume + input/output device selection through `pactl` (works with pipewire-pulse).
//! `pactl subscribe` is the event source; state is re-read only when something changed.
use super::{menu_button, tag, Ctx};
use crate::source;
use gtk4 as gtk;
use gtk::{glib, prelude::*};
use std::{cell::{Cell, RefCell}, process::Command, rc::Rc, time::Duration};

#[derive(Clone, Default)]
struct Dev { name: String, desc: String, vol: u32, mute: bool }
#[derive(Clone, Default)]
struct Snap { sinks: Vec<Dev>, sources: Vec<Dev>, def_sink: String, def_source: String }

fn pactl(args: &[&str]) -> serde_json::Value {
    Command::new("pactl").arg("--format=json").args(args).output().ok()
        .and_then(|o| serde_json::from_slice(&o.stdout).ok()).unwrap_or_default()
}

fn devices(kind: &str) -> Vec<Dev> {
    let v = pactl(&["list", kind]);
    v.as_array().cloned().unwrap_or_default().iter().filter_map(|d| {
        let name = d["name"].as_str()?.to_string();
        if name.ends_with(".monitor") { return None; }
        let vol = d["volume"].as_object()?.values().next()?["value_percent"]
            .as_str()?.trim_end_matches('%').parse().ok()?;
        let desc = d["description"].as_str().unwrap_or(&name).to_string();
        Some(Dev { name, desc, vol, mute: d["mute"].as_bool().unwrap_or(false) })
    }).collect()
}

fn snapshot() -> Snap {
    let info = pactl(&["info"]);
    Snap {
        sinks: devices("sinks"),
        sources: devices("sources"),
        def_sink: info["default_sink_name"].as_str().unwrap_or("").into(),
        def_source: info["default_source_name"].as_str().unwrap_or("").into(),
    }
}

fn snapshots() -> async_channel::Receiver<Snap> {
    let (tx, rx) = async_channel::unbounded();
    std::thread::spawn(move || {
        let ev = source::lines("pactl subscribe");
        if tx.send_blocking(snapshot()).is_err() { return; }
        while let Ok(l) = ev.recv_blocking() {
            if !(l.contains("on sink #") || l.contains("on source #") || l.contains("on server")) { continue; }
            std::thread::sleep(Duration::from_millis(30));
            while ev.try_recv().is_ok() {}
            if tx.send_blocking(snapshot()).is_err() { break; }
        }
    });
    rx
}

struct Section {
    root: gtk::Box,
    dd: gtk::DropDown,
    scale: gtk::Scale,
    names: Rc<RefCell<Vec<String>>>,
    busy: Rc<Cell<bool>>,
}

impl Section {
    fn new(title: &str, kind: &'static str) -> Self {
        let root = gtk::Box::new(gtk::Orientation::Vertical, 4);
        let t = gtk::Label::new(Some(title));
        t.set_xalign(0.0);
        t.add_css_class("section-title");
        root.append(&t);
        let dd = gtk::DropDown::from_strings(&[]);
        root.append(&dd);
        let scale = gtk::Scale::with_range(gtk::Orientation::Horizontal, 0.0, 150.0, 1.0);
        scale.set_size_request(240, -1);
        scale.set_draw_value(true);
        root.append(&scale);

        let names = Rc::new(RefCell::new(Vec::<String>::new()));
        let busy = Rc::new(Cell::new(false));
        {
            let (names, busy) = (names.clone(), busy.clone());
            dd.connect_selected_notify(move |d| {
                if busy.get() { return; }
                if let Some(n) = names.borrow().get(d.selected() as usize) {
                    source::exec(&["pactl", &format!("set-default-{kind}"), n]);
                }
            });
        }
        {
            // debounce: at most one pactl call per 40 ms while dragging
            let (busy, pending) = (busy.clone(), Rc::new(Cell::new(None::<u32>)));
            scale.connect_value_changed(move |s| {
                if busy.get() { return; }
                let first = pending.get().is_none();
                pending.set(Some(s.value() as u32));
                if first {
                    let pending = pending.clone();
                    glib::timeout_add_local_once(Duration::from_millis(40), move || {
                        if let Some(v) = pending.take() {
                            source::exec(&["pactl", &format!("set-{kind}-volume"),
                                &format!("@DEFAULT_{}@", kind.to_uppercase()), &format!("{v}%")]);
                        }
                    });
                }
            });
        }
        Section { root, dd, scale, names, busy }
    }

    fn update(&self, devs: &[Dev], default: &str) {
        self.busy.set(true);
        if let Some(model) = self.dd.model().and_downcast::<gtk::StringList>() {
            let descs: Vec<&str> = devs.iter().map(|d| d.desc.as_str()).collect();
            model.splice(0, model.n_items(), &descs);
        }
        *self.names.borrow_mut() = devs.iter().map(|d| d.name.clone()).collect();
        if let Some(i) = devs.iter().position(|d| d.name == default) {
            self.dd.set_selected(i as u32);
            self.scale.set_value(devs[i].vol as f64);
        }
        self.busy.set(false);
    }
}

pub fn build(ctx: &Ctx) -> gtk::Widget {
    let icon = ctx.cfg.icon.clone().unwrap_or_else(|| "🔊".into());
    let content = gtk::Box::new(gtk::Orientation::Vertical, 10);
    let out = Section::new("Output", "sink");
    let inp = Section::new("Input", "source");
    content.append(&out.root);
    content.append(&inp.root);

    let (mb, _pop) = menu_button(ctx, &content);
    mb.set_label(&icon);
    tag(&mb, "volume");

    // right click = mute, wheel = ±5 %
    let g = gtk::GestureClick::builder().button(3).build();
    g.connect_pressed(|_, _, _, _| source::exec(&["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]));
    mb.add_controller(g);
    let sc = gtk::EventControllerScroll::new(gtk::EventControllerScrollFlags::VERTICAL);
    sc.connect_scroll(|_, _, dy| {
        source::exec(&["pactl", "set-sink-volume", "@DEFAULT_SINK@", if dy < 0.0 { "+5%" } else { "-5%" }]);
        glib::Propagation::Stop
    });
    mb.add_controller(sc);

    let rx = snapshots();
    let (mbc, report) = (mb.clone(), ctx.report.clone());
    glib::spawn_future_local(async move {
        while let Ok(s) = rx.recv().await {
            out.update(&s.sinks, &s.def_sink);
            inp.update(&s.sources, &s.def_source);
            let cur = s.sinks.iter().find(|d| d.name == s.def_sink);
            let (text, class): (String, &str) = match cur {
                Some(d) if d.mute => ("muted".into(), "muted"),
                Some(d) => (format!("{}%", d.vol), ""),
                None => ("n/a".into(), ""),
            };
            mbc.set_label(&format!("{icon} {text}"));
            if class == "muted" { mbc.add_css_class("muted") } else { mbc.remove_css_class("muted") }
            report(&text, class);
        }
    });
    mb.upcast()
}
