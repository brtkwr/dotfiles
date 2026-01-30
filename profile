# =============================================================================
# Secrets
# =============================================================================
source ~/.secrets

# =============================================================================
# Homebrew (early init - needed for brew --prefix)
# =============================================================================
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=1
export BREW_PREFIX="/opt/homebrew" # Cache brew prefix - avoids subprocess calls
export DYLD_LIBRARY_PATH="$BREW_PREFIX/lib:$DYLD_LIBRARY_PATH"

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

# fnm (fast node manager)
eval "$(fnm env)"

# nvm compatibility wrapper
nvm() {
  case "$1" in
  ls)
    shift
    fnm list "$@"
    ;;
  ls-remote)
    shift
    fnm list-remote "$@"
    ;;
  alias)
    shift
    [[ "$1" == "default" ]] && shift
    fnm default "$@"
    ;;
  *) fnm "$@" ;;
  esac
}

# Google Cloud SDK (PATH only - completions loaded in .zshrc)
source "$BREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"

# =============================================================================
# Aliases and Functions
# =============================================================================
source ~/Code/dotfiles/aliases.sh

# =============================================================================
# Startup (backgrounded to avoid blocking, skipped in Claude Code)
# =============================================================================
if [[ -z "$CLAUDECODE" ]]; then
  # Check ADC validity and auto-login if needed
  (
    adc_file="$HOME/.config/gcloud/application_default_credentials.json"
    needs_login=false

    if [[ ! -f "$adc_file" ]]; then
      needs_login=true
    else
      now=$(date +%s)
      file_age=$(( now - $(stat -f %m "$adc_file") ))
      if (( file_age > 3600 )); then  # Older than 1 hour
        needs_login=true
      elif ! gcloud auth application-default print-access-token &>/dev/null; then
        needs_login=true
      fi
    fi

    if [[ $needs_login == true ]]; then
      glogin
    fi
  ) &
  (brew update >/dev/null 2>&1 &)
fi
