#!/bin/bash
set -eu

dir="$HOME/media/Screenshots"
mkdir -p "$dir"

file="$dir/screenshot-$(date +%Y%m%d-%H%M%S).png"

grim -g "$(slurp)" "$file"
