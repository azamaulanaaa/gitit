FROM ghcr.io/azamaulanaaa/gitit:latest

# --- Install CI/CD Hook Dependencies ---
# These are the tools needed for the post-receive hook to execute remote commands.
RUN apk add --no-cache \
  openssh-client \
  ca-certificates \
  sshpass

# --- Hook and Entrypoint Setup ---

# Copy the hooks directory (containing the post-receive script)
COPY ./hooks /hooks

# Make the hooks executable
RUN chmod +x /hooks/*

# Copy the wrapper script (which will now execute the old entrypoint and the CMD)
COPY wrapped_entrypoint.sh /usr/local/bin/wrapped_entrypoint.sh
RUN chmod +x /usr/local/bin/wrapped_entrypoint.sh

# Set the entrypoint to our script
ENTRYPOINT ["/usr/local/bin/wrapped_entrypoint.sh"]
