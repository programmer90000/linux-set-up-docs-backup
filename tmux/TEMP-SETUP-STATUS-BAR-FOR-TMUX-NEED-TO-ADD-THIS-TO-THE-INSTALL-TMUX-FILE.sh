#!/bin/bash

echo "Ensure you are running this file from the root of the linux-set-up-docs repository"

sudo apt update
sudo apt install -y tmux git

# Create a COMPLETELY NEW tmux config from scratch
cat > ~/.tmux.conf << 'EOF'
# =============================================
# BASIC TMUX CONFIGURATION
# =============================================

# Enable mouse support
set -g mouse on

# Better colors
set -g default-terminal "screen-256color"

# =============================================
# STATUS BAR CONFIGURATION
# =============================================

# Make sure status bar is enabled and visible
set -g status on
set -g status-position bottom
set -g status-interval 1  # Update every second

# Status bar colors (make it stand out)
set -g status-style bg=green,fg=black

# Left side of status bar - show session name
set -g status-left "#[bg=green,fg=black] SESSION:#S "

# Center of status bar - show windows
set -g status-justify centre
set -g window-status-format " #I:#W "
set -g window-status-current-format "#[bg=white,fg=black] #I:#W "

# RIGHT SIDE - Show git info if in a repo, otherwise nothing
set -g status-right "#[bg=green,fg=black]#(~/.tmux-git-status.sh) %H:%M "

# =============================================
# PLUGINS (to be added later)
# =============================================

# Tmux-Resurrect
run-shell ~/.tmux/plugins/tmux-resurrect/resurrect.tmux
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'

EOF

# ! Create a git status script that only shows output when in a git repo
cat > ~/.tmux-git-status.sh << 'EOF'
#!/bin/bash
# Only show output if current directory is in a git repo

# Get the current pane's directory
DIR=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)
if [ -n "$DIR" ]; then
    cd "$DIR" 2>/dev/null || exit 0
    
    # Check if we're in a git repo
    if git rev-parse --git-dir >/dev/null 2>&1; then
        # Get current branch name
        BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [ -n "$BRANCH" ]; then
            # Check for modified files
            if git status --porcelain 2>/dev/null | grep -q '^ M\|^??\|^ D'; then
                # Red if there are modified/untracked/deleted files
                echo "#[fg=red]$BRANCH#[fg=black]"
            elif git status --porcelain 2>/dev/null | grep -q '^M'; then
                # Yellow if only staged files
                echo "#[fg=yellow]$BRANCH#[fg=black]"
            else
                # Green if clean
                echo "#[fg=green]$BRANCH#[fg=black]"
            fi
        fi
    fi
fi
EOF
chmod +x ~/.tmux-git-status.sh

# Kill any existing tmux servers to start fresh
tmux kill-server 2>/dev/null

echo ""
echo "=========================================="
echo "TMUX INSTALLATION COMPLETE"
echo "=========================================="
echo ""
echo "NEXT STEPS:"
echo "-----------"
echo "1. Start a new tmux session:"
echo "   tmux new -s test"
echo ""
echo "2. You should see a GREEN status bar at the bottom with:"
echo "   - Left side: 'SESSION:test'"
echo "   - Center: your windows (0:bash)"
echo "   - Right side: Git branch name (if in a git repo) and time"
echo ""
echo "3. Git branch colors:"
echo "   - Green: Clean working directory"
echo "   - Yellow: Staged files only"
echo "   - Red: Modified/untracked/deleted files"
echo ""
echo "4. Test it out:"
echo "   cd into any git repository and watch the status bar update!"
echo ""
echo "Current tmux version: $(tmux -V)"