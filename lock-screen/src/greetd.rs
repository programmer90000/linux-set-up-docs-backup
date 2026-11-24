use pam_client::{Context, Conversation, Flag};
use std::process::Command;

pub fn verify_lock_password(username: &str, password: &str) -> Result<(), String> {
    // Initialize PAM context for the local system login service
    let mut context = Context::new(
        "login",
        Some(username),
        Conversation::new(move |messages| {
            let mut responses = Vec::new();
            for _ in messages {
                responses.push(Some(password.as_bytes().to_vec()));
            }
            Ok(responses)
        }),
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
