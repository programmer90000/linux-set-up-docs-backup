#!/bin/bash

mkdir -p ~/.config/
echo "Refreshing package list"
sudo apt update
echo "Installing curl"
sudo apt install -y curl
echo "Installing tmux"
sudo apt install -y tmux
mkdir -p ~/.config/tmux/
cp apps/config/tmux/tmux.conf ~/.config/tmux/
mkdir -p ~/.config/tmux/tmux-resurrect/
cp -r apps/config/tmux/tmux-resurrect/* ~/.config/tmux/tmux-resurrect/
chmod +x ~/.config/tmux/tmux-resurrect/scripts/*.sh
cp -r apps/config/tmux/tmux-better-mouse-mode/ ~/.config/tmux/
echo "Installing Neovim"
sudo apt install -y neovim
mkdir -p ~/.config/nvim/
cp -r apps/config/nvim/lualine/ ~/.config/nvim/
cp -r apps/config/nvim/mason/ ~/.config/nvim/
cp -r apps/config/nvim/neo-tree/ ~/.config/nvim/
cp -r apps/config/nvim/nui/ ~/.config/nvim/
cp -r apps/config/nvim/nvim-surround/ ~/.config/nvim/
cp -r apps/config/nvim/nvim-treesitter/ ~/.config/nvim/
cp -r apps/config/nvim/nvim-web-devicons/ ~/.config/nvim/
cp -r apps/config/nvim/plenary/ ~/.config/nvim/
cp -r apps/config/nvim/indent-blankline/ ~/.config/nvim/
cp -r apps/config/nvim/comment/ ~/.config/nvim/
cp -r apps/config/nvim/neominimap ~/.config/nvim/
cp -r apps/config/nvim/autopairs/ ~/.config/nvim/
cp -r apps/config/nvim/quickui/ ~/.config/nvim/
mkdir -p ~/.config/nvim/colors/
cp apps/config/nvim/colours/colour-scheme.lua ~/.config/nvim/colors/
cp apps/config/nvim/init.lua ~/.config/nvim/
echo "Installing Shotcut"
sudo apt install -y shotcut
mkdir -p ~/.config/Meltytech/
cp apps/config/Meltytech/Shotcut.conf ~/.config/Meltytech/
echo "Installing VLC Media Player"
sudo apt install -y vlc
mkdir -p ~/.config/vlc/
cp apps/config/vlc/vlcrc ~/.config/vlc/
echo "Installing Gimp Image Editor"
sudo apt install -y gimp
mkdir -p ~/.config/GIMP/3.0/
cp apps/config/GIMP/3.0/gimprc ~/.config/GIMP/3.0/
echo "Installing Thunderbird"
sudo apt install -y thunderbird
mkdir -p ~/.config/thunderbird/custom-profile/
thunderbird -CreateProfile "custom-profile $HOME/.config/thunderbird/custom-profile/"
thunderbird -P custom-profile &
sleep 3
pkill thunderbird 2>/dev/null
cp apps/config/thunderbird/addons.json ~/.config/thunderbird/custom-profile/
cp apps/config/thunderbird/extensions.json ~/.config/thunderbird/custom-profile/
cp apps/config/thunderbird/installs.ini ~/.config/thunderbird/custom-profile/
cp apps/config/thunderbird/mailViews.dat ~/.config/thunderbird/custom-profile/
cp apps/config/thunderbird/profiles.ini ~/.config/thunderbird/custom-profile/
cp apps/config/thunderbird/user.js ~/.config/thunderbird/custom-profile/
cp apps/config/thunderbird/virtualFolders.dat ~/.config/thunderbird/custom-profile/
cp apps/config/thunderbird/xulstore.json ~/.config/thunderbird/custom-profile/
echo "Installing CopyQ"
sudo apt install -y copyq
mkdir -p ~/.config/copyq/
cp apps/config/copyq/copyq.conf ~/.config/copyq/
echo "Installing Audacity"
sudo apt install -y audacity
mkdir -p ~/.config/audacity/
cp apps/config/audacity/audacity.cfg ~/.config/audacity/
echo "Installing LibreOffice"
sudo apt install -y libreoffice
mkdir -p ~/.config/libreoffice/4/user/
cp apps/config/libreoffice/registrymodifications.xcu ~/.config/libreoffice/4/user/
echo "Installing Screen Ruler"
sudo apt install -y screenruler
mkdir -p ~/.config/screenruler/
cp apps/config/screenruler/settings.yml ~/.config/screenruler/
echo "Installing GPRename"
sudo apt install -y gprename
mkdir -p ~/.config/gprename/
cp apps/config/gprename/gprename ~/.config/gprename/
echo "Installing xdg-desktop-portal-wlr"
sudo apt install -y xdg-desktop-portal-wlr
echo "Installing grim"
sudo apt install -y grim
echo "Installing slurp"
sudo apt install -y slurp
echo "Installing imagemagick"
sudo apt install -y imagemagick
echo "Installing Kooha"
sudo apt install -y kooha
echo "Installing Hardinfo2"
echo "iperf3 iperf3/start_daemon boolean false" | sudo debconf-set-selections
sudo apt install -y lm-sensors sysbench lsscsi mesa-utils dmidecode udisks2 xdg-utils iperf3 vulkan-tools gawk
sudo DEBIAN_FRONTEND=noninteractive apt install -y hardinfo2
mkdir -p ~/.config/hardinfo2/
cp apps/config/hardinfo2/settings.ini ~/.config/hardinfo2/
echo "Installing trash-cli"
sudo apt install -y trash-cli
echo "Installing wdiff"
sudo apt install -y wdiff
echo "Installing colordiff"
sudo apt install -y colordiff
echo "Installing rmlint"
sudo apt install -y rmlint
echo "Installing lnav"
sudo apt install -y lnav
echo "Installing Valgrind"
sudo apt install -y valgrind
echo "Installing Beekeeper Studio"
sudo apt install -y ca-certificates curl gpg
curl -fsSL https://deb.beekeeperstudio.io/beekeeper.key | sudo gpg --dearmor --output /usr/share/keyrings/beekeeper.gpg
sudo chmod go+r /usr/share/keyrings/beekeeper.gpg
sudo tee /etc/apt/sources.list.d/beekeeper-studio-app.sources > /dev/null << EOF
Types: deb
URIs: https://deb.beekeeperstudio.io
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/beekeeper.gpg
EOF
sudo apt update
sudo apt install -y beekeeper-studio
echo "Installing dunst"
sudo apt install -y dunst
echo "Installing libnotify-bin"
sudo apt install -y libnotify-bin
echo "Installing KeePassXc"
sudo apt install -y keepassxc-full
echo "Installing QEMU/KVM"
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients virtinst bridge-utils
echo "Installing Extrepo"
sudo apt install -y extrepo
sudo cp apps/config.yaml /etc/extrepo/config.yaml
echo "Installing Brave Browser"
sudo extrepo enable brave_release
sudo apt update
sudo apt install -y brave-browser
mkdir -p ~/.config/BraveSoftware/Brave-Browser/Default/
cp "apps/config/brave/Local State" ~/.config/BraveSoftware/Brave-Browser/
cp apps/config/brave/Preferences ~/.config/BraveSoftware/Brave-Browser/Default/
cp apps/config/brave/Bookmarks ~/.config/BraveSoftware/Brave-Browser/Default/
echo "Installing Vivaldi browser"
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg
echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo dd of=/etc/apt/sources.list.d/vivaldi-archive.list
sudo apt update
sudo apt install -y vivaldi-stable
echo "Installing LibreWolf browser"
sudo extrepo enable librewolf
sudo extrepo update librewolf
sudo apt update
sudo apt install librewolf -y
mkdir -p ~/.config/librewolf/librewolf/
cp apps/config/librewolf/librewolf.overrides.cfg ~/.config/librewolf/librewolf/
echo "Installing man pages"
sudo apt install -y man-db manpages manpages-dev manpages-posix manpages-posix-dev
