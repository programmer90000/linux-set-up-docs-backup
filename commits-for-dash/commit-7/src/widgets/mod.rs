use crate::config::WidgetCfg;
use gtk4 as gtk;
use gtk::{glib, prelude::*};
use std::rc::Rc;

pub mod app_list;
pub mod clock;
pub mod command;
pub mod date;

pub struct Ctx {
    pub cfg: WidgetCfg,
    pub vertical: bool,
    pub arrow: gtk::ArrowType,
    pub report: Rc<dyn Fn(&str, &str)>,
}

pub fn build(kind: &str, ctx: &Ctx) -> Option<gtk::Widget> {
    Some(match kind {
        "app_list" => app_list::build(ctx),
        "clock" => clock::build(ctx),
        "date" => date::build(ctx),
        "command" => command::build(ctx, command::Defaults::default()),
        other => {
            eprintln!("dash: unknown widget type '{other}'");
            return None;
        }
    })
}

pub fn tag(w: &impl IsA<gtk::Widget>, kind: &str) {
    w.add_css_class("widget");
    w.add_css_class(&format!("widget-{}", kind.replace('_', "-")));
}

pub fn time_label(ctx: &Ctx, kind: &str, default_fmt: &str) -> gtk::Widget {
    let fmt = ctx.cfg.format.clone().unwrap_or_else(|| default_fmt.to_string());
    let label = gtk::Label::new(None);
    tag(&label, kind);
    let update = {
        let (label, fmt) = (label.clone(), fmt.clone());
        move || {
            if let Ok(now) = glib::DateTime::now_local() {
                if let Ok(s) = now.format(&fmt) { label.set_text(&s); }
            }
        }
    };
    update();
    crate::source::on_boundary(crate::source::granularity(&fmt), update);
    label.upcast()
}