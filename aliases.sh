# Shell Aliases and Functions

# =============================================================================
# Git Functions
# =============================================================================

# Git worktree selector with fzf
wt() {
  local copy_envrc=false
  local name=""

  _wt_usage() {
    cat <<USAGE
Usage: wt [<name>] [-e] [-h]

Git worktree helper with fzf selection.

Options:
  <name>      Create a new worktree with branch name <name>
  -e          Copy .envrc from root and run direnv allow (use with name)
  -h          Show this help message

Examples:
  wt                  Fuzzy select and cd to a worktree (use CTRL-D to delete)
  wt feature-x        Create worktree 'feature-x' and cd into it
  wt feature-x -e     Same as above, plus setup direnv
USAGE
  }

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -e)
      copy_envrc=true
      shift
      ;;
    -h)
      _wt_usage
      return 0
      ;;
    -*)
      _wt_usage
      return 1
      ;;
    *)
      name="$1"
      shift
      ;;
    esac
  done

  if [[ -n "$name" ]]; then
    local root=$(git rev-parse --show-toplevel)
    local new_path
    # If user specified a path with /, use it as-is; otherwise put it in .worktrees/
    if [[ "$name" == */* ]]; then
      new_path="$root/$name"
    else
      local worktrees_dir="$root/.worktrees"
      [[ ! -d "$worktrees_dir" ]] && mkdir -p "$worktrees_dir"
      new_path="$worktrees_dir/$name"
    fi
    git worktree add "$new_path" -b "$(basename "$name")" && cd "$new_path"
    if $copy_envrc && [[ -f "$root/.envrc" ]]; then
      cp "$root/.envrc" "$new_path/.envrc"
      direnv allow
    fi
  else
    local selected=$(git worktree list | \
      fzf --height 40% --reverse \
          --header 'ENTER: cd | CTRL-D: delete | CTRL-L: full log with diffs' \
          --preview 'git -C $(echo {} | awk '\''{print $1}'\'') log --stat --format=medium --color -10' \
          --preview-window 'right:60%:wrap' \
          --bind 'ctrl-d:execute(
            main_wt=$(git worktree list | head -1 | awk '\''{print $1}'\''); \
            wt_path=$(echo {} | awk '\''{print $1}'\''); \
            if [[ "$wt_path" != "$main_wt" ]]; then \
              git worktree remove "$wt_path" && echo "Deleted $wt_path" || echo "Failed to delete $wt_path"; \
            else \
              echo "Error: cannot delete main worktree"; \
            fi; \
            read -p "Press enter to continue..."
          )+reload(git worktree list)' \
          --bind 'ctrl-l:execute(git -C $(echo {} | awk '\''{print $1}'\'') log -p --color | less -R)' | \
      awk '{print $1}')
    [[ -n "$selected" ]] && cd "$selected"
  fi
}

# Fuzzy checkout branch
co() {
  git checkout $(git branch | fzf | tr -d "* ")
}

# =============================================================================
# GCP Functions
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
# Usage: glogin [-f] [-q] [-s]
glogin() {
  local force=false
  local quiet=false
  local sheets=false
  local opt

  while getopts ":fqs" opt; do
    case ${opt} in
    f) force=true ;;
    q) quiet=true ;;
    s) sheets=true ;;
    \?)
      echo "Usage: glogin [-f] [-q] [-s]" >&2
      echo "  -f  Force re-login" >&2
      echo "  -q  Quiet mode" >&2
      echo "  -s  Include Google Sheets scope (requires extra browser auth)" >&2
      return 1
      ;;
    esac
  done

  if ! logged_in=$(yes | gcloud auth print-identity-token --verbosity=debug 2>&1 | grep 'POST /token .* 200'); then
    force=true
  fi

  if [[ $force == true ]]; then
    echo "Time to log back into Google Cloud..."
    gcloud auth login --update-adc
  else
    if [[ $quiet == false ]]; then
      account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
      echo "Already logged in to Google Cloud as $account."
    fi
  fi

  if [[ $sheets == true ]]; then
    current_scopes=$(curl -s "https://oauth2.googleapis.com/tokeninfo?access_token=$(gcloud auth application-default print-access-token 2>/dev/null)" | jq -r '.scope // empty')
    if [[ "$current_scopes" == *"spreadsheets"* ]] && [[ "$current_scopes" == *"cloud-platform"* ]]; then
      if [[ $quiet == false ]]; then
        echo "ADC already has spreadsheets and cloud-platform scopes."
      fi
    else
      echo "Adding Google Sheets scope..."
      gcloud auth application-default login --scopes=https://www.googleapis.com/auth/spreadsheets,https://www.googleapis.com/auth/cloud-platform
    fi
  fi
}

# =============================================================================
# Kubernetes Functions
# =============================================================================

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

# =============================================================================
# Neovim Functions
# =============================================================================

# Neovim: Open ripgrep results in quickfix
rgv() {
  nvim -c "cexpr system('rg -n \"$1\" .')" -c "copen"
}

# =============================================================================
# General Aliases
# =============================================================================

alias nv="nvim"
alias vimdiff="nvim -d"

# =============================================================================
# Kubernetes Aliases
# =============================================================================

alias k="kubectl"
alias kget="kubectl get"
alias kdes="kubectl describe"
alias kdel="kubectl delete"
alias klog="kubectl logs"
alias kexec="kubectl exec -it"
alias kapply="kubectl apply"
alias kdrain="kubectl drain --ignore-daemonsets --delete-emptydir-data"
alias kworkload="kubectl get nodes -o custom-columns=NAME:.metadata.name,WORKLOAD:.metadata.labels.workload"

# =============================================================================
# Stern (Kubernetes log tailing) Aliases
# =============================================================================

alias sternx="stern -o raw -i 'event'"
alias jqx="jq -r '.severity + \" | \" + .event'"

# =============================================================================
# Claude Code Aliases
# =============================================================================

unalias claude 2>/dev/null
claude() {
  source ~/.claude.secret
  command claude "$@"
}

alias cc="claude"
alias ccy="cc --allow-dangerously-skip-permissions --permission-mode plan"
alias claudey="ccy"

unalias ccs 2>/dev/null
ccs() {
  source ~/.claude.secret
  command ccs "$@"
}

unalias ccsy 2>/dev/null
ccsy() {
  ccs "$@" -- --allow-dangerously-skip-permissions --permission-mode plan
}

alias ccspeak="rm ~/.claude/.silence 2> /dev/null"
alias ccquiet="touch ~/.claude/.silence"
