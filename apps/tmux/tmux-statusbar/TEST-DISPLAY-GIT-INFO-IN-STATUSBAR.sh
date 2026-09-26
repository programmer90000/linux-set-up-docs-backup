#!/bin/bash

set -e  # Exit on any error

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Tmux Git Data Plugin Installer${NC}"
echo -e "${GREEN}  For Debian 13 (Fresh Installation)${NC}"
echo -e "${GREEN}========================================${NC}\n"

if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run this script as root. Run as a regular user.${NC}"
    exit 1
fi

USER_HOME="$HOME"
echo -e "${YELLOW}Installing for user: $(whoami)${NC}"
echo -e "${YELLOW}Home directory: ${USER_HOME}${NC}"

# Function to print section headers
print_section() {
    echo -e "\n${BLUE}==>${NC} ${YELLOW}$1${NC}\n"
}

# Function to check if command succeeded
check_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1 successful${NC}"
    else
        echo -e "${RED}✗ $1 failed${NC}"
        exit 1
    fi
}

#===========================================
# PART 1: Update System and Install Prerequisites (with sudo)
#===========================================
print_section "Part 1: Updating System and Installing Prerequisites"

echo -e "${YELLOW}Updating package lists (requires sudo)...${NC}"
sudo apt update -y
check_success "Package list update"

echo -e "${YELLOW}Installing essential build tools and dependencies (requires sudo)...${NC}"
sudo apt install -y build-essential pkg-config libssl-dev tmux
check_success "Essential packages installation"


#===========================================
# PART 2: Install Go Programming Language (with sudo)
#===========================================
print_section "Part 2: Installing Go Programming Language"

GO_VERSION="1.21.5"
GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://dl.google.com/go/${GO_TAR}"

echo -e "${YELLOW}Downloading Go ${GO_VERSION}...${NC}"
wget -q --show-progress ${GO_URL}
check_success "Go download"

echo -e "${YELLOW}Extracting Go to /usr/local (requires sudo)...${NC}"
sudo tar -C /usr/local -xzf ${GO_TAR}
check_success "Go extraction"

# Set up Go environment variables for the user
echo -e "${YELLOW}Configuring Go environment...${NC}"
mkdir -p ${USER_HOME}/go
mkdir -p ${USER_HOME}/.config

# Add to bashrc if not already there
if ! grep -q "GOPATH=${USER_HOME}/go" ${USER_HOME}/.bashrc; then
    echo '' >> ${USER_HOME}/.bashrc
    echo '# Go environment variables' >> ${USER_HOME}/.bashrc
    echo 'export GOPATH=$HOME/go' >> ${USER_HOME}/.bashrc
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ${USER_HOME}/.bashrc
fi

# Apply to current session
export GOPATH=${USER_HOME}/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Verify Go installation
go version
check_success "Go installation"

# Clean up downloaded tar
rm ${GO_TAR}

#===========================================
# PART 3: Create Plugin Directory Structure
#===========================================
print_section "Part 3: Creating Plugin Directory Structure"

# Create all necessary directories in user's home
PLUGIN_DIR="${USER_HOME}/.tmux/plugins/tmux-git-data"
mkdir -p ${PLUGIN_DIR}/bin
mkdir -p ${PLUGIN_DIR}/scripts

echo -e "${YELLOW}Plugin directory created at: ${PLUGIN_DIR}${NC}"
ls -la ${PLUGIN_DIR} 2>/dev/null || echo "Directory created"

#===========================================
# PART 4: Create the Go Program (UPDATED with renamed files)
#===========================================
print_section "Part 4: Creating Go Git Data Extractor"

# Navigate to plugin directory
cd ${PLUGIN_DIR}

# Create the Go module
go mod init tmux-git-data 2>/dev/null || true
check_success "Go module initialization"

# Install required Go packages
echo -e "${YELLOW}Installing go-git library...${NC}"
go get github.com/go-git/go-git/v5
check_success "go-git installation"

# Create the main Go program with renamed files support
cat > ${PLUGIN_DIR}/gitdata.go << 'EOF'
package main

import (
    "encoding/json"
    "fmt"
    "os"
    "path/filepath"
    "strings"

    "github.com/go-git/go-git/v5"
    "github.com/go-git/go-git/v5/plumbing"
    "github.com/go-git/go-git/v5/plumbing/object"    // Add this
    "github.com/go-git/go-git/v5/plumbing/storer"    // Add this
)

type GitStatus struct {
    IsRepo           bool   `json:"is_repo"`
    Path             string `json:"path"`
    RootDir          string `json:"root_dir"`
    Branch           string `json:"branch"`
    CommitHash       string `json:"commit_hash"`
    CommitHashShort  string `json:"commit_hash_short"`
    IsDetached       bool   `json:"is_detached"`
    IsInitial        bool   `json:"is_initial"`
    RemoteName       string `json:"remote_name"`
    RemoteBranch     string `json:"remote_branch"`
    RemoteURL        string `json:"remote_url"`
    AheadCount       int    `json:"ahead_count"`
    BehindCount      int    `json:"behind_count"`
    StagedFiles      int    `json:"staged_files"`
    ModifiedFiles    int    `json:"modified_files"`
    DeletedFiles     int    `json:"deleted_files"`
    UntrackedFiles   int    `json:"untracked_files"`
    RenamedFiles     int    `json:"renamed_files"`      // NEW: renamed files count
    ConflictFiles    int    `json:"conflict_files"`
    StashCount       int    `json:"stash_count"`
    IsMerging        bool   `json:"is_merging"`
    IsRebasing       bool   `json:"is_rebasing"`
    IsCherryPicking  bool   `json:"is_cherry_picking"`
}

func main() {
    dir := "."
    if len(os.Args) > 1 {
        dir = os.Args[1]
    }
    
    field := ""
    if len(os.Args) > 2 {
        field = os.Args[2]
    }
    
    status := getAllGitData(dir)
    
    if field == "" || field == "all" {
        jsonData, _ := json.MarshalIndent(status, "", "  ")
        fmt.Println(string(jsonData))
    } else {
        outputField(status, field)
    }
}

func getAllGitData(path string) *GitStatus {
    status := &GitStatus{
        IsRepo:       false,
        StashCount:   0,
    }
    
    repo, err := git.PlainOpen(path)
    if err != nil {
        return status
    }
    
    status.IsRepo = true
    status.Path = path
    
    wt, _ := repo.Worktree()
    if wt != nil {
        status.RootDir = wt.Filesystem.Root()
    }
    
    // Get HEAD reference
    head, err := repo.Head()
    if err == nil {
        status.CommitHash = head.Hash().String()
        if len(status.CommitHash) >= 7 {
            status.CommitHashShort = status.CommitHash[:7]
        }
        
        if head.Name().IsBranch() {
            status.Branch = head.Name().Short()
            status.IsDetached = false
        } else {
            status.Branch = "detached"
            status.IsDetached = true
        }
    } else {
        status.IsInitial = true
    }
    
    // Get remote information and calculate ahead/behind
    remotes, _ := repo.Remotes()
    if len(remotes) > 0 {
        status.RemoteName = remotes[0].Config().Name
        if len(remotes[0].Config().URLs) > 0 {
            status.RemoteURL = remotes[0].Config().URLs[0]
        }
        
        // Calculate ahead/behind counts if we have a branch and remote
        if status.Branch != "" && status.Branch != "detached" && status.RemoteName != "" {
            remoteRefName := plumbing.NewRemoteReferenceName(status.RemoteName, status.Branch)
            remoteRef, err := repo.Reference(remoteRefName, true)
            if err == nil {
                status.RemoteBranch = remoteRef.Name().Short()
                
                // Calculate ahead/behind counts
                ahead, behind, err := calculateAheadBehind(repo, head.Hash(), remoteRef.Hash())
                if err == nil {
                    status.AheadCount = ahead
                    status.BehindCount = behind
                }
            }
        }
    }
    
    // Get working tree status
    if wt != nil {
        gitStatus, _ := wt.Status()
        
        for _, fileStatus := range gitStatus {
            // Check staging area
            if fileStatus.Staging != git.Unmodified {
                status.StagedFiles++
                
                // Check for renamed files in staging area
                if fileStatus.Staging == git.Renamed {
                    status.RenamedFiles++
                }
            }
            
            // Check worktree
            if fileStatus.Worktree == git.Modified {
                status.ModifiedFiles++
            } else if fileStatus.Worktree == git.Deleted {
                status.DeletedFiles++
            } else if fileStatus.Worktree == git.Untracked {
                status.UntrackedFiles++
            }
            
            // Check for renamed files in worktree (though this is rare)
            if fileStatus.Worktree == git.Renamed {
                status.RenamedFiles++
            }
            
            // Conflicts
            if fileStatus.Staging == git.UpdatedButUnmerged {
                status.ConflictFiles++
            }
        }
    }
    
    // Get stash count
    if wt != nil {
        gitDir := filepath.Join(wt.Filesystem.Root(), ".git")
        stashRefPath := filepath.Join(gitDir, "refs", "stash")
        if _, err := os.Stat(stashRefPath); err == nil {
            data, _ := os.ReadFile(stashRefPath)
            if len(data) > 0 {
                status.StashCount = 1
            }
        }
        
        stashLogPath := filepath.Join(gitDir, "logs", "refs", "stash")
        if _, err := os.Stat(stashLogPath); err == nil {
            data, _ := os.ReadFile(stashLogPath)
            if len(data) > 0 {
                lines := strings.Split(string(data), "\n")
                count := 0
                for _, line := range lines {
                    if strings.TrimSpace(line) != "" {
                        count++
                    }
                }
                if count > status.StashCount {
                    status.StashCount = count
                }
            }
        }
    }
    
    // Check for merge/rebase/cherry-pick states
    if wt != nil {
        gitDir := filepath.Join(wt.Filesystem.Root(), ".git")
        
        if _, err := os.Stat(filepath.Join(gitDir, "MERGE_HEAD")); err == nil {
            status.IsMerging = true
        }
        
        if _, err := os.Stat(filepath.Join(gitDir, "rebase-apply")); err == nil {
            status.IsRebasing = true
        }
        
        if _, err := os.Stat(filepath.Join(gitDir, "CHERRY_PICK_HEAD")); err == nil {
            status.IsCherryPicking = true
        }
    }
    
    return status
}

// Helper function to calculate ahead/behind counts
func calculateAheadBehind(repo *git.Repository, local, remote plumbing.Hash) (int, int, error) {
    // Get the commit objects
    localCommit, err := repo.CommitObject(local)
    if err != nil {
        return 0, 0, err
    }
    
    remoteCommit, err := repo.CommitObject(remote)
    if err != nil {
        return 0, 0, err
    }
    
    // Find the merge base
    base, err := localCommit.MergeBase(remoteCommit)
    if err != nil {
        return 0, 0, err
    }
    
    if len(base) == 0 {
        // No common ancestor - count all commits as ahead/behind
        localCount, err := countCommits(repo, localCommit, nil)
        if err != nil {
            return 0, 0, err
        }
        remoteCount, err := countCommits(repo, remoteCommit, nil)
        if err != nil {
            return 0, 0, err
        }
        return localCount, remoteCount, nil
    }
    
    // Count commits from base to local (ahead)
    ahead, err := countCommits(repo, localCommit, base[0])
    if err != nil {
        return 0, 0, err
    }
    
    // Count commits from base to remote (behind)
    behind, err := countCommits(repo, remoteCommit, base[0])
    if err != nil {
        return 0, 0, err
    }
    
    return ahead, behind, nil
}

// Helper function to count commits between two points
func countCommits(repo *git.Repository, from, to *object.Commit) (int, error) {
    if to != nil && from.Hash == to.Hash {
        return 0, nil
    }
    
    count := 0
    commitIter := object.NewCommitPreorderIter(from, nil, nil)
    err := commitIter.ForEach(func(c *object.Commit) error {
        if to != nil && c.Hash == to.Hash {
            return storer.ErrStop
        }
        count++
        return nil
    })
    
    if err != nil && err != storer.ErrStop {
        return 0, err
    }
    
    return count, nil
}
func outputField(status *GitStatus, field string) {
    switch field {
    case "branch":
        fmt.Print(status.Branch)
    case "commit":
        fmt.Print(status.CommitHashShort)
    case "commit_full":
        fmt.Print(status.CommitHash)
    case "remote":
        fmt.Print(status.RemoteName)
    case "remote_branch":
        fmt.Print(status.RemoteBranch)
    case "remote_url":
        fmt.Print(status.RemoteURL)
    case "ahead":
        fmt.Print(status.AheadCount)
    case "behind":
        fmt.Print(status.BehindCount)
    case "staged":
        fmt.Print(status.StagedFiles)
    case "modified":
        fmt.Print(status.ModifiedFiles)
    case "deleted":
        fmt.Print(status.DeletedFiles)
    case "untracked":
        fmt.Print(status.UntrackedFiles)
    case "renamed":                                  // NEW: renamed files command
        fmt.Print(status.RenamedFiles)
    case "conflicts":
        fmt.Print(status.ConflictFiles)
    case "stashes":
        fmt.Print(status.StashCount)
    case "is_clean":
        if status.StagedFiles == 0 && status.ModifiedFiles == 0 && 
           status.UntrackedFiles == 0 && status.DeletedFiles == 0 && 
           status.RenamedFiles == 0 {                // NEW: include renamed in clean check
            fmt.Print("clean")
        } else {
            fmt.Print("dirty")
        }
    case "is_merging":
        fmt.Print(status.IsMerging)
    case "is_rebasing":
        fmt.Print(status.IsRebasing)
    case "root_dir":
        fmt.Print(status.RootDir)
    default:
        fmt.Print("")
    }
}
EOF

echo -e "${GREEN}✓ Go source file created (with renamed files support)${NC}"

#===========================================
# PART 5: Build the Go Program
#===========================================
print_section "Part 5: Building the Go Program"

cd ${PLUGIN_DIR}
echo -e "${YELLOW}Building git-data-extractor...${NC}"
go mod tidy
go build -o ${PLUGIN_DIR}/bin/git-data-extractor gitdata.go
check_success "Go build"

# Create a symbolic link in /usr/local/bin (requires sudo)
echo -e "${YELLOW}Creating system-wide link (requires sudo)...${NC}"
sudo ln -sf ${PLUGIN_DIR}/bin/git-data-extractor /usr/local/bin/git-data
check_success "Symbolic link creation"

echo -e "${GREEN}✓ Binary built at: ${PLUGIN_DIR}/bin/git-data-extractor${NC}"
echo -e "${GREEN}✓ System command created: git-data${NC}"

# Test the binary
echo -e "${YELLOW}Testing binary...${NC}"
${PLUGIN_DIR}/bin/git-data-extractor --help 2>/dev/null || echo -e "${GREEN}✓ Binary is executable${NC}"

#===========================================
# PART 6: Create Tmux Plugin File (UPDATED with renamed files)
#===========================================
print_section "Part 6: Creating Tmux Plugin Configuration"

# Navigate to the plugin directory
cd ~/.tmux/plugins/tmux-git-data

# Fix the tmux plugin file
cat > git-data.tmux << 'EOF'
#!/usr/bin/env bash

# Get the plugin directory
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BINARY="${CURRENT_DIR}/bin/git-data-extractor"

# Simple key bindings that work - no xargs, direct output
tmux bind-key G run-shell "$BINARY \"#{pane_current_path}\" branch && tmux display-message \"Branch: \$($BINARY \"#{pane_current_path}\" branch)\""
tmux bind-key H run-shell "$BINARY \"#{pane_current_path}\" commit && tmux display-message \"Commit: \$($BINARY \"#{pane_current_path}\" commit)\""
tmux bind-key M run-shell "$BINARY \"#{pane_current_path}\" modified && tmux display-message \"Modified: \$($BINARY \"#{pane_current_path}\" modified)\""
tmux bind-key U run-shell "$BINARY \"#{pane_current_path}\" untracked && tmux display-message \"Untracked: \$($BINARY \"#{pane_current_path}\" untracked)\""
tmux bind-key S run-shell "$BINARY \"#{pane_current_path}\" stashes && tmux display-message \"Stashes: \$($BINARY \"#{pane_current_path}\" stashes)\""
tmux bind-key C run-shell "$BINARY \"#{pane_current_path}\" conflicts && tmux display-message \"Conflicts: \$($BINARY \"#{pane_current_path}\" conflicts)\""
tmux bind-key R run-shell "$BINARY \"#{pane_current_path}\" renamed && tmux display-message \"Renamed: \$($BINARY \"#{pane_current_path}\" renamed)\""  # NEW: renamed files

# Dashboard command (UPDATED with renamed files)
tmux bind-key D run-shell "
    BRANCH=\$($BINARY \"#{pane_current_path}\" branch)
    COMMIT=\$($BINARY \"#{pane_current_path}\" commit)
    STAGED=\$($BINARY \"#{pane_current_path}\" staged)
    MODIFIED=\$($BINARY \"#{pane_current_path}\" modified)
    UNTRACKED=\$($BINARY \"#{pane_current_path}\" untracked)
    RENAMED=\$($BINARY \"#{pane_current_path}\" renamed)
    tmux display-message \"Git: \$BRANCH (\$COMMIT) | Staged: \$STAGED Mod: \$MODIFIED New: \$UNTRACKED Renamed: \$RENAMED\"
"

# Quick summary
tmux bind-key T run-shell "
    BRANCH=\$($BINARY \"#{pane_current_path}\" branch)
    COMMIT=\$($BINARY \"#{pane_current_path}\" commit)
    tmux display-message \"\$BRANCH (\$COMMIT)\"
"

# Clean status (UPDATED to use new is_clean)
tmux bind-key L run-shell "
    CLEAN=\$($BINARY \"#{pane_current_path}\" is_clean)
    tmux display-message \"Repository is \$CLEAN\"
"

tmux display-message "Git Data Plugin loaded! Try prefix + G for branch, R for renamed files"
EOF

# Make it executable
chmod +x git-data.tmux

chmod +x ${PLUGIN_DIR}/git-data.tmux
check_success "Tmux plugin file creation"

#===========================================
# PART 7: Configure Tmux (UPDATED help text)
#===========================================
print_section "Part 7: Configuring Tmux"

TMUX_CONF="${USER_HOME}/.tmux.conf"
cat > ${TMUX_CONF} << 'EOF'
# Tmux Configuration - Git Data Plugin

# Set prefix to Ctrl-a (easier to reach)
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Increase scrollback history
set -g history-limit 10000

# Enable mouse mode
set -g mouse on

# Status bar customization
set -g status-interval 1
set -g status-justify centre

# Load our plugin
run-shell ~/.tmux/plugins/tmux-git-data/git-data.tmux

# Additional help text (UPDATED with renamed files)
bind-key ? run-shell "tmux display-message 'Git Plugin: G=branch, H=commit, M=modified, U=untracked, R=renamed, S=stashes, C=conflicts, D=dashboard, T=summary, L=clean status'"
EOF

check_success "Tmux configuration"

#===========================================
# PART 8: Create Test Git Repository (UPDATED with rename test)
#===========================================
print_section "Part 8: Creating Test Git Repository"

TEST_REPO="${USER_HOME}/test-git-repo"
mkdir -p ${TEST_REPO}
cd ${TEST_REPO}

echo -e "${YELLOW}Initializing Git repository...${NC}"
git init
check_success "Git init"

# Configure Git user for commits
git config user.name "Test User"
git config user.email "test@example.com"

# Create initial files and commits
echo -e "${YELLOW}Creating test files and commits...${NC}"

# First commit
echo "# Test Repository" > README.md
echo "console.log('Hello World');" > app.js
git add README.md app.js
git commit -m "Initial commit: Add README and app.js"
echo -e "${GREEN}✓ Commit 1 created${NC}"

# Second commit - modify files
cat >> app.js << 'EOF'
function greet(name) {
    return `Hello, ${name}!`;
}
EOF
echo "node_modules/" > .gitignore
git add app.js .gitignore
git commit -m "Add greet function and gitignore"
echo -e "${GREEN}✓ Commit 2 created${NC}"

# Third commit - add more files
mkdir -p src
echo "export const VERSION = '1.0.0';" > src/version.js
git add src/version.js
git commit -m "Add version module"
echo -e "${GREEN}✓ Commit 3 created${NC}"

# Create some uncommitted changes for testing
echo "// TODO: implement this feature" >> src/version.js
echo "tempfile.txt" > untracked-file.txt
mkdir -p src/utils
echo "// Utility functions will go here" > src/utils/helpers.js

# Create a stash for testing
echo "// Stashed change" > stash-test.js
git add stash-test.js
git stash push -m "Test stash" 2>/dev/null || true

# Create a renamed file for testing (NEW)
echo "// Original content" > original-name.js
git add original-name.js
git commit -m "Add original-name.js"
echo "// Modified content" > original-name.js
git mv original-name.js renamed-file.js 2>/dev/null || mv original-name.js renamed-file.js
git add -A 2>/dev/null || true

echo -e "\n${GREEN}Test repository created at: ${TEST_REPO}${NC}"
echo -e "Repository has:"
echo -e "  - 4 commits (one added for rename test)"
echo -e "  - Modified file (src/version.js)"
echo -e "  - Untracked file (untracked-file.txt)"
echo -e "  - New directory with untracked file (src/utils/helpers.js)"
echo -e "  - 1 stash entry"
echo -e "  - 1 renamed file (original-name.js → renamed-file.js)"

# Show repository status
cd ${TEST_REPO}
echo -e "\n${YELLOW}Current Git status:${NC}"
git status -s

#===========================================
# PART 9: Create Test Script (UPDATED with renamed files)
#===========================================
print_section "Part 9: Creating Test Script"

TEST_SCRIPT="${USER_HOME}/test-plugin.sh"
cat > ${TEST_SCRIPT} << 'EOF'
#!/bin/bash

echo "Testing Git Data Plugin..."
echo "=========================="

cd ~/test-git-repo

echo -e "\n1. Testing binary directly:"
echo "   Branch: $(~/.tmux/plugins/tmux-git-data/bin/git-data-extractor . branch)"
echo "   Commit: $(~/.tmux/plugins/tmux-git-data/bin/git-data-extractor . commit)"
echo "   Modified: $(~/.tmux/plugins/tmux-git-data/bin/git-data-extractor . modified)"
echo "   Untracked: $(~/.tmux/plugins/tmux-git-data/bin/git-data-extractor . untracked)"
echo "   Staged: $(~/.tmux/plugins/tmux-git-data/bin/git-data-extractor . staged)"
echo "   Renamed: $(~/.tmux/plugins/tmux-git-data/bin/git-data-extractor . renamed)"
echo "   Stashes: $(~/.tmux/plugins/tmux-git-data/bin/git-data-extractor . stashes)"

echo -e "\n2. Testing JSON output:"
~/.tmux/plugins/tmux-git-data/bin/git-data-extractor . all | jq '. | {branch, commit_hash_short, modified_files, untracked_files, staged_files, renamed_files, stash_count}'

echo -e "\n3. Testing system command:"
echo "   Branch: $(git-data . branch)"
echo "   Commit: $(git-data . commit)"
echo "   Renamed: $(git-data . renamed)"

echo -e "\n4. To test in Tmux, run: tmux new -s test"
echo "   Then press: Ctrl-a + G (for branch)"
echo "              Ctrl-a + H (for commit)"
echo "              Ctrl-a + M (for modified files)"
echo "              Ctrl-a + U (for untracked files)"
echo "              Ctrl-a + R (for renamed files)"
echo "              Ctrl-a + S (for stashes)"
echo "              Ctrl-a + D (for dashboard)"
echo "              Ctrl-a + ? (for help)"
EOF

chmod +x ${TEST_SCRIPT}
check_success "Test script creation"

#===============================================================================
# I added this part myself. Display git branch in Tmux status bar. I need to update this to display all data I want to display and move the file into the correct directory
#===============================================================================
cat > ~/.tmux.conf << 'EOF'
set -g status-right-length 100
set -g status-right "#(git-data '#{pane_current_path}' branch)#[fg=colour245] on #[fg=colour33]#(git-data '#{pane_current_path}' commit) #[fg=colour245]| #[fg=colour240]%H:%M %d-%b-%y"
EOF

#===========================================
# PART 10: Final Setup and Instructions (UPDATED with renamed files)
#===========================================
print_section "Part 10: Installation Complete!"

echo -e "${GREEN}✓✓✓ ALL INSTALLATIONS COMPLETED SUCCESSFULLY ✓✓✓${NC}\n"

echo -e "${YELLOW}Installation Summary:${NC}"
echo -e "  • Tmux version: $(tmux -V)"
echo -e "  • Go version: $(go version)"
echo -e "  • Git version: $(git --version)"
echo -e "  • Plugin location: ${PLUGIN_DIR}"
echo -e "  • Test repository: ${TEST_REPO}"
echo -e "  • Test script: ${TEST_SCRIPT}"
echo -e "  • Tmux config: ${TMUX_CONF}\n"

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}WHAT WAS INSTALLED:${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"

echo -e "1. ${GREEN}System packages (with sudo):${NC}"
echo -e "   • git, tmux, jq, build-essential, curl, wget, etc."

echo -e "\n2. ${GREEN}Go programming language:${NC}"
echo -e "   • /usr/local/go"

echo -e "\n3. ${GREEN}Plugin files (in your home):${NC}"
echo -e "   • ${PLUGIN_DIR}/bin/git-data-extractor"
echo -e "   • ${PLUGIN_DIR}/gitdata.go"
echo -e "   • ${PLUGIN_DIR}/git-data.tmux"

echo -e "\n4. ${GREEN}System command (with sudo):${NC}"
echo -e "   • /usr/local/bin/git-data -> points to your binary"

echo -e "\n5. ${GREEN}Test repository:${NC}"
echo -e "   • ${TEST_REPO} (includes renamed file test)"

echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}HOW TO USE YOUR PLUGIN:${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"

echo -e "1. ${GREEN}Test the binary directly (no tmux needed):${NC}"
echo "   $ bash ~/test-plugin.sh"
echo ""

echo -e "2. ${GREEN}Start Tmux:${NC}"
echo "   $ tmux new -s test"
echo ""

echo -e "3. ${GREEN}Navigate to test repository (inside tmux):${NC}"
echo "   $ cd ~/test-git-repo"
echo ""

echo -e "4. ${GREEN}Try these key bindings (press prefix first - Ctrl-a):${NC}"
echo -e "   ${YELLOW}Ctrl-a + G${NC}    - Show current branch"
echo -e "   ${YELLOW}Ctrl-a + H${NC}    - Show current commit hash"
echo -e "   ${YELLOW}Ctrl-a + M${NC}    - Show number of modified files"
echo -e "   ${YELLOW}Ctrl-a + U${NC}    - Show number of untracked files"
echo -e "   ${YELLOW}Ctrl-a + R${NC}    - Show number of renamed files"
echo -e "   ${YELLOW}Ctrl-a + S${NC}    - Show stash count"
echo -e "   ${YELLOW}Ctrl-a + D${NC}    - Show Git dashboard"
echo -e "   ${YELLOW}Ctrl-a + ?${NC}    - Show help"
echo ""

echo -e "5. ${GREEN}Direct command usage (from anywhere):${NC}"
echo "   $ git-data ~/test-git-repo branch"
echo "   $ git-data ~/test-git-repo commit"
echo "   $ git-data ~/test-git-repo renamed"
echo "   $ git-data ~/test-git-repo all"
echo ""

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}TROUBLESHOOTING:${NC}"
echo -e "If commands don't work:"
echo -e "  1. Check if binary exists: ${GREEN}ls -la ~/.tmux/plugins/tmux-git-data/bin/${NC}"
echo -e "  2. Check if you're in a Git repo: ${GREEN}git status${NC}"
echo -e "  3. Reload tmux config: ${GREEN}tmux source-file ~/.tmux.conf${NC}"
echo -e "  4. Test binary directly: ${GREEN}~/.tmux/plugins/tmux-git-data/bin/git-data-extractor ~/test-git-repo renamed${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

# Final verification
echo -e "\n${YELLOW}Performing final verification...${NC}"

# Check all important files
if [ -f "${PLUGIN_DIR}/bin/git-data-extractor" ]; then
    echo -e "${GREEN}✓ Binary installed correctly${NC}"
else
    echo -e "${RED}✗ Binary not found${NC}"
fi

if [ -f "${TMUX_CONF}" ]; then
    echo -e "${GREEN}✓ Tmux config created${NC}"
else
    echo -e "${RED}✗ Tmux config missing${NC}"
fi

if [ -f "${TEST_SCRIPT}" ]; then
    echo -e "${GREEN}✓ Test script created${NC}"
else
    echo -e "${RED}✗ Test script missing${NC}"
fi

if [ -d "${TEST_REPO}" ]; then
    echo -e "${GREEN}✓ Test repository created${NC}"
else
    echo -e "${RED}✗ Test repository missing${NC}"
fi

if [ -f "/usr/local/bin/git-data" ]; then
    echo -e "${GREEN}✓ System command created${NC}"
else
    echo -e "${RED}✗ System command missing${NC}"
fi

# Quick test
echo -e "\n${YELLOW}Quick test of the binary:${NC}"
cd ${TEST_REPO}
BRANCH=$(${PLUGIN_DIR}/bin/git-data-extractor . branch)
COMMIT=$(${PLUGIN_DIR}/bin/git-data-extractor . commit)
RENAMED=$(${PLUGIN_DIR}/bin/git-data-extractor . renamed)
echo -e "Current branch in test repo: ${GREEN}$BRANCH${NC}"
echo -e "Current commit in test repo: ${GREEN}$COMMIT${NC}"
echo -e "Renamed files in test repo: ${GREEN}$RENAMED${NC}"

echo -e "\n${GREEN}Installation complete! Run 'bash ~/test-plugin.sh' to verify everything works!${NC}"