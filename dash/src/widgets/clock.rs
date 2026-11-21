use super::Ctx;
use gtk4 as gtk;

pub fn build(ctx: &Ctx) -> gtk::Widget {
    super::time_label(ctx, "clock", "%H:%M")
}
