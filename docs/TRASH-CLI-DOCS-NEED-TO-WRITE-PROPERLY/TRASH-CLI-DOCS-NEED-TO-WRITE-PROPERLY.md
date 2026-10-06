# Install trash-cli

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

### How do I recover files without trash-restore?
**A**: You can manually copy from `~/.local/share/Trash/files/` but you'll need to check `~/.local/share/Trash/info/` for original paths.

### How do I check trash size?
**A**: Use standard du command:
```bash
du -sh ~/.local/share/Trash/
```