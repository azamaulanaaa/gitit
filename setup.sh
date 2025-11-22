#!/bin/sh

# --- 1. SETUP ROOT-REQUIRED CONFIGURATION (Host Keys & Password) ---

HOST_KEY_PATH="/etc/dropbear/dropbear_rsa_host_key"

if [ ! -f "$HOST_KEY_PATH" ]; then
    echo "Host key not found. Generating new Dropbear host keys for persistence..."
    mkdir -p /etc/dropbear
    chmod 700 /etc/dropbear

    /usr/bin/dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
    /usr/bin/dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key
    /usr/bin/dropbearkey -t ed25519 -f /etc/dropbear/dropbear_ed25519_host_key
    
    echo "New keys generated. Remember to persist the /etc/dropbear directory."
else
    echo "Existing host keys found. Using persistent keys."
fi

# Set password for the 'git' user (Requires root)
if [ -z "$GIT_PASSWORD" ]; then
    echo "FATAL: GIT_PASSWORD environment variable is not set. Cannot authenticate user 'git'."
    exit 1
fi

echo "Setting password for user 'git'..."
echo "git:$GIT_PASSWORD" | chpasswd
REPO_ROOT="/git"

find "${REPO_ROOT}" -mindepth 1 -maxdepth 1 -type d | while read REPO_PATH; do
    REPO_NAME=$(basename "$REPO_PATH")

    if [ "$(ls -A "$REPO_PATH")" ]; then
        echo "Directory '$REPO_NAME' is NOT empty. Skipping init."
        continue
    fi

    echo "Initializing EMPTY directory '$REPO_NAME' as a BARE Git repository..."
    git init --bare "$REPO_PATH" > /dev/null 2>&1
    echo "Repo '$REPO_NAME' successfully configured."

done
