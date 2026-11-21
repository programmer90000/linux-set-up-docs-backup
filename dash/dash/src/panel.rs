use crate::config::{Config, PanelCfg};
use crate::widgets::{self, Ctx};
use gtk4 as gtk;
use gtk::{gdk, glib, prelude::*};
use gtk4_layer_shell::{Edge, Layer, LayerShell};
use std::{cell::RefCell, rc::Rc};

pub fn wanted(p: &PanelCfg, m: &gdk::Monitor) -> bool {
    if p.monitors.is_empty() || p.monitors.iter().any(|x| x == "*") { return true; }
    m.connector().map(|c| p.monitors.iter().any(|x| x == c.as_str())).unwrap_or(false)
}

/// When does a widget from `more` move onto the dash?
enum Mode { Never, Always, NonEmpty, Class(String), MinLen(i32) }

impl Mode {
    fn parse(s: Option<&str>) -> Mode {
        match s.unwrap_or("never") {
            "never" => Mode::Never,
            "always" => Mode::Always,
            "nonempty" => Mode::NonEmpty,
            x if x.starts_with("class:") => Mode::Class(x[6..].to_string()),
            x if x.starts_with("min_length:") => Mode::MinLen(x[11..].parse().unwrap_or(i32::MAX)),
            other => { eprintln!("dash: bad show_on_dash '{other}'"); Mode::Never }
        }
    }
    fn initially_on_dash(&self, len: i32) -> bool {
        match self { Mode::Always => true, Mode::MinLen(n) => len >= *n, _ => false }
    }
    /// Decision after a widget reported new state (None = this mode ignores reports).
    fn on_report(&self, text: &str, class: &str) -> Option<bool> {
        match self {
            Mode::NonEmpty => Some(!text.is_empty()),
            Mode::Class(c) => Some(class == c),
            _ => None,
        }
    }
}

pub fn build(app: &gtk::Application, cfg: &Config, p: &PanelCfg, mon: &gdk::Monitor) -> gtk::ApplicationWindow {
    let (top, bottom, left, right, vertical, arrow) = match p.position.as_str() {
        "bottom" => (false, true, true, true, false, gtk::ArrowType::Up),
        "left" => (true, true, true, false, true, gtk::ArrowType::Right),
        "right" => (true, true, false, true, true, gtk::ArrowType::Left),
        _ => (true, false, true, true, false, gtk::ArrowType::Down),
    };

    let win = gtk::ApplicationWindow::new(app);
    win.add_css_class("dash");
    win.init_layer_shell();
    win.set_layer(Layer::Top);
    win.set_monitor(mon);
    win.set_namespace("dash");
    win.set_anchor(Edge::Top, top);
    win.set_anchor(Edge::Bottom, bottom);
    win.set_anchor(Edge::Left, left);
    win.set_anchor(Edge::Right, right);
    win.auto_exclusive_zone_enable(); // reserves screen space
    if vertical { win.set_default_size(p.size, -1) } else { win.set_default_size(-1, p.size) }

    let orient = if vertical { gtk::Orientation::Vertical } else { gtk::Orientation::Horizontal };
    let dash = gtk::Box::new(orient, p.spacing);
    dash.add_css_class("dash-box");
    let more_box = gtk::Box::new(gtk::Orientation::Vertical, 6);
    more_box.add_css_class("more-box");

    let geo = mon.geometry();
    let len = if vertical { geo.height() } else { geo.width() };
    let noop: Rc<dyn Fn(&str, &str)> = Rc::new(|_, _| {});

    for name in &p.widgets {
        let (kind, wc) = cfg.resolve(name);
        let ctx = Ctx { cfg: wc, vertical, arrow, report: noop.clone() };
        let w = if kind == "show_more" { Some(widgets::show_more::build(&ctx, &more_box)) } else { widgets::build(&kind, &ctx) };
        if let Some(w) = w { dash.append(&w); }
    }

    for name in &p.more {
        let (kind, wc) = cfg.resolve(name);
        let mode = Rc::new(Mode::parse(wc.show_on_dash.as_deref()));
        let slot: Rc<RefCell<Option<gtk::Widget>>> = Default::default();

        let mover = {
            let (slot, dash, more_box) = (slot.clone(), dash.clone(), more_box.clone());
            Rc::new(move |on: bool| {
                let Some(w) = slot.borrow().clone() else { return };
                let in_dash = w.parent().map(|p| p == dash.clone().upcast::<gtk::Widget>());
                if in_dash == Some(on) { return; }
                if let Some(b) = w.parent().and_then(|p| p.downcast::<gtk::Box>().ok()) { b.remove(&w); }
                if on { dash.append(&w) } else { more_box.append(&w) }
            })
        };
        let report: Rc<dyn Fn(&str, &str)> = {
            let (mode, mover) = (mode.clone(), mover.clone());
            Rc::new(move |t, c| { if let Some(on) = mode.on_report(t, c) { mover(on) } })
        };

        let ctx = Ctx { cfg: wc, vertical, arrow, report };
        if let Some(w) = widgets::build(&kind, &ctx) {
            *slot.borrow_mut() = Some(w.clone());
            if mode.initially_on_dash(len) { dash.append(&w) } else { more_box.append(&w) }
        }
    }

    let scroll = gtk::ScrolledWindow::new();
    if vertical {
        scroll.set_policy(gtk::PolicyType::Never, gtk::PolicyType::Automatic);
    } else {
        scroll.set_policy(gtk::PolicyType::Automatic, gtk::PolicyType::Never);
        // mouse wheel scrolls sideways on a horizontal dash
        let sc = gtk::EventControllerScroll::new(gtk::EventControllerScrollFlags::VERTICAL);
        let adj = scroll.hadjustment();
        sc.connect_scroll(move |_, _, dy| {
            adj.set_value(adj.value() + dy * 40.0);
            glib::Propagation::Stop
        });
        scroll.add_controller(sc);
    }
    scroll.set_child(Some(&dash));
    win.set_child(Some(&scroll));
    win.present();
    win
}
