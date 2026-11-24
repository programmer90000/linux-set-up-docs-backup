use pam_client::{Context, Flag, ConversationHandler, Response, MessageStyle};
use std::process::Command;

// Define a custom conversation handler to pass the user's password to PAM
struct PasswordConversation {
    password: String,
}

impl ConversationHandler for PasswordConversation {
    fn conversation(&mut self, messages: &[(&MessageStyle, &str)]) -> Result<Vec<Response>, ()> {
        let mut responses = Vec::new();
        for (style, _msg) in messages {
            match *style {
                MessageStyle::PromptEchoOff | MessageStyle::PromptEchoOn => {
                    // Respond to PAM's password prompt with our stored password string
                    responses.push(Response::text(self.password.clone()));
                }
                _ => {
                    // For informational or error messages, just return an empty response
                    responses.push(Response::default());
                }
            }
        }
        Ok(responses)
    }
}

pub fn verify_lock_password(username: &str, password: &str) -> Result<(), String> {
    // Initialize the conversation handler with our password
    let conv = PasswordConversation {
        password: password.to_string(),
    };

    // Initialize PAM context using "login" (or your custom service name if configured)
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