use crate::config::{Config, PanelCfg};
use gtk4 as gtk;
use gtk::{gdk, prelude::*};
use gtk4_layer_shell::{Edge, Layer, LayerShell};

pub fn wanted(p: &PanelCfg, m: &gdk::Monitor) -> bool {
    if p.monitors.is_empty() || p.monitors.iter().any(|x| x == "*") { return true; }
    m.connector().map(|c| p.monitors.iter().any(|x| x == c.as_str())).unwrap_or(false)
}

pub fn build(app: &gtk::Application, _cfg: &Config, p: &PanelCfg, mon: &gdk::Monitor) -> gtk::ApplicationWindow {
    let (top, bottom, left, right, vertical) = match p.position.as_str() {
        "bottom" => (false, true, true, true, false),
        "left" => (true, true, true, false, true),
        "right" => (true, true, false, true, true),
        _ => (true, false, true, true, false),
    };

    let win = gtk::ApplicationWindow::new(app);
    win.add_css_class("dash");
    win.init_layer_shell();
    win.set_layer(Layer::Top);
    win.set_monitor(mon);
    win.set_namespace("dash");
    win.set_anchor(Edge::Top, top);
    win.set_anchor(Edge::Bottom, bottom);
    win.set_anchor(Edge::Left, left);
    win.set_anchor(Edge::Right, right);
    win.auto_exclusive_zone_enable();
    if vertical { win.set_default_size(p.size, -1) } else { win.set_default_size(-1, p.size) }

    let orient = if vertical { gtk::Orientation::Vertical } else { gtk::Orientation::Horizontal };
    let dash = gtk::Box::new(orient, p.spacing);
    dash.add_css_class("dash-box");

    win.set_child(Some(&dash));
    win.present();
    win
}