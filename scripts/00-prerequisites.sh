#!/usr/bin/env bash
# 00-prerequisites.sh — System packages required by all other scripts
source "$(dirname "$0")/common.sh"
check_not_root

header "System Prerequisites"

PACKAGES=(
  curl wget unzip git jq gnupg
  software-properties-common apt-transport-https
  ca-certificates lsb-release make tree
  bash-completion htop
)

MISSING=()
for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    success "$pkg already installed"
  else
    MISSING+=("$pkg")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  info "Installing missing packages: ${MISSING[*]}"
  sudo apt update -qq
  sudo apt install -y -qq "${MISSING[@]}"
  success "Installed: ${MISSING[*]}"
else
  success "All system prerequisites already present"
fi

# yq (YAML processor) — not in default Ubuntu repos, install from binary
if ! cmd_exists yq; then
  info "Installing yq..."
  YQ_VERSION=$(curl -sL "https://api.github.com/repos/mikefarah/yq/releases/latest" | jq -r .tag_name)
  wget -qO /tmp/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}"
  chmod +x /tmp/yq
  sudo mv /tmp/yq /usr/local/bin/yq
  success "yq installed (${YQ_VERSION})"
else
  success "yq already installed ($(yq --version 2>/dev/null | head -1))"
fi

# bat (better cat) — Ubuntu names it batcat
if ! cmd_exists batcat && ! cmd_exists bat; then
  info "Installing bat..."
  sudo apt install -y -qq bat
  success "bat installed"
else
  success "bat already installed"
fi

# fzf (fuzzy finder) — source install at ~/.fzf
# Why source, not apt: Ubuntu 24.04 ships fzf 0.44 which doesn't support
# `fzf --zsh` (added in 0.48). Source install always tracks latest, generates
# ~/.fzf.zsh automatically, and updates via `cd ~/.fzf && git pull && ./install`.
if [ -d "$HOME/.fzf" ] && [ -x "$HOME/.fzf/bin/fzf" ]; then
  success "fzf already installed from source ($($HOME/.fzf/bin/fzf --version | awk '{print $1}'))"
else
  info "Installing fzf from source..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf"/install --key-bindings --completion --no-update-rc
  success "fzf installed from source ($($HOME/.fzf/bin/fzf --version | awk '{print $1}'))"
fi
