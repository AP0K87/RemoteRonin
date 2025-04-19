# RemoteRonin

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![CI](https://img.shields.io/github/actions/workflow/status/your-org/remoteronin/ci.yml?branch=main)](https://github.com/your-org/remoteronin/actions)

*RemoteRonin* is a comprehensive shell environment toolkit that transforms any Linux host into your portable development cockpit. Designed for remote workers, digital nomads, and new hires, it bundles SSH key management, dotfiles synchronization, VPN/VPC access, cloud CLI helpers, and productivity plugins—so you can log in anywhere and immediately hit your stride.

---

## Table of Contents

1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Prerequisites Setup Script](#prerequisites-setup-script)
4. [Installation](#installation)
5. [Configuration](#configuration)
6. [Helper Scripts](#helper-scripts)
7. [Usage](#usage)
8. [VPN & Remote Functions](#vpn--remote-functions)
9. [Cloud & DevOps Helpers](#cloud--devops-helpers)
10. [Customization & Plugins](#customization--plugins)
11. [Contributing](#contributing)
12. [License](#license)

---

## Features

- **Consistent Shell Experience**: Centralized Bash (and optional Zsh) profile, prompts, aliases, and shortcuts.
- **SSH Key & Agent Forwarding**: Automatic syncing, secure loading, and forwarding of your SSH keys.
- **Dotfiles Sync**: Pull and apply your version-controlled dotfiles (`.vimrc`, `.gitconfig`, `.tmux.conf`, etc.).
- **Auto-Completion & Fuzzy Search**: Built-in `fzf` integration and bash completion for faster navigation.
- **VPN & VPC Access**: One-command VPN start/stop plus SSH tunnel helpers to access private VPC endpoints.
- **Environment Provisioning**: Auto-installs common developer tools (Docker, Git, Python, Node.js).
- **Cloud & DevOps Helpers**: Quick AWS, GCP, and Azure CLI login functions, Kubernetes context switchers, and Terraform init shortcuts.
- **Tmux Session Manager**: Preconfigured `tmux` scripts to restore workspaces across machines.
- **Dotfiles Backup**: Snapshot and restore your current config before applying updates.
- **Interactive Setup Wizard**: Guided first-time setup to configure your profile, plugins, and services.
- **Secret Store Integration**: Fetch credentials securely from HashiCorp Vault or AWS Secrets Manager.
- **Documentation Launcher**: Open project wikis, markdown guides, or PDF docs with a simple command.
- **Telemetry Opt-In**: Anonymous usage stats to help improve RemoteRonin (fully optional and GDPR-friendly).

---

## Prerequisites

- Linux host with `bash` (v4+) or `zsh` (optional)
- `git`
- `ssh` client
- (Optional) VPN client (`openvpn`, `wireguard`)
- (Optional) Cloud CLIs: AWS (`aws`), GCP (`gcloud`), Azure (`az`)
- (Optional) HashiCorp Vault CLI (`vault`)
- `curl` or `wget`

---

## Prerequisites Setup Script

Save as `setup-prerequisites.sh`, make executable, then run:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Detect package manager
declare PKG
if command -v apt-get &>/dev/null; then
  PKG="apt-get"
elif command -v yum &>/dev/null; then
  PKG="yum"
elif command -v pacman &>/dev/null; then
  PKG="pacman"
else
  echo "Unsupported package manager. Install manually." >&2
  exit 1
fi

install_apt() {
  sudo apt-get update
  sudo apt-get install -y bash zsh git openssh-client curl wget fzf tmux \
    openvpn wireguard-tools awscli google-cloud-sdk azure-cli vault || true
}
install_yum() {
  sudo yum install -y bash zsh git openssh-clients curl wget fzf tmux \
    openvpn wireguard-tools awscli google-cloud-sdk azure-cli vault || true
}
install_pacman() {
  sudo pacman -Sy --noconfirm bash zsh git openssh curl wget fzf tmux \
    openvpn wireguard-tools aws-cli google-cloud-cli azure-cli vault || true
}

case "$PKG" in
  apt-get) install_apt ;; 
  yum)    install_yum ;; 
  pacman) install_pacman ;; 
esac

# Optional: set bash as default shell
if ! grep -q "$(which bash)" /etc/shells; then
  echo "$(which bash)" | sudo tee -a /etc/shells
fi
chsh -s "$(which bash)" || true

echo "Prerequisites installed successfully."
```

```sh
chmod +x setup-prerequisites.sh
./setup-prerequisites.sh
```

---

## Installation

```bash
git clone https://github.com/your-org/remoteronin.git ~/.remote-ronin
~/.remote-ronin/setup.sh
exec $SHELL
```

---

## Configuration

```bash
cp ~/.remote-ronin/config.example ~/.remote-ronin/config
# Edit ~/.remote-ronin/config
```

Set dotfiles repo, VPN profiles, cloud defaults, shell, secret store endpoints.

---

## Helper Scripts

RemoteRonin provides standalone scripts in `~/.remote-ronin/bin/`. Ensure this directory is in your `PATH`.

### 1. `sync.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
HOME_DOTFILES="${HOME}/.dotfiles"
REPO_URL="$(grep '^dotfiles_repo=' ~/.remote-ronin/config | cut -d'=' -f2)"

# Clone or pull
if [ -d "$HOME_DOTFILES/.git" ]; then
  git -C "$HOME_DOTFILES" pull
else
  git clone "$REPO_URL" "$HOME_DOTFILES"
fi
# Copy files
rsync -av --exclude='.git' "$HOME_DOTFILES/" "$HOME/"
echo "Dotfiles synced."
```

### 2. `vpn.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
PROFILE="$1"
CONF_DIR="~/.remote-ronin/vpn"
case "$2" in
  start)
    sudo openvpn --config "$CONF_DIR/$PROFILE.ovpn" &
    echo "VPN $PROFILE started.";;
  stop)
    pkill -f "openvpn.*$PROFILE.ovpn"
    echo "VPN $PROFILE stopped.";;
  *) echo "Usage: vpn.sh <profile> {start|stop}" && exit 1;;
esac
```

### 3. `vpc.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
ENDPOINT="$1"
ssh -N -L localhost:localhost "$ENDPOINT"
```

### 4. `docs.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
DOC="$1"
DOCDIR="~/.remote-ronin/docs"
xdg-open "$DOCDIR/$DOC" || open "$DOCDIR/$DOC"
```

### 5. `kube.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
kubectl config use-context "$1"
```

### 6. `tmux.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
SESSION="remote-ronin"
if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
else
  tmux new -s "$SESSION"
fi
```

### 7. `aws.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
aws sso login --profile default
```

### 8. `gcp.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
gcloud auth login
```

### 9. `az.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
az login
```

### 10. `tf.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
terraform init
```

Make all scripts executable:
```bash
chmod +x ~/.remote-ronin/bin/*.sh
```

---

## Usage

```bash
remote-ronin sync           # Runs bin/sync.sh
remote-ronin vpn start dev  # Runs bin/vpn.sh dev start
remote-ronin vpc endpoint   # Runs bin/vpc.sh endpoint
remote-ronin docs guide.pdf # Runs bin/docs.sh guide.pdf
remote-ronin kube context   # Runs bin/kube.sh context
remote-ronin tmux           # Runs bin/tmux.sh
remote-ronin aws            # Runs bin/aws.sh
remote-ronin gcp            # Runs bin/gcp.sh
remote-ronin az             # Runs bin/az.sh
remote-ronin tf             # Runs bin/tf.sh
```

---

## VPN & Remote Functions

- `remote-ronin vpn start <profile>`: Connect VPN using saved credentials
- `remote-ronin vpn stop <profile>`: Disconnect VPN
- `remote-ronin vpc <endpoint>`: SSH tunnel to VPC

---

## Cloud & DevOps Helpers

- `remote-ronin aws`  
- `remote-ronin gcp`  
- `remote-ronin az`   
- `remote-ronin tf`   
- `remote-ronin kube use <context>`

---

## Customization & Plugins

- Place scripts in `~/.remote-ronin/plugins/`
- Drop extra functions in `~/.remote-ronin/custom.sh`
- Add themes to `~/.remote-ronin/themes/`

---

## Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feature/xyz`
3. Commit: `git commit -m "Add xyz feature"`
4. Push: `git push origin feature/xyz`
5. Open a PR

---

## License

This project is licensed under the [MIT License](LICENSE).

