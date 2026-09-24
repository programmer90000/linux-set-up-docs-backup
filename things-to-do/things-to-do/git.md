Clone this repo: https://github.com/dandavison/delta

Add this to .gitconfig:
```
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true  # use n and N to move between diff sections
    dark = true      # or light = true, or omit for auto-detection

[merge]
    conflictStyle = zdiff3

[rerere]
enabled=true
```

Write a note in the docs: To view the entire file in git diff, run: ```git diff --unified=NUMBER OF LINES IN THE LARGER FILE```

Find a theme for git in the terminal

Look for a terminal tool to review git diffs

Write docs on git tag