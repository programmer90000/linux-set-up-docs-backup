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
diff.autoRefreshIndex
diff.algorithm
diff.context
diff.interHunkContext
diff.indentHeuristic
diff.suppressBlankEmpty
diff.wordRegex
diff.mnemonicPrefix
diff.noPrefix
diff.srcPrefix
diff.dstPrefix
diff.relative
diff.dirstat
diff.submodule
diff.ignoreSubmodules
diff.colorMoved
diff.colorMovedWS
diff.wsErrorHighlight
diff.tool
diff.guitool
difftool.trustExitCode
difftool.prompt
difftool.guiDefault
grep.lineNumber
grep.column
grep.patternType
grep.extendedRegexp
grep.threads
grep.fullName
grep.fallbackToNoIndex
help.format
help.autoCorrect
i18n.commitEncoding
i18n.logOutputEncoding
init.defaultBranch
log.graphColors
core.whitespace
core.pager
core.editor
core.autocrlf
blame.blankBoundary
blame.date
blame.showEmail
branch.sort
color.advice
color.advice.hint
color.blame.highlightRecent
color.blame.repeatedLines
color.branch
color.branch.<slot>
color.diff
color.diff.<slot>
color.decorate.<slot>
color.grep
color.grep.<slot>
color.interactive
color.interactive.<slot>
color.pager
color.push
color.push.error
color.remote
color.remote.<slot>
color.showBranch
color.status
color.status.<slot>
color.transport
color.transport.rejected
color.ui
commit.status
core.quotePath
core.eol
core.safecrlf
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
