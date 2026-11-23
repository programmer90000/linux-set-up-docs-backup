The second directory (`desktop/dash`) needs the same Show More functionality as `dash/working-dash`.

The update requires four changes:

1. Add `show_more.rs` to `desktop/dash/src/widgets/`.
2. Register the module and widget in `widgets/mod.rs`.
3. Add a `more` widget list to `PanelCfg` (already present in `config.rs`).
4. Update `panel.rs` to create a popover, put additional widgets inside it, and promote widgets onto the panel when their `show_on_dash` condition is met.

I'll preserve the existing widgets and their behaviour.

## 1. Create `desktop/dash/src/widgets/show_more.rs`

rust

```rust

use super::{menu_button, tag, Ctx};
use gtk4 as gtk;
use gtk::prelude::*;

/// The "Show more" button. `content` holds widgets configured in `more`.
pub fn build(ctx: &Ctx, content: &gtk::Box) -> gtk::Widget {
    let (mb, _pop) = menu_button(ctx, content);
    mb.set_label(ctx.cfg.icon.as_deref().unwrap_or("⋯"));
    tag(&mb, "show_more");
    mb.upcast()
}
```

## 2. Update `desktop/dash/src/widgets/mod.rs`

Add the module:

rust

```rust
pub mod show_more;
```

Replace the existing `build` function with:

rust

```rust
pub fn build(kind: &str, ctx: &Ctx) -> Option<gtk::Widget> {
    Some(match kind {
        "app_list" => app_list::build(ctx),
        "caps_lock" => caps_lock::build(ctx),
        "clock" => clock::build(ctx),
        "date" => date::build(ctx),
        "workspaces" => workspaces::build(ctx),
        "power" => power::build(ctx),
        "notifications" => notifications::build(ctx),
        "copyq" => copyq::build(ctx),
        "volume" => volume::build(ctx),
        "show_more" => return None, // Built specially by panel.rs
        other => {
            eprintln!("dash: unknown widget type '{other}'");
            return None;
        }
    })
}
```

The `show_more` widget is built specially because it needs access to the popover's contents.

## 3. Replace `desktop/dash/src/panel.rs`

This is the main change. It adds:

- A popover containing widgets from `more`.
- The three automatic promotion conditions: `always`, `nonempty`, and `class:`.
- Monitor-size-based promotion using `min_length:`.
- Correct popover arrow direction for each panel position.
- Automatic movement between the panel and popover.

rust

```rust

use crate::config::{Config, PanelCfg};
use crate::widgets::{self, Ctx};
use gtk4 as gtk;
use gtk::{gdk, prelude::*};
use gtk4_layer_shell::{Edge, Layer, LayerShell};
use std::{cell::RefCell, rc::Rc};

pub fn wanted(p: &PanelCfg, m: &gdk::Monitor) -> bool {
    if p.monitors.is_empty() || p.monitors.iter().any(|x| x == "*") {
        return true;
    }
    m.connector()
        .map(|c| p.monitors.iter().any(|x| x == c.as_str()))
        .unwrap_or(false)
}

enum Mode {
    Never,
    Always,
    NonEmpty,
    Class(String),
    MinLen(i32),
}

impl Mode {
    fn parse(s: Option<&str>) -> Mode {
        match s.unwrap_or("never") {
            "never" => Mode::Never,
            "always" => Mode::Always,
            "nonempty" => Mode::NonEmpty,
            x if x.starts_with("class:") =>
                Mode::Class(x[6..].to_string()),
            x if x.starts_with("min_length:") =>
                Mode::MinLen(x[11..].parse().unwrap_or(i32::MAX)),
            other => {
                eprintln!("dash: bad show_on_dash '{other}'");
                Mode::Never
            }
        }
    }

    fn initially_on_dash(&self, len: i32) -> bool {
        match self {
            Mode::Always => true,
            Mode::MinLen(n) => len >= *n,
            _ => false,
        }
    }

    fn on_report(&self, text: &str, class: &str) -> Option<bool> {
        match self {
            Mode::NonEmpty => Some(!text.is_empty()),
            Mode::Class(c) => Some(class == c),
            _ => None,
        }
    }
}

pub fn build(
    app: &gtk::Application,
    cfg: &Config,
    p: &PanelCfg,
    mon: &gdk::Monitor,
) -> gtk::ApplicationWindow {

    let (top, bottom, left, right, vertical, arrow) =
        match p.position.as_str() {
            "bottom" => (
                false, true, true, true,
                false, gtk::ArrowType::Up
            ),
            "left" => (
                true, true, true, false,
                true, gtk::ArrowType::Right
            ),
            "right" => (
                true, true, false, true,
                true, gtk::ArrowType::Left
            ),
            _ => (
                true, false, true, true,
                false, gtk::ArrowType::Down
            ),
        };

    let win = gtk::ApplicationWindow::new(app);
    win.add_css_class("dash");
    win.init_layer_shell();
    win.set_layer(Layer::Top);
    win.set_monitor(mon);
    win.set_namespace("dash");

    win.set_anchor(Edge::Top, top);
    win.set_anchor(Edge::Bottom, bottom);
    win.set_anchor(Edge::Left, left);
    win.set_anchor(Edge::Right, right);

    win.auto_exclusive_zone_enable();

    if vertical {
        win.set_default_size(p.size, -1);
    } else {
        win.set_default_size(-1, p.size);
    }

    let orient = if vertical {
        gtk::Orientation::Vertical
    } else {
        gtk::Orientation::Horizontal
    };

    let dash = gtk::Box::new(orient, p.spacing);
    dash.add_css_class("dash-box");

    // Container for widgets inside the Show More popover.
    let more_box = gtk::Box::new(gtk::Orientation::Vertical, 6);
    more_box.add_css_class("more-box");

    let geo = mon.geometry();
    let len = if vertical {
        geo.height()
    } else {
        geo.width()
    };

    let noop: Rc<dyn Fn(&str, &str)> = Rc::new(|_, _| {});

    // Normal panel widgets.
    for name in &p.widgets {
        let (kind, wc) = cfg.resolve(name);

        let ctx = Ctx {
            cfg: wc,
            vertical,
            arrow,
            report: noop.clone(),
        };

        let w = if kind == "show_more" {
            Some(widgets::show_more::build(&ctx, &more_box))
        } else {
            widgets::build(&kind, &ctx)
        };

        if let Some(w) = w {
            dash.append(&w);
        }
    }

    // Additional widgets, initially inside the popover.
    for name in &p.more {
        let (kind, wc) = cfg.resolve(name);

        let mode = Rc::new(Mode::parse(
            wc.show_on_dash.as_deref()
        ));

        let slot: Rc<RefCell<Option<gtk::Widget>>> =
            Default::default();

        // Moves the widget between the panel and popover.
        let mover = {
            let (slot, dash, more_box) = (
                slot.clone(),
                dash.clone(),
                more_box.clone()
            );

            Rc::new(move |on: bool| {
                let Some(w) = slot.borrow().clone() else {
                    return;
                };

                let in_dash = w.parent().map(
                    |p| p == dash.clone().upcast::<gtk::Widget>()
                );

                if in_dash == Some(on) {
                    return;
                }

                if let Some(parent) = w.parent()
                    .and_then(|p| p.downcast::<gtk::Box>().ok())
                {
                    parent.remove(&w);
                }

                if on {
                    dash.append(&w);
                } else {
                    more_box.append(&w);
                }
            })
        };

        let report: Rc<dyn Fn(&str, &str)> = {
            let (mode, mover) = (
                mode.clone(),
                mover.clone()
            );

            Rc::new(move |text, class| {
                if let Some(on) = mode.on_report(text, class) {
                    mover(on);
                }
            })
        };

        let ctx = Ctx {
            cfg: wc,
            vertical,
            arrow,
            report,
        };

        if let Some(w) = widgets::build(&kind, &ctx) {
            *slot.borrow_mut() = Some(w.clone());

            if mode.initially_on_dash(len) {
                dash.append(&w);
            } else {
                more_box.append(&w);
            }
        }
    }

    // Scrollable panel.
    let scroll = gtk::ScrolledWindow::new();

    if vertical {
        scroll.set_policy(
            gtk::PolicyType::Never,
            gtk::PolicyType::Automatic
        );
    } else {
        scroll.set_policy(
            gtk::PolicyType::Automatic,
            gtk::PolicyType::Never
        );

        let sc = gtk::EventControllerScroll::new(
            gtk::EventControllerScrollFlags::VERTICAL
        );

        let adj = scroll.hadjustment();

        sc.connect_scroll(move |_, _, dy| {
            adj.set_value(adj.value() + dy * 40.0);
            glib::Propagation::Stop
        });

        scroll.add_controller(sc);
    }

    scroll.set_child(Some(&dash));
    win.set_child(Some(&scroll));
    win.present();

    win
}
```

## 4. Update `desktop/dash/src/config.rs`

The `PanelCfg` structure already contains `more`, so no structural changes are necessary.

However, update the default panel configuration inside `load()`.

Replace its `widgets` and `more` values with:

rust

```rust
widgets: vec![
    "app_list".into(),
    "workspaces".into(),
    "volume".into(),
    "wifi".into(),
    "caps_lock".into(),
    "date".into(),
    "clock".into(),
    "show_more".into(),
    "power".into(),
],
more: vec![
    "notifications".into(),
    "copyq".into(),
],
```

This moves notifications and clipboard history into the Show More popover by default.

## 5. Configure your TOML

Your `~/.config/dash/config.toml` should contain something like:

toml

```toml

[[panel]]
position = "top"
size = 36
spacing = 4
monitors = ["*"]

widgets = [
    "app_list",
    "workspaces",
    "volume",
    "wifi",
    "caps_lock",
    "date",
    "clock",
    "show_more",
    "power"
]

more = [
    "notifications",
    "copyq"
]

[widget.notifications]
stream = "swaync-client -swb"
on_click = "swaync-client -t -sw"

[widget.copyq]
show_on_dash = "never"
```

## 6. What the result looks like

## Dash panel preview

🌐

▦ 1/4

🔊 65%

📶 Wi-Fi

⇪

Mon 23 Nov

17:13

⋯⏻

Show More popover

🔔

Notifications

0

📋

Clipboard history

CopyQ

## 7. Build and install

From `desktop/dash`:

bash

```bash
cargo build --release

install -Dm755 target/release/dash ~/.local/bin/dash
```

Restart Dash to see the changes.

Important: The code above preserves the existing second directory's widget set. Notifications need a configured event source to display live information. Also, the changes are supplied as file replacements and patches here; I haven't directly modified your filesystem or run the build.

You have two separate Rust compilation errors. Both are straightforward to fix.

## 1. Fix `glib` not found (`src/panel.rs:250`)

Error:

rust

```rust
glib::Propagation::Stop
```

The compiler cannot resolve `glib` because it isn't imported into the current module.

Option A — Recommended: Add this at the top of `src/panel.rs`:

rust

```rust
use gtk::glib;
```

Then your existing code can remain unchanged:

rust

```rust
glib::Propagation::Stop
```

Option B: Import `Propagation` directly:

rust

```rust
use gtk::glib::Propagation;
```

Then change line 250 to:

rust

```rust
Propagation::Stop
```

## 2. Fix duplicate `more` field (`src/config.rs:102`)

You have declared `more` twice in the same struct initialization.

Currently:

rust

```rust
more: vec![
    "notifications".into(),
    "copyq".into(),
],
more: vec![],
```

Rust does not allow duplicate fields in a struct initializer.

Fix: Remove the second declaration:

rust

```rust
more: vec![
    "notifications".into(),
    "copyq".into(),
],
```

If you intended an empty list instead, use:

rust

```rust
more: vec![],
```

## 3. Recompile

After making both changes, run:

bash

```bash
cargo clean
cargo build
```

You can also run:

bash

```bash
cargo check
```

`cargo check` is faster because it checks compilation without producing the final executable.

Expected resultBoth reported errors should be resolved.

If another error appears, share the output and I can help fix the next issue.