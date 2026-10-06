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