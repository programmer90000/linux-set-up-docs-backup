mod config;
mod panel;
mod source;

use gtk4 as gtk;
use gtk::{gdk, glib, prelude::*};
use std::{cell::RefCell, rc::Rc};

fn main() -> glib::ExitCode {
    let path = std::env::args().nth(1).map(std::path::PathBuf::from).unwrap_or_else(config::default_path);
    let cfg = Rc::new(config::load(&path));
    let app = gtk::Application::builder().application_id("dev.local.dash").build();

    app.connect_activate(move |app| {
        std::mem::forget(app.hold());
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
        let r = rebuild.clone();
        display.monitors().connect_items_changed(move |_, _, _, _| r());
    });

    app.run_with_args(&["dash"])
}