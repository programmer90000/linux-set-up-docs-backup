use super::{tag, Ctx};
use crate::source;
use gtk4 as gtk;
use gtk::{gio, prelude::*};

/// Launcher buttons from `items` (use `desktop = "x.desktop"` or `command = "..."`).
pub fn build(ctx: &Ctx) -> gtk::Widget {
    let orient = if ctx.vertical { gtk::Orientation::Vertical } else { gtk::Orientation::Horizontal };
    let row = gtk::Box::new(orient, 4);
    tag(&row, "app_list");
    for it in &ctx.cfg.items {
        let btn = gtk::Button::new();
        btn.add_css_class("app");
        let info = it.desktop.as_deref().and_then(gio::DesktopAppInfo::new);
        if let Some(name) = &it.icon {
            btn.set_child(Some(&gtk::Image::from_icon_name(name)));
        } else if let Some(icon) = info.as_ref().and_then(|i| i.icon()) {
            btn.set_child(Some(&gtk::Image::from_gicon(&icon)));
        } else {
            btn.set_label(it.label.as_deref().unwrap_or("?"));
        }
        if let Some(t) = it.label.clone().or_else(|| info.as_ref().map(|i| i.name().to_string())) {
            btn.set_tooltip_text(Some(&t));
        }
        if let Some(info) = info {
            btn.connect_clicked(move |_| { let _ = info.launch(&[], gio::AppLaunchContext::NONE); });
        } else if let Some(cmd) = it.command.clone() {
            btn.connect_clicked(move |_| source::spawn(&cmd));
        }
        row.append(&btn);
    }
    row.upcast()
}
