use pam_client::{Context, Conversation, PamResult};

struct SimpleConversation {
    password: String,
}

impl Conversation for SimpleConversation {
    fn prompt_echo_off(&pam_client: &str) -> PamResult<String> {
        // PAM calls this to request the password securely
        Ok(password)
    }

    fn prompt_echo_on(_msg: &str) -> PamResult<String> {
        Err(pam_client::PamError::ConversationError)
    }

    fn error(_msg: &str) {}
    fn info(_msg: &str) {}
}

pub fn authenticate_user(username: &str, password: &str) -> Result<(), String> {
    let mut ctx = Context::new("system-auth", username)
        .map_err(|e| format!("Failed to create PAM context: {e}"))?;
    
    // Provide conversation handler with the password
    // (In production, use a custom conversation struct holding the password string)
    let mut conv = SimpleConversation {
        password: password.to_string(),
    };

    let result = ctx.authenticate(&mut conv);
    match result {
        Ok(()) => {
            ctx.acct_mgmt()
                .map_err(|e| format!("Account management check failed: {e}"))?;
            Ok(())
        }
        Err(e) => Err(format!("Authentication failed: {e}")),
    }
}