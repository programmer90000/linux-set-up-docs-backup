#!/bin/bash

sudo apt update
sudo apt install swaybg
sudo cp desktop/desktop-wallpaper.png /usr/share/pixmaps/
mkdir -p ~/.config/labwc
cp desktop/labwc/autostart ~/.config/labwc/
swaybg -i /usr/share/pixmaps/desktop-wallpaper.png -m fill &
sudo apt install -y build-essential libgtk-3-dev libgtk-layer-shell-dev
cd desktop/icons/
make
sudo make install
mkdir -p ~/Desktop/
cd ../../
cp desktop/desktop-files/brave-browser.desktop ~/Desktop/
cp desktop/desktop-files/thunderbird.desktop ~/Desktop/
cp desktop/desktop-files/alacritty.desktop ~/Desktop/
cp desktop/desktop-files/shotcut.desktop ~/Desktop/
cp desktop/desktop-files/vlc.desktop ~/Desktop/
cp desktop/desktop-files/gimp.desktop ~/Desktop/
cp desktop/desktop-files/hard-info-2.desktop ~/Desktop/
mkdir -p ~/.config/desktop-icons/
cp desktop/icons/order.conf ~/.config/desktop-icons/
cp desktop/icons/config.conf ~/.config/desktop-icons/
mkdir -p ~/.config/desktop-files/
cp desktop/desktop-files/* ~/.config/desktop-files/
icons &
sudo apt install -y build-essential cmake meson ninja-build pkg-config libgtk-3-dev libgdk-pixbuf-2.0-dev libcairo2-dev libglib2.0-dev libwayland-dev libgtk-layer-shell-dev libxkbregistry-dev libgtkmm-3.0-dev libjson-c-dev nlohmann-json3-dev libpulse-dev libasound2-dev libpipewire-0.3-dev python3-docutils
cd desktop/app-launcher/
meson setup builddir -Dbuildtype=release
ninja -C builddir
sudo ninja -C builddir install
cd ../dash/
meson setup build -Dauto_features=enabled -Dbuildtype=release
ninja -C build
sudo ninja -C build install
cd ../dash-config/
mkdir -p ~/.config/sfwbar/scripts/
cp sfwbar.config ~/.config/sfwbar/sfwbar.config
cp style.css ~/.config/sfwbar/style.css
cp init.sh ~/.config/sfwbar/scripts/init.sh
chmod +x ~/.config/sfwbar/scripts/init.sh
sfwbar &
mkdir -p ~/.config/labwc
cd ../labwc/
cp autostart ~/.config/labwc/autostart
cp rc.xml ~/.config/labwc/rc.xml
chmod +x ~/.config/labwc/autostart
