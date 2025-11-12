# gitit-compose

only container you need to do CI/CD for your compose file

# Deployment Steps

To deploy the gitit-compose image, use the following nerdctl run command:

```sh
nerdctl run --name gitit -d \
  --add-host host.docker.internal:host-gateway \
  -e PROFILE="cloudflared tinyproxy" \
  -e SSH_USER=nerdctl \
  -e SSH_PASSWORD=nerdctl \
  -e CONTAINER_CLI=nerdctl \
  -e BASE_DIR=/mnt/sda \
  -v /mnt/sda/selfhost:/git/selfhost\
  -p 8000:80 \
  ghcr.io/azamaulanaaa/gitit:compose
```

## Command Breakdown

Let's break down what each part of the command does:

- `nerdctl run`: This is the base command to run a Docker image.

- `--name gitit`: Assigns the name `gitit` to your running container. This makes
  it easier to refer to and manage the container later.

- `-d`: Runs the container in detached mode, meaning it will run in the
  background and not tie up your terminal.

- `--add-host host.docker.internal:host-gateway`: This adds an entry to the
  container's `/etc/hosts` file, allowing the container to resolve
  host.docker.internal to the IP address of the host machine. This is useful for
  services within the container that need to communicate with services running
  directly on the host.

- `-e PROFILE="cloudflared tinyproxy"`: Sets the `PROFILE` environment variable.
  This variable allows users to deploy the compose file for specific profiles,
  with multiple profiles separated by spaces.

- `-e SSH_USER=nerdctl`: Sets the `SSH_USER` environment variable inside the
  container to docker. This variable is likely used by the application within
  the container for SSH operations.

- `-e SSH_PASSWORD=nerdctl`: Sets the `SSH_PASSWORD` environment variable inside
  the container to docker. Similar to `SSH_USER`, this is used for SSH
  authentication.

- `-e CONTAINER_CLI=nerdctl`: Sets the `CONTAINER_CLI` environment variable to
  docker. the options only `nerdctl` or `docker` This tells the application
  inside the container which container runtime CLI to use for its internal
  operations.

- `-e BASE_DIR=/mnt/sda`: Sets the host directory where all repositories will be
  stored. This directory (`/mnt/sda`) is the parent of all Git repositories. The
  repository's local directory name on the host (e.g., `selfhost`) must match
  its remote name as used by the application inside the container. This means
  the path `/mnt/sda/selfhost` on the host must be mounted to a corresponding
  location inside the container, typically `/git/selfhost` (or similar,
  depending on the application's configuration), to ensure data persistence and
  correct access.

- `-v /mnt/sda/selfhost:/git/selfhost`: This creates a bind mount. It mounts the
  `/mnt/sda/selfhost` directory from your host machine into the `/git/selfhost`
  directory inside the container. This is crucial for persisting your Git
  repository data outside the container, ensuring that your data is not lost if
  the container is removed or recreated. The host directory `/mnt/sda/selfhost`
  must be a subdirectory of the host's `BASE_DIR` (e.g., if `BASE_DIR` is set to
  `/mnt/sda`, the host path is `/mnt/sda/selfhost`). Furthermore, the repository
  name (`selfhost`) must match on both the host and container paths. The
  application expects to find this specific repository's data at `/git/selfhost`
  within the container.

- `-p 8000:80`: Maps port `8000` on your host machine to port `80` inside the
  container. This means you can access the application running on port `80`
  inside the container by navigating to `http://your-host-ip:8000` in your web
  browser.

- `ghcr.io/azamaulanaaa/gitit:compose` : This is the name of the Docker image
  you are deploying.

# Accessing the Repository

Once the container is running, you can access the gitit-compose application by
opening your web browser and navigating to:

```sh
git clone http://<Your_Host_IP_Address>:8000/selfhost.git
```

Replace <Your_Host_IP_Address> with the actual IP address of the machine where
you deployed the container.
