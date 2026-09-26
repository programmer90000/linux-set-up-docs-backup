#!/bin/bash

TMUX_CONF="tmux/tmux.conf"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: This script should not be run as root or with sudo.${NC}"
    echo "Please run it as a regular user."
    exit 1
fi

if [ ! -f "$TMUX_CONF" ]; then
    echo -e "${RED}Configuration file '$TMUX_CONF' not found.${NC}"
    echo "Please ensure the file exists in the correct location."
    exit 1
fi

echo -e "${GREEN}Refreshing package list${NC}"
sudo apt update

echo -e "${GREEN}Installing packages${NC}"
sudo apt install -y tmux build-essential pkg-config libssl-dev golang curl git

echo -e "${GREEN}Writing Go program${NC}"
mkdir -p ~/.config/tmux/plugins/tmux-git-data/bin/
mkdir -p ~/.config/tmux/plugins/tmux-git-data/scripts/
cd ~/.config/tmux/plugins/tmux-git-data/
go mod init tmux-git-data 2>/dev/null || true
# ! IMPORTANT: CLONE THIS REPO
go get github.com/go-git/go-git/v5
cp tmux/gitdata.go ~/.config/tmux/plugins/tmux-git-data/
go mod tidy
go build -o ~/.config/tmux/plugins/tmux-git-data/bin/git-data-extractor gitdata.go
sudo ln -sf ~/.config/tmux/plugins/tmux-git-data/bin/git-data-extractor /usr/local/bin/git-data
cp tmux/git-data.tmux ~/.config/tmux/plugins/tmux-git-data/
chmod +x ~/.config/tmux/plugins/tmux-git-data/git-data.tmux

echo -e "${GREEN}Copying tmux.conf${NC}"
mkdir -p ~/.config/tmux/
cp $TMUX_CONF ~/.config/tmux/

echo -e "${YELLOW}GitHub account information${NC}"
echo "Email: grrj50@outlook.com"
echo "Username: User6212"
echo -e "${GREEN}Using hardcoded Personal Access Token${NC}"

# GitHub Personal Access Token (hardcoded)
GITHUB_TOKEN="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"

# Test the token with more detailed output
echo -e "${YELLOW}Testing GitHub token...${NC}"

# Get both status code and response body
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/user")

# Extract status code (last line)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
# Extract response body (everything except last line)
BODY=$(echo "$RESPONSE" | sed '$d')

echo -e "${YELLOW}Response body:${NC} $BODY"
echo -e "${YELLOW}HTTP Code:${NC} $HTTP_CODE"

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}Token is valid! Authenticated as:${NC}"
    echo "$BODY" | grep -o '"login": "[^"]*"' | sed 's/"login": "//;s/"//'
elif [ "$HTTP_CODE" -eq 401 ]; then
    echo -e "${RED}Error: Token authentication failed (401).${NC}"
    echo -e "${YELLOW}Response:${NC} $BODY"
    echo ""
    echo "Possible issues:"
    echo "1. Token might be expired - generate a new one"
    echo "2. Token format might be incorrect"
    echo "3. Token might not have the right permissions"
    echo ""
    echo "Try testing your token manually with:"
    echo "curl -H \"Authorization: token $GITHUB_TOKEN\" https://api.github.com/user"
    exit 1
else
    echo -e "${RED}Error testing token. HTTP Code: $HTTP_CODE${NC}"
    echo -e "${YELLOW}Response:${NC} $BODY"
    exit 1
fi

# Continue with the rest of the script...
mkdir -p ~/tmux-git-data-repo
cd ~/tmux-git-data-repo

# Configure git user email and name
echo -e "${GREEN}Configuring git user...${NC}"
git config user.email "grrj50@outlook.com"
git config user.name "User6212"

echo -e "${GREEN}Checking if repository exists...${NC}"
REPO_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/User6212/test")

REPO_HTTP_CODE=$(echo "$REPO_RESPONSE" | tail -n1)
REPO_BODY=$(echo "$REPO_RESPONSE" | sed '$d')

echo -e "${YELLOW}Repository check HTTP Code:${NC} $REPO_HTTP_CODE"

if [ "$REPO_HTTP_CODE" -eq 404 ]; then
    echo -e "${GREEN}Repository doesn't exist. Creating...${NC}"
    CREATE_RESPONSE=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user/repos \
        -d '{"name":"test", "private":false, "auto_init":false}')
    
    # Check if creation was successful
    if echo "$CREATE_RESPONSE" | grep -q "id"; then
        echo -e "${GREEN}Repository created successfully${NC}"
    else
        echo -e "${RED}Failed to create repository. Response:${NC}"
        echo "$CREATE_RESPONSE"
        exit 1
    fi
elif [ "$REPO_HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}Repository already exists${NC}"
    echo "Clone URL: $(echo "$REPO_BODY" | grep -o '"clone_url": "[^"]*"' | sed 's/"clone_url": "//;s/"//')"
elif [ "$REPO_HTTP_CODE" -eq 401 ]; then
    echo -e "${RED}Authentication failed when checking repository.${NC}"
    echo "Response: $REPO_BODY"
    exit 1
else
    echo -e "${RED}Error checking repository. HTTP Code: $REPO_HTTP_CODE${NC}"
    echo "Response: $REPO_BODY"
    exit 1
fi

# Initialize git repository if needed
if [ ! -d .git ]; then
    echo -e "${GREEN}Initializing git repository...${NC}"
    git init
    git config user.email "grrj50@outlook.com"
    git config user.name "User6212"
fi

# Copy files
echo -e "${GREEN}Copying files to repository...${NC}"
# Copy only if files exist
if [ -d ~/.config/tmux/plugins/tmux-git-data/ ] && [ "$(ls -A ~/.config/tmux/plugins/tmux-git-data/)" ]; then
    cp ~/.config/tmux/plugins/tmux-git-data/* . 2>/dev/null || true
    cp ~/.config/tmux/plugins/tmux-git-data/.* . 2>/dev/null || true
else
    echo -e "${YELLOW}Warning: No files found in ~/.config/tmux/plugins/tmux-git-data/${NC}"
    # Create a README file so we have something to commit
    echo "# Tmux Git Data Plugin" > README.md
    echo "This repository contains the tmux-git-data plugin files." >> README.md
fi

# Check if there are any changes to commit
if git status --porcelain | grep -q .; then
    git add .
    git commit -m "Update tmux-git-data files"
    echo -e "${GREEN}Changes committed${NC}"
else
    echo -e "${YELLOW}No changes to commit${NC}"
fi

# Set up remote with token authentication
git branch -M main
git remote remove origin 2>/dev/null

# Use the token in the remote URL
git remote add origin "https://User6212:${GITHUB_TOKEN}@github.com/User6212/test.git"

# Push to GitHub
echo -e "${GREEN}Pushing to GitHub...${NC}"

# Try to pull first if repository exists and has content
if [ "$REPO_HTTP_CODE" -eq 200 ]; then
    echo -e "${YELLOW}Attempting to pull latest changes...${NC}"
    git pull origin main --allow-unrelated-histories -X ours || true
fi

# Now push
echo -e "${YELLOW}Executing: git push -u origin main${NC}"
PUSH_OUTPUT=$(git push -u origin main 2>&1)
PUSH_EXIT_CODE=$?

if [ $PUSH_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}Done! Repository pushed to https://github.com/User6212/test${NC}"
else
    echo -e "${RED}Failed to push to GitHub. Error:${NC}"
    echo "$PUSH_OUTPUT"
    
    # Check if it's an authentication issue
    if echo "$PUSH_OUTPUT" | grep -q "authentication"; then
        echo -e "${YELLOW}This appears to be an authentication issue.${NC}"
        echo "Your token might not have the required permissions."
        echo "Make sure your token has the 'repo' scope."
    fi
    
    exit 1
fi

# Clean up: remove token from remote URL (replace with regular HTTPS URL)
git remote set-url origin https://github.com/User6212/test.git
echo -e "${GREEN}Remote URL cleaned up (token removed)${NC}"
