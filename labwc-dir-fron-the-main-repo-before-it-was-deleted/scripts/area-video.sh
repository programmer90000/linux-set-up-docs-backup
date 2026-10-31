#!/bin/bash
set -eu

dir="$HOME/media/Recordings"
mkdir -p "$dir"

file="$dir/recording-$(date +%Y%m%d-%H%M%S).mp4"

wf-recorder -g "$(slurp)" -f "$file"
