# Git Commands Documentation

This document provides detailed documentation for various Git commands, including their flags and usage examples.

## Table of Contents
1. [git commit --amend](#git-commit---amend)
2. [git merge](#git-merge)
3. [git diff](#git-diff)
4. [git log](#git-log)
5. [git reset](#git-reset)
6. [git reflog](#git-reflog)
7. [git pull --rebase](#git-pull---rebase)
8. [git bisect](#git-bisect)
9. [git revert](#git-revert)
10. [git worktree](#git-worktree)
11. [git rebase](#git-rebase)
12. [git cherry-pick](#git-cherry-pick)
13. [git grep](#git-grep)
14. [git clean](#git-clean)
15. [git add --patch](#git-add---patch)

---

git commit --amend

Modify the most recent commit.

Flags

-m, --message

Replace the commit message.

Examples:

```bash
# Change commit message
git commit --amend -m "New commit message"

# Add multiple paragraphs
git commit --amend -m "Title" -m "Description"

# Fix typo in last commit message
git commit --amend -m "Fix: Correct spelling error"
```

--no-edit

Amend without changing the commit message.

Examples:

```bash
# Add forgotten file to last commit
git add forgotten-file.txt
git commit --amend --no-edit

# Fix whitespace issues
git add -u
git commit --amend --no-edit

# Add changes without editing message
git commit --amend --no-edit
```

--author

Change the author of the commit.

Examples:

```bash
# Set new author
git commit --amend --author="John Doe <john@example.com>"

# Reset to current user
git commit --amend --reset-author

# Change author but keep commit date
git commit --amend --author="Jane Smith <jane@example.com>" --no-edit
```

---

git merge

Combine branches together.

Flags

--no-ff

Create a merge commit even when fast-forward is possible.

Examples:

```bash
# Merge feature branch with explicit merge commit
git merge --no-ff feature-branch

# Merge and customize commit message
git merge --no-ff -m "Merge feature branch" feature-branch

# Merge and verify with diff
git merge --no-ff --stat feature-branch
```

--squash

Combine all commits from the merged branch into one.

Examples:

```bash
# Squash feature branch commits
git merge --squash feature-branch
git commit -m "Add new feature"

# Squash without auto-commit
git merge --squash --no-commit feature-branch

# Squash and stage changes
git merge --squash -m "Squashed feature" feature-branch
```

--abort

Cancel an ongoing merge.

Examples:

```bash
# Abort merge with conflicts
git merge --abort

# Abort and clean up
git merge --abort && git clean -fd

# Abort and reset to specific commit
git merge --abort && git reset --hard HEAD
```

---

git diff

Show changes between commits, branches, files, etc.

Flags

--staged, --cached

Show changes staged for commit.

Examples:

```bash
# View staged changes
git diff --staged

# View staged changes for specific file
git diff --staged src/main.js

# View staged changes with color
git diff --staged --color
```

--word-diff

Show word-level changes instead of line-level.

Examples:

```bash
# View word differences
git diff --word-diff

# View word differences with color
git diff --word-diff=color

# View plain word differences
git diff --word-diff=plain
```

--stat

Show summary of changes with statistics.

Examples:

```bash
# Show diff statistics
git diff --stat

# Show statistics for specific branch
git diff main feature --stat

# Show statistics with patch
git diff --stat --patch
```

---

git log

Show commit history.

Flags

--oneline

Show each commit on a single line.

Examples:

```bash
# Simple one-line log
git log --oneline

# Show last 5 commits in one line
git log -5 --oneline

# One-line log with graph
git log --oneline --graph
```

--graph

Show ASCII graph of branch structure.

Examples:

```bash
# View branch history with graph
git log --graph

# Detailed graph with dates
git log --graph --pretty=format:"%h %ar %s"

# Graph with all branches
git log --graph --all
```

--author

Filter commits by author.

Examples:

```bash
# Commits by specific author
git log --author="John"

# Case-insensitive author search
git log --author="john" -i

# Commits by multiple authors
git log --author="John\|Jane"
```

---

git reset

Reset current HEAD to a specified state.

Flags

--soft

Move HEAD but keep changes staged.

Examples:

```bash
# Undo last commit but keep changes staged
git reset --soft HEAD~1

# Uncommit multiple commits
git reset --soft HEAD~3

# Reset to specific commit
git reset --soft abc123
```

--mixed (default)

Move HEAD and unstaged changes.

Examples:

```bash
# Unstage all files
git reset --mixed

# Unstage specific file
git reset --mixed file.txt

# Reset to previous commit with unstaged changes
git reset --mixed HEAD~2
```

--hard

Discard all changes and match target commit exactly.

Examples:

```bash
# Discard all local changes
git reset --hard HEAD

# Revert to previous commit
git reset --hard HEAD~1

# Reset to specific commit
git reset --hard abc123
```

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

git pull --rebase

Fetch and rebase instead of merge.

Flags

--rebase

Rebase current branch onto upstream.

Examples:

```bash
# Pull with rebase
git pull --rebase origin main

# Pull with rebase and autostash
git pull --rebase --autostash

# Pull with rebase and verify
git pull --rebase --verify
```

--autostash

Automatically stash before rebasing.

Examples:

```bash
# Pull with automatic stashing
git pull --rebase --autostash

# Pull with stash and rebase
git pull --rebase --autostash origin develop

# Pull with stash, rebase, and pop
git pull --rebase --autostash origin main
```

--no-rebase

Override configuration to merge instead.

Examples:

```bash
# Pull with merge despite config
git pull --no-rebase origin main

# Pull with merge and squash
git pull --no-rebase --squash

# Pull with merge and commit
git pull --no-rebase --no-ff
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

git revert

Undo commits by creating new commits.

Flags

--no-commit

Revert without auto-committing.

Examples:

```bash
# Revert commit but don't commit
git revert --no-commit abc123

# Revert multiple without committing
git revert --no-commit HEAD~3..HEAD

# Revert and manually commit
git revert --no-commit abc123 && git commit -m "Manual revert"
```

--edit

Edit commit message before committing.

Examples:

```bash
# Revert with message editing
git revert --edit abc123

# Revert range with editing
git revert --edit HEAD~3..HEAD

# Revert with custom editor
GIT_EDITOR=vim git revert --edit abc123
```

-n, --no-edit

Use default revert message.

Examples:

```bash
# Revert with default message
git revert --no-edit abc123

# Revert multiple with default messages
git revert --no-edit HEAD~2..HEAD

# Revert and skip confirmation
git revert --no-edit --no-verify abc123
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

git rebase

Reapply commits on top of another branch.

Flags

-i, --interactive

Interactive rebase mode.

Examples:

```bash
# Interactive rebase last 3 commits
git rebase -i HEAD~3

# Interactive rebase onto main
git rebase -i main

# Interactive with specific commit
git rebase -i abc123
```

--onto

Rebase onto different base.

Examples:

```bash
# Rebase feature onto main
git rebase --onto main feature

# Rebase with specific start point
git rebase --onto main base-branch feature-branch

# Rebase limited range
git rebase --onto main abc123 def456
```

--continue

Continue rebase after resolving conflicts.

Examples:

```bash
# Continue after conflict resolution
git rebase --continue

# Continue with message
git rebase --continue -m "Resolved conflicts"

# Continue and verify
git rebase --continue && git log --oneline -5
```

---

git cherry-pick

Apply specific commits to current branch.

Flags

-x

Add reference to original commit.

Examples:

```bash
# Cherry-pick with reference
git cherry-pick -x abc123

# Cherry-pick range with references
git cherry-pick -x main~3..main

# Cherry-pick multiple with references
git cherry-pick -x abc123 def456
```

-n, --no-commit

Apply changes without committing.

Examples:

```bash
# Cherry-pick without commit
git cherry-pick -n abc123

# Cherry-pick multiple without commit
git cherry-pick -n abc123 def456

# Cherry-pick and stage only
git cherry-pick -n abc123 && git status
```

-e, --edit

Edit commit message.

Examples:

```bash
# Cherry-pick with editing
git cherry-pick -e abc123

# Edit message during cherry-pick
git cherry-pick -e --no-commit abc123

# Cherry-pick range with editing
git cherry-pick -e main~3..main
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

---

git clean

Remove untracked files.

Flags

-n, --dry-run

Show what would be removed.

Examples:

```bash
# Preview clean operation
git clean -n

# Preview with directories
git clean -n -d

# Preview specific files
git clean -n *.tmp
```

-f, --force

Actually remove files.

Examples:

```bash
# Force remove untracked files
git clean -f

# Force remove with directories
git clean -fd

# Force remove specific patterns
git clean -f *.log
```

-d

Remove untracked directories.

Examples:

```bash
# Remove untracked directories
git clean -fd

# Remove directories dry run
git clean -nd

# Remove directories and files
git clean -fd -x
```

---

git add --patch

Interactively stage hunks of changes.

Flags

-p, --patch

Choose hunks to stage.

Examples:

```bash
# Interactive staging
git add -p

# Interactive for specific file
git add -p src/main.js

# Interactive with diff options
git add -p --ignore-whitespace
```

Interactive Commands

While in patch mode:

```bash
# Stage current hunk
git add -p
# Press 'y' when prompted

# Skip current hunk
git add -p
# Press 'n' when prompted

# Split hunk into smaller parts
git add -p
# Press 's' when prompted

# Edit hunk manually
git add -p
# Press 'e' when prompted
```

--ignore-whitespace

Ignore whitespace changes.

Examples:

```bash
# Stage ignoring whitespace
git add -p --ignore-whitespace

# Ignore whitespace in specific file
git add -p src/main.js --ignore-whitespace

# Quiet mode with whitespace ignore
git add -p -q --ignore-whitespace
```