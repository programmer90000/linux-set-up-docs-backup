To see every variable Git can possibly accept, run this in your terminal:

```bash
git help --config
```

This outputs the full, canonical list of all configuration keys .

Some of the keys to look at:
```
core.editor
credential.helper
diff.tool
merge.tool
column.ui
color.ui
log.date
```

`user.useConfigOnly`: Set it to true
`status.relativePaths`: Set it to false
`status.short`: Set it to false
`status.aheadBehind`: Set it to true
`status.displayCommentPrefix`: Set it to false
`status.showStash`: Set it to true
`status.showUntrackedFiles`: Set it to normal
