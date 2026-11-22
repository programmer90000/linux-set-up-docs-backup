use super::{command::{build as cmd, Defaults}, Ctx};
use gtk4 as gtk;

// Configure with `stream`, or `watch` + `command`, in [widget.wheeltani].
pub fn build(ctx: &Ctx) -> gtk::Widget {
    cmd(ctx, Defaults { kind: "wheeltani", icon: "🖱", ..Default::default() })
}
