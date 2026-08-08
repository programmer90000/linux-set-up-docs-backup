# Installing Debian

## Download Debian ISO

Go to the [Debian Installation page](https://www.debian.org/distrib/netinst)

Download the correct `iso` file for your system architecture

## Create Bootable USB

Copy the .iso file onto a USB stick using a tool like:

Rufus (Windows)

balenaEtcher (Linux/macOS/Windows)

dd command (Linux/macOS - use with caution)

> If the USB drive can't be flashed, use a tool like GParted to format it first

## Boot From USB

Insert the USB into the target computer

Power on the computer

Enter the BIOS/UEFI (usually by pressing Del, F2, or Esc right after turning on the machine)

Change the boot order to set the USB/DVD as the first boot device

Save and exit BIOS/UEFI

## Start Installtion

When the boot menu appears, choose Install

Press Enter to begin

## Select Locale Options

Choose:

* Language

* Location (for timezone)

* Keyboard layout

## Configure Network

* Ethernet: Should auto-configure via DHCP.

* Wi-Fi:

  * Select your SSID

  * Enter the Wi-Fi password

  * Set:

    * Hostname (e.g., debian) **The hostname is what the computer will be known as on the network**

    * Domain name (optional)

## Set Up Users

Set a root password

(You can skip this for a sudo-only setup)

Create a regular user account for daily use.

## Disk Partitioning

Choose a partitioning method:

Guided – use entire disk (erases everything)

Manual (advanced, allows dual boot, LVM, encryption, etc.)

For encryption or LVM, select the appropriate guided option.

## Install the Base System

Installer will copy core Debian files to your disk.

Wait for the process to complete (can take several minutes).

## Configure Package Manager

Choose a nearby mirror for package downloads.

Enable network mirror (recommended)

## Software Selection
Select `Standard System Utilities`

Uncheck all other options by pressing the spacebar

## Install GRUB Bootloader
Choose Yes to install GRUB.

Select target device (usually /dev/sda or your main drive).

## Finish Installation
Remove the USB installation media when prompted.

Reboot into your new Debian system.