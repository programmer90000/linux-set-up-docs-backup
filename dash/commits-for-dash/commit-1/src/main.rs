mod panel;

use gtk4 as gtk;
use gtk::{gdk, glib, prelude::*};
use std::{cell::RefCell, rc::Rc};

fn main() -> glib::ExitCode {
    let app = gtk::Application::builder().application_id("dev.local.dash").build();

    app.connect_activate(move |app| {
        std::mem::forget(app.hold());
        let display = gdk::Display::default().expect("no display");
        let windows: Rc<RefCell<Vec<gtk::ApplicationWindow>>> = Default::default();

        let mons = display.monitors();
        for i in 0..mons.n_items() {
            let Some(m) = mons.item(i).and_downcast::<gdk::Monitor>() else { continue };
            windows.borrow_mut().push(panel::build_skeleton(&app, &m));
        }
    });

    app.run_with_args(&["dash"])
}