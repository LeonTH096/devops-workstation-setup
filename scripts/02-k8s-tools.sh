#!/usr/bin/env bash
# 02-k8s-tools.sh — kind, eksctl, kubeconform, pluto
source "$(dirname "$0")/common.sh"
check_not_root

header "Kubernetes Ecosystem Tools"

# ─── kind (Kubernetes in Docker) ─────────────────────────────────────────────
install_kind() {
  info "Installing kind..."
  local url="https://kind.sigs.k8s.io/dl/latest/kind-linux-${ARCH}"
  curl -sLo /tmp/kind "$url"
  chmod +x /tmp/kind
  sudo mv /tmp/kind /usr/local/bin/kind
  success "kind installed ($(get_version kind))"
}

if ! cmd_exists kind; then
  install_kind
else
  success "kind already installed ($(get_version kind))"
fi

# ─── eksctl ──────────────────────────────────────────────────────────────────
install_eksctl() {
  info "Installing eksctl..."
  local platform="${OS}_${ARCH}"
  curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${platform}.tar.gz"
  tar -xzf "eksctl_${platform}.tar.gz" -C /tmp
  rm "eksctl_${platform}.tar.gz"
  sudo mv /tmp/eksctl /usr/local/bin/
  success "eksctl installed ($(get_version eksctl))"
}

if ! cmd_exists eksctl; then
  install_eksctl
else
  success "eksctl already installed ($(get_version eksctl))"
fi

# ─── kubeconform (K8s manifest validation) ───────────────────────────────────
install_kubeconform() {
  info "Installing kubeconform..."
  local version
  version=$(curl -sL "https://api.github.com/repos/yannh/kubeconform/releases/latest" | jq -r .tag_name)
  wget -qO /tmp/kubeconform.tar.gz \
    "https://github.com/yannh/kubeconform/releases/download/${version}/kubeconform-linux-${ARCH}.tar.gz"
  tar -xzf /tmp/kubeconform.tar.gz -C /tmp kubeconform
  sudo mv /tmp/kubeconform /usr/local/bin/
  rm /tmp/kubeconform.tar.gz
  success "kubeconform installed (${version})"
}

if ! cmd_exists kubeconform; then
  install_kubeconform
else
  success "kubeconform already installed ($(get_version kubeconform))"
fi

# ─── pluto (deprecated API detection) ────────────────────────────────────────
install_pluto() {
  info "Installing pluto..."
  local version
  version=$(curl -sL "https://api.github.com/repos/FairwindsOps/pluto/releases/latest" | jq -r .tag_name)
  wget -qO /tmp/pluto.tar.gz \
    "https://github.com/FairwindsOps/pluto/releases/download/${version}/pluto_${version#v}_linux_${ARCH}.tar.gz"
  tar -xzf /tmp/pluto.tar.gz -C /tmp pluto
  sudo mv /tmp/pluto /usr/local/bin/
  rm /tmp/pluto.tar.gz
  success "pluto installed (${version})"
}

if ! cmd_exists pluto; then
  install_pluto
else
  success "pluto already installed ($(get_version pluto))"
fi

echo ""
success "All Kubernetes tools ready."
