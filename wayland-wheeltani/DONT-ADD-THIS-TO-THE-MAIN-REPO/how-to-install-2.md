Run:
```
sudo cp target/release/wayland-wheeltani /usr/local/bin/
echo "uinput" | sudo tee /etc/modules-load.d/uinput.conf
echo 'KERNEL=="uinput", MODE="0660", GROUP="input"' | sudo tee /etc/udev/rules.d/99-uinput.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
mkdir -p ~/.config/systemd/user/
nano ~/.config/systemd/user/wayland-wheeltani.service
```
Paste the following:
```
[Unit]
Description=Wayland-Wheeltani Middle-Click Autoscroll Daemon
After=graphical-session.target

[Service]
ExecStart=/usr/local/bin/wayland-wheeltani
Restart=on-failure

[Install]
WantedBy=default.target
```

Run:
```
systemctl --user daemon-reload
systemctl --user enable --now wayland-wheeltani
```
