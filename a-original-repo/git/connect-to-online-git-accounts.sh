#!/bin/bash

SSH_KEY_NAME="id_ed25519"
SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"
SSH_PUB_PATH="${SSH_KEY_PATH}.pub"
SSH_EMAIL="abdulr568programming@outlook.com"
OUTPUT_CONFIG="$HOME/.ssh/config"

mkdir -p ~/.ssh/
chmod 700 ~/.ssh/
if ! ls ~/.ssh/${SSH_KEY_NAME}* 2>/dev/null >/dev/null; then
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY_PATH" -N ""
fi
if [ -f "$SSH_KEY_PATH" ]; then
    chmod 600 "$SSH_KEY_PATH"
fi
if [ -f "$SSH_PUB_PATH" ]; then
    chmod 644 "$SSH_PUB_PATH"
fi

eval "$(ssh-agent -s)"
if [ $? -ne 0 ]; then
    exit 1
fi
if [ -f "$SSH_KEY_PATH" ]; then
    ssh-add "$SSH_KEY_PATH"
fi
cat > "$OUTPUT_CONFIG" << EOF
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile $SSH_KEY_PATH
    IdentitiesOnly yes

# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile $SSH_KEY_PATH
    IdentitiesOnly yes

# BitBucket
Host bitbucket.org
    HostName bitbucket.org
    User git
    IdentityFile $SSH_KEY_PATH
    IdentitiesOnly yes
EOF

chmod 600 "$OUTPUT_CONFIG"
echo "$SSH_KEY_PATH"
echo "$OUTPUT_CONFIG"
cat "$SSH_PUB_PATH"
cat "$SSH_PUB_PATH"
echo "Follow the docs in git/connect-to-online-git-accounts.md to connect to your Git accounts"