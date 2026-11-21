use super::{command::{build as cmd, Defaults}, Ctx};
use gtk4 as gtk;

// Shows PipeWire's graph sample rate; `pw-metadata -m` prints on every settings change.
pub fn build(ctx: &Ctx) -> gtk::Widget {
    cmd(ctx, Defaults {
        kind: "pipewire", icon: "PW", format: "{icon} {text}",
        watch: Some("pw-metadata -m -n settings"),
        command: Some(r##"pw-metadata -n settings 0 clock.rate 2>/dev/null | sed -n "s/.*value:'\([0-9]*\)'.*/\1 Hz/p" | grep . || echo off"##),
        on_click: Some("qpwgraph"),
        ..Default::default()
    })
}
