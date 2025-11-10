FROM ghcr.io/azamaulanaaa/gitit:latest

RUN apk add --no-cache \
  openssh-client \
  ca-certificates \
  sshpass

COPY wrapped_entrypoint.sh /usr/local/bin/wrapped_entrypoint.sh
RUN chmod +x /usr/local/bin/wrapped_entrypoint.sh

# Set the entrypoint to our script
ENTRYPOINT ["/usr/local/bin/wrapped_entrypoint.sh"]

# Start the server
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
