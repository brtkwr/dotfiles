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
# Aliases and Functions
# =============================================================================
source ~/Code/dotfiles/aliases.sh

# =============================================================================
# Startup
# =============================================================================
glogin -qs
(brew update >/dev/null 2>&1 &)
