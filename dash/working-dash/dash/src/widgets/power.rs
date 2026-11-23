use super::{menu_button, tag, Ctx};
use crate::{config::Item, source};
use gtk4 as gtk;
use gtk::prelude::*;

fn item(label: &str, cmd: &str) -> Item {
    Item { label: Some(label.into()), command: Some(cmd.into()), ..Default::default() }
}

pub fn build(ctx: &Ctx) -> gtk::Widget {
    let items = if ctx.cfg.items.is_empty() {
        vec![
            item("Suspend", "systemctl suspend"),
            item("Reboot", "systemctl reboot"),
            item("Power off", "systemctl poweroff"),
            item("Log out", "loginctl terminate-session \"$XDG_SESSION_ID\""),
        ]
    } else { ctx.cfg.items.clone() };

    let list = gtk::Box::new(gtk::Orientation::Vertical, 2);
    let (mb, pop) = menu_button(ctx, &list);
    for it in items {
        let b = gtk::Button::with_label(it.label.as_deref().unwrap_or("?"));
        b.add_css_class("flat");
        let (pop, cmd) = (pop.clone(), it.command.unwrap_or_default());
        b.connect_clicked(move |_| { pop.popdown(); source::spawn(&cmd); });
        list.append(&b);
    }
    mb.set_label(ctx.cfg.icon.as_deref().unwrap_or("⏻"));
    tag(&mb, "power");
    mb.upcast()
}
