# =============================================================================
# Secrets
# =============================================================================
source ~/.secrets

# =============================================================================
# Homebrew (early init - needed for brew --prefix)
# =============================================================================
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=1
export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"

# =============================================================================
# Environment Variables
# =============================================================================

# GPG
export GPG_TTY=$(tty)

# Go
export GOPATH="$HOME/.local/share/go"
export GOBIN="$HOME/.local/bin"

# Terraform
export TF_CLI_ARGS_plan="-parallelism=50"
export TF_CLI_ARGS_apply="-parallelism=50"

# GCP
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# 1Password SSH Agent
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Tools
export AIDER_MODEL="gemini"
export MCP_TOOL_TIMEOUT=10000

# =============================================================================
# PATH
# =============================================================================
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.claude/bin"
export PATH="$PATH:$HOME/Code/two/infra/bin"
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# =============================================================================
# Tool Initialisations
# =============================================================================

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Google Cloud SDK
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"

# =============================================================================
# Functions
# =============================================================================

# GCP: Fetch secret
# Usage: gsecret [secret-name] [-p|--project project-id]
gsecret() {
  local secret_name=""
  local project=""

  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
      echo "Usage: gsecret [secret-name] [-p|--project project-id]"
      echo ""
      echo "Options:"
      echo "  -p, --project    GCP project ID (defaults to current project)"
      echo "  -h, --help       Show this help message"
      echo ""
      echo "Examples:"
      echo "  gsecret                          # List and select secret from current project"
      echo "  gsecret my-secret                # Get 'my-secret' from current project"
      echo "  gsecret -p my-project            # List and select secret from 'my-project'"
      echo "  gsecret my-secret -p my-project  # Get 'my-secret' from 'my-project'"
      return 0
      ;;
    -p | --project)
      if [[ -z "$2" || "$2" == -* ]]; then
        echo "Error: -p|--project requires a project ID argument" >&2
        echo "Run 'gsecret --help' for usage information" >&2
        return 1
      fi
      project="$2"
      shift 2
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      echo "Run 'gsecret --help' for usage information" >&2
      return 1
      ;;
    *)
      secret_name="$1"
      shift
      ;;
    esac
  done

  if [[ -z "$project" ]]; then
    project=$(gcloud config get-value project 2>/dev/null)
  fi

  if [[ -z "$project" ]]; then
    echo "Error: No project specified and no default project configured" >&2
    return 1
  fi

  if [[ -z "$secret_name" ]]; then
    secret_name=$(gcloud secrets list --project="$project" --format="value(name)" | fzf --prompt="Select secret from $project: ")
    if [[ -z "$secret_name" ]]; then
      echo "No secret selected" >&2
      return 1
    fi
  fi

  gcloud secrets versions access latest --secret="$secret_name" --project="$project"
}

# GCP: Auto login
# Usage: glogin [-f] [-q]
glogin() {
  local force=false
  local quiet=false
  local opt

  while getopts ":fq" opt; do
    case ${opt} in
    f) force=true ;;
    q) quiet=true ;;
    \?)
      echo "Usage: glogin [-f] [-q]" >&2
      return 1
      ;;
    esac
  done

  if ! logged_in=$(yes | gcloud auth print-identity-token --verbosity=debug 2>&1 | grep 'POST /token .* 200'); then
    force=true
  fi

  if [[ $force == true ]]; then
    echo "Time to log back into Google Cloud..."
    gcloud auth login --update-adc --scopes="https://www.googleapis.com/auth/spreadsheets,https://www.googleapis.com/auth/cloud-platform"
  else
    if [[ $quiet == false ]]; then
      account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
      echo "Already logged in to Google Cloud as $account."
    fi
  fi
}

# Kubernetes: Switch context and namespace
# Usage: kube <cluster> <namespace>
kube() {
  kubectx ${1:-}
  kubens ${2:-}
}

# Kubernetes: Force ArgoCD sync
ksync() {
  kubectl patch app "${1}" -n argocd \
    -p '{"metadata": {"annotations":{"argocd.argoproj.io/refresh":"hard"}}}' \
    --type merge
}

# Neovim: Open ripgrep results in quickfix
rgv() {
  nvim -c "cexpr system('rg -n \"$1\" .')" -c "copen"
}

# =============================================================================
# Aliases
# =============================================================================

# General
alias nv="nvim"
alias vimdiff="nvim -d"

# Git
alias co='git checkout $(git branch | fzf | tr -d "* ")'

# Kubernetes
alias k="kubectl"
alias kget="kubectl get"
alias kdes="kubectl describe"
alias kdel="kubectl delete"
alias klog="kubectl logs"
alias kexec="kubectl exec -it"
alias kapply="kubectl apply"
alias kdrain="kubectl drain --ignore-daemonsets --delete-emptydir-data"
alias kworkload="kubectl get nodes -o custom-columns=NAME:.metadata.name,WORKLOAD:.metadata.labels.workload"

# Stern (Kubernetes log tailing)
alias sternx="stern -o raw -i 'event'"
alias jqx="jq -r '.severity + \" | \" + .event'"

# Claude Code
alias claudes="rm ~/.claude/.silence 2> /dev/null"
alias claudeq="touch ~/.claude/.silence"
alias claudey="claude --dangerously-skip-permissions"
alias ccsy="ccs --dangerously-skip-permissions"

# =============================================================================
# Startup
# =============================================================================
glogin -q
(brew update >/dev/null 2>&1 &)
