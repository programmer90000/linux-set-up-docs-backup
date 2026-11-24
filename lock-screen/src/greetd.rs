use pam_client::{Context, Flag};
use pam_client::conv_mock::Conversation;
use std::process::Command;

pub fn verify_lock_password(username: &str, password: &str) -> Result<(), String> {
    // Create a mock conversation and add the password as an expected response
    let mut conv = Conversation::new();
    conv.add(password); // Feed the password to the mock conversation handler

    let mut context = Context::new(
        "login",
        Some(username),
        conv,
    )
    .map_err(|e| format!("Failed to initialize PAM: {e:?}"))?;

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