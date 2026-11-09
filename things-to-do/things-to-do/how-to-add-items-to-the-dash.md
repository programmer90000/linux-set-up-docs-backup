# Date/ Time:

~/.config/sfwbar/datetime.widget:
```
Module("clock")

layout {
grid "datetime_container" {
label "date_label" {
value = Time("%a, %b %d")
style = "date_text"
}
label "time_label" {
value = Time("%H:%M")
style = "time_text"
}
}
}
```

sfwbar.config:
```
# Load your widget into the bar layout
layout "sfwbar" {
# ... other widgets ...

include("datetime.widget")
}

# --- CONFIGURATION & STYLING ---
css {
/* 1. LAYOUT DIRECTION */
/* Set to 'column' for vertical (date on top, time below) */
/* Set to 'row' for horizontal (date next to time) */
grid#datetime_container {
grid-auto-flow: column;
align-items: center;
justify-content: center;
}

/* 2. DATE FONT AND SIZE */
label#date_label {
font-family: "Sans";
font-size: 11px;
font-weight: bold;
color: #a6adc8;
}

/* 3. TIME FONT AND SIZE */
label#time_label {
font-family: "Monospace";
font-size: 14px;
font-weight: bold;
color: #cdd6f4;
}
}
```

# Caps Lock Status:

~/.config/sfwbar/capslock.widget:
```
# capslock.widget

# Set configurable defaults (overridden if set in sfwbar.config)
Set $CapsLock_ShowDisabled = "false" if $CapsLock_ShowDisabled == ""
Set $CapsLock_IconOn = "caps-lock-on" if $CapsLock_IconOn == ""
Set $CapsLock_IconOff = "caps-lock-off" if $CapsLock_IconOff == ""

layout {
image {
style = "capslock_icon"

# 1. Update icon dynamically based on state
value = $CapsLock ? $CapsLock_IconOn : $CapsLock_IconOff

# 2. Control visibility without polling
# Hides element entirely when disabled IF $CapsLock_ShowDisabled is "false"
loc_x = ($CapsLock || $CapsLock_ShowDisabled == "true") ? 0 : -10000

# Tooltip for user status
tooltip = $CapsLock ? "Caps Lock: ON" : "Caps Lock: OFF"
}
}
```

sfwbar.config:
```
# --- Caps Lock Widget Configuration ---

# 1. Choose if icon appears when Caps Lock is OFF ("true" or "false")
Set $CapsLock_ShowDisabled = "false"

# 2. Define icon for Caps Lock ON (Icon name or absolute path)
Set $CapsLock_IconOn = "caps-lock-on"

# 3. Define icon for Caps Lock OFF
Set $CapsLock_IconOff = "caps-lock-off"

# --- Main Bar Layout ---
layout "sfwbar" {
include("taskbar.widget")

label { style = "spacer" }

# Include the custom event-driven widget
include("capslock.widget")

include("clock.widget")
}
```

sfwbar.css:
```
image#capslock_icon {
min-width: 18px;
min-height: 18px;
padding: 0 6px;
}
```

# Virtual Desktops:

~/.config/sfwbar/desktops.widget:
```
# --- 1. Load Workspace Data ---
# LabWC exposes workspaces via wlr-foreign-toplevel / pager module
Module("pager")

# Default visibility toggle ($ShowIfEmpty: 1 = Show when 0/1 desktop, 0 = Hide)
Set $ShowIfEmpty = 0

# --- 2. Interactive Management Popup Window ---
popup "desktop_manager" {
style = "desktop_popup"

layout {
label {
value = "LabWC Virtual Desktops"
style = "popup_title"
}

# Visual LabWC Workspace Pager Grid
pager {
style = "popup_pager"
rows = 1
pins = ["1", "2", "3", "4"]
}

# LabWC Workspace Control Buttons
grid {
style = "popup_actions"

button {
value = "Go To Next"
style = "action_btn"
# Switch to next desktop in LabWC
action[1] = Exec "wlrctl window focus desktop next"
}

button {
value = "+ Create Desktop"
style = "action_btn"
# Prompts for name & switches to a new workspace using LabWC IPC/Zenity
action[1] = Exec "zenity --entry --title='New LabWC Workspace' --text='Workspace Name:' | xargs -I {} labwc --action GoToDesktop {}"
}

button {
value = "Rename Current"
style = "action_btn"
action[1] = Exec "zenity --entry --title='Rename' --text='New Name:' | xargs -I {} labwc --action SetDesktopName {}"
}
}
}
}

# --- 3. Bar Widget Definition ---
layout {
label {
# Hide widget when workspace count <= 1 and $ShowIfEmpty is 0
style = ($PagerWorkspaces <= 1 && $ShowIfEmpty == 0) ? "hidden_widget" : "desktop_widget"

# Show desktop icon and count
value = "󰍹 " + Str($PagerWorkspaces) + " Desktops"
tooltip = "Click to manage LabWC workspaces"

# Toggle Popup Window above widget on Left-Click
action[1] = SfwbarCmd "PopUp desktop_manager"
}
}
```

~/.config/sfwbar/sfwbar.config:
```
# --- Global Configuration Variables ---
# Set to 1: Widget ALWAYS shows
# Set to 0: Widget HIDES when there are no extra virtual desktops (<= 1)
Set $ShowIfEmpty = 0

layout "sfwbar" {
include("taskbar.widget")

label { style = "spacer" }

# Virtual Desktops Widget for LabWC
include("desktops.widget")

include("clock.widget")
}
```

~/.config/sfwbar/sfwbar.css:
```
/* Hide widget when 0/1 desktop exists and toggle is OFF */
label#hidden_widget {
display: none;
}

/* Main bar label */
label#desktop_widget {
padding: 0 8px;
color: #cdd6f4;
font-weight: bold;
}

/* Floating Management Window */
window#desktop_popup {
background-color: #1e1e2e;
border: 1px solid #45475a;
border-radius: 8px;
padding: 12px;
min-width: 280px;
}

label#popup_title {
font-size: 14px;
font-weight: bold;
color: #89b4fa;
margin-bottom: 8px;
}

button.action_btn {
background-color: #313244;
color: #cdd6f4;
border-radius: 4px;
padding: 6px 10px;
margin: 3px;
}

button.action_btn:hover {
background-color: #45475a;
}
```

# Volume:

~/.config/sfwbar/volume.widget:
```
# Load the native Sfwbar volume module (uses PipeWire / PulseAudio)
Module("volume")

# 1. Define the Pop-Up Window (Slider + Mute Button)
popup "vol_popup" {
    style = "volume_popup_window"

    layout {
        # Volume Percentage Label
        label {
            value = Str($Volume) + "%"
            style = "vol_popup_label"
        }

        # Volume Slider
        scale {
            value = $Volume / 100
            style = "vol_slider"
            # Dragging or clicking the slider updates the system volume
            action = Exec "pamixer --set-volume " + Str($Value * 100)
        }

        # Mute Toggle Button inside the Pop-up
        button {
            value = $SetMuteIcon
            style = "vol_popup_mute_btn"
            action[1] = Exec "pamixer -t"
        }
    }
}

# 2. Main Bar Widget Definition
layout {
    label {
        # Select icon based on mute status or current volume level
        value = $Muted ? $SetMuteIcon : ( \
            $Volume == 0 ? $SetIconMute : ( \
            $Volume < 33  ? $SetIconLow  : ( \
            $Volume < 66  ? $SetIconMed  : $SetIconHigh )))

        style = "vol_bar_icon"
        tooltip = "Volume: " + Str($Volume) + "%"

        # Left Click: Toggle Pop-Up Window directly above the widget
        action[1] = SfwbarCmd "PopUp vol_popup"

        # Scroll Up/Down: Change Volume directly from the bar icon
        action[4] = Exec "pamixer -i 5"
        action[5] = Exec "pamixer -d 5"
    }
}
```

~/.config/sfwbar/sfwbar.config:
```
# --- Volume Widget Settings ---
# Customize your icons here (Nerd Font icons or Unicode characters)
Set $SetIconLow  = "󰕿"
Set $SetIconMed  = "󰖀"
Set $SetIconHigh = "󰕾"
Set $SetIconMute = "󰝟"
Set $SetMuteIcon = "󰝟"

# Include the volume widget in your main bar layout
layout "sfwbar" {
    # ... other widgets (e.g. taskbar) ...

    label { style = "spacer" }

    include("volume.widget")
}

# --- Pop-up Dimensions & Styling ---
css {
    /* Define the Pop-Up Window Dimensions */
    window#volume_popup_window {
        background-color: #1e1e2e;
        border: 1px solid #45475a;
        border-radius: 8px;
        padding: 10px;

        /* Adjust width and height of the pop-up window here */
        min-width: 180px;
        min-height: 120px;
    }

    label#vol_popup_label {
        font-weight: bold;
        color: #cdd6f4;
        margin-bottom: 5px;
    }

    scale#vol_slider {
        margin: 8px 0px;
    }

    button#vol_popup_mute_btn {
        padding: 4px 8px;
        background-color: #313244;
        border-radius: 4px;
        color: #f38ba8;
    }

    label#vol_bar_icon {
        font-size: 16px;
        padding: 0px 8px;
    }
}
```

Note: If this doesn't work, run:
```
sudo apt install pamixer
```

# WiFi:

~/.config/sfwbar/scripts/wifi-monitor.sh:
```
#!/bin/sh
# Event-driven monitor using NetworkManager's monitor mode

update_sfwbar() {
    # Extract current Wi-Fi status via nmcli
    CON_INFO=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes:')
    if [ -n "$CON_INFO" ]; then
        SSID=$(echo "$CON_INFO" | cut -d: -f2)
        SIGNAL=$(echo "$CON_INFO" | cut -d: -f3)
    else
        SSID=""
        SIGNAL=0
    fi
   
    # Send variables directly into SFWBar via client IPC
    sfwbar-msg "Set \$WifiSSID=\"$SSID\""
    sfwbar-msg "Set \$WifiSignal=$SIGNAL"
}

# Run once at startup
update_sfwbar

# Listen to NetworkManager event stream (Zero CPU usage when idle)
nmcli monitor | while read -r line; do
    case "$line" in
        *primary-connection*|*connectivity*|*WLAN*)
            update_sfwbar
            ;;
    esac
done
```

~/.config/sfwbar/wifi.widget:
```
# --- Wi-Fi Event Signal Receiver ---
# Runs the monitor script asynchronously on startup
Exec "killall -q wifi-monitor.sh; ~/.config/sfwbar/scripts/wifi-monitor.sh &"

# --- Popup Flyout Window ---
popup "wifi_popup" {
    style = "wifi_popup_window"

    layout {
        label {
            style = "wifi_popup_header"
            value = $WifiSSID != "" ? "Connected to: " + $WifiSSID : "Disconnected"
        }

        # Terminal network picker for selecting networks and entering passwords
        # Triggered directly within the flyout window frame
        grid {
            cols = 1
            button {
                value = "Scan & Connect to Wi-Fi"
                action[1] = Exec "kitty --class=wifi_picker -e nmtui-connect"
            }
        }
    }
}

# --- Status Bar Widget ---
layout {
    image {
        style = "wifi_icon"
       
        # Dynamically set icon based on signal level ranges
        value = $WifiSignal == 0 ? $WifiIconOff : \
               ($WifiSignal < 25 ? $WifiIconLow : \
               ($WifiSignal < 60 ? $WifiIconMid : \
               ($WifiSignal < 85 ? $WifiIconHigh : $WifiIconFull)))

        tooltip = $WifiSSID != "" ? $WifiSSID + " (" + Str($WifiSignal) + "%)" : "Disconnected"

        # Left click opens the popup directly above the widget
        action[1] = SfwbarCmd "PopUp wifi_popup"
    }
}
```

~/.config/sfwbar/sfwbar.config:
```
# --- Wi-Fi Icon Configuration ---
# Customize your icons here (Freedesktop icon names or direct paths)
Set $WifiIconOff  = "network-wireless-offline-symbolic"
Set $WifiIconLow  = "network-wireless-signal-weak-symbolic"
Set $WifiIconMid  = "network-wireless-signal-ok-symbolic"
Set $WifiIconHigh = "network-wireless-signal-good-symbolic"
Set $WifiIconFull = "network-wireless-signal-excellent-symbolic"

# --- Main Layout ---
layout "sfwbar" {
    # Include other widgets...
   
    label { style = "spacer" }

    # Include your custom Wi-Fi widget
    include("wifi.widget")
}

# --- GTK Styling and Popup Sizing ---
css {
    /* Define popup dimensions and styling */
    window#wifi_popup_window {
        background-color: #1e1e2e;
        border: 1px solid #45475a;
        border-radius: 8px;
        padding: 10px;
       
        /* Configure Popup Window Size */
        min-width: 280px;
        min-height: 180px;
    }

    label#wifi_popup_header {
        font-weight: bold;
        color: #cdd6f4;
        margin-bottom: 8px;
    }

    image#wifi_icon {
        padding: 0 6px;
    }
}
```

~/.config/labwc/rc.xml:
```
<windowRules>
  <windowRule identifier="wifi_picker">
    <action name="Float"/>
    <action name="ResizeTo" width="500" height="400"/>
    <action name="MoveTo" x="center" y="center"/>
  </windowRule>
</windowRules>
```

Note: If nmcli isn't installed

Run:
```
sudo apt update
sudo apt install network-manager
sudo systemctl enable --now NetworkManager
```

If NetworkManager says an interface is "unmanaged", check `/etc/NetworkManager/NetworkManager.conf` and set:
```
managed=true:
[ifupdown]
managed=true
```

Then restart the service:
```
sudo systemctl restart NetworkManager
```

Verify nmcli is working:
```
nmcli device status
```