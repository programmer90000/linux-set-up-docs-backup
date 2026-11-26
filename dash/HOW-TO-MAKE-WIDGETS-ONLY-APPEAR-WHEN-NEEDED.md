# Answer from Claude for hiding the caps lock widget
I made the widget hide itself, so it no longer depends on the `show_on_dash` config. All changes are in `caps_lock.rs`.

**1. Start hidden**

```rust
    let label = gtk::Label::new(Some(&icon));
    tag(&label, "caps_lock");
    label.add_css_class("off");
    label.set_visible(false); // hidden until Caps Lock is reported on
```

**2. Toggle visibility in the `set` closure**

```rust
    let set = Rc::new({
        let (label, report) = (label.clone(), ctx.report.clone());
        move |on: bool| {
            label.set_text(&if on { format!("{icon} CAPS") } else { icon.clone() });
            label.remove_css_class(if on { "off" } else { "on" });
            label.add_css_class(if on { "on" } else { "off" });
            label.set_visible(on);
            report(if on { "CAPS" } else { "" }, if on { "on" } else { "off" });
        }
    });
```

Because every state change goes through `set`, this covers the initial LED state read in the background thread and every later LED event. If Caps Lock is already on at startup, the widget appears right away.

Things to know:

- **No readable keyboard:** the widget stays hidden, so the "no readable keyboard" tooltip on the label will never be seen. The `eprintln!` message about the `input` group still prints, so check stderr if the widget never shows up. If you want that case visible, set `label.set_visible(true)` in the `!found` branch.
- **`show_on_dash`:** this still works alongside the change. `show_on_dash = "class:on"` or `"nonempty"` gives the same show/hide behavior from the panel side. Under `more`, the widget is moved between the dash and the overflow popup, and it is now also hidden whenever Caps Lock is off.
- **Layout:** a hidden GTK widget takes no space, but the box's `spacing` is only applied between visible children, so the dash won't leave a gap when it's hidden.
