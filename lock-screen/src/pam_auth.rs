use pam_client::{Context, Flag, conv_mock::Conversation};

struct SimpleConversation {
    password: String,
}

impl Conversation for SimpleConversation {
    fn prompt_echo_off(_msg: &str) -> PamResult<String> {
        Ok("".to_string())
    }

    fn prompt_echo_on(_msg: &str) -> PamResult<String> {
        Err(pam_client::PamError::ConversationError)
    }

    fn error(_msg: &str) {}
    fn info(_msg: &str) {}
}

pub fn authenticate_user(username: &str, password: &str) -> Result<(), String> {
    let mut ctx = Context::new(Some(username), Conversation::new(password))
        .map_err(|e| format!("Failed to create PAM context: {e}"))?;

    ctx.authenticate(Flag::NONE)
        .map_err(|e| format!("Authentication failed: {e}"))?;

    ctx.acct_mgmt(Flag::NONE)
        .map_err(|e| format!("Account validation failed: {e}"))?;

    Ok(())
}