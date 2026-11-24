use pam_client::{Context, Flag};
use pam_client::conv_mock::Conversation;
use std::process::Command;

pub fn verify_lock_password(username: &str, password: &str) -> Result<(), String> {
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
    .map_err(|e| format!("Failed to initialize pam: {e:?}"))?;

    context
        .authenticate(Flag::NONE)
        .map_err(|_| "Incorrect password".to_string())?;

    context
        .acct_mgmt(Flag::NONE)
        .map_err(|_| "Account validation failed".to_string())?;

    Ok(())
}

pub fn system_power_action(action: &str) {
    let _ = Command::new("loginctl").arg(action).spawn();
}
