# Git

## Configuration

| Command                    | Purpose                  |
|----------------------------|--------------------------|
| git config --global --edit | Edit the git config file |

## Remote Repositories

| Command                     | Purpose                                                                                              |
|-----------------------------|------------------------------------------------------------------------------------------------------|
| git remote -v               | List all remote repositories with their fetch and push URLs                                          |
| git clone -b <branch> <url> | Only clone a single branch from a git repository                                                     |
| git push --force-with-lease | Force push only if your remote references match your expected ones                                   |
| git fetch --prune           | Download remote changes and delete local remote-tracking branches that no longer exist on the remote |
| git pull --rebase           | Fetch remote changes and rebase local commits on top instead of merging (cleaner history)            |

## Staging Changes

| Command                     | Purpose                                                                   |
|-----------------------------|---------------------------------------------------------------------------|
| git add .                   | Stage all changes in the current directory and any subdirectories         |
| git add --all               | Stage all changes in the repository                                       |
| git rm --cached <file>      | Remove a file from the staging area without removing it from the computer |
| git restore --staged <file> | Remove a file from the staging area without changing working directory    |
| git add -p <file> | Enter interactive hunk-by-hunk staging mode for the specified file |

## Interactive Staging (git add -p)

| Command | Purpose                                                                               |
|---------|---------------------------------------------------------------------------------------|
| y       | Stage the current hunk                                                                |
| n       | Do not stage the current hunk                                                         |
| q       | Quit - do not stage the current hunk or any remaining hunks                           |
| a       | Stage this hunk and all remaining hunks in this file without further prompts          |
| g       | Go to a specific hunk number (useful for large files with many changes)               |
| /       | Search forward for a hunk containing a specific regular expression pattern            |
| s       | Split the current hunk into smaller hunks (when lines are too close together)         |
| e       | Manually edit the current hunk in your text editor for precise line-by-line control   |
| ?       | Display help menu showing all available interactive staging commands                  |
| j       | Leave this hunk undecided and move to the next undecided hunk                         |
| J       | Leave this hunk undecided and move to the next hunk regardless of its decision status |
| k       | Move back to the previous undecided hunk (reverse navigation)                         |
| K       | Move back to the previous hunk while keeping current hunk undecided                   |

## Committing

| Command                         | Purpose                                                                                         |
|---------------------------------|-------------------------------------------------------------------------------------------------|
| git commit --amend -m "message" | Amend a commit message                                                                          |
| git commit --fixup=<commit>     | Create a commit that will automatically squash into the target commit during interactive rebase |

## Branches

| Command               | Purpose                                                       |
|-----------------------|---------------------------------------------------------------|
| git branch            | Display all branches with an * before the current branch      |
| git branch <name>     | Create a new branch at the current commit                     |
| git checkout <branch> | Switch to an existing branch                                  |
| git merge <branch>    | Integrate changes from another branch into the current branch |


## Diff

| Command                       | Purpose                                                                   |
|-------------------------------|---------------------------------------------------------------------------|
| git diff                      | Review what changes have been made before staging them                    |
| git diff --staged             | Review what changes have been made to files in the staging area           |
| git diff <branch1>..<branch2> | Show differences between two branches (changes in branch2 not in branch1) |
| git diff HEAD~n               | Compare current working directory with the state n commits ago            |

## Log

| Command           | Purpose                                                          |
|-------------------|------------------------------------------------------------------|
| git log           | Display commit history                                           |
| git log --oneline | Display commit history with each commit taking one line of space |

## Reset

| Command                    | Purpose                                                                       |
|----------------------------|-------------------------------------------------------------------------------|
| git reset --soft <commit>  | Move HEAD back to a commit, keeping all changes staged                        |
| git reset --mixed <commit> | Move HEAD back to a commit, keeping changes in working directory but unstaged |
| git reset --hard <commit>  | Move HEAD back to a commit, discarding all changes completely (dangerous)     |
| git revert <commit>        | Create a new commit that undoes the one specified commit only                 |
| git restore <file>         | Discard unstaged changes in a file                                            |
| git clean -fd              | Remove all untracked files and directories from working directory             |

## Stash

| Command                     | Purpose                                                                                 |
|-----------------------------|-----------------------------------------------------------------------------------------|
| git stash push -m "message" | Save uncommitted changes temporarily with a descriptive label                           |
| git stash list              | Display all stashed changes with their indices and messages                             |
| git stash pop               | Apply the most recent stash to your working directory and remove it from the stash list |
| git stash apply             | Apply the most recent stash to your working directory but keep it in the stash list     |
| git stash branch <name>     | Create a new branch from the commit where the stash was created, then apply the stash   |

## Rebase

| Command              | Purpose                                                                            |
|----------------------|------------------------------------------------------------------------------------|
| git rebase <branch>  | Reapply commits from current branch on top of the target branch (linear history)   |
| git rebase -i HEAD~n | Interactive rebase for the last n commits - squash, reword, reorder, edit, or drop |

## Cherry Pick
| Command                       | Purpose                                                              |
|-------------------------------|----------------------------------------------------------------------|
| git cherry-pick <commit-hash> | Apply a specific commit from another branch into your current branch |

## Tag

| Command                      | Purpose                                                           |
|------------------------------|-------------------------------------------------------------------|
| git tag                      | List all tags in the repository alphabetically                    |
| git tag -a v1.0 -m "message" | Create an annotated tag with a message (recommended for releases) |
| git push --tags              | Upload all local tags to the remote repository                    |
jhn