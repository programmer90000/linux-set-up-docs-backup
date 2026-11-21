use super::{tag, Ctx};
use gtk4 as gtk;
use gtk::{glib, prelude::*};
use std::{fs, io::Read, os::{fd::AsRawFd, unix::fs::OpenOptionsExt}, rc::Rc};

const EV_LED: u16 = 0x11;
const LED_CAPSL: u16 = 1;

fn ioc_read(nr: u32, len: u32) -> libc::c_ulong {
    ((2u32 << 30) | (len << 16) | ((b'E' as u32) << 8) | nr) as libc::c_ulong
}

pub fn build(ctx: &Ctx) -> gtk::Widget {
    let icon = ctx.cfg.icon.clone().unwrap_or_else(|| "⇪".into());
    let label = gtk::Label::new(Some(&icon));
    tag(&label, "caps_lock");
    label.add_css_class("off");

    let set = Rc::new({
        let (label, report) = (label.clone(), ctx.report.clone());
        move |on: bool| {
            label.set_text(&if on { format!("{icon} CAPS") } else { icon.clone() });
            label.remove_css_class(if on { "off" } else { "on" });
            label.add_css_class(if on { "on" } else { "off" });
            report(if on { "CAPS" } else { "" }, if on { "on" } else { "off" });
        }
    });

    let mut found = false;
    for entry in fs::read_dir("/dev/input").into_iter().flatten().flatten() {
        if !entry.file_name().to_string_lossy().starts_with("event") { continue; }
        let Ok(mut file) = fs::OpenOptions::new().read(true)
            .custom_flags(libc::O_NONBLOCK | libc::O_CLOEXEC).open(entry.path()) else { continue };
        let fd = file.as_raw_fd();

        let mut supported = [0u8; 2];
        let r = unsafe { libc::ioctl(fd, ioc_read(0x20 + EV_LED as u32, 2), supported.as_mut_ptr()) };
        if r < 0 || (supported[0] >> LED_CAPSL) & 1 == 0 { continue; }

        let mut state = [0u8; 2];
        let r = unsafe { libc::ioctl(fd, ioc_read(0x19, 2), state.as_mut_ptr()) };
        if r >= 0 && !found { set((state[0] >> LED_CAPSL) & 1 == 1); }
        found = true;

        let set = set.clone();
        glib::source::unix_fd_add_local(fd, glib::IOCondition::IN | glib::IOCondition::ERR | glib::IOCondition::HUP, move |_, cond| {
            if cond.intersects(glib::IOCondition::ERR | glib::IOCondition::HUP) { return glib::ControlFlow::Break; }
            let mut buf = [0u8; 24 * 32];
            loop {
                match file.read(&mut buf) {
                    Ok(0) => return glib::ControlFlow::Break,
                    Ok(n) => {
                        for ev in buf[..n].chunks_exact(24) {
                            let ty = u16::from_ne_bytes([ev[16], ev[17]]);
                            let code = u16::from_ne_bytes([ev[18], ev[19]]);
                            let val = i32::from_ne_bytes([ev[20], ev[21], ev[22], ev[23]]);
                            if ty == EV_LED && code == LED_CAPSL { set(val != 0); }
                        }
                        if n < buf.len() { break; }
                    }
                    Err(e) if e.kind() == std::io::ErrorKind::WouldBlock => break,
                    Err(_) => return glib::ControlFlow::Break,
                }
            }
            glib::ControlFlow::Continue
        });
    }
    if !found {
        eprintln!("dash: caps_lock: no readable keyboard in /dev/input (add yourself to group 'input')");
        label.set_tooltip_text(Some("no readable keyboard in /dev/input"));
    }
    label.upcast()
}