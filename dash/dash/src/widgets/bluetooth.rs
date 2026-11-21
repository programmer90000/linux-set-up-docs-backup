use super::{command::{build as cmd, Defaults}, Ctx};
use gtk4 as gtk;

// Watches BlueZ's D-Bus signals; text = "off" or number of connected devices.
pub fn build(ctx: &Ctx) -> gtk::Widget {
    cmd(ctx, Defaults {
        kind: "bluetooth", icon: "",
        watch: Some(r##"dbus-monitor --system "type='signal',sender='org.bluez'""##),
        command: Some(r##"p=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}'); if [ "$p" = yes ]; then bluetoothctl devices Connected 2>/dev/null | wc -l; else echo off; fi"##),
        on_click: Some("blueman-manager"),
        ..Default::default()
    })
}
