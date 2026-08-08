#!/bin/bash

sudo apt update
sudo apt install -y curl wget

validate_source() {
    local source="$1"
    
    # Check if it's a URL
    if [[ "$source" =~ ^https?:// ]]; then
        if curl --output /dev/null --silent --head --fail "$source"; then
            echo "URL"
            return 0
        else
            echo "Error: URL is not accessible." >&2
            return 1
        fi
    fi
    
    # Check if it's a local file
    local expanded_source="${source/#\~/$HOME}"
    
    if [[ ! -f "$expanded_source" ]]; then
        echo "Error: File does not exist." >&2
        return 1
    fi
    
    if [[ ! -x "$expanded_source" ]]; then
        echo "Error: File is not executable." >&2
        return 1
    fi
    
    echo "FILE"
    return 0
}

get_source() {
    local app_name="$1"
    local download_source
    
    read -p "Enter source for $app_name (URL or local executable file path): " download_source
    
    while true; do
        download_source=$(echo "$download_source" | xargs)
        
        if [[ -z "$download_source" ]]; then
            echo "Error: No input provided." >&2
            read -p "Please enter a valid URL or executable file path: " download_source
            continue
        fi
        
        validation_result=$(validate_source "$download_source")
        validation_status=$?
        
        if [[ $validation_status -eq 0 ]]; then
            source_type=$(echo "$validation_result" | head -n 1)
            if [[ "$source_type" == "URL" ]]; then
                echo "URL found: $download_source" >&2
                echo "$download_source"
                return 0
            elif [[ "$source_type" == "FILE" ]]; then
                expanded_source="${download_source/#\~/$HOME}"
                echo "Executable file found: $expanded_source" >&2
                echo "$expanded_source"
                return 0
            fi
        else
            echo "Invalid input: '$download_source' is not a valid URL or existing executable file." >&2
            echo "Requirements for local files:" >&2
            echo "    - File must exist" >&2
            echo "    - File must have execute permissions (chmod +x)" >&2
            echo "" >&2
            read -p "Please enter a valid URL or executable file path: " download_source
        fi
    done
}

install_from_source() {
    local source="$1"
    local app_name="$2"
    
    echo ""
    if [[ "$source" =~ ^https?:// ]]; then
        echo "Downloading $app_name from URL..."
        
        temp_dir=$(mktemp -d)
        cd "$temp_dir" || exit 1
        
        if wget --show-progress "$source"; then
            echo "Download completed successfully."
            
            downloaded_file=$(ls | head -n 1)
            
            if [[ "$downloaded_file" == *.sh ]]; then
                chmod +x "$downloaded_file"
                echo "Running $app_name installer..."
                ./"$downloaded_file"
            elif [[ "$downloaded_file" == *.deb ]]; then
                echo "Installing $app_name .deb package..."
                sudo apt install -y "./$downloaded_file"
                sudo apt-get install -f -y # Fix any dependency issues
            else
                echo "Unknown file type. Please install manually."
                ls -la
            fi
        else
            echo "Error: Failed to download from URL."
            exit 1
        fi
        
        # Clean up
        cd /tmp || exit
        rm -rf "$temp_dir"
        
    else
        echo "Installing $app_name from local file..."
        
        if [[ "$source" == *.deb ]]; then
            echo "Installing .deb package..."
            sudo apt install -y "$source"
            sudo apt-get install -f -y # Fix any dependency issues
        elif [[ "$source" == *.sh ]]; then
            echo "Running shell script installer..."
            "$source"
        else
            echo "Running executable file..."
            "$source"
        fi
    fi
}

install_zoom() {
    local source
    source=$(get_source "Zoom")
    install_from_source "$source" "Zoom"
    
    echo ""
    if command -v zoom &> /dev/null; then
        echo "Zoom has been successfully installed! You can launch Zoom by typing 'zoom' in the terminal"
    else
        echo "Installation completed, but 'zoom' command not found in PATH."
        echo "You may need to log out and back in, or manually launch Zoom from the installed location."
    fi
}

install_sniffnet() {
    local source
    source=$(get_source "Sniffnet")
    install_from_source "$source" "Sniffnet"
    
    echo ""
    if command -v sniffnet &> /dev/null; then
        echo "Sniffnet has been successfully installed! You can launch Sniffnet by typing 'sniffnet' in the terminal"
    else
        echo "Installation completed, but 'sniffnet' command not found in PATH."
        echo "You may need to log out and back in, or manually launch Sniffnet from the installed location."
    fi
}

read -p "What would you like to install? " install_target

install_target=$(echo "$install_target" | xargs)

if [[ "$install_target" == "Zoom" || "$install_target" == "zoom" ]]; then
    install_zoom
elif [[ "$install_target" == "Sniffnet" || "$install_target" == "sniffnet" ]]; then
    install_sniffnet
else
    echo "You entered an invalid app name to install"
    exit 1
fi