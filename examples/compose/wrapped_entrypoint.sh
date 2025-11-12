#!/bin/sh

HOOKS_SOURCE="/hooks"
# The path where all repositories are expected to reside (as set by the volume mount)
REPO_ROOT="/git"

# Find only top-level directories under REPO_ROOT
find "${REPO_ROOT}" -mindepth 1 -maxdepth 1 -type d | while read REPO_PATH; do

    REPO_NAME=$(basename "${REPO_PATH}")

    if ! git -C "$REPO_PATH" rev-parse --show-toplevel > /dev/null 2>&1; then
        echo "⚠️ Directory '${REPO_NAME}' is NOT a Git repo Skipping."
        continue
    fi

    HOOKS_DESTINATION="${REPO_PATH}/.git/hooks"

    echo "Copying custom hooks to ${REPO_NAME}..."
    cp -n "$HOOKS_SOURCE"/* "$HOOKS_DESTINATION"/ # -n means no-clobber (don't overwrite existing files)

done

# Execute the original entrypoint.sh.
# This runs it as a separate process.
# We pass all arguments to it.
/usr/local/bin/entrypoint.sh "$@"
