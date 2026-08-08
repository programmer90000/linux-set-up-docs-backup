#!/bin/bash

ENVIRONMENT="labwc/environment"

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

echo "Installing Labwc"
sudo apt update
sudo apt install -y labwc
echo "Setting keyboard layout"
mkdir ~/.config/labwc/
cp $ENVIRONMENT ~/.config/labwc/
echo "Copying rc.xml file"
cp labwc/rc.xml ~/.config/labwc/
