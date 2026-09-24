# Files to make the screenshot

Make these files in `~/.config/labwc/scripts`

Full-screen screenshot:
```bash
#!/usr/bin/env bash
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

grim "$FILE"

# Optional: copy path to clipboard if wl-copy is installed
if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$FILE" | wl-copy
fi

# Optional: notify if notify-send / mako is present
if command -v notify-send >/dev/null 2>&1; then
    notify-send "Screenshot saved" "$FILE"
fi
```

Region screenshot:
```bash
#!/usr/bin/env bash
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

# slurp returns a geometry; grim captures it
if ! GEOM=$(slurp); then
    exit 0   # user cancelled
fi

grim -g "$GEOM" "$FILE"

if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$FILE" | wl-copy
fi

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Screenshot saved" "$FILE"
fi
```

# Make the top bar which allows me to switch between different screenshot modes
Option A: Yad (recommended — real buttons)

Install:

```bash
sudo apt install yad
```

Panel script ~/.local/bin/screenshot-panel:

```bash
#!/usr/bin/env bash
set -euo pipefail

CHOICE=$(yad --title="Screenshot" \
    --window-icon=applets-screenshooter \
    --borders=10 \
    --center \
    --on-top \
    --skip-taskbar \
    --buttons-layout=center \
    --button="Full Screen!video-display:1" \
    --button="Select Region!edit-select-all:2" \
    --button="Cancel!gtk-cancel:3" \
    --text="Choose a screenshot mode" \
    --width=340 \
    ) || exit 0

case "$CHOICE" in
    1) exec "$HOME/.local/bin/screenshot-full" ;;
    2) exec "$HOME/.local/bin/screenshot-region" ;;
    *) exit 0 ;;
esac
```

Note: I used --center because positioning yad at the top of the screen in Wayland is unreliable — the compositor decides placement. If you're on LabWC and yad has no layer-shell support, --center is the safe default. If you really need it top-anchored, the wofi/rofi approach below lets you control placement via CSS.

If you want a true top bar, you could instead use fuzzel with a --anchor=top flag (see Option C).

Option B: Wofi dmenu

If you already use wofi:

```bash
#!/usr/bin/env bash
set -euo pipefail

CHOICE=$(printf '%s\n' "Full Screen" "Select Region" \
    | wofi --dmenu --prompt "Screenshot:" \
           --width 320 --height 120 --insensitive --cache-file /dev/null) || exit 0

case "$CHOICE" in
    "Full Screen")  exec "$HOME/.local/bin/screenshot-full" ;;
    "Select Region") exec "$HOME/.local/bin/screenshot-region" ;;
esac
```

Option C: Fuzzel (nice, natively anchored to top)

fuzzel supports layer-shell anchoring, which is what you want for a "panel at the top":

```bash
#!/usr/bin/env bash
set -euo pipefail

CHOICE=$(printf '%s\n' "Full Screen" "Select Region" \
    | fuzzel --dmenu --prompt "Screenshot: " \
             --anchor top --lines 2 --width 30) || exit 0

case "$CHOICE" in
    "Full Screen")  exec "$HOME/.local/bin/screenshot-full" ;;
    "Select Region") exec "$HOME/.local/bin/screenshot-region" ;;
esac
```

Make the panel script executable:

```bash
chmod +x ~/.local/bin/screenshot-panel
```

# Keyboard Shortcut
Add this to `rc.xml`:
```
<keybind key="Print">
    <action name="Execute" command="~/.config/labwc/scripts/screenshot-panel" />
</keybind>
```