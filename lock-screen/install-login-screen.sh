#!/bin/bash
set -e

sudo apt update
sudo apt install -y cargo rustc pkg-config libgtk-4-dev libpam0g-dev libgtk-layer-shell-dev

cargo build --release
sudo install -Dm755 target/release/wayfire-lock-screen /usr/local/bin/wayfire-lock-screen

THEME_DIR="/usr/share/wayland-lock-screen"
sudo mkdir -p "${THEME_DIR}/assets"
sudo cp -r assets/* "${THEME_DIR}/" 2>/dev/null || true
sudo chmod -R 755 "${THEME_DIR}"

echo "Lock screen installed successfully!"
echo "You can trigger it using swayidle or bind it via Wayfire configuration."
