## Prerequisites Setup Script
## To run do this, 
## chmod +x setup-prerequisites.sh
## ./setup-prerequisites.sh
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
#if ! grep -q "$(which bash)" /etc/shells; then
#  echo "$(which bash)" | sudo tee -a /etc/shells
#fi
#chsh -s "$(which bash)" || true
echo "Prerequisites installed successfully."




