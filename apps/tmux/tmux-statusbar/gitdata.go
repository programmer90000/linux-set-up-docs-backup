package main

import (
    "encoding/json"
    "fmt"
    "os"
    "path/filepath"
    "strings"

    "github.com/go-git/go-git/v5"
    "github.com/go-git/go-git/v5/plumbing"
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
    
    remotes, _ := repo.Remotes()
    if len(remotes) > 0 {
        status.RemoteName = remotes[0].Config().Name
        if len(remotes[0].Config().URLs) > 0 {
            status.RemoteURL = remotes[0].Config().URLs[0]
        }
        
        if status.Branch != "" && status.Branch != "detached" && status.RemoteName != "" {
            remoteRefName := plumbing.NewRemoteReferenceName(status.RemoteName, status.Branch)
            remoteRef, err := repo.Reference(remoteRefName, true)
            if err == nil {
                status.RemoteBranch = remoteRef.Name().Short()
            }
        }
    }
    
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