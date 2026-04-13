# DevOps Workstation Setup

Automated, idempotent development environment setup.

One command installs and configures every tool needed to build production-grade Kubernetes infrastructure on AWS with Terraform, Terragrunt, Helm, and GitHub Actions CI/CD.

```bash
make all
```

## Why This Exists

Setting up a DevOps workstation involves 20+ tools across cloud providers, container runtimes, orchestrators, IaC, security scanners, and debugging utilities. Doing this manually is error-prone and unreproducible. This repo automates the entire process with modular, idempotent bash scripts orchestrated by a Makefile.

**Design principles:**
- **Idempotent** — safe to run repeatedly. Scripts check before installing, update only when needed.
- **Modular** — each script handles one logical group. Run everything or just what you need.
- **Version-pinned** — critical tools pinned to tested versions. No surprise breaking changes.
- **Self-verifying** — built-in verification reports exactly what's installed and what's missing.

## Quick Start

```bash
# Clone the repo
git clone git@github.com:LeonTH096/devops-workstation-setup.git
cd devops-workstation-setup

# Full setup (first time)
make all

# Reload shell to pick up new aliases and completions
source ~/.zshrc   # or ~/.bashrc
```

That's it. `make all` runs every script in order, installs missing tools, skips what's already current, configures your shell, and finishes with a full verification report.

## What Gets Installed

### Core Tools (`make core`)

| Tool | Version | Purpose |
|------|---------|---------|
| Docker Engine | 27.x+ | Container builds, local testing, kind clusters |
| AWS CLI v2 | 2.x (latest) | EKS, ECR, S3, IAM — all AWS interactions |
| Terraform | >= 1.14.8 | IaC foundation (Babenko modules, state management) |
| Terragrunt | 1.0.0 | DRY infrastructure orchestration (Sistemi pattern) |
| kubectl | 1.31.x | Kubernetes cluster interaction (pinned to EKS version) |
| Helm | >= 4.1.x | Kubernetes package management (Server-Side Apply) |

### Kubernetes Ecosystem (`make k8s`)

| Tool | Purpose |
|------|---------|
| kind | Local Kubernetes clusters for Helm chart development |
| eksctl | EKS cluster utilities and OIDC troubleshooting |
| kubeconform | Validate Helm-rendered manifests against K8s JSON schemas |
| pluto | Detect deprecated Kubernetes API versions |

### Security & Linting (`make security`)

| Tool | Purpose |
|------|---------|
| Trivy | Container image CVE scanning + Terraform misconfiguration detection |
| tflint | Terraform linter (catches errors `terraform validate` misses) |
| terraform-docs | Auto-generate documentation from Terraform modules |

### Productivity & Debugging (`make productivity`)

| Tool | Purpose |
|------|---------|
| k9s | Terminal UI for Kubernetes — real-time cluster management |
| stern | Multi-pod log tailing with color-coded output |
| kubectx / kubens | Fast context and namespace switching |
| dive | Docker image layer analysis for size optimization |
| act | Run GitHub Actions workflows locally |

### VS Code (`make vscode`)

**Essential extensions:** HashiCorp Terraform, Docker, Kubernetes, YAML, GitHub Actions, Helm Intellisense, Makefile Tools, SOPS.

**Recommended extensions:** GitLens, Spell Checker, Todo Tree, Material Icons, Prettier, markdownlint.

Also includes `.vscode/settings.json` with format-on-save, schema associations for K8s YAML and GitHub Actions workflows, and search exclusions for `.terraform` and `.terragrunt-cache`.

### Shell Configuration (`make shell`)

Adds a managed block to your `~/.zshrc` (or `~/.bashrc`) with:

- `AWS_PROFILE=npo-aws` and `AWS_DEFAULT_REGION=eu-west-1`
- `TF_PLUGIN_CACHE_DIR` for shared Terraform provider cache
- Aliases: `tf`, `tg`, `k`, `h`, `d`
- kubectl and Helm autocompletion
- Terraform plugin cache directory creation

The block is clearly marked and replaced on re-runs — it won't duplicate.

## Usage

```bash
# Full setup (recommended first time)
make all

# Individual targets
make prereqs        # System packages (curl, git, jq, etc.)
make core           # Docker, AWS CLI, Terraform, Terragrunt, kubectl, Helm
make k8s            # kind, eksctl, kubeconform, pluto
make security       # Trivy, tflint, terraform-docs
make productivity   # k9s, stern, kubectx, dive, act
make vscode         # VS Code extensions
make shell          # Shell aliases, env vars, completions

# Verification only (no installs)
make verify

# Combine targets
make core verify        # Update core tools then verify
make core k8s verify    # Update core + k8s tools then verify

# Cleanup temp files
make clean

# Show help
make help
```

## Verification

`make verify` produces a color-coded report:

```
═══ DevOps Project 2026 — Environment Verification ═══

Core Tools:
[PASS]  Docker                 27.5.1
[PASS]  AWS CLI                aws-cli/2.27.41
[PASS]  Terraform              1.14.8
[PASS]  Terragrunt             1.0.0
[PASS]  kubectl                v1.31.4
[PASS]  Helm                   v4.1.3

Kubernetes Ecosystem:
[PASS]  kind                   0.27.0
[PASS]  eksctl                 0.204.0
...

═══ Summary ═══
  Passed:   28
  Failed:   0
  Skipped:  2

Environment is ready! You can start building.
```

## Version Pinning Strategy

- **kubectl** is pinned to `1.31.x` to match the EKS cluster version (±1 minor version skew policy).
- **Terragrunt** is pinned to `1.0.0` — the first stable release with guaranteed backwards compatibility.
- **Terraform** requires `>= 1.14.0` (current latest: 1.14.8). Babenko modules work with TF >= 1.3.
- **Helm** requires `>= 4.1.0`. Helm 4 uses Server-Side Apply by default for new installations.
- All other tools install the latest stable release.

## Repo Structure

```
devops-workstation-setup/
├── Makefile                    # Orchestrator — single entry point
├── scripts/
│   ├── common.sh               # Shared helpers (colors, version checks)
│   ├── 00-prerequisites.sh     # System packages
│   ├── 01-core-tools.sh        # Docker, AWS CLI, TF, TG, kubectl, Helm
│   ├── 02-k8s-tools.sh         # kind, eksctl, kubeconform, pluto
│   ├── 03-security-lint.sh     # Trivy, tflint, terraform-docs
│   ├── 04-productivity.sh      # k9s, stern, kubectx, dive, act
│   ├── 05-vscode.sh            # VS Code extensions
│   ├── 06-shell-config.sh      # Shell env vars, aliases, completions
│   └── 07-verify.sh            # Full verification report
├── .vscode/
│   ├── settings.json           # Workspace settings (copy to your project)
│   └── extensions.json         # Extension recommendations
├── .gitignore
└── README.md
```

## How Scripts Work

Each script follows the same pattern:

1. **Source `common.sh`** — loads color helpers, version comparison functions, architecture detection.
2. **Check if tool exists** — `cmd_exists` tests if the binary is in `$PATH`.
3. **Compare versions** — `version_gte` does semver comparison. If installed version meets minimum, skip.
4. **Install or update** — downloads from official sources (GitHub releases, apt repos, install scripts).
5. **Verify** — prints the installed version with a green `[OK]` status.

This makes every script **idempotent**: running it twice produces the same result without errors.

## Customization

### Changing tool versions

Edit the `MIN_*` and `*_TARGET` variables at the top of each script:

```bash
# In scripts/01-core-tools.sh
MIN_TF="1.14.0"        # Minimum Terraform version
MIN_HELM="4.1.0"       # Minimum Helm version
TG_TARGET="v1.0.0"     # Exact Terragrunt version to install
```

### Adding new tools

1. Add installation logic to the appropriate script (or create a new `0N-*.sh`).
2. Add a check to `07-verify.sh`.
3. If new script, add a Makefile target.

### Changing AWS profile

Edit `scripts/06-shell-config.sh` and update the `AWS_PROFILE` value.

## Prerequisites

- **OS:** Ubuntu 24.04 LTS (tested). Should work on 22.04+ and Debian 12+.
- **Privileges:** Non-root user with `sudo` access.
- **Internet:** Required for downloads from GitHub, Docker Hub, HashiCorp, AWS.
- **VS Code:** Must be installed separately (scripts install extensions, not VS Code itself).

## Part of DevOps Project 2026

This repo is the environment setup companion to the main portfolio:

- **Main project:** [`devops-project-2026`](https://github.com/LeonTH096/devops-project-2026) — production-grade AWS infrastructure + Kubernetes platform
- **This repo:** `devops-workstation-setup` — automated workstation provisioning

Both repos demonstrate platform engineering thinking: automate everything, make it reproducible, document decisions.

## License

MIT
