use super::{command::{build as cmd, Defaults}, Ctx};
use gtk4 as gtk;

pub fn build(ctx: &Ctx) -> gtk::Widget {
    cmd(ctx, Defaults {
        kind: "wifi", icon: "📶",
        watch: Some("nmcli monitor"),
        command: Some(r##"nmcli -t -f TYPE,STATE,CONNECTION dev | awk -F: '$1=="wifi"&&$2=="connected"{print $3;f=1} END{if(!f)print "down"}'"##),
        on_click: Some("nm-connection-editor"),
        ..Default::default()
    })
}