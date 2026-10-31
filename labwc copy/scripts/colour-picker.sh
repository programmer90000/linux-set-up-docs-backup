#!/bin/bash

set -eu

grim -g "$(slurp -p)" -t ppm - | convert - -format "#%[hex:p{0,0}]" info: | wl-copy
