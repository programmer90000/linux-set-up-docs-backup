use std::process::{Command, Stdio};
use std::io::Write;

pub fn verify_lock_password(username: &str, password: &str) -> Result<(), String> {
    // Spawn standard system authentication check or use a secure subprocess
    let mut child = Command::new("su")
        .args([username, "-c", "exit 0"])
        .stdin(Stdio::piped())
        .stdout(Stdio::null())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| format!("Failed to start auth process: {e}"))?;

    if let Some(mut stdin) = child.stdin.take() {
        writeln!(stdin, "{}", password).map_err(|_| "Failed to pass password".to_string())?;
    }

    let status = child.wait().map_err(|_| "Authentication process error".to_string())?;

    if status.success() {
        Ok(())
    } else {
        Err("Incorrect password".to_string())
    }
}

pub fn system_power_action(action: &str) {
    let _ = Command::new("loginctl").arg(action).spawn();
}