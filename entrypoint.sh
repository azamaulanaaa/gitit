#!/bin/sh

# Define the repository path
REPO_PATH="/git/default.git"

# Check if the directory is a valid Git repository
# This command returns 0 if it's a valid work tree, non-zero otherwise.
# We also check if the .git directory exists to handle cases where
# the mount might be completely empty initially.
if [ ! -d "$REPO_PATH/.git" ] || ! git -C "$REPO_PATH" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Initializing Git repository in $REPO_PATH..."
    mkdir -p "$REPO_PATH"
    cd "$REPO_PATH"
    git init --initial-branch=main
    git config http.receivepack true
    git config advice.detachedHead false
    git config receive.denyCurrentBranch updateInstead
    echo "Git repository initialized."
else
    echo "Git repository already initialized in $REPO_PATH."
fi

# Execute the original command
exec "$@"
