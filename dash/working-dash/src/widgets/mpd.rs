use super::{command::{build as cmd, Defaults}, Ctx};
use gtk4 as gtk;

// `mpc idle` blocks until MPD reports a change; the loop re-arms it.
pub fn build(ctx: &Ctx) -> gtk::Widget {
    cmd(ctx, Defaults {
        kind: "mpd", icon: "♫",
        watch: Some("while :; do mpc idle || sleep 3; done"),
        command: Some("mpc current"),
        on_click: Some("mpc toggle"),
        on_right_click: Some("mpc next"),
        ..Default::default()
    })
}
