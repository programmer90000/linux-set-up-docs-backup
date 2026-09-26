#!/bin/bash

echo "Ensure you are running this file from the root of the linux-set-up-docs repository"

sudo apt update
sudo apt install -y tmux git

# ! Tmux-Resurrect
mkdir -p ~/.tmux/plugins/
mkdir -p ~/.tmux/resurrect/
cp -r tmux-resurrect/ ~/.tmux/plugins/tmux-resurrect

# ! Tmux-Continuum
git clone https://github.com/tmux-plugins/tmux-continuum.git ~/.tmux/plugins/tmux-continuum

# Create tmux config with resurrect manually loaded
# THIS IS A TEMP FILE I HAVE NOT CHECKED
cat > ~/.tmux.conf << 'EOF'
# Mouse support
set -g mouse on

# Better colors
set -g default-terminal "screen-256color"

# Manual loading of tmux-resurrect
run-shell ~/.tmux/plugins/tmux-resurrect/resurrect.tmux

# Resurrect settings
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'
EOF

# ! Tmux-Yank
sudo apt update
sudo apt install -y copyq wl-clipboard
copyq &
git clone https://github.com/tmux-plugins/tmux-yank ~/.config/tmux/plugins/tmux-yank
echo "run-shell ~/.config/tmux/plugins/tmux-yank/yank.tmux" >> ~/.tmux.conf
tmux
tmux source-file ~/.tmux.conf
# Reload tmux config
tmux source ~/.tmux.conf

echo "To copy text to the clipboard, run: printf "test123" | wl-copy"
echo "To paste the text, run: wl-paste"
echo "To open the CopyQ GUI, run: copyq show"
echo "Exit Tmux: exit"
echo "Open the CopyQ GUI in the normal terminal to check if it's still copied: copyq show"

# ! Tmux-Zoom
mkdir ~/bin/
wget -q --show-progress -O ~/bin/tmux-zoom.sh https://raw.githubusercontent.com/jipumarino/tmux-zoom/master/tmux-zoom.sh
chmod +x ~/bin/tmux-zoom.sh
echo "bind C-k run-shell \"$HOME/bin/tmux-zoom.sh\"" >> ~/.tmux.conf
echo "bind z run-shell \"$HOME/bin/tmux-zoom.sh\"" >> ~/.tmux.conf
tmux source-file ~/.tmux.conf
echo "- 'Prefix' (usually Ctrl-b) + z → Zoom current pane"
echo "- 'Prefix' + Ctrl-k → Also zooms current pane"
echo "- Press the same key combination again to unzoom"
echo ""
echo "• Example workflow:"
echo "1. Start tmux: tmux new -s mysession"
echo "2. Split panes: Prefix + % or Prefix + \""
echo "3. Navigate to a pane: Prefix + arrow keys"
echo "4. Zoom (meaning make it full screen): Prefix + z"
echo "5. Unzoom: Prefix + z again"

# ! Tmux-Better-Mouse-Mode
git clone https://github.com/nhdaly/tmux-better-mouse-mode.git ~/.config/tmux/plugins/tmux-better-mouse-mode
echo "" >> ~/.tmux.conf
echo "# tmux-better-mouse-mode plugin" >> ~/.tmux.conf
echo "run-shell ~/.config/tmux/plugins/tmux-better-mouse-mode/scroll_copy_mode.tmux" >> ~/.tmux.conf
# Add recommended settings
echo "" >> ~/.tmux.conf
echo "# tmux-better-mouse-mode settings" >> ~/.tmux.conf
echo "set -g @scroll-speed-num-lines-per-scroll \"5\"" >> ~/.tmux.conf
echo "set -g @emulate-scroll-for-no-mouse-alternate-buffer \"on\"" >> ~/.tmux.conf
echo "set -g @scroll-down-exit-copy-mode \"on\"" >> ~/.tmux.conf
tmux source-file ~/.tmux.conf
echo "Use your mouse wheel to scroll up/down"
echo "You should be able to scroll smoothly through the buffer"
echo "Scroll all the way to the bottom - you should automatically exit copy mode"
echo "Enter copy mode: Ctrl-b ["
echo "Scrolling should continue after reaching the bottom"
echo "Press Esc to exit copy mode"

# ! Tmux Built-in Choose-Tree
echo "" >> ~/.tmux.conf
echo "# Built-in tmux choose-tree (session/window/pane tree)" >> ~/.tmux.conf
echo "# Show session tree (all sessions, windows, panes)" >> ~/.tmux.conf
echo "bind Tab choose-tree" >> ~/.tmux.conf
echo "# Show only window tree" >> ~/.tmux.conf
echo "bind C-t choose-tree -w" >> ~/.tmux.conf
echo "# Show only session tree" >> ~/.tmux.conf
echo "bind C-s choose-tree -s" >> ~/.tmux.conf
echo "# Show only pane tree" >> ~/.tmux.conf
echo "bind C-p choose-tree -p" >> ~/.tmux.conf
echo "" >> ~/.tmux.conf
echo "# Choose-tree appearance settings" >> ~/.tmux.conf
echo "set -g @choose-tree-expand 'on'  # Start with all items expanded" >> ~/.tmux.conf
echo "set -g @choose-tree-show-session-names 'on'  # Show session names" >> ~/.tmux.conf
echo "Prefix + Tab - Show full tree (sessions/windows/panes)"
echo "Prefix + Ctrl-s  - Show only sessions"
echo "Prefix + Ctrl-w  - Show only windows"
echo "Prefix + Ctrl-p  - Show only panes"
echo "Navigation (when in choose-tree mode):"
echo "Arrow keys       - Move up/down/left/right"
echo "Enter            - Select and switch to item"
echo "Space            - Expand/collapse tree items"
echo "s                - Change sort order"
echo "t                - Toggle tree/plain view"
echo "v                - Toggle preview"
echo "q or Escape      - Exit choose-tree"
echo "What you can do with choose-tree:"
echo "Switch between sessions/windows/panes"
echo "Kill sessions/windows/panes (press 'x')"
echo "Rename sessions/windows (press 'r')"
echo "Create new windows (press 'n')"
echo "Preview pane contents (press 'v')"
echo "Example workflow:"
echo "Press 'Prefix + Tab' to open the tree"
echo "Navigate to any session/window/pane"
echo "Press Enter to switch to it"
echo "Or press 'x' to kill it"
echo "Or press 'r' to rename it"

tmux source-file ~/.tmux.conf
