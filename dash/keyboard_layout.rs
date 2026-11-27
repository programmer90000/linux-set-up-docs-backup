use super::{tag, Ctx};
use crate::source;
use gtk4 as gtk;
use gtk::{glib, prelude::*};
use std::process::Command;

pub fn build(ctx: &Ctx) -> gtk::Widget {
    let icon = ctx.cfg.icon.clone().unwrap_or_default();
    let format = ctx.cfg.format.clone().unwrap_or_else(|| "{text}".into());
    
    let label = gtk::Label::new(None);
    let btn = gtk::Button::new();
    btn.set_child(Some(&label));
    tag(&btn, "keyboard_layout");

    let report_for_async = ctx.report.clone();
    let report_for_click = ctx.report.clone();

    let rx = source::watch_query(
        "while :; do sleep 3; done",
        r##"localectl status 2>/dev/null | awk '/X11 Layout/{print $3}' | grep . || echo 'n/a'"##
    );
    
    let label_clone = label.clone();
    let format_clone = format.clone();
    let icon_clone = icon.clone();
    glib::spawn_future_local(async move {
        while let Ok(line) = rx.recv().await {
            let text = format_clone.replace("{icon}", &icon_clone).replace("{text}", line.trim());
            label_clone.set_text(&text);
            report_for_async(line.trim(), "");
        }
    });

    let label_for_click_win = label.clone();
    let format_for_click = format.clone();
    let icon_for_click = icon.clone();

    btn.connect_clicked(move |_| {
        open_keyboard_layouts_window(
            label_for_click_win.clone(),
            format_for_click.clone(),
            icon_for_click.clone(),
            report_for_click.clone(),
        );
    });

    btn.upcast()
}

fn fetch_layouts() -> Vec<String> {
    let out = Command::new("sh")
        .arg("-c")
        .arg("localectl list-x11-keymap-layouts 2>/dev/null")
        .output();
    match out {
        Ok(o) if o.status.success() => {
            String::from_utf8_lossy(&o.stdout)
                .lines()
                .map(|s| s.trim().to_string())
                .filter(|s| !s.is_empty())
                .collect()
        }
        _ => vec!["us".to_string(), "gb".to_string(), "de".to_string(), "fr".to_string()],
    }
}

fn open_keyboard_layouts_window(
    label: gtk::Label,
    format: String,
    icon: String,
    report: std::rc::Rc<dyn Fn(&str, &str)>,
) {
    let win = gtk::Window::builder()
        .title("Keyboard Layouts")
        .default_width(320)
        .default_height(420)
        .modal(true)
        .build();
    
    win.add_css_class("dash-window");

    let vbox = gtk::Box::new(gtk::Orientation::Vertical, 10);
    vbox.set_margin_start(12);
    vbox.set_margin_end(12);
    vbox.set_margin_top(12);
    vbox.set_margin_bottom(12);

    let title_label = gtk::Label::new(Some("Select Keyboard Layout"));
    title_label.set_halign(gtk::Align::Start);
    title_label.add_css_class("section-title");
    vbox.append(&title_label);

    let scroll = gtk::ScrolledWindow::new();
    scroll.set_vexpand(true);
    scroll.set_policy(gtk::PolicyType::Never, gtk::PolicyType::Automatic);

    let list_box = gtk::ListBox::new();
    list_box.add_css_class("keyboard-layout-list");
    scroll.set_child(Some(&list_box));
    vbox.append(&scroll);

    win.set_child(Some(&vbox));

    let layouts = fetch_layouts();
    for layout in layouts {
        let row = gtk::ListBoxRow::new();
        let lbl = gtk::Label::new(Some(&layout));
        lbl.set_xalign(0.0);
        lbl.set_margin_top(8);
        lbl.set_margin_bottom(8);
        lbl.set_margin_start(8);
        lbl.set_margin_end(8);
        row.set_child(Some(&lbl));
        list_box.append(&row);
    }

    let win_clone = win.clone();
    list_box.connect_row_activated(move |_, row| {
        if let Some(child) = row.child() {
            if let Ok(lbl) = child.downcast::<gtk::Label>() {
                let layout = lbl.text().to_string();
                
                // 1. Set system-wide via localectl (triggers authentication)
                source::spawn(&format!("localectl set-x11-keymap {}", layout));
                
                // 2. Apply instantly to the active session
                source::spawn(&format!("setxkbmap {}", layout));

                // 3. Update the panel text instantly
                let text = format.replace("{icon}", &icon).replace("{text}", &layout);
                label.set_text(&text);
                report(&layout, "");

                win_clone.close();
            }
        }
    });

    win.present();
}
