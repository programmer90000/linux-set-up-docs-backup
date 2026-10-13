#!/bin/bash

echo "Ensure you are running this file from the root of the linux-set-up-docs repository"

sudo apt update
sudo apt install -y tmux git

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

tmux source-file ~/.tmux.conf
