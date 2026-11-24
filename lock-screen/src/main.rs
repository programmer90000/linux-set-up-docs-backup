mod pam_auth;

use chrono::Local;
use gtk4::gdk::Display;
use gtk4::prelude::*;
use gtk4::{
    Align, Application, ApplicationWindow, Box as GtkBox, ContentFit, CssProvider,
    Image, Label, Orientation, Overlay, PasswordEntry, Stack,
};
use gtk4_session_lock::prelude::*;
use gtk4_session_lock::{LockToplevel, SessionLock};
use std::fs;
use std::path::Path;
use std::rc::Rc;

const THEME_DIR: &str = "/usr/share/wayfire-lock-screen";

struct CurrentUser {
    username: String,
    avatar_path: String,
}

fn get_current_user() -> CurrentUser {
    let username = users::get_current_username()
        .map(|u| u.to_string_lossy().into_owned())
        .unwrap_or_else(|| "user".to_string());
    
    let avatar_path = format!("{THEME_DIR}/{username}/profile-picture.png");
    CurrentUser { username, avatar_path }
}

fn format_clock() -> String {
    Local::now().format("%H:%M:%S").to_string()
}

fn format_date() -> String {
    Local::now().format("%a %d/%m/%Y").to_string()
}

fn load_css() {
    let provider = CssProvider::new();
    provider.load_from_data(include_str!("style.css"));
    if let Some(display) = Display::default() {
        gtk4::style_context_add_provider_for_display(
            &display,
            &provider,
            gtk4::STYLE_PROVIDER_PRIORITY_APPLICATION,
        );
    }
}

fn main() {
    let app = Application::builder()
        .application_id("org.wayfire.lock.screen")
        .build();

    app.connect_activate(build_ui);
    app.run();
}

fn build_ui(app: &Application) {
    load_css();

    let lock = match SessionLock::new() {
        Ok(l) => l,
        Err(_) => {
            eprintln!("Failed to acquire session lock. Is the compositor running ext-session-lock-v1?");
            std::process::exit(1);
        }
    };

    let user = Rc::new(get_current_user());

    lock.connect_lock(move |lock, surfaces| {
        for surface in surfaces {
            create_lock_surface(app, &lock, &surface, user.clone());
        }
    });
}

fn create_lock_surface(
    app: &Application,
    lock: &SessionLock,
    lock_surface: &LockToplevel,
    user: Rc<CurrentUser>,
) {
    let window = ApplicationWindow::builder()
        .application(app)
        .decorated(false)
        .build();

    lock_surface.assign(&window);
    window.present();

    let root_overlay = Overlay::new();

    let bg_path = format!("{THEME_DIR}/splash_background.png");
    let bg_picture = if Path::new(&bg_path).exists() {
        gtk4::Picture::for_filename(&bg_path)
    } else {
        gtk4::Picture::new()
    };
    bg_picture.set_hexpand(true);
    bg_picture.set_vexpand(true);
    bg_picture.set_content_fit(ContentFit::Cover);
    root_overlay.set_child(Some(&bg_picture));

    let dim_box = GtkBox::new(Orientation::Vertical, 0);
    dim_box.add_css_class("dim-overlay");
    dim_box.set_hexpand(true);
    dim_box.set_vexpand(true);
    root_overlay.add_overlay(&dim_box);

    let center_box = GtkBox::new(Orientation::Vertical, 15);
    center_box.set_halign(Align::Center);
    center_box.set_valign(Align::Center);
    center_box.set_width_request(300);

    let avatar_stack = Stack::new();
    avatar_stack.set_size_request(80, 80);
    avatar_stack.set_halign(Align::Center);

    let avatar_image = Image::new();
    avatar_image.set_pixel_size(80);
    avatar_stack.add_named(&avatar_image, Some("image"));

    let avatar_fallback = Label::new(Some(
        &user.username.chars().next().unwrap_or('?').to_uppercase().to_string(),
    ));
    avatar_fallback.add_css_class("avatar-large-fallback");
    avatar_stack.add_named(&avatar_fallback, Some("fallback"));

    if Path::new(&user.avatar_path).exists() {
        avatar_image.set_from_file(Some(&user.avatar_path));
        avatar_stack.set_visible_child_name("image");
    } else {
        avatar_stack.set_visible_child_name("fallback");
    }

    let username_label = Label::new(Some(&user.username));
    username_label.add_css_class("username-label");
    username_label.set_halign(Align::Center);

    let password_entry = PasswordEntry::new();
    password_entry.add_css_class("password-input");
    password_entry.set_placeholder_text(Some("Password"));
    password_entry.set_show_peek_icon(false);

    let error_label = Label::new(None);
    error_label.add_css_class("error-label");
    error_label.set_halign(Align::Center);
    error_label.set_visible(false);

    center_box.append(&avatar_stack);
    center_box.append(&username_label);
    center_box.append(&password_entry);
    center_box.append(&error_label);
    root_overlay.add_overlay(&center_box);

    {
        let uname = user.username.clone();
        let pw_entry = password_entry.clone();
        let err_lbl = error_label.clone();
        let lock_clone = lock.clone();

        password_entry.connect_activate(move |_| {
            let password = pw_entry.text().to_string();
            if password.is_empty() {
                return;
            }

            pw_entry.set_sensitive(false);
            err_lbl.set_visible(false);

            match pam_auth::authenticate_user(&uname, &password) {
                Ok(()) => {
                    lock_clone.unlock();
                }
                Err(msg) => {
                    pw_entry.set_text("");
                    pw_entry.set_sensitive(true);
                    err_lbl.set_text(&msg);
                    err_lbl.set_visible(true);
                    pw_entry.grab_focus();
                }
            }
        });
    }

    window.set_child(Some(&root_overlay));
    password_entry.grab_focus();
}
