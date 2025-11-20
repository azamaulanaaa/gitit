# Gitit: A Lightweight SSH Git Server for CI/CD

Gitit is an extremely lightweight Docker image built on Alpine Linux and
**Dropbear SSH** to serve **bare Git repositories**. Its primary design goal is
to provide a minimalist, secure endpoint for **Continuous Integration/Continuous
Deployment (CI/CD)** workflows triggered by Git hooks.

## Features

- **Protocol:** Securely serves Git over **SSH (Dropbear)** using password
  authentication.
- **Ultra-Lightweight:** Built on Alpine Linux with minimal dependencies for a
  small footprint and fast startup.
- **Bare Repositories:** Designed to host bare repositories (`repo-name.git`),
  the standard format for centralized Git remotes.
- **Automatic Initialization:** Automatically initializes empty directories as
  bare repositories on startup.
- **Persistent Identity:** Host keys are externalized for **consistent server
  identity** across restarts, preventing client errors.

---

## Deployment

### Prerequisites

- Docker or Podman installed on your system.
- The **`git`** user requires a strong password set via an environment variable.

### Running the Container

Gitit requires volumes for **repository storage** and **SSH host key
persistence**.

```sh
docker run -d \
    --name gitit \
    -p 8022:22 \
    -v gitit_repos:/git \
    -v gitit_keys:/etc/dropbear \
    -e GIT_PASSWORD=YOUR_SECURE_PASSWORD \
    ghcr.io/azamaulanaaa/gitit
```

## Usage

The repository user is always **`git`**. All repositories are accessed via the
path `/git/<repo-name.git>`.

### Cloning a New Repository

To clone a repository named `my-project.git`:

```sh
git clone ssh://git@<Your_Host_IP_Address>:8022/git/my-project.git
```

### Pushing Changes

To push changes to the server:

```sh
# 1. Add Gitit as a remote
git remote add gitit ssh://git@<Your_Host_IP_Address>:8022/git/my-project.git

# 2. Push the changes (you will be prompted for the GIT_PASSWORD)
git push gitit main
```
