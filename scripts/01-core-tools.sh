#!/usr/bin/env bash
# 01-core-tools.sh — Docker, AWS CLI, Terraform, Terragrunt, kubectl, Helm
source "$(dirname "$0")/common.sh"
check_not_root

header "Core CLI Tools"

# ─── Docker Engine ───────────────────────────────────────────────────────────
MIN_DOCKER="27.0.0"

install_docker() {
  info "Installing Docker Engine..."
  sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update -qq
  sudo apt install -y -qq docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

  # Add current user to docker group
  if ! groups "$USER" | grep -q docker; then
    sudo usermod -aG docker "$USER"
    warn "Added $USER to docker group — log out and back in to take effect"
  fi

  success "Docker installed ($(get_version docker))"
}

if ! print_status docker "$MIN_DOCKER" 2>/dev/null; then
  install_docker
fi

# ─── AWS CLI v2 ──────────────────────────────────────────────────────────────
MIN_AWS="2.20.0"

install_awscli() {
  info "Installing/updating AWS CLI v2..."
  local tmpdir
  tmpdir=$(mktemp -d)
  curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmpdir/awscliv2.zip"
  unzip -qo "$tmpdir/awscliv2.zip" -d "$tmpdir"
  sudo "$tmpdir/aws/install" --update
  rm -rf "$tmpdir"
  success "AWS CLI installed ($(get_version aws))"
}

if ! print_status aws "$MIN_AWS" 2>/dev/null; then
  install_awscli
fi

# ─── Terraform ───────────────────────────────────────────────────────────────
MIN_TF="1.14.0"

install_terraform() {
  info "Installing Terraform via HashiCorp repo..."
  wget -qO- https://apt.releases.hashicorp.com/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg --yes

  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

  sudo apt update -qq
  sudo apt install -y -qq terraform
  success "Terraform installed ($(get_version terraform))"
}

if ! print_status terraform "$MIN_TF" 2>/dev/null; then
  install_terraform
fi

# ─── Terragrunt ──────────────────────────────────────────────────────────────
MIN_TG="1.0.0"
TG_TARGET="v1.0.0"

install_terragrunt() {
  info "Installing Terragrunt ${TG_TARGET}..."
  local binary="terragrunt_linux_${ARCH}"
  local url="https://github.com/gruntwork-io/terragrunt/releases/download/${TG_TARGET}/${binary}"
  wget -qO /tmp/terragrunt "$url"
  chmod +x /tmp/terragrunt
  sudo mv /tmp/terragrunt /usr/local/bin/terragrunt
  success "Terragrunt installed ($(get_version terragrunt))"
}

if ! print_status terragrunt "$MIN_TG" 2>/dev/null; then
  install_terragrunt
fi

# ─── kubectl ─────────────────────────────────────────────────────────────────
# Pin to 1.31.x to match EKS cluster version
MIN_KUBECTL="1.31.0"

install_kubectl() {
  info "Installing kubectl 1.31.x (matching EKS cluster version)..."
  local stable
  stable=$(curl -sL https://dl.k8s.io/release/stable-1.31.txt)
  curl -sLO "https://dl.k8s.io/release/${stable}/bin/linux/${ARCH}/kubectl"
  curl -sLO "https://dl.k8s.io/release/${stable}/bin/linux/${ARCH}/kubectl.sha256"

  if echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check --status 2>/dev/null; then
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    success "kubectl installed (${stable})"
  else
    error "kubectl checksum verification failed!"
    rm -f kubectl kubectl.sha256
    return 1
  fi
  rm -f kubectl kubectl.sha256
}

if ! print_status kubectl "$MIN_KUBECTL" 2>/dev/null; then
  install_kubectl
fi

# ─── Helm ────────────────────────────────────────────────────────────────────
MIN_HELM="4.1.0"

install_helm() {
  info "Installing Helm 4.x..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  success "Helm installed ($(get_version helm))"
}

if ! print_status helm "$MIN_HELM" 2>/dev/null; then
  install_helm
fi

echo ""
success "All core tools ready."
