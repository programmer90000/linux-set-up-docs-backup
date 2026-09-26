# Tmux Resurrect

Restore `tmux` environment after system restart.

Tmux is great, except when you have to restart the computer. You lose all the running programs, working directories, pane layouts etc. There are helpful management tools out there, but they require initial configuration and continuous updates as your workflow evolves or you start new projects.

`tmux-resurrect` saves all the little details from your tmux environment so it can be completely restored after a system restart (or when you feel like it). No configuration is required. You should feel like you never quit tmux.

### Key bindings

- `prefix + Ctrl-s` - save
- `prefix + Ctrl-r` - restore

### About

This plugin goes to great lengths to save and restore all the details from your `tmux` environment. Here's what's been taken care of:

- All sessions, windows, panes and their order
- Current working directory for each pane
- **Exact pane layouts** within windows (even when zoomed)
- Active and alternative session
- Active and alternative window for each session
- Windows with focus
- Active pane for each window
- "grouped sessions" (useful feature when using tmux with multiple monitors)
- Programs running within a pane! More details in the [restoring programs doc](docs/restoring_programs.md).

Optional:

- [restoring pane contents](docs/restoring_pane_contents.md)
- [restoring a previously saved environment](docs/restoring_previously_saved_environment.md)

Requirements / dependencies: `tmux 1.9` or higher, `bash`

Tested and working on Linux, OSX and Cygwin

`tmux-resurrect` is idempotent! It will not try to restore panes or windows that already exist. The single exception to this is when tmux is started with only 1 pane in order to restore previous tmux env. Only in this case will this single pane be overwritten.

### Docs

**Configuration**

- [Changing the default key bindings](docs/custom_key_bindings.md).
- [Setting up hooks on save & restore](docs/hooks.md).
- [Change a directory](docs/save_dir.md) where `tmux-resurrect` saves tmux environment.

### License
[MIT](LICENSE.md)

### Credits

Tmux Resurrect was cloned from https://github.com/tmux-plugins/tmux-resurrect