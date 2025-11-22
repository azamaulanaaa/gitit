#!/bin/sh

/usr/local/bin/setup.sh

HOOKS_SOURCE="/hooks"
REPO_ROOT="/git"
    
find "${REPO_ROOT}" -mindepth 1 -maxdepth 1 -type d | while read REPO_PATH; do
    REPO_NAME=$(basename "$REPO_PATH")
    
    HOOKS_DESTINATION="$REPO_PATH/hooks"
    
    echo "Copying custom hooks to '$REPO_NAME' (bare repo)..."
    
    cp "${HOOKS_SOURCE}"/* "$HOOKS_DESTINATION"/
    
    echo "Hook setup complete for '$REPO_NAME'"
done

env | grep -vE "^(HOME|PWD|SHLVL|_|PATH)" > /etc/gitit.env
chmod 644 /etc/gitit.env

exec "$@"
