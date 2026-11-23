# dash — event-driven Wayland panel (Rust, GTK4 + layer-shell)

## Build (Debian 13)
    sudo apt install build-essential pkg-config libgtk-4-dev libgtk4-layer-shell-dev rustc cargo
    cargo build --release
    install -Dm755 target/release/dash ~/.local/bin/dash
    mkdir -p ~/.config/dash && cp config.example.toml ~/.config/dash/config.toml

Runtime helpers used by the default widget commands:
    sudo apt install pulseaudio-utils pipewire-pulse network-manager bluez dbus-bin mpc wl-clipboard pipewire-bin
    sudo usermod -aG input $USER        # caps lock (reads LED events from /dev/input)

## Wayfire
~/.config/wayfire.ini:
    [core]
    plugins = ... ipc ipc-rules ...     # needed by the `workspaces` widget
    [autostart]
    dash = ~/.local/bin/dash

## Writing your own widget source (no code needed)
In `[widget.<name>]`: `stream` (each stdout line = new state), or `watch` (each stdout
line re-runs `command`), or just `command` (runs once). Output is plain text or
JSON `{"text":"3","class":"warning","tooltip":"3 unread","icon":"🔔"}`.
Style with CSS: classes `.widget`, `.widget-<type>`, plus the reported class.

Adding a new built-in: create src/widgets/foo.rs, `pub mod foo;` and a match arm in widgets/mod.rs.
