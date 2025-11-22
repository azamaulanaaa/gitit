#!/bin/sh

# Set defaults
PUID=${PUID:-1000}
PGID=${PGID:-1000}
GIT_USER="git"

if ! grep -q ":${PGID}:" /etc/group; then
    echo "${GIT_USER}:x:${PGID}:" >> /etc/group
fi

if ! grep -q "^${GIT_USER}:" /etc/passwd; then
    echo "Creating user ${GIT_USER} (UID:${PUID}) with home set to /"
    echo "${GIT_USER}:x:${PUID}:${PGID}:Git User:/:/bin/sh" >> /etc/passwd
fi

if [ -n "$GIT_PASSWORD" ]; then
    echo "${GIT_USER}:${GIT_PASSWORD}" | chpasswd
else
    echo "WARNING: GIT_PASSWORD not set"
fi


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
