[![CI](https://github.com/docloulou/Wayland-Wheeltani/actions/workflows/ci.yml/badge.svg)](https://github.com/docloulou/Wayland-Wheeltani/actions/workflows/ci.yml)
[![CodeQL](https://github.com/docloulou/Wayland-Wheeltani/actions/workflows/codeql.yml/badge.svg)](https://github.com/docloulou/Wayland-Wheeltani/actions/workflows/codeql.yml)
[![License: 0BSD](https://img.shields.io/badge/license-0BSD-brightgreen.svg)](LICENSE)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/W7W01LZHA2)

# Wayland-Wheeltani

Progressive middle-click autoscroll for Wayland.

Hold the middle mouse button, move vertically or horizontally, and
Wayland-Wheeltani emits smooth wheel events through a virtual mouse. Release the
middle button and scrolling stops immediately. A short middle click still
behaves like a normal middle click.

```text
hold middle button
  ├─ tiny movement inside deadzone       -> normal middle click on release
  ├─ move down from press position       -> continuous scroll down
  ├─ move right from press position      -> continuous horizontal scroll right
  ├─ move farther from press position    -> faster scroll
  ├─ return near press position          -> scroll slows/stops
  └─ cross the press position            -> scroll reverses on that axis
```

Prefer clicking once instead of holding? `mode = "toggle_progressive"` latches
scroll mode on a click and ends it on the next one.

No GUI, no overlay, no network, no keyboard capture. The project is split into a
portable, unit-tested Rust core and a Linux backend using `evdev` + `uinput`.

## Features

| Feature | Details | Wiki |
|---|---|---|
| **Progressive autoscroll** | Speed follows the distance from the middle-button press point; a short click still behaves as a normal middle click | — |
| **Hold or toggle, any button** | Hold to scroll, or click once to latch (`toggle_progressive`); trigger with the middle, side or extra button | [Configuration](https://github.com/docloulou/Wayland-Wheeltani/wiki/Configuration) |
| **Inertia & axis lock** | Optional kinetic coasting after release; lock scrolling to the dominant or first axis | [Configuration](https://github.com/docloulou/Wayland-Wheeltani/wiki/Configuration) |
| **Per-application profiles** | Different speed, mode or inertia per focused app with `[[profiles]]` | [Foreground filter](https://github.com/docloulou/Wayland-Wheeltani/wiki/Foreground-Filter) |
| **Live control** | `--status`, `--pause`, `--resume`, `--toggle` (bind it to a shortcut), `--reload` | [Configuration](https://github.com/docloulou/Wayland-Wheeltani/wiki/Configuration) |
| **Live tuning & hot reload** | `--tune` changes speed and deadzone in the running daemon, then saves; edits to the config file apply on save | [Configuration](https://github.com/docloulou/Wayland-Wheeltani/wiki/Configuration) |
| **Indicator hooks** | Run a command when autoscroll starts/stops or the daemon is paused: notification, Waybar module, cursor change… | [Configuration](https://github.com/docloulou/Wayland-Wheeltani/wiki/Configuration) |
| **Several mice** | `--add-device` drives a second mouse with the same settings | [Configuration](https://github.com/docloulou/Wayland-Wheeltani/wiki/Configuration) |
| **Stable device matching** | Matches your mouse by USB vendor/product id, so config survives reboots and USB port changes | [Configuration](https://github.com/docloulou/Wayland-Wheeltani/wiki/Configuration) |
| **Runtime hot-reconnect** | Survives a live unplug/replug without restarting the daemon; every button and axis of the mouse keeps working | [Configuration](https://github.com/docloulou/Wayland-Wheeltani/wiki/Configuration) |
| **Per-application foreground filter** | Turn autoscroll on/off per focused app (denylist/allowlist); off by default | [Foreground filter](https://github.com/docloulou/Wayland-Wheeltani/wiki/Foreground-Filter) |
| **Foreground providers** | Hyprland, Sway/i3, GNOME (bundled Shell extension), KDE Plasma (`kdotool`), or any custom command | [Foreground filter](https://github.com/docloulou/Wayland-Wheeltani/wiki/Foreground-Filter) · [GNOME setup](https://github.com/docloulou/Wayland-Wheeltani/wiki/GNOME-Setup) · [KDE setup](https://github.com/docloulou/Wayland-Wheeltani/wiki/KDE-Setup) |
| **`--detect-foreground` helper** | Prints the exact identifier to use in `deny_apps`/`allow_apps` | [Foreground filter](https://github.com/docloulou/Wayland-Wheeltani/wiki/Foreground-Filter) |
| **`systemd --user` service** | Install, start, stop, and restart the daemon as a user service | [Installation](https://github.com/docloulou/Wayland-Wheeltani/wiki/Installation) |
| **Root-free daily use** | Generates a targeted udev rule for your mice and `/dev/uinput` | [Installation](https://github.com/docloulou/Wayland-Wheeltani/wiki/Installation) · [Troubleshooting](https://github.com/docloulou/Wayland-Wheeltani/wiki/Troubleshooting) |
| **`wlw` short CLI alias** | Same program as `wayland-wheeltani`, shorter to type; shell completions and man pages for both | [Installation](https://github.com/docloulou/Wayland-Wheeltani/wiki/Installation) |
| **Dry-run & verbose logging** | `--dry-run` and `-v`/`-vv` to debug without touching the virtual mouse | [Configuration](https://github.com/docloulou/Wayland-Wheeltani/wiki/Configuration) |
| **Packages** | Arch `PKGBUILD`, `.deb`/`.rpm` metadata and a Nix flake | [`packaging/`](packaging/README.md) |


## License

Released under the [BSD Zero Clause License](LICENSE) (0BSD) — do whatever you
want with it, no attribution required.
