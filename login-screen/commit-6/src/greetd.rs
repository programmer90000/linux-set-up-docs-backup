use greetd_ipc::codec::SyncCodec;
use greetd_ipc::{AuthMessageType, ErrorType, Request, Response};
use std::env;
use std::os::unix::net::UnixStream;
use std::process::Command;

pub fn authenticate_and_start(username: &str, password: &str, session_cmd: &[String]) -> Result<(), String> {
    let sock_path = env::var("GREETD_SOCK")
        .map_err(|_| "GREETD_SOCK environment variable is not set".to_string())?;

    let mut stream = UnixStream::connect(&sock_path)
        .map_err(|e| format!("Failed to connect to greetd socket: {e}"))?;

    Request::CreateSession {
        username: username.to_string(),
    }
    .write_to(&mut stream)
    .map_err(|e| format!("Failed to send CreateSession: {e}"))?;

    loop {
        let response = Response::read_from(&mut stream)
            .map_err(|e| format!("Failed to read greetd response: {e}"))?;

        match response {
            Response::AuthMessage {
                auth_message_type,
                auth_message,
            } => {
                let answer = match auth_message_type {
                    AuthMessageType::Secret => Some(password.to_string()),
                    AuthMessageType::Visible => Some(username.to_string()),
                    AuthMessageType::Info | AuthMessageType::Error => None,
                };

                Request::PostAuthMessageResponse { response: answer }
                    .write_to(&mut stream)
                    .map_err(|e| format!("Failed to send auth response: {e}"))?;

                if matches!(auth_message_type, AuthMessageType::Error) {
                    let _ = cancel_session(&mut stream);
                    return Err(auth_message);
                }
            }
            Response::Success => {
                Request::StartSession {
                    cmd: session_cmd.to_vec(),
                    env: vec![],
                }
                .write_to(&mut stream)
                .map_err(|e| format!("Failed to send StartSession: {e}"))?;

                match Response::read_from(&mut stream) {
                    Ok(Response::Success) => return Ok(()),
                    Ok(Response::Error { description, .. }) => return Err(description),
                    Ok(_) => return Err("Unexpected response starting session".to_string()),
                    Err(e) => return Err(format!("Socket error starting session: {e}")),
                }
            }
            Response::Error {
                error_type,
                description,
            } => {
                let _ = cancel_session(&mut stream);
                return match error_type {
                    ErrorType::AuthError => Err("Authentication failed".to_string()),
                    ErrorType::Error => Err(description),
                };
            }
        }
    }
}

fn cancel_session(stream: &mut UnixStream) -> Result<(), ()> {
    Request::CancelSession.write_to(stream).map_err(|_| ())?;
    let _ = Response::read_from(stream);
    Ok(())
}

pub fn system_power_action(action: &str) {
    let _ = Command::new("loginctl").arg(action).spawn();
}