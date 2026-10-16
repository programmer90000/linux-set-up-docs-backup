Try this to get the Tmux pane number in the status bar
`run-shell 'tmux set-option -g status-right "#[fg=colour236]#S • $USER@$(hostname -s) • Pane:#{pane_index} (#{pane_current_command})"'`

| Feature | Supported |
|---------|-----------|
| Save Tmux sessions so they can be accessed after boot (tmux-ressurect) | ✅ |
| File path | ✅ |
| Status Bar | ✅ |
| Currently active session, windows, pane in status bar | ✅ |
| Ability to copy and paste text | ✅ |
| Tree view of all sessions, windows, panes | ✅ |
| Search | ✅ |
| Ability to save output to a file (tmux-logging) | ✅ |
| Move panes across windows | ✅ |
| Highlight pane when output appears after some idle time | ✅ |
| Use mouse to resize panes | ✅ |
| Use mouse to scroll through output | ✅ |
| Notification when long running command completes | ✅ |
| A fuzzy finder within Tmux | ✅ |
| Dynamic status bar colors based on session state (e.g., red when a pane has an error) | ❌ |
| Show a warning before closing a pane with a running process | ✅ |
| List all pane processes (what's running inside each pane) | ✅ |
| Stop highliting text from automatically copying it | ✅ |
| Install https://github.com/jaclu/tmux-power-zoom | ❌ |

Use Zsh precmd to send a message to Tmux with the exit code of the command. If it isn't 0, Tmux should highlight it.

precmd is executed after a command finishes, before the new prompt is written

Look at installing these Tmux plugins:


https://github.com/spywhere/tmux-named-snapshot
