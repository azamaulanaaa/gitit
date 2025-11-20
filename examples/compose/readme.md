# gitit-compose

only container you need to do CI/CD for your compose file

## Deployment

### Running the Container

Gitit requires volumes for **repository storage** and **SSH host key
persistence**.

```sh
nerdctl run -d \
    --name gitit \
    -p 8022:22 \
    -v gitit_repos:/git \
    -v gitit_keys:/etc/dropbear \
    -e GIT_PASSWORD=YOUR_SECURE_PASSWORD \
    -e PROFILE="cloudflared tinyproxy" \
    -e SSH_USER=nerdctl \
    -e SSH_PASSWORD=nerdctl \
    -e CONTAINER_CLI=nerdctl \
    -e REMOTE_DEPLOY_BASE=/mnt/sda/deploy
    ghcr.io/azamaulanaaa/gitit:compose
```
