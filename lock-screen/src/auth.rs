pub fn authenticate_user(username: &str, password: &str) -> Result<(), String> {
    let mut auth = pam::Authenticator::with_password("login")
        .map_err(|e| format!("Failed to initialize PAM: {e:?}"))?;
    
    auth.handler_mut().set_credentials(username, password);
    
    match auth.authenticate() {
        Ok(()) => {
            match auth.acct_mgmt() {
                Ok(()) => Ok(()),
                Err(e) => Err(format!("Account validation failed: {e:?}")),
            }
        }
        Err(_) => Err("Authentication failed".to_string()),
    }
}

pub fn system_power_action(action: &str) {
    let _ = std::process::Command::new("loginctl").arg(action).spawn();
}
