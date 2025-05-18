# Use a lightweight base image
FROM alpine:latest

# Install Busybox and Git
RUN apk add --no-cache busybox-extras git-daemon

# Create necessary directories
RUN mkdir -p /www /git

# Create the default Git repository and initialize if it doesn't exist
RUN mkdir -p /git/default.git && \
    if [ ! -d "/git/default.git/objects" ]; then \
        git --git-dir=/git/default.git init --bare && \
        git --git-dir=/git/default.git config http.receivepack true && \
        touch /git/default.git/git-daemon-export-ok;  \
    fi

VOLUME ["/git/default.git/hooks"]

# Copy cgi-bin
COPY ./cgi-bin /www/cgi-bin
RUN chmod a+x /www/cgi-bin/*

ENV GIT_HTTP_EXPORT_ALL=true
ENV GIT_PROJECT_ROOT=/git

# Expose the port
EXPOSE 80

# Start the Busybox httpd server
CMD ["httpd", "-f", "-vv", "-p", "80", "-h", "/www"]

