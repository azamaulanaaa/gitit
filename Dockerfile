# Use a lightweight base image
FROM alpine:latest

# Install Busybox and Git
RUN apk add --no-cache busybox-extras git-daemon

# Create necessary directories
RUN mkdir -p /www /git/default.git

WORKDIR /git/default.git

# Initialize git repository
RUN git init --bare --initial-branch=main && \
  git config http.receivepack true

VOLUME ["/git/default.git/.git/hooks"]

# Copy cgi-bin
COPY ./cgi-bin /www/cgi-bin
RUN chmod a+x /www/cgi-bin/*

ENV GIT_HTTP_EXPORT_ALL=true
ENV GIT_PROJECT_ROOT=/git

# Expose the port
EXPOSE 80

# Start the Busybox httpd server
CMD ["httpd", "-f", "-vv", "-p", "80", "-h", "/www"]

