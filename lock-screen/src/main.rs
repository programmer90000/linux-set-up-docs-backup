mod auth;

use chrono::Local;
use gtk4::gdk::{Display, Key};
use gtk4::glib;
use gtk4::prelude::*;
use gtk4::{
    Align, Application, ApplicationWindow, Box as GtkBox, Button, ContentFit, CssProvider,
    EventControllerKey, GestureClick, Image, Label, ListBox, ListBoxRow, Orientation, Overlay,
    PasswordEntry, PolicyType, Popover, PositionType, ScrolledWindow, SelectionMode, Stack,
    StackTransitionType,
};
use gtk4_session_lock::{GtkSessionLockInstance, InitializationExt, LockSurfaceExt};
use std::cell::{Cell, RefCell};
use std::fs;
use std::path::Path;
use std::rc::Rc;
use std::time::Duration;

const THEME_DIR: &str = "/usr/share/wayland-lock-screen";

#[derive(Clone, Debug)]
struct UserInfo {
    username: String,
    avatar_path: String,
}

fn load_system_users() -> Vec<UserInfo> {
    let mut users = Vec::new();
    if let Ok(content) = fs::read_to_string("/etc/passwd") {
        for line in content.lines() {
            if line.starts_with('#') || line.trim().is_empty() {
                continue;
            }
            let parts: Vec<&str> = line.split(':').collect();
            if parts.len() >= 7 {
                let username = parts[0];
                let uid: u32 = parts[2].parse().unwrap_or(0);
                let shell = parts[6];
                if uid >= 1000
                    && username != "nobody"
                    && !shell.ends_with("/nologin")
                    && !shell.ends_with("/false")
                {
                    users.push(UserInfo {
                        username: username.to_string(),
                        avatar_path: format!("{THEME_DIR}/{username}/profile-picture.png"),
                    });
                }
            }
        }
    }
    users
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
        .application_id("org.wayland.lockscreen")
        .build();

    app.connect_activate(build_ui);
    app.run();
}

fn build_ui(app: &Application) {
    load_css();

    let lock_instance = GtkSessionLockInstance::new();
    let app_clone = app.clone();

    lock_instance.connect_lock(move |instance, surfaces| {
        for surface in surfaces {
            let window = ApplicationWindow::builder()
                .application(&app_clone)
                .decorated(false)
                .build();

            surface.assign(&window);
            window.present();

            let root_overlay = Overlay::new();
            let bg_picture = gtk4::Picture::for_filename(format!("{THEME_DIR}/splash_background.png"));
            bg_picture.set_hexpand(true);
            bg_picture.set_vexpand(true);
            bg_picture.set_content_fit(ContentFit::Cover);
            root_overlay.set_child(Some(&bg_picture));

            let dim_box = GtkBox::new(Orientation::Vertical, 0);
            dim_box.add_css_class("dim-overlay");
            dim_box.set_hexpand(true);
            dim_box.set_vexpand(true);
            root_overlay.add_overlay(&dim_box);

            let main_stack = Stack::new();
            main_stack.set_transition_type(StackTransitionType::Crossfade);
            main_stack.set_transition_duration(150);
            main_stack.set_hexpand(true);
            main_stack.set_vexpand(true);
            root_overlay.add_overlay(&main_stack);

            // Splash & Login UI assembly (matches previous UI layout)
            let splash_overlay = Overlay::new();
            splash_overlay.set_hexpand(true);
            splash_overlay.set_vexpand(true);
            splash_overlay.set_focusable(true);

            let splash_clock_box = GtkBox::new(Orientation::Vertical, 10);
            splash_clock_box.set_halign(Align::Center);
            splash_clock_box.set_valign(Align::Start);
            splash_clock_box.set_margin_top(50);

            let splash_clock_label = Label::new(Some(&format_clock()));
            splash_clock_label.add_css_class("clock-text");
            let splash_date_label = Label::new(Some(&format_date()));
            splash_date_label.add_css_class("date-text");

            splash_clock_box.append(&splash_clock_label);
            splash_clock_box.append(&splash_date_label);
            splash_overlay.add_overlay(&splash_clock_box);
            main_stack.add_named(&splash_overlay, Some("splash"));

            let login_overlay = Overlay::new();
            login_overlay.set_hexpand(true);
            login_overlay.set_vexpand(true);

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

            let avatar_fallback = Label::new(Some("?"));
            avatar_fallback.add_css_class("avatar-large-fallback");
            avatar_stack.add_named(&avatar_fallback, Some("fallback"));
            avatar_stack.set_visible_child_name("fallback");

            let username_label = Label::new(Some("Select a user"));
            username_label.add_css_class("username-label-empty");

            let password_entry = PasswordEntry::new();
            password_entry.add_css_class("password-input");
            password_entry.set_placeholder_text(Some("Password"));
            password_entry.set_sensitive(false);

            let error_label = Label::new(None);
            error_label.add_css_class("error-label");
            error_label.set_visible(false);

            center_box.append(&avatar_stack);
            center_box.append(&username_label);
            center_box.append(&password_entry);
            center_box.append(&error_label);
            login_overlay.add_overlay(&center_box);

            let users = Rc::new(load_system_users());
            let selected_username = Rc::new(RefCell::new(String::new()));

            let user_scroll = ScrolledWindow::new();
            user_scroll.set_halign(Align::Start);
            user_scroll.set_valign(Align::End);
            user_scroll.set_margin_start(20);
            user_scroll.set_margin_bottom(20);
            user_scroll.set_min_content_width(200);
            user_scroll.set_max_content_height(300);
            user_scroll.set_propagate_natural_height(true);
            user_scroll.set_policy(PolicyType::Never, PolicyType::Automatic);

            let user_listbox = ListBox::new();
            user_listbox.add_css_class("user-list");
            user_listbox.set_selection_mode(SelectionMode::Single);
            user_scroll.set_child(Some(&user_listbox));
            login_overlay.add_overlay(&user_scroll);

            // Populate users list
            for user in users.iter() {
                let row = ListBoxRow::new();
                let card = GtkBox::new(Orientation::Horizontal, 10);
                card.add_css_class("user-card");
                let name_lbl = Label::new(Some(&user.username));
                card.append(&name_lbl);
                row.set_child(Some(&card));
                user_listbox.append(&row);
            }

            let inst_clone = instance.clone();
            let sel_user = selected_username.clone();
            let pw_entry = password_entry.clone();
            let err_lbl = error_label.clone();

            password_entry.connect_activate(move |_| {
                let username = sel_user.borrow().clone();
                let password = pw_entry.text().to_string();
                if username.is_empty() || password.is_empty() {
                    return;
                }

                match auth::authenticate_user(&username, &password) {
                    Ok(()) => {
                        inst_clone.unlock();
                        std::process::exit(0);
                    }
                    Err(msg) => {
                        pw_entry.set_text("");
                        err_lbl.set_text(&msg);
                        err_lbl.set_visible(true);
                    }
                }
            });

            main_stack.add_named(&login_overlay, Some("login"));
            window.set_child(Some(&root_overlay));
            window.present();
            main_stack.set_visible_child_name("splash");
        }
    });
}
