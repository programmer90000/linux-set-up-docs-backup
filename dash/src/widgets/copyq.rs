use super::{command::{build as cmd, Defaults}, Ctx};
use gtk4 as gtk;

// `wl-paste --watch` runs a command on every clipboard change (event based).
pub fn build(ctx: &Ctx) -> gtk::Widget {
    cmd(ctx, Defaults {
        kind: "copyq", icon: "📋",
        watch: Some("wl-paste --watch echo changed"),
        command: Some("copyq count"),
        on_click: Some("copyq toggle"),
        ..Default::default()
    })
}
