Save tmux pane to a file:
1.Open Command Mode: Press `Ctrl + b`, then type `:` to enter the Tmux command prompt.

Capture entire history (scrollback):
```
capture-pane -S -
```

Capture only current visible screen:
```
capture-pane
```

Capture last N lines (e.g., last 3000 lines):
```
capture-pane -S -3000
```

Press `Ctrl + b`, type `:`, then run:
```
save-buffer ~/pane_output.txt
```



Command to show a confirmation prompt before closing a pane if a process is running:
```
bind-key x if-shell '[ "$(tmux display-message -p "#{pane_current_command}")" = "zsh" ] || [ "$(tmux display-message -p "#{pane_current_command}")" = "bash" ]' 'kill-pane' 'confirm-before -p "Are you sure you want to kill this process? (y/n)" "confirm-before -p \"Process running (#{pane_current_command}). Kill pane? (y/n)\" kill-pane"'
```
