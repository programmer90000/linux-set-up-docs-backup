use super::{tag, Ctx};
use gtk4 as gtk;
use gtk::{glib, prelude::*};
use serde_json::{json, Value};
use std::{io::{self, Read, Write}, os::unix::net::UnixStream, time::Duration};

fn connect() -> io::Result<UnixStream> {
    UnixStream::connect(std::env::var("WAYFIRE_SOCKET").map_err(io::Error::other)?)
}
fn send(s: &mut UnixStream, v: &Value) -> io::Result<()> {
    let b = v.to_string();
    s.write_all(&(b.len() as u32).to_ne_bytes())?;
    s.write_all(b.as_bytes())
}
fn recv(s: &mut UnixStream) -> io::Result<Value> {
    let mut l = [0u8; 4];
    s.read_exact(&mut l)?;
    let mut buf = vec![0u8; u32::from_ne_bytes(l) as usize];
    s.read_exact(&mut buf)?;
    serde_json::from_slice(&buf).map_err(io::Error::other)
}

fn query() -> Option<(u64, u64)> {
    let mut s = connect().ok()?;
    send(&mut s, &json!({"method": "window-rules/get-focused-output", "data": {}})).ok()?;
    let v = recv(&mut s).ok()?;
    let w = &v["workspace"];
    let (gw, gh) = (w["grid_width"].as_u64()?, w["grid_height"].as_u64()?);
    Some((w["y"].as_u64()? * gw + w["x"].as_u64()? + 1, gw * gh))
}

pub fn build(ctx: &Ctx) -> gtk::Widget {
    let icon = ctx.cfg.icon.clone().unwrap_or_else(|| "▦".into());
    let format = ctx.cfg.format.clone().unwrap_or_else(|| "{icon} {current}/{total}".into());
    let label = gtk::Label::new(Some(&icon));
    tag(&label, "workspaces");

    let (tx, rx) = async_channel::unbounded::<(u64, u64)>();
    std::thread::spawn(move || loop {
        if let Ok(mut s) = connect() {
            if send(&mut s, &json!({"method": "window-rules/events/watch"})).is_ok() && recv(&mut s).is_ok() {
                if tx.send_blocking(query().unwrap_or((0, 0))).is_err() { return; }
                while let Ok(ev) = recv(&mut s) {
                    if ev["event"] == "wset-workspace-changed" || ev["event"] == "output-gain-focus" {
                        if tx.send_blocking(query().unwrap_or((0, 0))).is_err() { return; }
                    }
                }
            }
        }
        if tx.is_closed() { return; }
        std::thread::sleep(Duration::from_secs(2));
    });

    let report = ctx.report.clone();
    let l = label.clone();
    glib::spawn_future_local(async move {
        while let Ok((cur, total)) = rx.recv().await {
            let text = if total == 0 { "n/a".to_string() } else {
                format.replace("{icon}", &icon).replace("{current}", &cur.to_string()).replace("{total}", &total.to_string())
            };
            l.set_text(text.trim());
            report(&text, "");
        }
    });
    label.upcast()
}