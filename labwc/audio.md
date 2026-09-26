Install Pipewire:
```
sudo apt update
sudo apt install pipewire wireplumber pipewire-pulse alsa-utils
```

Enable Pipewire user services:
```
systemctl --user --now enable pipewire pipewire-pulse wireplumber
```

Ensure it is running correctly:
```
pactl info
```

Install Pulsemixer volume manager:
```
sudo apt install pulsemixer
```

Add the following code to rc.xml:
```
<!-- Super + Up Arrow = Volume Up -->
<keybind key="W-Up">
  <action name="Execute">
    <command>wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+</command>
  </action>
</keybind>

<!-- Super + Down Arrow = Volume Down -->
<keybind key="W-Down">
  <action name="Execute">
    <command>wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-</command>
  </action>
</keybind>

<!-- Toggle Mute with Super + M -->
<keybind key="W-m">
  <action name="Execute">
    <command>wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle</command>
  </action>
</keybind>
```

Adjust the keyboard shortcuts

Run:
```
labwc --reconfigure
```