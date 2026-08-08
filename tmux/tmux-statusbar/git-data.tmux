#!/usr/bin/env bash

# Get the plugin directory
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BINARY="${CURRENT_DIR}/bin/git-data-extractor"

# Simple key bindings that work - no xargs, direct output
tmux bind-key G run-shell "$BINARY \"#{pane_current_path}\" branch && tmux display-message \"Branch: \$($BINARY \"#{pane_current_path}\" branch)\""
tmux bind-key H run-shell "$BINARY \"#{pane_current_path}\" commit && tmux display-message \"Commit: \$($BINARY \"#{pane_current_path}\" commit)\""
tmux bind-key M run-shell "$BINARY \"#{pane_current_path}\" modified && tmux display-message \"Modified: \$($BINARY \"#{pane_current_path}\" modified)\""
tmux bind-key U run-shell "$BINARY \"#{pane_current_path}\" untracked && tmux display-message \"Untracked: \$($BINARY \"#{pane_current_path}\" untracked)\""
tmux bind-key S run-shell "$BINARY \"#{pane_current_path}\" stashes && tmux display-message \"Stashes: \$($BINARY \"#{pane_current_path}\" stashes)\""
tmux bind-key C run-shell "$BINARY \"#{pane_current_path}\" conflicts && tmux display-message \"Conflicts: \$($BINARY \"#{pane_current_path}\" conflicts)\""
tmux bind-key R run-shell "$BINARY \"#{pane_current_path}\" renamed && tmux display-message \"Renamed: \$($BINARY \"#{pane_current_path}\" renamed)\""  # NEW: renamed files

# Dashboard command (UPDATED with renamed files)
tmux bind-key D run-shell "
    BRANCH=\$($BINARY \"#{pane_current_path}\" branch)
    COMMIT=\$($BINARY \"#{pane_current_path}\" commit)
    STAGED=\$($BINARY \"#{pane_current_path}\" staged)
    MODIFIED=\$($BINARY \"#{pane_current_path}\" modified)
    UNTRACKED=\$($BINARY \"#{pane_current_path}\" untracked)
    RENAMED=\$($BINARY \"#{pane_current_path}\" renamed)
    tmux display-message \"Git: \$BRANCH (\$COMMIT) | Staged: \$STAGED Mod: \$MODIFIED New: \$UNTRACKED Renamed: \$RENAMED\"
"

# Quick summary
tmux bind-key T run-shell "
    BRANCH=\$($BINARY \"#{pane_current_path}\" branch)
    COMMIT=\$($BINARY \"#{pane_current_path}\" commit)
    tmux display-message \"\$BRANCH (\$COMMIT)\"
"

# Clean status (UPDATED to use new is_clean)
tmux bind-key L run-shell "
    CLEAN=\$($BINARY \"#{pane_current_path}\" is_clean)
    tmux display-message \"Repository is \$CLEAN\"
"

tmux display-message "Git Data Plugin loaded! Try prefix + G for branch, R for renamed files"