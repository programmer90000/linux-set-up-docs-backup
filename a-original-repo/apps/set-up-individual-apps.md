# Set Up Individual Apps

## KeePassXc

1. Click `Create Database`
2. Set the name to `Passwords`
3. Click `Continue`
4. Set the `Database format` to the recommended option
5. Set the `Encryption Settings` to `Basic`. Do **not** change any `Advanced` settings
6. Set the `Decryption Time` to `1.0 sec`
7. Select `Continue`
8. Set the `Password` to a strong password different to your user password
9. Select `Add additional protection...`
10. Select `Add Key File`
11. Select `Generate`
12. Set it to `~/.config/keepassxc/passwords.keyx`
13. Select `Done`
14. Save the database as `~/.config/keepassxc/Passwords.kdbx`
15. Go to `Settings > Browser integration`
16. Enable `Browser Integration`
17. Enable `Brave`
18. For each website, create a new password. Set the `Title`, `Username`, `Password` and `URL`
19. Press `Ok`
20. Open `Brave browser`
21. Go to the `Extensions` page
22. Install the `KeePassXC-Browser` extension by `https://keepassxc.org/`. The publisher should have a tick before the name. Hovering over the name should reveal the message: `Created by the owner of the listed website. The publisher has a good record with no history of violations.`
23. Click `Add to Brave`
24. Click on the extension
25. Click `Connect`
26. Set the name of the connection to `brave-browser`
27. Open each website
28. This should open `Keepassxc`. Enable `Remember`. Click `Allow Selected`
29. When asked to save the password in Brave browser, select `Never`

TEMP DOCS: AFTER THIS, RUN `./APPS/CONFIG/KEEPASSXC/INSTALL.SH`. I STILL NEED TO WRITE THIS FILE PROPERLY. RUN `CHMOD +X` AND THEN RUN IT WITH NORMAL USER PRIVLIGES. AFTER THIS, RUN: `sudo keepassxc-unlock-setup $USER ~/.config/keepassxc/Passwords.kdbx`

## Thunderbird

- Go to `Settings > Add-ons and Themes > Themes`
- Enable `Dark` theme
- Login to all email accounts

## QEMU/ KVM

1. Run:
```
virt-install --name debian-13 --memory 2048 --vcpus 1 --disk size=3,format=qcow2 --os-variant=debian13 --cdrom /home/abdul/Downloads/debian-13.5.0-amd64-netinst.iso --network default --graphics vnc,listen=127.0.0.1,port=5901 --noautoconsole
```
Change the name, memory, vcpus, disk size, OS variant, cdrom and listen appropriately

2. Follow the docs in [../installation.md] to create the VM. Set the `hostname` to `are-debian-13-vm` or another appropriate hostname. Set the `Full name` to `Password Is Admin`. Set the `Username` to `password-is-admin`. Set the `Password` to `admin`. Set the `Partitioning method` to `Guided - use entire disk`. Select `Yes` when asked to install the GRUB boot loader. Set the device to the device shown. Do not manually enter a device.
