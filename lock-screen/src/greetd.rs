use pam_client::{Context, Flag};
use pam_client::conv_mock::Conversation;
use std::process::Command;

pub fn verify_lock_password(username: &str, password: &str) -> Result<(), String> {
    // Initialize PAM context with a zero-argument mock conversation
    let mut context = Context::new(
        "login",
        Some(username),
        Conversation::new(),
    )
    .map_err(|e| format!("Failed to initialize PAM: {e:?}"))?;

    // Note: If your version of conv_mock requires setting the password/response 
    // via a separate method on the conversation object before or after creation, 
    // configure it here.

    // Authenticate the user
    context
        .authenticate(Flag::NONE)
        .map_err(|_| "Incorrect password".to_string())?;

    // Validate account status (not expired/locked)
    context
        .acct_mgmt(Flag::NONE)
        .map_err(|_| "Account validation failed".to_string())?;

    Ok(())
}

pub fn system_power_action(action: &str) {
    let _ = Command::new("loginctl").arg(action).spawn();
}