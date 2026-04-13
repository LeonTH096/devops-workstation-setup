#!/usr/bin/env bash
# 03-security-lint.sh — Trivy, tflint, terraform-docs
source "$(dirname "$0")/common.sh"
check_not_root

header "Security & Linting Tools"

# ─── Trivy (container/config security scanner) ───────────────────────────────
MIN_TRIVY="0.69.0"

install_trivy() {
  info "Installing Trivy..."
  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
    gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

  echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
    https://aquasecurity.github.io/trivy-repo/deb generic main" | \
    sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null

  sudo apt update -qq
  sudo apt install -y -qq trivy
  success "Trivy installed ($(get_version trivy))"
}

if ! print_status trivy "$MIN_TRIVY" 2>/dev/null; then
  install_trivy
fi

# ─── tflint (Terraform linter) ───────────────────────────────────────────────
install_tflint() {
  info "Installing tflint..."
  curl -sL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
  success "tflint installed ($(get_version tflint))"
}

if ! cmd_exists tflint; then
  install_tflint
else
  success "tflint already installed ($(get_version tflint))"
fi

# ─── terraform-docs (auto-generate module documentation) ─────────────────────
install_terraform_docs() {
  info "Installing terraform-docs..."
  local version
  version=$(curl -sL "https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest" | jq -r .tag_name)
  wget -qO /tmp/terraform-docs.tar.gz \
    "https://github.com/terraform-docs/terraform-docs/releases/download/${version}/terraform-docs-${version}-linux-${ARCH}.tar.gz"
  tar -xzf /tmp/terraform-docs.tar.gz -C /tmp terraform-docs
  sudo mv /tmp/terraform-docs /usr/local/bin/
  rm /tmp/terraform-docs.tar.gz
  success "terraform-docs installed (${version})"
}

if ! cmd_exists terraform-docs; then
  install_terraform_docs
else
  success "terraform-docs already installed ($(get_version terraform-docs))"
fi

echo ""
success "All security & linting tools ready."
