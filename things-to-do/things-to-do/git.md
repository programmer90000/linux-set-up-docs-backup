Keys to look at:
```
credential.helper
diff.tool
merge.tool
column.ui
status.branch
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
log.graphColors
core.pager
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
commit.status
```

Keys to set:
`core.editor`: Set it to nvim

`core.autocrlf`: Set it to `input`

`core.eol`: Set it to `lf`

`core.safecrlf`: Set it to `warn`

`core.quotePath`: Set it to `false`

`core.whitespace`: Set it to `trailing-space, space-before-tab, indent-with-non-tab, tab-in-indent, cr-at-eol`

`help.autoCorrect`: Set it to `0`

`user.useConfigOnly`: Set it to true

`elativePaths`: Set it to false

`status.short`: Set it to false

`status.aheadBehind`: Set it to true

`status.displayCommentPrefix`: Set it to false

`status.showStash`: Set it to true

`status.showUntrackedFiles`: Set it to normal

`i18n.commitEncoding`: Set it to `UTF-8`

`i18n.logOutputEncoding`: Set it to `UTF-8`

`init.defaultBranch`: Set it to `main`

`color.ui`: Set it to `auto`

`column.ui`: Set it to `auto column dense`

`color.advice`: Set it to `always`

`sequence.editor`: Set it to `nvim`

`blame.showEmail`: Set it to true

`blame.blankBoundary`: Set it to false

`blame.date`: Set it to `default`

`log.date`: Set it to `default`

`tag.sort`: Set it to `version:refname`

```
[branch]
	sort = refname
	sort = version:refname
	sort = -committerdate
```