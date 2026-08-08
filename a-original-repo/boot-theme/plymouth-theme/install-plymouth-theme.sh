#!/bin/bash
set -e

BASE_DIR="./boot-theme/plymouth-theme/"

THEME_NAME="custom-progress-theme"
THEME_DIR="/usr/share/plymouth/themes/$THEME_NAME"

BACKGROUND_IMAGE="${BASE_DIR}/background.png"
DEBIAN_LOGO="${BASE_DIR}/debian-logo.png"
DEBIAN_TEXT="${BASE_DIR}/debian-text.png"
PROGRESS_BOX="${BASE_DIR}/progress_box.png"
PROGRESS_FILL="${BASE_DIR}/progress_fill.png"
PLYMOUTH_SCRIPT="${BASE_DIR}/custom-progress-theme.script"
PLYMOUTH_FILE="${BASE_DIR}/custom-progress-theme.plymouth"
GRUB_FILE="${BASE_DIR}../grub"

REQUIRED_FILES=(
    ../grub
    "background.png"
    "debian-logo.png"
    "debian-text.png"
    "progress_box.png"
    "progress_fill.png"
    "custom-progress-theme.script"
    "custom-progress-theme.plymouth"
)

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root or with sudo."
    echo "Please run it as a regular user."
    exit 1
fi

if [ ! -d "$BASE_DIR" ]; then
    echo "Error: Directory '$BASE_DIR' not found."
    echo "Please ensure you are in the correct location and the boot-theme/plymouth-theme directory exists."
    exit 1
fi

echo -e "\n Checking for required files..."
for file in "${REQUIRED_FILES[@]}"; do
    file_path="${BASE_DIR}/${file}"
    if [ ! -f "$file_path" ]; then
        echo "Error: Required file '$file_path' not found."
        echo "Please ensure all theme files are present in $BASE_DIR"
        exit 1
    fi
done

if [[ ! -f "/etc/debian_version" ]]; then
    echo "Error: This script is made for Debian-based systems"
    echo -e "Distribution detected: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo 'Unknown OS')"
    exit 1
fi

sudo apt update
sudo apt install -y plymouth plymouth-themes
sudo mkdir -p "$THEME_DIR"

sudo cp -a --no-preserve=ownership "${BASE_DIR}/background.png" "${THEME_DIR}/"
sudo cp -a --no-preserve=ownership "${BASE_DIR}/debian-logo.png" "${THEME_DIR}/"
sudo cp -a --no-preserve=ownership "${BASE_DIR}/debian-text.png" "${THEME_DIR}/"
sudo cp -a --no-preserve=ownership "${BASE_DIR}/progress_box.png" "${THEME_DIR}/"
sudo cp -a --no-preserve=ownership "${BASE_DIR}/progress_fill.png" "${THEME_DIR}/"
sudo cp -a --no-preserve=ownership "${BASE_DIR}/custom-progress-theme.script" "${THEME_DIR}/"
sudo cp -a --no-preserve=ownership "${BASE_DIR}/custom-progress-theme.plymouth" "${THEME_DIR}/"
sudo cp "$GRUB_FILE" /etc/default/grub

sudo plymouth-set-default-theme "$THEME_NAME"
sudo update-initramfs -u
sudo update-grub
