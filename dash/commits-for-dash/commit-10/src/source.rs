use async_channel::Receiver;
use gtk4::glib::{self, ControlFlow, IOCondition};
use std::{
    io::{BufRead, BufReader},
    os::unix::process::CommandExt,
    process::{Child, Command, Stdio},
    time::Duration,
};

fn kill_group(child: &mut Child) {
    unsafe { libc::kill(-(child.id() as i32), libc::SIGTERM) };
    let _ = child.wait();
}

pub fn lines(cmd: &str) -> Receiver<String> {
    let (tx, rx) = async_channel::unbounded();
    let cmd = cmd.to_string();
    std::thread::spawn(move || loop {
        let child = Command::new("sh").arg("-c").arg(&cmd)
            .stdin(Stdio::null()).stdout(Stdio::piped()).stderr(Stdio::null())
            .process_group(0).spawn();
        if let Ok(mut child) = child {
            if let Some(out) = child.stdout.take() {
                for line in BufReader::new(out).lines().map_while(Result::ok) {
                    if tx.send_blocking(line).is_err() {
                        kill_group(&mut child);
                        return;
                    }
                }
            }
            let _ = child.wait();
        }
        if tx.is_closed() { return; }
        std::thread::sleep(Duration::from_secs(3));
    });
    rx
}

pub fn run_once(cmd: &str) -> String {
    Command::new("sh").arg("-c").arg(cmd)
        .stdin(Stdio::null()).stderr(Stdio::null()).output()
        .map(|o| String::from_utf8_lossy(&o.stdout).lines().next().unwrap_or("").to_string())
        .unwrap_or_default()
}

pub fn query_once(cmd: &str) -> Receiver<String> {
    let (tx, rx) = async_channel::unbounded();
    let cmd = cmd.to_string();
    std::thread::spawn(move || { let _ = tx.send_blocking(run_once(&cmd)); });
    rx
}

pub fn watch_query(watch: &str, query: &str) -> Receiver<String> {
    let (tx, rx) = async_channel::unbounded();
    let ev = lines(watch);
    let query = query.to_string();
    std::thread::spawn(move || {
        if tx.send_blocking(run_once(&query)).is_err() { return; }
        while ev.recv_blocking().is_ok() {
            std::thread::sleep(Duration::from_millis(50));
            while ev.try_recv().is_ok() {}
            if tx.send_blocking(run_once(&query)).is_err() { break; }
        }
    });
    rx
}

pub fn spawn(cmd: &str) {
    if let Ok(mut c) = Command::new("sh").arg("-c").arg(cmd)
        .stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null()).spawn()
    {
        std::thread::spawn(move || { let _ = c.wait(); });
    }
}

pub fn exec(args: &[&str]) {
    if let Ok(mut c) = Command::new(args[0]).args(&args[1..])
        .stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null()).spawn()
    {
        std::thread::spawn(move || { let _ = c.wait(); });
    }
}

#[derive(Clone, Copy)]
pub enum Gran { Second, Minute, Day }

pub fn granularity(fmt: &str) -> Gran {
    let has = |l: &[&str]| l.iter().any(|t| fmt.contains(t));
    if has(&["%S", "%T", "%X", "%s", "%c", "%r", "%+"]) { Gran::Second }
    else if has(&["%H", "%M", "%R", "%I", "%l", "%k", "%p", "%P"]) { Gran::Minute }
    else { Gran::Day }
}

fn arm(fd: i32, g: Gran) {
    let Ok(now) = glib::DateTime::now_local() else { return };
    let t = now.to_unix();
    let target = match g {
        Gran::Second => t + 1,
        Gran::Minute => (t / 60 + 1) * 60,
        Gran::Day => now.add_days(1).ok()
            .and_then(|n| glib::DateTime::from_local(n.year(), n.month(), n.day_of_month(), 0, 0, 0.0).ok())
            .map(|d| d.to_unix()).unwrap_or(t + 3600),
    };
    let spec = libc::itimerspec {
        it_interval: libc::timespec { tv_sec: 0, tv_nsec: 0 },
        it_value: libc::timespec { tv_sec: target as libc::time_t, tv_nsec: 0 },
    };
    unsafe {
        libc::timerfd_settime(fd, libc::TFD_TIMER_ABSTIME | libc::TFD_TIMER_CANCEL_ON_SET, &spec, std::ptr::null_mut());
    }
}

pub fn on_boundary<F: FnMut() + 'static>(g: Gran, mut f: F) {
    let fd = unsafe { libc::timerfd_create(libc::CLOCK_REALTIME, libc::TFD_NONBLOCK | libc::TFD_CLOEXEC) };
    if fd < 0 { return; }
    arm(fd, g);
    glib::source::unix_fd_add_local(fd, IOCondition::IN, move |fd, _| {
        let mut b = [0u8; 8];
        unsafe { libc::read(fd, b.as_mut_ptr() as *mut _, 8) };
        f();
        arm(fd, g);
        ControlFlow::Continue
    });
}