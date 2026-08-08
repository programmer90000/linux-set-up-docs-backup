# Install trash-cli

Run:
```
sudo apt update
sudo apt install trash-cli
```

# Complete Documentation for trash-cli

## Table of Contents
1. [Introduction](#introduction)
3. [Understanding the Trash System](#understanding-the-trash-system)
4. [Command Reference](#command-reference)
5. [Advanced Usage](#advanced-usage)
6. [Troubleshooting](#troubleshooting)

---

## Introduction

**trash-cli** is a command-line interface to the FreeDesktop.org Trash specification, providing a safer alternative to the traditional `rm` command. Instead of permanently deleting files immediately, it moves them to a trash directory where they can be recovered if needed.

### Key Features
- Cross-desktop environment compatibility
- Supports multiple trash locations (home directory and mounted volumes)
- Restore files to their original locations
- Empty trash with age-based filtering
- List and selectively delete trashed files
- Preserves original file paths, permissions, and timestamps

---

---

## Understanding the Trash System

### Trash Locations
trash-cli follows the FreeDesktop.org specification, which defines two types of trash locations:

1. **Home Trash Directory**: `~/.local/share/Trash/`
   - Used for files on the same filesystem as your home directory
   - Contains two subdirectories:
     - `files/`: The actual trashed files
     - `info/`: Metadata including original paths and deletion dates

2. **Top-level Trash Directories**: `/.Trash-1000/` or `/.Trash/`
   - Created on external drives and separate partitions
   - The number (1000) corresponds to your user ID

### How It Works
When you trash a file:
1. The file is moved to the appropriate trash directory
2. A metadata file (`.trashinfo`) is created containing:
   - Original file path
   - Deletion timestamp
   - File permissions

---

## Command Reference

### 1. `trash-put` - Move Files to Trash
**Purpose**: Safely delete files by moving them to the trash.

**Syntax**:
```bash
trash-put [options] file1 file2...
```

**Examples**:
```bash
# Trash a single file
trash-put document.txt

# Trash multiple files
trash-put file1.txt file2.jpg file3.pdf

# Trash an entire directory
trash-put old_project/

# Trash files with wildcards
trash-put *.tmp
trash-put log_2023*.txt

# Trash files but preserve directory structure
trash-put -r backup_folder/
```

**Options**:
- `-r, --recursive`: Trash directories recursively
- `-f, --force`: Silently ignore nonexistent files
- `-v, --verbose`: Show detailed output

### 2. `trash-list` - List Trashed Files
**Purpose**: Display all files currently in the trash with their original locations.

**Syntax**:
```bash
trash-list [options]
```

**Examples**:
```bash
# List all trashed files
trash-list

# List with detailed information
trash-list --verbose

# List files trashed from a specific directory
trash-list | grep "/home/user/Documents"
```

**Sample Output**:
```
2024-01-15 10:30:45 /home/user/Documents/old_report.txt
2024-01-14 15:20:10 /home/user/Downloads/setup.exe
2024-01-13 09:00:00 /home/user/Pictures/screenshot.png
```

### 3. `trash-restore` - Restore Trashed Files
**Purpose**: Interactively restore files from trash to their original locations.

**Syntax**:
```bash
trash-restore [options]
```

**Interactive Usage**:
```bash
$ trash-restore
   0 2024-01-15 10:30:45 /home/user/Documents/old_report.txt
   1 2024-01-14 15:20:10 /home/user/Downloads/setup.exe
   2 2024-01-13 09:00:00 /home/user/Pictures/screenshot.png
What file to restore [0..2]: 0
```

**Non-interactive Usage**:
```bash
# Restore by matching pattern (using external tools)
trash-list | grep "report" | cut -d' ' -f1 | xargs -I {} trash-restore --match {} --force

# Restore all files from a specific date
trash-list | grep "2024-01-15" | while read line; do
    echo "$line" | cut -d' ' -f1 | xargs trash-restore
done
```

### 4. `trash-empty` - Empty the Trash
**Purpose**: Permanently delete files from the trash.

**Syntax**:
```bash
trash-empty [days] [options]
```

**Examples**:
```bash
# Empty entire trash
trash-empty

# Empty files older than 30 days
trash-empty 30

# Empty files older than 7 days with verbose output
trash-empty 7 --verbose

# Force empty without confirmation
trash-empty --force
```

**How age filtering works**:
- `trash-empty 30`: Deletes files trashed more than 30 days ago
- Files are kept for exactly the specified number of days
- The count starts from the deletion date, not the current date

### 5. `trash-rm` - Remove Specific Files from Trash
**Purpose**: Permanently delete specific files from the trash without restoring them.

**Syntax**:
```bash
trash-rm pattern
```

**Examples**:
```bash
# Remove files matching a pattern
trash-rm "*.tmp"

# Remove specific filename
trash-rm "old_report.txt"

# Remove files from a specific directory
trash-rm "*/Documents/*"

# Remove using regex (advanced)
trash-rm ".*\.log$"
```

**Note**: The pattern is matched against the original filenames, not the trashed names.

### 6. `trash-info` - Display Trash Information
**Purpose**: Show detailed information about trashed files.

**Syntax**:
```bash
trash-info [file_pattern]
```

**Examples**:
```bash
# Show info about all trashed files
trash-info

# Show info about specific files
trash-info "*.txt"
```

### 7. `trash-truncate` - Truncate Trash Database
**Purpose**: Optimize or repair the trash metadata database.

**Syntax**:
```bash
trash-truncate [options]
```

**Examples**:
```bash
# Optimize trash database
trash-truncate

# Force truncation
trash-truncate --force
```

---

### Is trash-cli a replacement for rm?
**A**: No, it's a complementary tool. Use `trash-put` for interactive deletion where recovery might be needed. Use `rm` for scripts and when you're certain you won't need the files back.

### How do I recover files without trash-restore?
**A**: You can manually copy from `~/.local/share/Trash/files/` but you'll need to check `~/.local/share/Trash/info/` for original paths.

### How do I check trash size?
**A**: Use standard du command:
```bash
du -sh ~/.local/share/Trash/
```