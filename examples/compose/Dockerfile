FROM ghcr.io/azamaulanaaa/gitit:latest

RUN apk add --no-cache \
  openssh-client \
  ca-certificates \
  sshpass

COPY ./hooks /hooks
RUN chmod +x /hooks/*

COPY wrapped_entrypoint.sh /usr/local/bin/wrapped_entrypoint.sh
RUN chmod +x /usr/local/bin/wrapped_entrypoint.sh

ENTRYPOINT ["/usr/local/bin/wrapped_entrypoint.sh"]

CMD ["/usr/sbin/dropbear", "-F", "-E", "-p", "22"]
