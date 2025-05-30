#!/bin/sh

# Create the directory for the default Git repository's hooks if it doesn't already exist.
# The '-p' flag ensures that parent directories are also created as needed.
mkdir -p /git/default.git/.git/hooks

# Redirect the following lines (up to 'EOF') into a file named 'post-receive'.
# This file will become a Git hook script that executes after a successful push to the repository.
# The 'cat >' command is used to create or overwrite the file.
cat > /git/default.git/.git/hooks/post-receive << EOF
#!/bin/sh
# ------------------------------------------------------------------------------
# Script: post-receive
# Description: This Git server-side hook runs inside the 'gitit' container.
#        It's triggered after a successful 'git push' to the non-bare
#        repository (whose working directory is volume-mounted to the host).
#        This hook then uses sshpass to connect back to the host machine
#        and redeploy the application using the specified container CLI
#        (nerdctl or docker) and Docker Compose.
# ------------------------------------------------------------------------------

# --- Configuration ---
# Target branch for deployments.
TARGET_BRANCH="refs/heads/main"

# Log file path within the gitit container. Ensure this path is writable.
LOG_FILE="/var/log/git-deploy.log"

# Remote Server Configuration (This is the host machine where the volumes are mounted)
# IMPORTANT: Ensure 'sshpass' is installed inside the 'gitit' container.

# SSH Host: Hardcoded as requested. This value will be used directly.
SSH_HOST="host.docker.internal"

# Other sensitive and dynamic configurations (SSH_USER, SSH_PASSWORD, BASE_DIR, CONTAINER_CLI)
# MUST be provided as environment variables to the container running this hook.

# Validate essential environment variables are set. If any are missing, the script will exit.
if [ -z "\$SSH_USER" ]; then
    echo "Error: SSH_USER environment variable is not set. This is required for remote SSH connection." >&2
    exit 1
fi
if [ -z "\$SSH_PASSWORD" ]; then
    echo "Error: SSH_PASSWORD environment variable is not set. WARNING: Hardcoding passwords is a security risk. Use environment variables or a secrets management system." >&2
    exit 1
fi
if [ -z "\$BASE_DIR" ]; then
    echo "Error: BASE_DIR environment variable is not set. This must point to your application's directory on the host." >&2
    exit 1
fi
if [ -z "\$CONTAINER_CLI" ]; then
    echo "Error: CONTAINER_CLI environment variable is not set. Please set it to 'nerdctl' or 'docker'." >&2
    exit 1
fi
if [ "\$CONTAINER_CLI" != "nerdctl" ] && [ "\$CONTAINER_CLI" != "docker" ]; then
    echo "Error: Invalid value for CONTAINER_CLI. Must be 'nerdctl' or 'docker'." >&2
    exit 1
fi


# SSH command prefix using sshpass.
# Directly using the environment variables (and the hardcoded SSH_HOST).
SSH_COMMAND_PREFIX="sshpass -p \"\$SSH_PASSWORD\" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \"\$SSH_USER@\$SSH_HOST\""

# --- Utility Functions ---

# Function to log messages with a timestamp
log_message() {
    local message="\$1"
    local timestamp=\$(date +"%Y-%m-%d %H:%M:%S %Z")
    echo "[\$timestamp] \$message"
    if [ -n "\$LOG_FILE" ]; then
        echo "[\$timestamp] \$message" >> "\$LOG_FILE"
    fi
}

# Function to handle errors and exit
handle_error() {
    local message="\$1"
    log_message "Error: \$message"
    exit 1
}

# Function to execute a command on the remote server (the host machine) via SSH
remote_exec() {
    local command="\$1"
    log_message "Executing remotely on \$SSH_HOST: \$command"
    # Ensure common commands are found on the remote server by setting PATH.
    # Redirect all output to the log file.
    eval "\$SSH_COMMAND_PREFIX \"source .profile && \$command\"" 2>&1 | tee -a "\$LOG_FILE"
    local status=\$? # This captures the exit status of the 'tee' command.
    if [ \$status -ne 0 ]; then
        handle_error "Remote command failed (exit code \$status): '\$command'."
    fi
}

# --- Deployment Functions ---

# Function to stop and remove existing containers on the remote server (host)
remote_stop_containers() {
    log_message "Stopping and removing existing containers on \$SSH_HOST using \$CONTAINER_CLI..."
    remote_exec "cd \"\$BASE_DIR\" && \$CONTAINER_CLI compose down --remove-orphans"
}

# Function to start new containers on the remote server (host)
remote_start_containers() {
    log_message "Starting the new containers on \$SSH_HOST using \$CONTAINER_CLI..."
    local compose_profiles_args=""

    # Construct the --profile arguments if DEPLOY_PROFILE is set
    if [ -n "\$PROFILE" ]; then
        for profile in \$PROFILE; do
            compose_profiles_args="\$compose_profiles_args --profile \"\$profile\""
        done
        log_message "Using Docker Compose profiles: \$PROFILE"
    else
        log_message "No specific Docker Compose profiles set. Starting default services."
    fi

    local compose_up_command="cd \"\$BASE_DIR\" && \$CONTAINER_CLI compose \$compose_profiles_args up -d"
    remote_exec "\$compose_up_command"
}

# --- Main execution block ---
log_message "Post-receive hook execution started."

# Read all incoming refs from stdin
while read oldrev newrev ref; do
    log_message "Received push event for ref: '\$ref' (old: '\$oldrev', new: '\$newrev')"

    # Check if the updated ref matches the target branch
    if [ "\$ref" = "\$TARGET_BRANCH" ]; then
        log_message "Detected update to the target branch: '\$TARGET_BRANCH'"

        # Perform deployment steps
        # The code update is handled by the 'git push' to the non-bare repo's volume mount.
        # We just need to restart the containers.
        remote_stop_containers
        remote_start_containers

        log_message "Deployment process completed successfully for branch '\$TARGET_BRANCH' on \$SSH_HOST."
    else
        log_message "Push event was for a different branch ('\$ref'). Skipping deployment."
    fi
done

log_message "Post-receive hook execution finished."
exit 0 # Indicate successful execution of the hook
EOF

chmod +x /git/default.git/.git/hooks/post-receive

# Execute the original entrypoint.sh.
# This runs it as a separate process.
# We pass all arguments to it.
/usr/local/bin/entrypoint.sh "$@"
