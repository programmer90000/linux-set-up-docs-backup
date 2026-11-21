use super::{command::{build as cmd, Defaults}, Ctx};
use gtk4 as gtk;

// No default source: configure it. Example for SwayNotificationCenter (streams JSON):
//   [widget.notifications]
//   stream = "swaync-client -swb"
//   on_click = "swaync-client -t -sw"
pub fn build(ctx: &Ctx) -> gtk::Widget {
    cmd(ctx, Defaults { kind: "notifications", icon: "🔔", ..Default::default() })
}
