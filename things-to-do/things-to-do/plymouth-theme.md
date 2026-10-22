Use this repo to make the boot theme: https://github.com/mrtxee/arch-plymouth-themes

If it doesn't work, try a different plymouth theme online.

Use the Debian section of the README file to install it

I have written the response Gemini gave below:

What is it?

The link ([https://github.com/mrtxee/arch-plymouth-themes/tree/main/arch-boot-dots](https://github.com/mrtxee/arch-plymouth-themes/tree/main/arch-boot-dots)) points to a custom graphical boot splash theme for Plymouth (a software used in Linux to show a graphical animation/logo during system boot and shutdown). Specifically, arch-boot-dots is themed around the Arch Linux aesthetic (utilizing dot animations and Arch branding).

Will it work on Debian 13?

Yes. Plymouth is completely distribution-agnostic. The underlying code of a Plymouth theme consists of a configuration file (.plymouth) and an initialization script written in a simple scripting language (.script) alongside image assets (usually PNG files). Debian 13 supports Plymouth fully, so the theme engine will run fine.

Can I replace the image with the Debian logo?

Yes, absolutely. You can replace any background or logo image asset inside the theme folder with a Debian logo.

* Note on formatting: Plymouth usually expects images to be in PNG format (ideally with a transparent background). Ensure your Debian logo image matches the dimensions or layout expected by the theme script, or modify the .script file if your image size is drastically different.

What will you need?

Since you installed Debian 13 without a Desktop Environment (DE), you will be interacting entirely via the command line. You will need:

* Plymouth and its core packages installed via APT.
* Git (to clone the repository) or a way to download the files.
* An image editing tool or utility if you want to convert/resize a Debian logo PNG (though you can prepare the logo on another machine or transfer it over, or use standard CLI tools if needed).
* Superuser (root) privileges (via sudo or logged in as root).

Step-by-Step Commands to Run in Order

Open your terminal and run the following commands sequentially:

Step 1: Install Plymouth and Git
Update your package lists and install Plymouth along with the default text/details renderers and Git:
```
sudo apt update
sudo apt install plymouth plymouth-themes git
```

Step 2: Clone the Repository

Download the theme repository to your local machine:
```
git clone https://github.com/mrtxee/arch-plymouth-themes.git
```

Step 3: Navigate to the Theme Directory

Move into the specific theme folder:
```
cd arch-plymouth-themes/arch-boot-dots
``|

Step 4: Replace/Add the Debian Logo (Optional Customization)

If the theme contains an Arch logo image file (e.g., arch-logo.png or similar depending on the exact folder layout), you can replace it with your own Debian PNG logo.

* If you name your Debian logo file to match the theme's expected asset filename (e.g., overwriting the existing logo asset):
```
# Assuming your debian logo is saved somewhere as 'debian-logo.png'
cp /path/to/your/debian-logo.png ./logo.png
# (Replace 'logo.png' with whatever image filename the theme script references)
```

* Check the .script or .plymouth file using a text editor like nano if you are unsure which image file name it references:
```
nano arch-boot-dots.script
```

Step 5: Install the Theme into Plymouth's Theme Directory

Plymouth themes live in /usr/share/plymouth/themes/. Create a directory for your custom theme and copy the files there:
```
sudo mkdir -p /usr/share/plymouth/themes/arch-boot-dots
sudo cp -r * /usr/share/plymouth/themes/arch-boot-dots/
```

(Optional: You may want to rename the folder path or configuration file to debian-boot-dots to keep things tidy, and update the theme name inside the .plymouth configuration file accordingly).

Step 6: Register and Set the Theme as Default
Tell Plymouth to use your newly added theme:
```
sudo plymouth-set-default-theme -R arch-boot-dots
```

(The -R flag automatically rebuilds your initramfs so Plymouth can load early during the boot process).

Step 7: Update GRUB Bootloader Parameters

For Plymouth to display correctly during boot without being overwritten by early kernel messages, you need to configure your kernel command line in GRUB.
* Open the GRUB configuration file:
```
sudo nano /etc/default/grub
```

* Find the line starting with `GRUB_CMDLINE_LINUX_DEFAULT`. It usually looks like this:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
```

* Change it to include splash (and optionally quiet splash):
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

* Save and exit (in nano, press Ctrl+O, Enter, then Ctrl+X).

Step 8: Update GRUB and Reboot

Apply your GRUB changes and restart your system to see your new Plymouth boot screen:
```
sudo update-grub
sudo reboot
```

| Feature | Done |
|---------|-----------|
| Cause errors to show above the Plymouth theme | ❌ |
| Update the Plymouth theme to display the text Debian 13 | ❌ |
| Update the Plymouth theme to display the Debian logo | ❌ |