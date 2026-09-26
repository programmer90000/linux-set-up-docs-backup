#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/.local/share/nvim/site/pack/vendor/start/"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Creating plugin base directory"
mkdir -p "$BASE"

echo "==> Copying plugins from local directories"

echo "Copying lualine"
cp -r "$SCRIPT_DIR/lualine" "$BASE"

echo "Copying mason"
cp -r "$SCRIPT_DIR/mason" "$BASE"

echo "Copying neo-tree"
cp -r "$SCRIPT_DIR/neo-tree" "$BASE"

echo "Copying nui"
cp -r "$SCRIPT_DIR/nui" "$BASE"

echo "Copying nvim-surround..."
cp -r "$SCRIPT_DIR/nvim-surround" "$BASE"

echo "Copying nvim-treesitter"
cp -r "$SCRIPT_DIR/nvim-treesitter/" "$BASE"

echo "Copying nvim-web-devicons"
cp -r "$SCRIPT_DIR/nvim-web-devicons" "$BASE"

echo "Copying plenary"
cp -r "$SCRIPT_DIR/plenary" "$BASE"