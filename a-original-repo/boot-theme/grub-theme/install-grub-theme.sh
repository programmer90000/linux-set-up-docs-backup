#!/bin/bash

set -e # Exit the script on error

BASE_DIR="./boot-theme/grub-theme"
BACKGROUND_IMAGE="${BASE_DIR}/background.png"
COMMON_DIR="${BASE_DIR}/common"
CONFIG_DIR="${BASE_DIR}/config"
ASSETS_DIR="${BASE_DIR}/assets"
ICONS_DIR="${ASSETS_DIR}/icons"
SELECT_DIR="${ASSETS_DIR}/select"

GRUB_DIR="/etc/default/"
GRUB_FILE="${BASE_DIR}/../grub"


COMMON_FILES=(
    "terminal_box_c.png"
    "terminal_box_e.png"
    "terminal_box_ne.png"
    "terminal_box_n.png"
    "terminal_box_nw.png"
    "terminal_box_se.png"
    "terminal_box_s.png"
    "terminal_box_sw.png"
    "terminal_box_w.png"
)
SELECT_FILES=(
    "select_c.png"
    "select_e.png"
    "select_w.png"
)
ICON_FILES=(
    "debian.png"
    "efi.png"
    "find.none.png"
    "gnu-linux.png"
    "kernel.png"
    "linux.png"
    "unknown.png"
)
THEME_DIR="/usr/share/grub/themes"
THEME_NAME='gradient'

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root or with sudo."
    echo "Please run it as a regular user."
    exit 1
fi

if [[ ! -f "/etc/debian_version" ]]; then
    echo "Error: This script is made for Debian-based systems"
    echo -e "Distribution detected: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo 'Unknown OS')"
    exit 1
fi

if [ ! -f "$GRUB_FILE" ]; then
    echo "Error: Grub file '$GRUB_FILE' not found."
    echo "Please ensure the file exists in the correct location."
    exit 1
fi

if [ ! -f "$BACKGROUND_IMAGE" ]; then
    echo "Error: Background image file '$BACKGROUND_IMAGE' not found."
    echo "Please ensure the file exists in the correct location."
    exit 1
fi

for file in "${COMMON_FILES[@]}"; do
    if [ ! -f "${COMMON_DIR}/${file}" ]; then
        echo "Error: Required file '${COMMON_DIR}/${file}' not found."
        exit 1
    fi
done

for file in "${SELECT_FILES[@]}"; do
    if [ ! -f "${SELECT_DIR}/${file}" ]; then
        echo "Error: Required file '${SELECT_DIR}/${file}' not found."
        exit 1
    fi
done

for file in "${ICON_FILES[@]}"; do
    if [ ! -f "${ICONS_DIR}/${file}" ]; then
        echo "Error: Required file '${ICONS_DIR}/${file}' not found."
        exit 1
    fi
done

if [ ! -f "${CONFIG_DIR}/theme.txt" ]; then
    echo "Error: Required file '${CONFIG_DIR}/theme.txt' not found."
    exit 1
fi

echo -e "\n Checking for the existence of themes directory..."

# Remove existing theme if present
[[ -d "${THEME_DIR}/${THEME_NAME}" ]] && sudo rm -rf "${THEME_DIR}/${THEME_NAME}"
sudo mkdir -p "${THEME_DIR}/${THEME_NAME}"

# Copy theme
echo -e "\n Installing ${THEME_NAME} theme..."

# Don't preserve ownership. The owner is root
sudo cp -a --no-preserve=ownership "$GRUB_FILE" "$GRUB_DIR"
sudo cp -a --no-preserve=ownership "$BACKGROUND_IMAGE" "${THEME_DIR}/${THEME_NAME}/background.png"

for file in "${COMMON_FILES[@]}"; do
    sudo cp -a --no-preserve=ownership "${COMMON_DIR}/${file}" "${THEME_DIR}/${THEME_NAME}/"
done

sudo cp -a --no-preserve=ownership "${CONFIG_DIR}/theme.txt" "${THEME_DIR}/${THEME_NAME}/theme.txt"

sudo mkdir -p "${THEME_DIR}/${THEME_NAME}/icons"
for file in "${ICON_FILES[@]}"; do
    sudo cp -a --no-preserve=ownership "${ICONS_DIR}/${file}" "${THEME_DIR}/${THEME_NAME}/icons/"
done

for file in "${SELECT_FILES[@]}"; do
    sudo cp -a --no-preserve=ownership "${SELECT_DIR}/${file}" "${THEME_DIR}/${THEME_NAME}/"
done

echo -e "\n Updating grub config... \n"
sudo /usr/sbin/grub-mkconfig -o /boot/grub/grub.cfg