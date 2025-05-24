# Gitit: A Lightweight HTTP Git Server for CI/CD

Gitit is an extremely lightweight Docker image designed to serve a non-bare Git repository over HTTP. Its primary purpose is to facilitate Continuous Integration/Continuous Deployment (CI/CD) workflows through the use of Git hooks.

## ✨ Features

- **Ultra-Lightweight**: Built with minimal dependencies, ensuring a small footprint and fast startup times.

- **Non-Bare Repository Serving**: Serves a standard Git repository, allowing for direct interaction and inspection of the working tree on the server.

- **HTTP Protocol**: Provides access to your repository via the ubiquitous HTTP protocol, simplifying network configuration.

- **Git Hook Integration**: Designed to integrate seamlessly with Git hooks, enabling automated CI/CD pipelines upon pushes.

## 🚀 Deployment

**Prerequisites**

Before deploying Gitit, ensure you have Docker installed on your system.

**Running the Container**

To deploy Gitit, use the following docker run command:

```sh
docker run -d \
    --name gitit \
    -v hooks:/git/default.git/.git/hooks:ro \
    -p 8000:80 \
    ghcr.io/azamaulanaaa/gitit
```

**Explanation of the command**:

- `-d`: Runs the container in detached mode (in the background).

- `--name gitit`: Assigns the name gitit to your container, making it easier to reference.

- `-v hooks:/git/default.git/.git/hooks:ro`: This is a crucial volume mount.

  - `hooks`: This refers to a Docker named volume (or a host directory if you specify a full path like `/path/to/your/hooks`). This volume should contain your custom Git hooks (e.g., post-receive, pre-receive) that you want to execute on the server.

  - `/git/default.git/.git/hooks`: This is the target directory inside the container where Git expects to find its hooks.

  - `:ro`: Mounts the volume as read-only, preventing the container from modifying your hook scripts directly.

- `-p 8000:80`: Maps port 8000 on your host machine to port 80 inside the container. This means you will access the Gitit server via port 8000.

- `ghcr.io/azamaulanaaa/gitit`: The Docker image to pull and run.

## 💡 Usage
Once the Gitit container is running, you can interact with your repository using standard Git commands. The repository is served at http://<Your_Host_IP_Address>:8000/cgi-bin/git/default.git.

**Cloning the Repository**

To clone the repository:

```sh
git clone http://<Your_Host_IP_Address>:8000/cgi-bin/git/default.git
```

Replace `<Your_Host_IP_Address>` with the actual IP address or hostname of the machine running the Docker container.

**Pushing Changes**

To add Gitit as a remote and push your changes:

```sh
git remote add gitit http://<Your_Host_IP_Address>:8000/cgi-bin/git/default.git
git push gitit main # Or your desired branch, e.g., 'master'
```

**Configuring Git Hooks**

The power of Gitit lies in its integration with Git hooks. Ensure your hooks volume (as specified in the docker run command) contains your executable hook scripts.

For example, to run a CI/CD script after every push, you would place a post-receive script in your hooks volume:

```sh
#!/bin/sh
# Example post-receive hook script
echo "--- Running post-receive hook ---"
# Your CI/CD commands go here, e.g.:
# cd /path/to/your/project && git pull && npm install && npm test && npm run deploy
echo "--- Post-receive hook finished ---"
```

Important: Make sure your hook scripts are executable (chmod +x your_hook_script).
