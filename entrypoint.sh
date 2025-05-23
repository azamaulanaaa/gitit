#!/bin/sh

# Define the repository path
REPO_PATH="/git/default.git"

# Check if the repository is already initialized
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Initializing Git repository in $REPO_PATH..."
    mkdir -p "$REPO_PATH"
    cd "$REPO_PATH"
    git init --initial-branch=main
    git config http.receivepack true
    git config advice.detachedHead false
    git config receive.denyCurrentBranch ignore
    echo "Git repository initialized."
else
    echo "Git repository already initialized in $REPO_PATH."
fi

# Execute the original command
exec "$@"
