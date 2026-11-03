#!/bin/bash
set -eu

CHOICE=$(printf '%s\n' "Full Screen" "Select Region" | wofi --dmenu --prompt "Screenshot:" --define=hide_search=true --columns 2 --location top --width 200 --height 33 --insensitive --cache-file /dev/null) || exit 0

case "$CHOICE" in
    "Full Screen")  exec "$HOME/media/screenshot.sh" ;;
    "Select Region") exec "$HOME/media/screenshot.sh" ;;
esac
