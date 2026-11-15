#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root or with sudo."
    echo "Please run it as a regular user."
    exit 1
fi

THEME_DIR="/etc/qtgreet/login-screen"

echo "Installing greetd and qtgreet..."
sudo apt update
sudo apt install -y greetd qtgreet

echo "Setting up configuration files and directories..."
sudo mkdir -p $THEME_DIR
sudo mkdir -p $THEME_DIR/assets/
sudo mkdir -p /etc/qtgreet/

sudo cp login-screen/Main.qml $THEME_DIR
sudo cp login-screen/UserList.qml $THEME_DIR
sudo cp login-screen/Clock.qml $THEME_DIR
sudo cp login-screen/PowerButton.qml $THEME_DIR
sudo cp -r login-screen/assets/ $THEME_DIR
sudo cp login-screen/LoginForm.qml $THEME_DIR
sudo cp login-screen/SplashScreen.qml $THEME_DIR

sudo cp login-screen/splash_background.png $THEME_DIR

# Copy daemon configuration blocks
sudo tee /etc/greetd/config.toml > /dev/null << 'EOF'
[terminal]
vt = 1

[default_session]
command = "qtgreet --config /etc/qtgreet/config.ini"
user = "greeter"
EOF

sudo tee /etc/qtgreet/config.ini > /dev/null << 'EOF'
[general]
theme = /etc/qtgreet/login-screen/
EOF

sudo mkdir -p "$THEME_DIR/$(whoami)"
if [ -f "login-screen/profile-picture.png" ]; then
    sudo cp login-screen/profile-picture.png "$THEME_DIR/$(whoami)"
fi

sudo chmod -R 755 /etc/qtgreet/
sudo systemctl enable greetd

echo "Migration complete! Please reboot your system."