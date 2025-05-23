FROM ghcr.io/azamaulanaaa/gitit:latest

COPY ./wrapped_entrypoint.sh /usr/local/bin/wrapped_entrypoint.sh

ENTRYPOINT ["/usr/local/bin/wrapped_entrypoint.sh"]

CMD ["httpd", "-f", "-vv", "-p", "80", "-h", "/www"]
