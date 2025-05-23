# gitit-compose

only container you need to do CI/CD for your compose file

# Deployment Steps

To deploy the gitit-compose image, use the following nerdctl run command:

```sh
docker run --name gitit -d \
  --add-host host.docker.internal:host-gateway \
  -e SSH_USER=nerdctl \
  -e SSH_PASSWORD=nerdctl \
  -e CONTAINER_CLI=nerdctl \
  -e BASE_DIR=/mnt/sda/selfhost \
  -e PROFILE="cloudflared tinyproxy" \
  -p 8000:80 \
  ghcr.io/azamaulanaaa/gitit:compose

```

## Command Breakdown

Let's break down what each part of the command does:

- `docker run`: This is the base command to run a Docker image.

- `--name gitit`: Assigns the name `gitit` to your running container. This makes it easier to refer to and manage the container later.

- `-d`: Runs the container in detached mode, meaning it will run in the background and not tie up your terminal.

- `--add-host host.docker.internal:host-gateway`: This adds an entry to the container's `/etc/hosts` file, allowing the container to resolve host.docker.internal to the IP address of the host machine. This is useful for services within the container that need to communicate with services running directly on the host.

- `-e SSH_USER=docker`: Sets the SSH_USER environment variable inside the container to docker. This variable is likely used by the application within the container for SSH operations.

- `-e SSH_PASSWORD=docker`: Sets the SSH_PASSWORD environment variable inside the container to docker. Similar to SSH_USER, this is used for SSH authentication.

- `-e CONTAINER_CLI=docker`: Sets the CONTAINER_CLI environment variable to docker. the options only `nerdctl` or `docker` This tells the application inside the container which container runtime CLI to use for its internal operations.

- `-e BASE_DIR=/mnt/sda/selfhost`: Sets the BASE_DIR environment variable to `/mnt/sda/selfhost`. This path specifies where the application within the container should store its data or configurations on the host system.

- `-e PROFILE="cloudflared tinyproxy"`: Sets the PROFILE environment variable. This variable allows users to deploy the compose file for specific profiles, with multiple profiles separated by spaces.

- `-p 8000:80`: Maps port 8000 on your host machine to port 80 inside the container. This means you can access the application running on port 80 inside the container by navigating to `http://your-host-ip:8000` in your web browser.

- `ghcr.io/azamaulanaaa/gitit:compose` : This is the name of the Docker image you are deploying.

# Accessing the Repository

Once the container is running, you can access the gitit-compose application by opening your web browser and navigating to:

```sh
git clone http://<Your_Host_IP_Address>:8000/cgi-bin/git/default.git

```

Replace <Your_Host_IP_Address> with the actual IP address of the machine where you deployed the container.
