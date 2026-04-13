#!/usr/bin/env bash
# 00-prerequisites.sh — System packages required by all other scripts
source "$(dirname "$0")/common.sh"
check_not_root

header "System Prerequisites"

PACKAGES=(
  curl wget unzip git jq gnupg
  software-properties-common apt-transport-https
  ca-certificates lsb-release make tree
  bash-completion htop fzf
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
