mod config;
mod panel;
mod source;
mod widgets;

use gtk4 as gtk;
use gtk::{gdk, glib, prelude::*};
use std::{cell::RefCell, path::Path, rc::Rc};

const CSS: &str = include_str!("default.css");

fn load_css(cfg_path: &Path) {
    let Some(display) = gdk::Display::default() else { return };
    let base = gtk::CssProvider::new();
    base.load_from_data(CSS);
    gtk::style_context_add_provider_for_display(&display, &base, gtk::STYLE_PROVIDER_PRIORITY_APPLICATION);
    if let Ok(user) = std::fs::read_to_string(cfg_path.with_file_name("style.css")) {
        let p = gtk::CssProvider::new();
        p.load_from_data(&user);
        gtk::style_context_add_provider_for_display(&display, &p, gtk::STYLE_PROVIDER_PRIORITY_USER);
    }
}

fn main() -> glib::ExitCode {
    let path = std::env::args().nth(1).map(std::path::PathBuf::from).unwrap_or_else(config::default_path);
    let cfg = Rc::new(config::load(&path));
    let app = gtk::Application::builder().application_id("dev.local.dash").build();

    app.connect_activate(move |app| {
        std::mem::forget(app.hold()); // stay alive even with zero monitors
        load_css(&path);
        let display = gdk::Display::default().expect("no display");
        let windows: Rc<RefCell<Vec<gtk::ApplicationWindow>>> = Default::default();

        let rebuild = {
            let (app, cfg, display, windows) = (app.clone(), cfg.clone(), display.clone(), windows.clone());
            Rc::new(move || {
                for w in windows.borrow_mut().drain(..) { w.close(); }
                let mons = display.monitors();
                for i in 0..mons.n_items() {
                    let Some(m) = mons.item(i).and_downcast::<gdk::Monitor>() else { continue };
                    for p in &cfg.panel {
                        if panel::wanted(p, &m) {
                            windows.borrow_mut().push(panel::build(&app, &cfg, p, &m));
                        }
                    }
                }
            })
        };
        rebuild();
        // Monitor hotplug: rebuild (event-driven, no polling).
        let r = rebuild.clone();
        display.monitors().connect_items_changed(move |_, _, _, _| r());
    });

    app.run_with_args(&["dash"])
}
