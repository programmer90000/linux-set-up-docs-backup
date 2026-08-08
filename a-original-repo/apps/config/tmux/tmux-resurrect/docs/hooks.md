# Save & Restore Hooks

Hooks allow to set custom commands that will be executed during session save and restore. Most hooks are called with zero arguments, unless explicitly stated otherwise.

Currently the following hooks are supported:
- `@resurrect-hook-post-save-layout`

Called after all sessions, panes and windows have been saved.

Passed single argument of the state file.

- `@resurrect-hook-post-save-all`

Called at end of save process right before the spinner is turned off.

- `@resurrect-hook-pre-restore-all`

Called before any tmux state is altered.

- `@resurrect-hook-pre-restore-pane-processes`

Called before running processes are restored.
