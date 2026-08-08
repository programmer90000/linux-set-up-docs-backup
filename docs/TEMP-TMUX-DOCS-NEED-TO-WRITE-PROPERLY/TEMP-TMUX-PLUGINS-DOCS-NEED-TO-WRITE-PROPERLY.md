# Tmux Git
Make a custom plugin to do the following:
- If the directory isn't a git repository, display the normal status line. Don't make any changes to it.
- If the directory is a git repository, display:
  - Current branch name
  - If there are uncommitted changes by using the * icon
  - If there are staged files by using the + icon
  - If there are conflicts by using the ! icon
  - If there are untracked files ? icon


You can customize the symbols used for Git status indicators by adding these options to your ~/.tmux.conf before loading the plugin:

```bash
# Custom symbols (set these BEFORE loading the plugin)
set -g @git_modified_symbol '⚡'
set -g @git_staged_symbol '✓'
set -g @git_conflicts_symbol '✗'
set -g @git_untracked_symbol '?'
```

# Tmux Logging
# Important: Check how to make this safe for confidential information such as passwords or credentials

This guide provides complete, step-by-step instructions for manually installing, setting up, and using tmux logging on Debian 13 (Trixie). Since Debian 13 may include a recent version of tmux by default (likely 3.3a or newer ), we will focus on using the built-in tools and a manual plugin installation for enhanced logging features.

---

1. Verifying Your Current tmux Installation

First, let's check which version of tmux is currently installed on your system. Open a terminal and run:

```bash
tmux -V
```

You will see output similar to tmux 3.3a . As long as you have a version 1.8 or newer (which is almost certain for Debian 13), all the commands in this guide will work.

If for some reason tmux is not installed, you can install it using the standard Debian package manager:

```bash
sudo apt update
sudo apt install tmux
```

2. Core Logging Methods (Built-in)

Tmux includes powerful built-in commands for capturing terminal output. These are the foundation of all logging techniques.

2.1 Capturing a Pane's History with capture-pane

This command saves the contents of a pane, including its scrollback history, to a file. It is a manual, one-time capture.

Method 1: Using the Tmux Command Prompt (Within a tmux session)

1. Enter tmux command mode by pressing Ctrl+b followed by : (colon).
2. Type the following command to capture the entire pane history:
   ```bash
   capture-pane -S -
   ```
   The -S - flag tells tmux to start from the very beginning of the history .
3. Press Enter. The pane content is now copied into a tmux internal buffer.
4. To save this buffer to a file, use the save-buffer command. From the command prompt again (Ctrl+b :):
   ```bash
   save-buffer ~/pane-capture.txt
   ```
   You can replace the path with your desired filename and location .

Method 2: One-Line Shell Command (From outside or inside tmux)
This is often the most efficient method. From your shell prompt, you can execute a single command to capture a specific pane's content directly to a file.

· Capture the current pane (the one you are in) to a file:
  ```bash
    tmux capture-pane -p -S - > ~/my-output.log
  ```
  The -p flag outputs the captured content to stdout (standard output), which we then redirect (>) to a file .
· Capture a specific pane by target:
  If you have multiple windows or panes, you can target a specific one. The target format is session:window.pane.
  ```bash
    tmux capture-pane -t mysession:mywindow.1 -p -S - > ~/specific-pane.log
  ```
  To find your current target, you can run tmux display -p '#{session_name}:#{window_index}.#{pane_index}' from within a pane .

2.2 Continuous Logging with pipe-pane

While capture-pane is a one-off snapshot, pipe-pane allows you to start and stop logging continuously. All new output in a pane will be piped to a file from the moment you start it.

1. Start Logging: Go to the pane you want to log. Enter command mode (Ctrl+b :) and type:
   ```bash
   pipe-pane -o 'cat >> ~/continuous-log.log'
   ```
   The -o flag logs only output (not typed commands). The command cat >> ~/continuous-log.log appends all output to the specified file . You can also use tee if you want to log and still see the output normally: pipe-pane -o 'tee -a ~/continuous-log.log'.
2. Stop Logging: To stop piping the output, run the command again without any arguments:
   ```bash
   pipe-pane
   ```

3. Manual Installation of tmux-logging Plugin

The built-in methods are powerful, but the tmux-logging plugin enhances them by providing convenient key bindings and automatically stripping ANSI color codes for cleaner log files .

Here is the manual installation process:

1. Clone the Plugin Repository:
   Choose a directory to store your tmux plugins, for example, ~/.tmux/plugins/. Then clone the tmux-logging repository.
   ```bash
   mkdir -p ~/.tmux/plugins/
   git clone https://github.com/tmux-plugins/tmux-logging ~/.tmux/plugins/tmux-logging
   ```
2. Configure tmux to Load the Plugin:
   Edit your tmux configuration file, usually located at ~/.tmux.conf.
   ```bash
   nano ~/.tmux.conf
   ```
   Add the following line to the very end of the file:
   ```bash
   run-shell ~/.tmux/plugins/tmux-logging/logging.tmux
   ```
   Save the file and exit the editor.
3. Reload the tmux Configuration:
   For the changes to take effect, you must reload the configuration. You can do this from within a tmux session by entering command mode (Ctrl+b :) and typing:
   ```bash
   source-file ~/.tmux.conf
   ```
   Or, you can restart all tmux sessions.

4. Using tmux-logging Features

Once the plugin is installed, you have three primary logging functions at your disposal, all accessible via key bindings. The default prefix is Ctrl+b.

Feature Key Binding Description
Toggle Continuous Logging Prefix + Shift + p Starts or stops logging all output in the current pane. The log file will be saved in your home directory (~/) with a filename like tmux-{session}-{window}-{pane}-{datetime}.log .
Save Visible Text (Screenshot) Prefix + Alt + p Saves only the currently visible text in the pane to a file. This is like taking a screenshot, but for text .
Save Complete Pane History Prefix + Alt + Shift + p Saves the entire scrollback history of the pane to a file. This is useful if you forgot to turn on logging but need to capture everything you've done .

5. Tips and Considerations

· Increasing Scrollback History: The "Save Complete Pane History" feature relies on tmux's history-limit option. To ensure you can capture a long session, increase this limit in your ~/.tmux.conf :
  ```bash
    set -g history-limit 50000
  ```
  Then, reload your configuration.
· Removing ANSI Color Codes: Logs created with the built-in pipe-pane method will contain raw ANSI color codes, which look like garbled text. The tmux-logging plugin automatically strips these out. For best results, especially on Debian, you can also install ansifilter, a more robust tool for this purpose :
  ```bash
    sudo apt install ansifilter
  ```
  The plugin will automatically use ansifilter if it is installed.
· Creating Custom Key Bindings: You are not limited to the plugin's bindings. You can create your own in ~/.tmux.conf. For example, to create a binding that toggles logging with a notification:
  ```bash
    # Toggle logging to a file named after the current window
    bind-key H pipe-pane -o "exec cat >>$HOME/'#W-tmux.log'" \; display-message 'Toggled logging to $HOME/#W-tmux.log'
  ```
  This uses the #W format symbol, which expands to the current window name .
· Security and Privacy: Be mindful that log files can contain sensitive information like passwords, API keys, or personal data. Ensure your log files are stored in a secure location and consider deleting them when they are no longer needed.