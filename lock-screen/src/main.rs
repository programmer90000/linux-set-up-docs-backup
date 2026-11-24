mod greetd;

use chrono::Local;
use gtk4::gdk::{Display, Key};
use gtk4::glib;
use gtk4::prelude::*;
use gtk4::{
    Align, Application, ApplicationWindow, Box as GtkBox, Button, ContentFit, CssProvider,
    EventControllerKey, GestureClick, Image, Label, Overlay,
    PasswordEntry, Popover, PositionType, Stack,
    StackTransitionType,
};
use gtk4_layer_shell::{Edge, KeyboardMode, Layer, LayerShell};
use std::cell::{Cell, RefCell};
use std::env;
use std::fs;
use std::path::Path;
use std::rc::Rc;
use std::time::Duration;

const THEME_DIR: &str = "/usr/share/greetd/login-screen";

#[derive(Clone, Debug)]
struct UserInfo {
    username: String,
    avatar_path: String,
}

fn load_current_user() -> UserInfo {
    let username = env::var("USER").unwrap_or_else(|_| "user".to_string());
    UserInfo {
        username: username.clone(),
        avatar_path: format!("{THEME_DIR}/{username}/profile-picture.png"),
    }
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
        .application_id("org.wayfire.greetd.lockscreen")
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
    window.set_namespace("greetd-lock-screen");
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

    let login_clock_box = GtkBox::new(Orientation::Vertical, 10);
    login_clock_box.set_halign(Align::Center);
    login_clock_box.set_valign(Align::Start);
    login_clock_box.set_margin_top(50);

    let login_clock_label = Label::new(Some(&format_clock()));
    login_clock_label.add_css_class("clock-text");

    let login_date_label = Label::new(Some(&format_date()));
    login_date_label.add_css_class("date-text");

    login_clock_box.append(&login_clock_label);
    login_clock_box.append(&login_date_label);
    login_overlay.add_overlay(&login_clock_box);

    let back_button = Button::new();
    back_button.add_css_class("circle-btn");
    back_button.set_halign(Align::Start);
    back_button.set_valign(Align::Start);
    back_button.set_margin_top(20);
    back_button.set_margin_start(20);
    back_button.set_tooltip_text(Some("Show Splash Screen"));
    let back_icon = Image::from_file(format!("{THEME_DIR}/assets/back_arrow_icon.png"));
    back_icon.set_pixel_size(24);
    back_button.set_child(Some(&back_icon));
    login_overlay.add_overlay(&back_button);

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
    avatar_fallback.set_halign(Align::Center);
    avatar_fallback.set_valign(Align::Center);
    avatar_stack.add_named(&avatar_fallback, Some("fallback"));
    avatar_stack.set_visible_child_name("fallback");

    let username_label = Label::new(None);
    username_label.add_css_class("username-label");
    username_label.set_halign(Align::Center);
    username_label.set_margin_top(5);

    let password_entry = PasswordEntry::new();
    password_entry.add_css_class("password-input");
    password_entry.set_placeholder_text(Some("Password"));
    password_entry.set_show_peek_icon(false);
    password_entry.set_margin_top(10);

    let error_label = Label::new(None);
    error_label.add_css_class("error-label");
    error_label.set_halign(Align::Center);
    error_label.set_visible(false);

    center_box.append(&avatar_stack);
    center_box.append(&username_label);
    center_box.append(&password_entry);
    center_box.append(&error_label);
    login_overlay.add_overlay(&center_box);

    let current_user = load_current_user();
    let selected_username = Rc::new(RefCell::new(current_user.username.clone()));

    {
        let initial = current_user
            .username
            .chars()
            .next()
            .map(|c| c.to_uppercase().to_string())
            .unwrap_or_else(|| "?".to_string());
        avatar_fallback.set_text(&initial);

        if Path::new(&current_user.avatar_path).exists() {
            avatar_image.set_from_file(Some(&current_user.avatar_path));
            avatar_stack.set_visible_child_name("image");
        } else {
            avatar_stack.set_visible_child_name("fallback");
        }
        username_label.set_text(&current_user.username);
    }

    let power_button = Button::new();
    power_button.add_css_class("circle-btn");
    power_button.set_halign(Align::End);
    power_button.set_valign(Align::End);
    power_button.set_margin_end(20);
    power_button.set_margin_bottom(20);
    power_button.set_tooltip_text(Some("Power Options"));
    let gear_icon = Image::from_file(format!("{THEME_DIR}/assets/gear-icon.png"));
    gear_icon.set_pixel_size(24);
    power_button.set_child(Some(&gear_icon));
    login_overlay.add_overlay(&power_button);

    let power_popover = Popover::new();
    power_popover.add_css_class("power-popover");
    power_popover.set_parent(&power_button);
    power_popover.set_position(PositionType::Top);
    power_popover.set_has_arrow(false);
    power_popover.set_offset(-56, -10);

    let menu_box = GtkBox::new(Orientation::Vertical, 5);
    let menu_specs = [
        ("Shut Down", "shutdown-icon.png", "poweroff"),
        ("Restart", "restart-icon.png", "reboot"),
        ("Suspend", "suspend-icon.png", "suspend"),
    ];

    let mut menu_buttons: Vec<Button> = Vec::new();
    for (label_text, icon_file, action) in menu_specs {
        let item_btn = Button::new();
        item_btn.add_css_class("power-menu-item");

        let row_box = GtkBox::new(Orientation::Horizontal, 10);
        let icon = Image::from_file(format!("{THEME_DIR}/assets/{icon_file}"));
        icon.set_pixel_size(20);
        let lbl = Label::new(Some(label_text));
        lbl.add_css_class("power-menu-label");

        row_box.append(&icon);
        row_box.append(&lbl);
        item_btn.set_child(Some(&row_box));

        let pop_clone = power_popover.clone();
        let pow_btn_clone = power_button.clone();
        item_btn.connect_clicked(move |_| {
            pop_clone.popdown();
            pow_btn_clone.grab_focus();
            greetd::system_power_action(action);
        });

        menu_box.append(&item_btn);
        menu_buttons.push(item_btn);
    }
    power_popover.set_child(Some(&menu_box));

    let selected_menu_idx = Rc::new(Cell::new(0usize));
    let menu_buttons_rc = Rc::new(menu_buttons);

    let update_menu_highlight = {
        let btns = menu_buttons_rc.clone();
        let idx = selected_menu_idx.clone();
        move || {
            for (i, b) in btns.iter().enumerate() {
                if i == idx.get() {
                    b.add_css_class("power-menu-item-selected");
                } else {
                    b.remove_css_class("power-menu-item-selected");
                }
            }
        }
    };

    {
        let pop = power_popover.clone();
        let idx = selected_menu_idx.clone();
        let highlight = update_menu_highlight.clone();
        power_button.connect_clicked(move |_| {
            if pop.is_visible() {
                pop.popdown();
            } else {
                idx.set(0);
                highlight();
                pop.popup();
            }
        });
    }

    {
        let pop = power_popover.clone();
        let pow_btn = power_button.clone();
        let idx = selected_menu_idx.clone();
        let btns = menu_buttons_rc.clone();
        let highlight = update_menu_highlight.clone();

        let pop_key_ctrl = EventControllerKey::new();
        pop_key_ctrl.connect_key_pressed(move |_, key, _, _| match key {
            Key::Down => {
                idx.set((idx.get() + 1) % 3);
                highlight();
                glib::Propagation::Stop
            }
            Key::Up => {
                idx.set((idx.get() + 2) % 3);
                highlight();
                glib::Propagation::Stop
            }
            Key::Return | Key::KP_Enter | Key::space => {
                let current = idx.get();
                pop.popdown();
                pow_btn.grab_focus();
                btns[current].emit_clicked();
                glib::Propagation::Stop
            }
            Key::Escape => {
                pop.popdown();
                pow_btn.grab_focus();
                glib::Propagation::Stop
            }
            _ => glib::Propagation::Proceed,
        });
        power_popover.add_controller(pop_key_ctrl);
    }

    main_stack.add_named(&login_overlay, Some("login"));

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

            match greetd::verify_lock_password(&username, &password) {
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

    let dismiss_splash = {
        let stack = main_stack.clone();
        let pw = password_entry.clone();

        move || {
            if stack.visible_child_name().as_deref() != Some("splash") {
                return;
            }
            stack.set_visible_child_name("login");
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

    {
        let stack = main_stack.clone();
        let splash = splash_overlay.clone();
        let s_clk = splash_clock_label.clone();
        let s_dt = splash_date_label.clone();
        back_button.connect_clicked(move |_| {
            s_clk.set_text(&format_clock());
            s_dt.set_text(&format_date());
            stack.set_visible_child_name("splash");
            splash.grab_focus();
        });
    }

    glib::timeout_add_local(Duration::from_secs(1), move || {
        let now_clock = format_clock();
        let now_date = format_date();
        splash_clock_label.set_text(&now_clock);
        splash_date_label.set_text(&now_date);
        login_clock_label.set_text(&now_clock);
        login_date_label.set_text(&now_date);
        glib::ControlFlow::Continue
    });

    window.set_child(Some(&root_overlay));
    window.present();
    main_stack.set_visible_child_name("splash");
    splash_overlay.grab_focus();
}
