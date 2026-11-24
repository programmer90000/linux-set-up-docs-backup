#!/bin/bash
set -e

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root or with sudo."
    echo "Please run it as a regular user."
    exit 1
fi

CURRENT_USER="$(whoami)"
THEME_DIR="/usr/share/wayfire-lock-screen"

sudo apt update
sudo apt install -y cargo rustc pkg-config libgtk-4-dev libpam0g-dev

cargo build --release
sudo install -Dm755 target/release/wayfire-lock-screen /usr/local/bin/wayfire-lock-screen

sudo mkdir -p "${THEME_DIR}/assets"
sudo mkdir -p "${THEME_DIR}/${CURRENT_USER}"
sudo cp -r assets/* "${THEME_DIR}/assets/"
sudo cp splash_background.png "${THEME_DIR}/"
sudo cp profile-picture.png "${THEME_DIR}/${CURRENT_USER}/"
sudo chmod -R 755 "${THEME_DIR}"
