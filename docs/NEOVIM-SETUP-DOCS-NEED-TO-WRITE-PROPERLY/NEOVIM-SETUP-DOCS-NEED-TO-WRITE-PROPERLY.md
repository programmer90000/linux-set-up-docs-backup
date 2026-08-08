# Neovim

## Modes of Operation

### 1. Normal Mode (Default)
This is where you navigate and execute commands. Press `ESC` to return here from any other mode.

### 2. Insert Mode
Enter by pressing `i`. Type text like a normal editor. Press `ESC` to return to Normal Mode.

### 3. Visual Mode
Enter by pressing `v`. Select text with movement commands. Press `ESC` to return to Normal Mode.

### 4. Command-Line Mode
Enter by pressing `:`. Execute commands like `:w` or `:q`. Press `Enter` to execute, `ESC` to cancel.

### Copying (Yanking)
```
y    Yank (copy) selected text
```

### Pasting
```
P     Paste before cursor
```

---

## Undo and Redo

```
u         Undo last change
Ctrl+r    Redo last undone change
```

---

## Visual Mode Operations

### Entering Visual Mode
```
v     Enter character-wise visual mode
V     Enter line-wise visual mode
```

### While in Visual Mode
```
y     Yank (copy) selected text
```

---

## File Operations

### Saving
```
:w         Save file
:w filename    Save as new filename
```

### Quitting
```
:q         Quit (only if no unsaved changes)
:q!        Quit without saving (force quit)
```

### Save and Quit
```
:wq        Save and quit
```

---

## Working with Multiple Files

### Opening Files
```
:e filename        Edit another file
:sp filename       Horizontal split window and open file
:vsp filename      Vertical split and open file
```

---

## Window Management

### Creating Windows
```
:sp          Split window horizontally
:vsp         Split window vertically
```

### Navigating Windows
```
Ctrl+w h     Move to left window
Ctrl+w j     Move to window below
Ctrl+w k     Move to window above
Ctrl+w l     Move to right window
Ctrl+w w     Cycle through windows
```

### Closing Windows
```
Ctrl+w c     Close current window
Ctrl+w o     Make current window only one (close others)
```

### Resizing Windows
```
Ctrl+w =     Make all windows equal size
Ctrl+w +     Increase window height
Ctrl+w -     Decrease window height
Ctrl+w >     Increase window width
Ctrl+w <     Decrease window width
```

---

## Tab Management

### Creating and Closing Tabs
```
:tabnew          Create new tab
:tabclose        Close current tab
:tabonly         Close all other tabs
```

### Tab Navigation
```
gt          Go to next tab
gT          Go to previous tab
NUMBERgt         Go to tab number 3
```

## Menu Bar

To access the menu bar, used the F1, F2 keys. The menu is defined in menu.lua file

## Neo Tree

To open Neo Tree, run
```
:Neotree
```

To find the commands for Neotree, press:
```
?
```