FROM caddy:2-builder as builder

RUN xcaddy build \
    --with=github.com/aksdb/caddy-cgi/v2

# Use a lightweight base image
FROM caddy:2-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Install and Git daemon
RUN apk add --no-cache \
  git \
  git-daemon

COPY ./config/Caddyfile /etc/caddy/Caddyfile

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint to our script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start the server
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
