#!/bin/sh

# --- 1. Execute the Base Image's Setup Logic ---

/usr/local/bin/setup.sh

# --- 2. Link Hooks to Bare Repositories ---

HOOKS_SOURCE="/hooks"
REPO_ROOT="/git"
USER_TO_RUN_AS="git"

echo "Linking custom hooks to bare repositories..."

# Execute the hook linking logic as the non-root user 'git'
su - "$USER_TO_RUN_AS" -c "
    echo 'Checking and linking hooks in ${REPO_ROOT}...'
    
    find \"${REPO_ROOT}\" -mindepth 1 -maxdepth 1 -type d | while read REPO_PATH; do
        REPO_NAME=\$(basename \"\$REPO_PATH\")
        
        # For a BARE repository, the hooks directory is located directly inside the repo root.
        HOOKS_DESTINATION=\"\$REPO_PATH/hooks\"
        
        echo \"Copying custom hooks to '\$REPO_NAME' (bare repo)...\"
        
        # Copy the hooks from the source folder to the bare repository's hooks directory.
        cp \"${HOOKS_SOURCE}\"/* \"\$HOOKS_DESTINATION\"/
        
        echo \"Hook setup complete for '\$REPO_NAME'\"
    done
"

# --- 3. START DROPBEAR (Execute the final CMD) ---

exec "$@"
