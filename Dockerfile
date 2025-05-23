# Use a lightweight base image
FROM alpine:latest

# Install Busybox and Git
RUN apk add --no-cache \
  busybox-extras \
  git-daemon \
  openssh-client \
  ca-certificates \
  sshpass

# Create necessary directories
RUN mkdir -p /www /git/default.git

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Copy cgi-bin
COPY ./cgi-bin /www/cgi-bin
RUN chmod a+x /www/cgi-bin/*

ENV GIT_HTTP_EXPORT_ALL=true
ENV GIT_PROJECT_ROOT=/git

# Expose the port
EXPOSE 80

# Set the entrypoint to our script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start the Busybox httpd server
CMD ["httpd", "-f", "-vv", "-p", "80", "-h", "/www"]

