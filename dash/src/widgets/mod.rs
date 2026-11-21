use crate::{config::WidgetCfg, source};
use gtk4 as gtk;
use gtk::{glib, prelude::*};
use std::rc::Rc;

pub mod app_list;
pub mod bluetooth;
pub mod caps_lock;
pub mod clock;
pub mod command;
pub mod copyq;
pub mod date;
pub mod keyboard_layout;
pub mod mpd;
pub mod notifications;
pub mod pipewire;
pub mod power;
pub mod show_more;
pub mod volume;
pub mod wheeltani;
pub mod wifi;
pub mod workspaces;

/// Everything a widget gets when it is built.
pub struct Ctx {
    pub cfg: WidgetCfg,
    pub vertical: bool,
    pub arrow: gtk::ArrowType, // direction popovers open in
    /// Call with (text, css-class) whenever state changes; drives `show_on_dash`.
    pub report: Rc<dyn Fn(&str, &str)>,
}

pub fn build(kind: &str, ctx: &Ctx) -> Option<gtk::Widget> {
    Some(match kind {
        "app_list" => app_list::build(ctx),
        "date" => date::build(ctx),
        "clock" => clock::build(ctx),
        "caps_lock" => caps_lock::build(ctx),
        "workspaces" => workspaces::build(ctx),
        "notifications" => notifications::build(ctx),
        "copyq" => copyq::build(ctx),
        "volume" => volume::build(ctx),
        "wifi" => wifi::build(ctx),
        "power" => power::build(ctx),
        "bluetooth" => bluetooth::build(ctx),
        "mpd" => mpd::build(ctx),
        "pipewire" => pipewire::build(ctx),
        "keyboard_layout" => keyboard_layout::build(ctx),
        "wheeltani" => wheeltani::build(ctx),
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

pub fn menu_button(ctx: &Ctx, content: &impl IsA<gtk::Widget>) -> (gtk::MenuButton, gtk::Popover) {
    let pop = gtk::Popover::new();
    pop.add_css_class("dash-popover");
    pop.set_child(Some(content));
    let mb = gtk::MenuButton::new();
    mb.set_direction(ctx.arrow);
    mb.set_popover(Some(&pop));
    (mb, pop)
}

/// Label that re-renders exactly when the shown time unit changes.
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
    source::on_boundary(source::granularity(&fmt), update);
    label.upcast()
}
