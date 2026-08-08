# Installation Docs for Debian

## Install Git

Run:
```
sudo apt update
sudo apt install git
```

## Clone and change directory into this repository

Run:
```
git clone https://github.com/programmer90000/linux-set-up-docs.git
cd linux-set-up-docs/
```

> All SH files in this repository should be run from the root of the Linux Set Up Docs directory

## Connect to Git accounts

Run:
```
chmod +x git/connect-to-online-git-accounts.sh
./git/connect-to-online-git-accounts.sh
```

Follow the docs in [connect-to-online-git-accounts.md](./git/connect-to-online-git-accounts.md)

## Install Alacritty

Run:
```
chmod +x alacritty/alacritty.sh
./alacritty/alacritty.sh
```

> **Do this before installing a window manager**

## Install Boot Theme

Run:
```
chmod +x boot-theme/grub-theme/install-grub-theme.sh boot-theme/plymouth-theme/install-plymouth-theme.sh
./boot-theme/grub-theme/install-grub-theme.sh
./boot-theme/plymouth-theme/install-plymouth-theme.sh
```

## Install Labwc Window Manager

Run:
```
chmod +x labwc/labwc.sh
./labwc/labwc.sh
```

## Install Desktop

Run:
```
chmod +x desktop/install-desktop.sh
./desktop/install-desktop.sh
```

## Install Apps

Run:
```
chmod +x apps/installing-apps.sh apps/get-and-install.sh
./apps/installing-apps.sh
./apps/get-and-install.sh
```

Follow the docs in [apps/config/set-up-individual-apps.md](apps/set-up-individual-apps.md)

## Install Login Screen

Run:
```
chmod +x login-screen/install-login-screen.sh
./login-screen/install-login-screen.sh
```
