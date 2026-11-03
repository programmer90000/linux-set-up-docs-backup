#!/bin/bash

ENVIRONMENT="labwc/environment"
AUTOSTART="labwc/autostart"
SCRIPTS="labwc/scripts"

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root or with sudo."
    echo "Please run it as a regular user."
    exit 1
fi

if [ ! -f "$ENVIRONMENT" ]; then
    echo "Configuration file '$ENVIRONMENT' not found."
    echo "Please ensure the file exists in the correct location."
    exit 1
fi

if [ ! -f "$AUTOSTART" ]; then
    echo "Configuration file '$AUTOSTART' not found."
    echo "Please ensure the file exists in the correct location."
    exit 1
fi

if [ ! -d "$SCRIPTS" ]; then
    echo "Configuration directory '$SCRIPTS' not found."
    echo "Please ensure the directory exists in the correct location."
    exit 1
fi

echo "Installing Labwc"
sudo apt update
sudo apt install -y labwc

echo "Installing make and build-essential"
sudo apt install make build-essential

echo "Installing wl-find-cursor"
cd labwc/wl-find-cursor/
make
cd ../../
sudo cp labwc/wl-find-cursor/wl-find-cursor /usr/local/bin/

echo "Installing wayland-wheeltani"
cd labwc/wayland-wheeltani/
cargo build --release --workspace --bins
cd ../../
sudo cp labwc/wayland-wheeltani/target/release/wayland-wheeltani /usr/local/bin/
sudo cp etc/uinput.conf /etc/modules-load.d/uinput.conf
sudo cp etc/99-uinput.rules /etc/udev/rules.d/99-uinput.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
mkdir -p ~/.config/systemd/user/
cp labwc/config/systemd/wayland-wheeltani.service ~/.config/systemd/user/wayland-wheeltani.service
systemctl --user daemon-reload
systemctl --user enable --now wayland-wheeltani
sudo adduser abdul input

echo "Setting up configuration directory"
mkdir -p ~/.config/labwc/

echo "Copying environment file"
cp $ENVIRONMENT ~/.config/labwc/

echo "Copying rc.xml file"
cp labwc/rc.xml ~/.config/labwc/

echo "Copying autostart file"
cp $AUTOSTART ~/.config/labwc/
chmod +x ~/.config/labwc/autostart

echo "Copying scripts directory"
cp -r $SCRIPTS ~/.config/labwc/
