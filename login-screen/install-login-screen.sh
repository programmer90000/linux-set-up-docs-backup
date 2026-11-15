#!/bin/bash
set -e

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root or with sudo."
    echo "Please run it as a regular user."
    exit 1
fi

CURRENT_USER="$(whoami)"
THEME_DIR="/usr/share/greetd/login-screen"

echo "Installing greetd and GTK4 Layer Shell build dependencies..."
sudo apt update
sudo apt install -y \
    greetd \
    cargo \
    rustc \
    pkg-config \
    libgtk-4-dev \
    libgtk4-layer-shell-dev \
    polkitd

echo "Building wayfire-greetd-ui release binary..."
pushd login-screen > /dev/null
cargo build --release
sudo install -Dm755 target/release/wayfire-greetd-ui /usr/local/bin/wayfire-greetd-ui
popd > /dev/null

echo "Installing theme assets to ${THEME_DIR}..."
sudo mkdir -p "${THEME_DIR}/assets"
sudo mkdir -p "${THEME_DIR}/${CURRENT_USER}"
sudo cp -r login-screen/assets/* "${THEME_DIR}/assets/"
sudo cp login-screen/splash_background.png "${THEME_DIR}/"
sudo cp login-screen/profile-picture.png "${THEME_DIR}/${CURRENT_USER}/"
sudo chmod -R 755 "${THEME_DIR}"

# Detect Debian's greetd service user (_greetd on Debian, greeter on some distros)
GREETER_USER="_greetd"
if ! id -u "${GREETER_USER}" >/dev/null 2>&1; then
    GREETER_USER="greeter"
fi

echo "Configuring /etc/greetd for user ${GREETER_USER}..."
sudo mkdir -p /etc/greetd
sudo cp login-screen/config/wayfire-greeter.ini /etc/greetd/wayfire-greeter.ini
sudo sed "s/user = \"_greetd\"/user = \"${GREETER_USER}\"/" login-screen/config/config.toml | sudo tee /etc/greetd/config.toml > /dev/null

# Allow the greeter user to poweroff, reboot, and suspend via logind/polkit
echo "Configuring Polkit rules for power options..."
sudo mkdir -p /etc/polkit-1/rules.d
sudo tee /etc/polkit-1/rules.d/50-greetd-power.rules > /dev/null <<EOF
polkit.addRule(function(action, subject) {
    if (subject.user == "${GREETER_USER}" &&
        (action.id == "org.freedesktop.login1.power-off" ||
         action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
         action.id == "org.freedesktop.login1.reboot" ||
         action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
         action.id == "org.freedesktop.login1.suspend" ||
         action.id == "org.freedesktop.login1.suspend-multiple-sessions")) {
        return polkit.Result.YES;
    }
});
EOF

# Disable SDDM if present and enable greetd
if systemctl list-unit-files | grep -q '^sddm.service'; then
    sudo systemctl disable sddm
fi
sudo systemctl enable greetd

echo "Done! Reboot or run 'sudo systemctl start greetd' from a TTY to launch the login screen."