#!/bin/bash
set -e

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root or with sudo."
    echo "Please run it as a regular user."
    exit 1
fi

CURRENT_USER="$(whoami)"
THEME_DIR="/usr/share/greetd/login-screen"

sudo apt update
sudo apt install -y greetd cargo rustc pkg-config libgtk-4-dev libgtk4-layer-shell-dev polkitd wayfire

cd login-screen/commit-6/
cargo build --release
sudo install -Dm755 target/release/wayfire-greetd-ui /usr/local/bin/wayfire-greetd-ui
cd ../

echo "Installing theme assets to ${THEME_DIR}..."
sudo mkdir -p "${THEME_DIR}/assets"
sudo mkdir -p "${THEME_DIR}/${CURRENT_USER}"
sudo cp -r login-screen/commit-6/assets/* "${THEME_DIR}/assets/"
sudo cp login-screen/commit-6/splash_background.png "${THEME_DIR}/"
sudo cp login-screen/commit-6/profile-picture.png "${THEME_DIR}/${CURRENT_USER}/"
sudo chmod -R 755 "${THEME_DIR}"

GREETER_USER="_greetd"

echo "Configuring /etc/greetd for user ${GREETER_USER}..."
sudo mkdir -p /etc/greetd
sudo cp login-screen/commit-6/config/wayfire-greeter.ini /etc/greetd/wayfire-greeter.ini

echo "Configuring Polkit rules for power options..."
sudo mkdir -p /etc/polkit-1/rules.d
sudo cp login-screen/commit-6/rules.d/50-greetd-power.rules /etc/polkit-1/rules.d/50-greetd-power.rules

sudo systemctl enable greetd