#!/bin/sh

# The path where all repositories are expected to reside (as set by the volume mount)
REPO_ROOT="/git"

# Find only top-level directories under REPO_ROOT
find "${REPO_ROOT}" -mindepth 1 -maxdepth 1 -type d | while read REPO_PATH; do
    
    REPO_NAME=$(basename "${REPO_PATH}")
    
    # Check 1: Is the directory already an independent Git repository?
    # We check for the existence of the .git folder/file directly inside the path.
    if git -C "$REPO_PATH" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "✅ Repo '${REPO_NAME}' already a git repository. Skipping init."
        continue
    fi
    
    # Check 2: If not a repo, is the directory empty?
    # We only initialize empty directories to prevent accidental deletion/corruption.
    if [ "$(ls -A "${REPO_PATH}")" ]; then
        echo "⚠️ Directory '${REPO_NAME}' is NOT a Git repo but is NOT empty. Skipping init."
        continue
    fi

    # If we reach here, the directory is empty AND not a repo. Initialize it.
    echo "⏳ Initializing EMPTY directory '${REPO_NAME}' as a non-bare Git repository..."
    
    # Change into the directory for configuration
    cd "${REPO_PATH}"

    # Initialize as a non-bare repository
    git init --initial-branch=main

    git config http.receivepack true
    git config advice.detachedHead false
    git config receive.denyCurrentBranch updateInstead
    
    echo "🎉 Repo '${REPO_NAME}' successfully configured."
done

# Execute the original command
exec "$@"
