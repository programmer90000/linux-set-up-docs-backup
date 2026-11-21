use super::{tag, Ctx};
use crate::source;
use gtk4 as gtk;
use gtk::{glib, prelude::*};
use std::{cell::RefCell, rc::Rc};

#[derive(Default, Clone, Copy)]
pub struct Defaults {
    pub kind: &'static str,
    pub icon: &'static str,
    pub format: &'static str,
    pub stream: Option<&'static str>,
    pub watch: Option<&'static str>,
    pub command: Option<&'static str>,
    pub on_click: Option<&'static str>,
    pub on_right_click: Option<&'static str>,
}

pub fn build(ctx: &Ctx, d: Defaults) -> gtk::Widget {
    let c = &ctx.cfg;
    let pick = |u: &Option<String>, d: Option<&'static str>| u.clone().or(d.map(String::from));
    let icon = c.icon.clone().unwrap_or_else(|| d.icon.to_string());
    let format = c.format.clone()
        .unwrap_or_else(|| if d.format.is_empty() { "{icon} {text}".into() } else { d.format.into() });
    let (stream, watch, command) = (pick(&c.stream, d.stream), pick(&c.watch, d.watch), pick(&c.command, d.command));

    let label = gtk::Label::new(None);
    let btn = gtk::Button::new();
    btn.set_child(Some(&label));
    tag(&btn, if d.kind.is_empty() { "command" } else { d.kind });

    let last_class = Rc::new(RefCell::new(String::new()));
    let apply = Rc::new({
        let (label, btn, report) = (label.clone(), btn.clone(), ctx.report.clone());
        move |line: String| {
            let mut text = line.trim().to_string();
            let (mut class, mut tip, mut ic) = (String::new(), None::<String>, icon.clone());
            if text.starts_with('{') {
                if let Ok(v) = serde_json::from_str::<serde_json::Value>(&text) {
                    text = v["text"].as_str().unwrap_or("").to_string();
                    class = v["class"].as_str().unwrap_or("").to_string();
                    tip = v["tooltip"].as_str().map(String::from);
                    if let Some(i) = v["icon"].as_str() { ic = i.to_string(); }
                }
            }
            label.set_text(format.replace("{icon}", &ic).replace("{text}", &text).trim());
            btn.set_tooltip_text(tip.as_deref());
            let mut lc = last_class.borrow_mut();
            if !lc.is_empty() { btn.remove_css_class(&lc); }
            if !class.is_empty() { btn.add_css_class(&class); }
            *lc = class.clone();
            report(&text, &class);
        }
    });

    let rx = match (&stream, &watch, &command) {
        (Some(s), _, _) => Some(source::lines(s)),
        (None, Some(w), Some(q)) => Some(source::watch_query(w, q)),
        (None, Some(w), None) => Some(source::lines(w)),
        (None, None, Some(q)) => Some(source::query_once(q)),
        _ => None,
    };
    match rx {
        Some(rx) => {
            let apply = apply.clone();
            glib::spawn_future_local(async move {
                while let Ok(line) = rx.recv().await { apply(line); }
            });
        }
        None => apply(String::new()),
    }

    if let Some(cmd) = pick(&c.on_click, d.on_click) {
        btn.connect_clicked(move |_| source::spawn(&cmd));
    }
    if let Some(cmd) = pick(&c.on_right_click, d.on_right_click) {
        let g = gtk::GestureClick::builder().button(3).build();
        g.connect_pressed(move |_, _, _, _| source::spawn(&cmd));
        btn.add_controller(g);
    }
    btn.upcast()
}