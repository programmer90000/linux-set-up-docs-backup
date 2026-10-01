To see every variable Git can possibly accept, run this in your terminal:

```bash
git help --config
```

This outputs the full, canonical list of all configuration keys .

Keys to look at:
```
core.editor
credential.helper
diff.tool
merge.tool
column.ui
color.ui
log.date
tag.sort
status.renames
status.renameLimit
status.branch
sequence.editor
showBranch.default
stash.showIncludeUntracked
stash.showPatch
stash.showStat
pager.<cmd>
pretty.<name>
pull.ff
pull.rebase
push.default
push.followTags
push.gpgSign
man.viewer
merge.conflictStyle
merge.renormalize
merge.defaultToUpstream
merge.ff
merge.autoStash
merge.verifySignatures
merge.log
merge.branchdesc
merge.suppressDest
merge.renames
merge.renameLimit
merge.directoryRenames
merge.stat
merge.verbosity
merge.tool
mergetool.<vimdiff variant>.layout
mergetool.keepBackup
mergetool.keepTemporaries
mergetool.writeToTemp
mergetool.hideResolved
mergetool.prompt
```

Keys to set:
```
`user.useConfigOnly`: Set it to true
`status.relativePaths`: Set it to false
`status.short`: Set it to false
`status.aheadBehind`: Set it to true
`status.displayCommentPrefix`: Set it to false
`status.showStash`: Set it to true
`status.showUntrackedFiles`: Set it to normal
```
