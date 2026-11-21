use super::{command::{build as cmd, Defaults}, Ctx};
use gtk4 as gtk;

// No default: Wayland clients cannot see the layout unless the compositor tells them.
// Give it a `stream` (prints a line on change) or `watch` + `command` in the config.
pub fn build(ctx: &Ctx) -> gtk::Widget {
    cmd(ctx, Defaults { kind: "keyboard_layout", icon: "⌨", ..Default::default() })
}
