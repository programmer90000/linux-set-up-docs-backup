mod greetd;

use gtk4::gdk::Display;
use gtk4::glib;
use gtk4::prelude::*;
use gtk4::{
    Align, Application, ApplicationWindow, Box as GtkBox, ContentFit, CssProvider,
    EventControllerKey, GestureClick, Image, Label, ListBox, ListBoxRow, Orientation, Overlay,
    PasswordEntry, PolicyType, ScrolledWindow, SelectionMode, Stack, StackTransitionType,
};
use gtk4_layer_shell::{Edge, KeyboardMode, Layer, LayerShell};
use std::cell::RefCell;
use std::fs;
use std::path::Path;
use std::rc::Rc;

const THEME_DIR: &str = "/usr/share/greetd/login-screen";

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
        .application_id("org.wayfire.greetd.login")
        .build();

    app.connect_activate(build_ui);
    app.run();
}

fn build_ui(app: &Application) {
    load_css();

    let window = ApplicationWindow::builder()
        .application(app)
        .decorated(false)
        .build();

    window.init_layer_shell();
    window.set_layer(Layer::Overlay);
    window.set_keyboard_mode(KeyboardMode::Exclusive);
    window.set_namespace("greetd-login-screen");
    window.set_anchor(Edge::Top, true);
    window.set_anchor(Edge::Bottom, true);
    window.set_anchor(Edge::Left, true);
    window.set_anchor(Edge::Right, true);
    window.set_exclusive_zone(-1);

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

    let splash_overlay = Overlay::new();
    splash_overlay.set_hexpand(true);
    splash_overlay.set_vexpand(true);
    splash_overlay.set_focusable(true);
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
    username_label.set_halign(Align::Center);

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
    user_scroll.set_policy(PolicyType::Never, PolicyType::Automatic);

    let user_listbox = ListBox::new();
    user_listbox.add_css_class("user-list");
    user_listbox.set_selection_mode(SelectionMode::Single);
    user_scroll.set_child(Some(&user_listbox));
    login_overlay.add_overlay(&user_scroll);

    struct RowWidgets {
        card: GtkBox,
        avatar_fallback: Label,
        name_label: Label,
        user: UserInfo,
    }

    let row_widgets: Rc<RefCell<Vec<RowWidgets>>> = Rc::new(RefCell::new(Vec::new()));

    let refresh_user_list_styles = {
        let rows = row_widgets.clone();
        let sel_user = selected_username.clone();
        let lb = user_listbox.clone();
        move || {
            let current_sel = sel_user.borrow();
            let list_has_focus = lb.has_focus() || lb.focus_child().is_some();
            for (idx, rw) in rows.borrow().iter().enumerate() {
                let is_sel = *current_sel == rw.user.username;
                let is_kbd = list_has_focus
                    && lb.selected_row().map(|r| r.index() as usize) == Some(idx);

                if is_sel {
                    rw.card.add_css_class("user-card-selected");
                    rw.avatar_fallback.add_css_class("user-avatar-small-selected");
                    rw.name_label.add_css_class("user-row-name-selected");
                } else {
                    rw.card.remove_css_class("user-card-selected");
                    rw.avatar_fallback.remove_css_class("user-avatar-small-selected");
                    rw.name_label.remove_css_class("user-row-name-selected");
                }

                if is_kbd {
                    rw.card.add_css_class("user-card-focused");
                } else {
                    rw.card.remove_css_class("user-card-focused");
                }
            }
        }
    };

    let select_user = {
        let sel_user = selected_username.clone();
        let avatar_stack = avatar_stack.clone();
        let avatar_image = avatar_image.clone();
        let avatar_fallback = avatar_fallback.clone();
        let username_label = username_label.clone();
        let password_entry = password_entry.clone();
        let error_label = error_label.clone();
        let refresh = refresh_user_list_styles.clone();

        move |user: &UserInfo| {
            *sel_user.borrow_mut() = user.username.clone();

            let initial = user
                .username
                .chars()
                .next()
                .map(|c| c.to_uppercase().to_string())
                .unwrap_or_else(|| "?".to_string());
            avatar_fallback.set_text(&initial);

            if Path::new(&user.avatar_path).exists() {
                avatar_image.set_from_file(Some(&user.avatar_path));
                avatar_stack.set_visible_child_name("image");
            } else {
                avatar_stack.set_visible_child_name("fallback");
            }

            username_label.set_text(&user.username);
            username_label.remove_css_class("username-label-empty");
            username_label.add_css_class("username-label");

            password_entry.set_text("");
            password_entry.set_sensitive(true);
            error_label.set_visible(false);
            refresh();
            password_entry.grab_focus();
        }
    };

    for user in users.iter() {
        let row = ListBoxRow::new();
        let card = GtkBox::new(Orientation::Horizontal, 10);
        card.add_css_class("user-card");

        let small_stack = Stack::new();
        small_stack.set_size_request(30, 30);
        small_stack.set_valign(Align::Center);

        let initial = user
            .username
            .chars()
            .next()
            .map(|c| c.to_uppercase().to_string())
            .unwrap_or_else(|| "?".to_string());

        let small_fallback = Label::new(Some(&initial));
        small_fallback.add_css_class("user-avatar-small-fallback");
        small_stack.add_named(&small_fallback, Some("fallback"));

        if Path::new(&user.avatar_path).exists() {
            let small_img = Image::from_file(&user.avatar_path);
            small_img.set_pixel_size(30);
            small_stack.add_named(&small_img, Some("image"));
            small_stack.set_visible_child_name("image");
        } else {
            small_stack.set_visible_child_name("fallback");
        }

        let name_lbl = Label::new(Some(&user.username));
        name_lbl.add_css_class("user-row-name");
        name_lbl.set_valign(Align::Center);

        card.append(&small_stack);
        card.append(&name_lbl);
        row.set_child(Some(&card));
        user_listbox.append(&row);

        row_widgets.borrow_mut().push(RowWidgets {
            card,
            avatar_fallback: small_fallback,
            name_label: name_lbl,
            user: user.clone(),
        });
    }

    {
        let users_clone = users.clone();
        let select_fn = select_user.clone();
        user_listbox.connect_row_activated(move |_, row| {
            let idx = row.index() as usize;
            if let Some(u) = users_clone.get(idx) {
                select_fn(u);
            }
        });
    }

    {
        let refresh = refresh_user_list_styles.clone();
        user_listbox.connect_selected_rows_changed(move |_| refresh());
    }

    {
        let sel_user = selected_username.clone();
        let pw_entry = password_entry.clone();
        let err_lbl = error_label.clone();
        let app_clone = app.clone();

        password_entry.connect_activate(move |_| {
            let username = sel_user.borrow().clone();
            let password = pw_entry.text().to_string();
            if username.is_empty() || password.is_empty() {
                return;
            }

            pw_entry.set_sensitive(false);
            err_lbl.set_visible(false);

            let session_cmd = vec!["wayfire".to_string()];
            match greetd::authenticate_and_start(&username, &password, &session_cmd) {
                Ok(()) => {
                    app_clone.quit();
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

    main_stack.add_named(&login_overlay, Some("login"));

    let dismiss_splash = {
        let stack = main_stack.clone();
        let users_clone = users.clone();
        let lb = user_listbox.clone();
        let select_fn = select_user.clone();
        let pw = password_entry.clone();

        move || {
            if stack.visible_child_name().as_deref() != Some("splash") {
                return;
            }
            stack.set_visible_child_name("login");
            if let Some(first_user) = users_clone.first() {
                if let Some(first_row) = lb.row_at_index(0) {
                    lb.select_row(Some(&first_row));
                }
                select_fn(first_user);
            }
            pw.grab_focus();
        }
    };

    {
        let dismiss = dismiss_splash.clone();
        let key_ctrl = EventControllerKey::new();
        key_ctrl.connect_key_pressed(move |_, _, _, _| {
            dismiss();
            glib::Propagation::Stop
        });
        splash_overlay.add_controller(key_ctrl);
    }

    {
        let dismiss = dismiss_splash.clone();
        let click_ctrl = GestureClick::new();
        click_ctrl.connect_pressed(move |_, _, _, _| {
            dismiss();
        });
        splash_overlay.add_controller(click_ctrl);
    }

    window.set_child(Some(&root_overlay));
    window.present();
    main_stack.set_visible_child_name("splash");
    splash_overlay.grab_focus();
}