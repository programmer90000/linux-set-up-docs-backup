# Prompt
```
I have installed Debian 13 without a WM. I have installed Wayfire. I want to make a custom dash using Rust. I want a customisable but lightweight framework. If raw Wayland protocols are best, I would prefer to use these. I should be able to place the dash on any side of the screen. The dash should be scrollable if there are too many items. It should be an exclusive panel reserving screen space. The dash should not contain any polling. It should only use event based updates. Each widget should be made in a different file. The config file should allow me to define which widgets are displayed in the dash itself, which widgets are displayed in the Show More button and when widgets in the Show More button should be displayed on the dash. I want to add to the dash:
An app list
The current date
The current time
The caps lock key status
The number of virtual desktops
Notifications
CopyQ
A volume slider with the ability to select the input and output devices
The WiFi status
A button to display power options
Bluetooth status
MPD
Pipewire
The current keyboard layout
Wayland-Wheeltani status
A show more widgets button

There should be a config file in which I can specify which items are displayed and where. The config file should allow me to decide which monitors it should display on

For any widgets I don't have a package yet, such as notifications, write it so that the only thing I need to do is write the command to get the information
```