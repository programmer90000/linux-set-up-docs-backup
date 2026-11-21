use gtk4 as gtk;
use gtk::{gdk, prelude::*};
use gtk4_layer_shell::{Edge, Layer, LayerShell};

pub fn build_skeleton(app: &gtk::Application, mon: &gdk::Monitor) -> gtk::ApplicationWindow {
    let win = gtk::ApplicationWindow::new(app);
    win.init_layer_shell();
    win.set_layer(Layer::Top);
    win.set_monitor(mon);
    win.set_namespace("dash");
    win.set_anchor(Edge::Top, true);
    win.set_anchor(Edge::Left, true);
    win.set_anchor(Edge::Right, true);
    win.auto_exclusive_zone_enable();
    win.set_default_size(-1, 36);

    let dash_box = gtk::Box::new(gtk::Orientation::Horizontal, 4);
    win.set_child(Some(&dash_box));
    win.present();
    win
}