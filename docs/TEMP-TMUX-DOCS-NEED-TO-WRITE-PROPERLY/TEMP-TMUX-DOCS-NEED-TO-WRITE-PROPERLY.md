# Tmux

## Sessions

### Start a session

To start a new Tmux session, run:
```
tmux new -s SESSION-NAME
```

### View all running sessions

Run:
```
tmux ls
```

Use this to view them interactivally:
```
Ctrl+B S
```

### Detatch from a session

To detatch from a Tmux session while keeping it running/ avaliable, press `Ctrl + B`. After this, press `D`

### Attatch to the most recent session

Run:
```
tmux a
```

### Attatch to a particular session

Run:
```
tmux a -t SESSION-NAME
```

### Kill most recent session

Run:
```
tmux kill-session
```

### Kill particular session

Run:
```
tmux kill-session -t SESSION-NAME
```

### Rename Session
```
tmux rename-session SESSION-NAME
```

## Windows

### Create a new window

To create a new window, run: `Ctrl + B`. After this, press `C`

To move to the previous window, run `Ctrl + B`. After this, press `P`

To move to the next window, run `Ctrl + B`. After this, press `N`

### Rename a window

To rename a window, run: `Ctrl + B`. After this, press `,`. This will change the bottom bar to allow me to rename the window

### Move between windows sequentially

To move between windows sequentially, run: `Ctrl + B`. After this, press `N`

### List all windows

To list all windows, run: `Ctrl + B`. After this, press `W`. I can now use the arrow keys to view different windows. I can use the `Enter` key to select a window

### Kill a window

To kill a window, run: `Ctrl + B`. After this, press `W`. Using the arrow keys, select the window to kill. Press `Ctrl + B`. After this, press `X`. To kill the window, type `y` into the confirmation prompt

## Panes

### Create pane on the right

To make a new pane on the right, run: `Ctrl + B`. After this, press `%`

### Create pane on the bottom

To make a new pane on the bottom, run: `Ctrl + B`. After this, press `"`

### Move between panes

To move between panes, press `Ctrl + B`. Use the directional arrows to move between panes

Another way to move between panes is by pressing `Ctrl + B`. After this, press `Q`. This will display the number of each pane. Press `Ctrl + B`. After this, press the number of the pane I want to switch to

### Resize panes

To resize panes, press `Ctrl + B`. After this, hold `Ctrl + B` and press the arrow keys. I can move a pane multiple times by keeping hold of the `Ctrl` key and pressing the arrow keys multiple times

> Holding the arrow key to resize the pane doesn't work

### Kill a pane

To kill a pane, select the pane. Press `Ctrl + B`. After this, press `X`. To kill the pane, type `y` into the confirmation prompt

## Save/ Restore session

- `Ctrl + B`. Afrer rhis, press `Ctrl + S` - save
- `Ctrl + B`. After this, press `Ctrl + R` - restore