FROM alpine

RUN apk add --no-cache \
  git \
  dropbear 

RUN adduser -D git
RUN mkdir -p /git && chown git:git /git

# Copy the setup script
COPY setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint to our script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /git
EXPOSE 22

CMD ["/usr/sbin/dropbear", "-F", "-E", "-p", "22"]
