Add this to the `install-desktop.sh` file

Run:
```
sudo apt update
sudo apt install build-essential meson ninja-build git libgtk-4-dev guile-3.0-dev libgtk4-layer-shell-dev pkg-config
cd lambdock
meson setup build
ninja -C build
sudo ninja -C build install
```

Add this to `~/.config/wayfire.ini`:
```
[autostart]
lambdock = lambdock
```
