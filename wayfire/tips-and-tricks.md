# Tips & Tricks

## Gtk+3 applications slow startup or .desktop files not opening

This is due to GTK+ waiting for xdg-desktop-portal to start via D-Bus. This times out because the D-Bus activated service doesn't know what `WAYLAND_DISPLAY` to connect to. This can also cause some .desktop files not to open on XDG Desktop Entry spec-compliant menus (like `wf-panel`) if they are `DBusActivatable=true`. Add the following to your configuration file:
```
[autostart]
0_environment = dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XAUTHORITY
```
For more details: https://github.com/WayfireWM/wayfire/issues/775

## Run xwayland apps as root

This is a small wrapper script that uses `xhost` and `sudo` to launch x11 clients as root under xwayland. Save to a file, make executable and use in place of sudo to run an x11 client with privileges in wayfire.

```
#!/bin/bash
# small script to enable root access to x-windows system

# enable root access
xhost +SI:localuser:root

sudo -E $@

# disable root access after application terminates
xhost -SI:localuser:root
```

## Login with gtkgreet and wayfire

1) Install `greetd` using your package manager.

2) Install [gtkgreet](https://git.sr.ht/~kennylevinsen/gtkgreet) to `/opt/gtkgreet`:

```
git clone https://git.sr.ht/~kennylevinsen/gtkgreet
cd gtkgreet
meson setup --prefix=/opt/gtkgreet build
ninja -C build install
```

3) Install [wayland-logout] to `/usr/`:

NOTE: This step can be skipped if `wf-shell` is installed to `$prefix/` and `$prefix/bin/` in `$PATH`, as it provides [wayland-logout] by default.

```
git clone https://github.com/soreau/wayland-logout
cd wayland-logout
meson setup --prefix=/usr build
ninja -C build install
```

4) Create a `wayfire.ini` for [gtkgreet](https://git.sr.ht/~kennylevinsen/gtkgreet) in `/opt/gtkgreet/share/`:

```
[autostart]
autostart_wf_shell = false
dm = /opt/gtkgreet/bin/gtkgreet -l && wayland-logout

[core]
plugins = autostart
vheight = 1
vwidth = 1
xwayland = false
```

5) Create a `wayfire-gtkgreet` script somewhere in `$PATH` such as `/usr/local/bin/`:

```
#!/bin/bash

cd
wayfire -c /opt/gtkgreet/share/wayfire.ini
```

6) Make the `wayfire-gtkgreet` script executable:

`chmod +x /usr/local/bin/wayfire-gtkgreet`

7) Configure `greetd` to start `wayfire` as the default session by using this `/etc/greetd/config.toml` config:

```
[terminal]
vt = 7

[default_session]
command = "wayfire-gtkgreet"
user = "replace_with_your_user_name"
```

8) Start the greetd service:

`systemctl start greetd`

9) Verify:

When [gtkgreet](https://git.sr.ht/~kennylevinsen/gtkgreet) appears, login by entering your user name, `wayfire` as the session and finally, enter your password.

10) If everything works, enable the `greetd` service so that it starts on boot:

`systemctl enable greetd`

[wayland-logout]: https://github.com/soreau/wayland-logout

## Logout and shutdown

Wayfire has a hard coded keybinding Ctrl+Alt+BkSpc to shutdown. It also supports layer shell protocol, which makes it possible to use a program such as [wlogout] to log out and shut down. There is also [wayland-logout] which kills the current wayland compositor instance.

[wlogout]: https://github.com/ArtsyMacaw/wlogout
[wayland-logout]: https://github.com/soreau/wayland-logout

## High CPU usage

Compile wayfire with the `release` buildtype to enable performance optimizations.
```
meson -Dbuildtype=release build
```

## Catch crashes with systemd-coredump

Build wayfire with the flag `-Dprint_trace=false`

## Screen sharing

To enable screen sharing in Firefox, Chromium, or any other XDG Desktop Portal client, add the following lines to the configuration file `wayfire.ini`:

```
[autostart]
0_0 = dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XAUTHORITY WAYFIRE_SOCKET XDG_CURRENT_DESKTOP=wayfire
xdp = sleep 1 && systemctl --user restart xdg-desktop-portal xdg-desktop-portal-wlr
```
Without `sleep 1 &&`, screen sharing may fail: [Issue #3053](https://github.com/WayfireWM/wayfire/issues/3053).

Install `xdg-desktop-portal` and `xdg-desktop-portal-wlr`. Edit the configuration file `~/.config/xdg-desktop-portal-wlr/config`:

```
[screencast]
max_fps=30
chooser_cmd=wf-stream-chooser
chooser_type=simple
```
`wf-stream-chooser` is included in `wf-shell`.

To test locally, use the following script: https://gitlab.gnome.org/-/snippets/19. Test online: https://mozilla.github.io/webrtc-landing/gum_test.html (press the _Screen capture_ button).

## Setting up monitor frequency if wayfire.ini does not work 

If your output = kanshi as default, you may need to create a config file in $HOME/.config/kanshi/config with your desired settings
e.g:
```
profile { 
	output DP-1 mode 2560x1080@74.990997 position 0,0
}
```

See kanshi git for more info: https://github.com/emersion/kanshi

## GTK Theme not working

[This script from a sway article](https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland) can set your theme for you, assuming you already had one set with X.

```sh
#!/bin/sh
# .config/setWaylandTheme.sh

# usage: import-gsettings
config="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
if [ ! -f "$config" ]; then exit 1; fi

gnome_schema="org.gnome.desktop.interface"
gtk_theme="$(grep 'gtk-theme-name' "$config" | sed 's/.*\s*=\s*//')"
icon_theme="$(grep 'gtk-icon-theme-name' "$config" | sed 's/.*\s*=\s*//')"
cursor_theme="$(grep 'gtk-cursor-theme-name' "$config" | sed 's/.*\s*=\s*//')"
font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"
gsettings set "$gnome_schema" gtk-theme "$gtk_theme"
gsettings set "$gnome_schema" icon-theme "$icon_theme"
gsettings set "$gnome_schema" cursor-theme "$cursor_theme"
gsettings set "$gnome_schema" font-name "$font_name"
```

add the script to autostart in your wayfire.ini. don't forget to add exec permissons.

```
[autostart]
a0 = ~/.config/setWaylandTheme.sh
```

## Getting the title and app-id of windows

Getting the title and/or app-id of a view/window (e.g. for use with the `window-rules` plugin) requires the use of the [`wlr-foreign-toplevel-management-v1`](https://wayland.app/protocols/wlr-foreign-toplevel-management-unstable-v1) protocol. Prior to Wayfire 0.8.0, this was implemented in core, but it's now implemented by the `foreign-toplevel` plugin.

Once support is enabled, a list of the title and app-id of views/windows can be found via the [`lswt` program](https://sr.ht/~leon_plickat/lswt/). Alternatively, one can compile and run the `foreign-toplevel.c` program; prior to 2023-10-12, this was available in the `examples` directory of the wlroots source, but is now [part of the wlr-clients repository](https://gitlab.freedesktop.org/wlroots/wlr-clients/-/blob/master/foreign-toplevel.c?ref_type=heads).