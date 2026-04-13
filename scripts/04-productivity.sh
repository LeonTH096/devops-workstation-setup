#!/usr/bin/env bash
# 04-productivity.sh — k9s, stern, kubectx/kubens, dive, act
source "$(dirname "$0")/common.sh"
check_not_root

header "Productivity & Debugging Tools"

# ─── k9s (Kubernetes TUI) ────────────────────────────────────────────────────
install_k9s() {
  info "Installing k9s..."
  wget -qO /tmp/k9s.deb \
    "https://github.com/derailed/k9s/releases/latest/download/k9s_linux_${ARCH}.deb"
  sudo apt install -y -qq /tmp/k9s.deb
  rm /tmp/k9s.deb
  success "k9s installed"
}

if ! cmd_exists k9s; then
  install_k9s
else
  success "k9s already installed"
fi

# ─── stern (multi-pod log tailing) ───────────────────────────────────────────
install_stern() {
  info "Installing stern..."
  local version
  version=$(curl -sL "https://api.github.com/repos/stern/stern/releases/latest" | jq -r .tag_name)
  wget -qO /tmp/stern.tar.gz \
    "https://github.com/stern/stern/releases/download/${version}/stern_${version#v}_linux_${ARCH}.tar.gz"
  tar -xzf /tmp/stern.tar.gz -C /tmp stern
  sudo mv /tmp/stern /usr/local/bin/
  rm /tmp/stern.tar.gz
  success "stern installed (${version})"
}

if ! cmd_exists stern; then
  install_stern
else
  success "stern already installed"
fi

# ─── kubectx + kubens (fast context/namespace switching) ─────────────────────
install_kubectx() {
  info "Installing kubectx + kubens..."
  local version
  version=$(curl -sL "https://api.github.com/repos/ahmetb/kubectx/releases/latest" | jq -r .tag_name)

  wget -qO /tmp/kubectx.tar.gz \
    "https://github.com/ahmetb/kubectx/releases/download/${version}/kubectx_${version}_linux_x86_64.tar.gz"
  tar -xzf /tmp/kubectx.tar.gz -C /tmp kubectx
  sudo mv /tmp/kubectx /usr/local/bin/
  rm /tmp/kubectx.tar.gz

  wget -qO /tmp/kubens.tar.gz \
    "https://github.com/ahmetb/kubectx/releases/download/${version}/kubens_${version}_linux_x86_64.tar.gz"
  tar -xzf /tmp/kubens.tar.gz -C /tmp kubens
  sudo mv /tmp/kubens /usr/local/bin/
  rm /tmp/kubens.tar.gz

  success "kubectx + kubens installed (${version})"
}

if ! cmd_exists kubectx; then
  install_kubectx
else
  success "kubectx already installed"
fi

# ─── dive (Docker image layer analysis) ──────────────────────────────────────
install_dive() {
  info "Installing dive..."
  local version
  version=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | jq -r .tag_name)
  wget -qO /tmp/dive.deb \
    "https://github.com/wagoodman/dive/releases/download/${version}/dive_${version#v}_linux_${ARCH}.deb"
  sudo apt install -y -qq /tmp/dive.deb
  rm /tmp/dive.deb
  success "dive installed (${version})"
}

if ! cmd_exists dive; then
  install_dive
else
  success "dive already installed"
fi

# ─── act (local GitHub Actions testing) ──────────────────────────────────────
install_act() {
  info "Installing act..."
  curl -sL https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash -s -- -b /usr/local/bin
  success "act installed ($(get_version act))"
}

if ! cmd_exists act; then
  install_act
else
  success "act already installed ($(get_version act))"
fi

echo ""
success "All productivity tools ready."
