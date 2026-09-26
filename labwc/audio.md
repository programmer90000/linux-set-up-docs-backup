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