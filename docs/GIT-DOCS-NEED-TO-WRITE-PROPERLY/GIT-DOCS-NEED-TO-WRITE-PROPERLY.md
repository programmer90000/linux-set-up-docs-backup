# Git Commands Documentation

This document provides detailed documentation for various Git commands, including their flags and usage examples.

## Table of Contents
6. [git reflog](#git-reflog)
8. [git bisect](#git-bisect)
10. [git worktree](#git-worktree)
13. [git grep](#git-grep)
---


git reflog

Manage reference logs.

Flags

--relative-date

Show dates in relative format.

Examples:

```bash
# Show reflog with relative dates
git reflog --relative-date

# Show specific branch reflog
git reflog show main --relative-date

# Show with custom format
git reflog --date=relative
```

--all

Show reflog for all references.

Examples:

```bash
# Show all reference logs
git reflog --all

# Show all with patch info
git reflog --all --patch

# Show all with statistics
git reflog --all --stat
```

--since

Show reflog entries since specific time.

Examples:

```bash
# Entries from last 2 days
git reflog --since="2 days ago"

# Entries since specific date
git reflog --since="2024-01-01"

# Entries from last week
git reflog --since="1 week"
```

---


git bisect

Find the commit that introduced a bug.

Commands

start

Begin bisect session.

Examples:

```bash
# Start bisect
git bisect start

# Start with known bad commit
git bisect start HEAD HEAD~10

# Start with specific range
git bisect start v1.0 v0.9
```

bad

Mark current commit as bad.

Examples:

```bash
# Mark current as bad
git bisect bad

# Mark specific commit as bad
git bisect bad abc123

# Mark with message
git bisect bad "Bug appears here"
```

good

Mark current commit as good.

Examples:

```bash
# Mark current as good
git bisect good

# Mark specific commit as good
git bisect good def456

# Mark multiple as good
git bisect good abc123 def456
```

---

git worktree

Manage multiple working trees.

Flags

add

Create new worktree.

Examples:

```bash
# Add worktree for branch
git worktree add ../hotfix hotfix-branch

# Add worktree for new branch
git worktree add -b new-feature ../feature

# Add worktree with specific commit
git worktree add ../old-version abc123
```

list

Show existing worktrees.

Examples:

```bash
# List all worktrees
git worktree list

# List with details
git worktree list --verbose

# List with porcelain format
git worktree list --porcelain
```

remove

Remove a worktree.

Examples:

```bash
# Remove worktree
git worktree remove ../hotfix

# Force remove worktree
git worktree remove --force ../feature

# Remove with cleanup
git worktree remove --force ../old-version
```

---

git grep

Search for patterns in tracked files.

Flags

-i, --ignore-case

Case-insensitive search.

Examples:

```bash
# Case-insensitive search
git grep -i "function"

# Case-insensitive in specific files
git grep -i "TODO" src/*.js

# Case-insensitive with line numbers
git grep -i -n "error"
```

-n, --line-number

Show line numbers.

Examples:

```bash
# Search with line numbers
git grep -n "console.log"

# Line numbers in specific commit
git grep -n "TODO" HEAD~2

# Line numbers with context
git grep -n -C 2 "function"
```

-c, --count

Show count of matches per file.

Examples:

```bash
# Count matches per file
git grep -c "import"

# Count in specific version
git grep -c "TODO" v1.0.0

# Count with file patterns
git grep -c "function" -- '*.js'
```
