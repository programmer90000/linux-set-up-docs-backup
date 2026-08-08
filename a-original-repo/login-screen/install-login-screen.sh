#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root or with sudo."
    echo "Please run it as a regular user."
    exit 1
fi

THEME_NAME=login-screen
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"

sudo apt update
sudo apt install -y sddm
sudo mkdir -p $THEME_DIR
sudo mkdir -p $THEME_DIR/assets/
sudo cp login-screen/Main.qml $THEME_DIR
sudo cp login-screen/UserList.qml $THEME_DIR
sudo cp login-screen/Clock.qml $THEME_DIR
sudo cp login-screen/PowerButton.qml $THEME_DIR
sudo cp -r login-screen/assets/ $THEME_DIR
sudo cp login-screen/LoginForm.qml $THEME_DIR
sudo cp login-screen/SplashScreen.qml $THEME_DIR
sudo cp login-screen/theme.conf $THEME_DIR
sudo chmod -R 755 "${THEME_DIR}"
sudo cp login-screen/sddm.conf /etc/sddm.conf
sudo mkdir -p /etc/sddm.conf.d/
sudo cp login-screen/sddm.conf.d/theme.conf /etc/sddm.conf.d/
sudo ln -s /usr/bin/sddm-greeter-qt6 /usr/bin/sddm-greeter
sudo mkdir -p $THEME_DIR/$(whoami)
sudo cp assets/profile-picture.jpg $THEME_DIR/$(whoami)
sudo cp login-screen/splash_background.png $THEME_DIR
sudo systemctl restart sddm
