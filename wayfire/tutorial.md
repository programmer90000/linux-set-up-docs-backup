### Notifications

Using [mako]:

`~/.config/wayfire.ini`

``` ini
[autostart]
notifications = mako
```

[mako]: https://wayland.emersion.fr/mako/

See [Autostart] for more information.

### Idle configuration

Example configuration with [swayidle] and [swaylock]:

`~/.config/wayfire.ini`

``` ini
[autostart]
idle = swayidle before-sleep swaylock

[idle]
toggle = <super> KEY_Z
screensaver_timeout = 300
dpms_timeout = 600
```

- Disables the compositor going idle with <kbd>Super</kbd> + <kbd>z</kbd>.
- This will lock your screen after 300 seconds of inactivity, then turn off
your displays after another 300 seconds.

[swayidle]: https://github.com/swaywm/swayidle
[swaylock]: https://github.com/swaywm/swaylock

See [Autostart] and [Idle] for more information.

Note: for now [there is a trick](https://github.com/WayfireWM/wayfire/issues/455#issuecomment-630125354) for binding a key to instantly turn-off the screen (DPMS).

### Screen locker

Lock your screen with [swaylock]:

`~/.config/wayfire.ini`

``` ini
[command]
binding_lock = <super> KEY_ESC
command_lock = swaylock
```

See [Command] for more information.

### Logout

Use [wayland-logout] to kill the current compositor instance.
Launch logout GUI [wlogout]:

`~/.config/wf-shell.ini`

``` ini
[panel]
menu_logout_command = wlogout
```

[wlogout]: https://github.com/ArtsyMacaw/wlogout
[wayland-logout]: https://github.com/soreau/wayland-logout

### Changing the volume

**Example** – Changing the volume with [ALSA]:

`~/.config/wayfire.ini`

``` ini
[command]
repeatable_binding_volume_up = KEY_VOLUMEUP
command_volume_up = amixer set Master 5%+
repeatable_binding_volume_down = KEY_VOLUMEDOWN
command_volume_down = amixer set Master 5%-
binding_mute = KEY_MUTE
command_mute = amixer set Master toggle
```

[ALSA]: https://alsa-project.org

**Example** – Changing the volume with [PulseAudio]:

`~/.config/wayfire.ini`

``` ini
[command]
repeatable_binding_volume_up = KEY_VOLUMEUP
command_volume_up = pactl set-sink-volume 0 +5%
repeatable_binding_volume_down = KEY_VOLUMEDOWN
command_volume_down = pactl set-sink-volume 0 -5%
binding_mute = KEY_MUTE
command_mute = pactl set-sink-mute 0 toggle
```

[PulseAudio]: https://freedesktop.org/wiki/Software/PulseAudio/

**Example** – Changing the volume with [WirePlumber] for [PipeWire]:

`~/.config/wayfire.ini`

``` ini
[command]
repeatable_binding_volume_up = KEY_VOLUMEUP
command_volume_up = wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
repeatable_binding_volume_down = KEY_VOLUMEDOWN
command_volume_down = wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
binding_mute = KEY_MUTE
command_mute = wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
```

[WirePlumber]: https://pipewire.pages.freedesktop.org/wireplumber/
[PipeWire]: https://pipewire.org/

See [Command] for more information.

### Automatically maximizing windows

You can maximize specific windows by default with the following command:

`~/.config/wayfire.ini`

``` ini
[window-rules]
alacritty = on created if app_id is "Alacritty" then maximize
```

You can get the properties of your applications with the following command:

``` sh
WAYLAND_DEBUG=1 alacritty 2>&1 | kak
```
See [Window rules] for more information.