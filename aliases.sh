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
  <name>      Create or switch to worktree with branch <name>
  -e          Copy .envrc from root and run direnv allow (use with name)
  -h          Show this help message

Interactive mode (no args):
  ENTER       cd into selected worktree
  CTRL-A      Create new worktree from search query
  CTRL-D      Delete worktree
  CTRL-R      Move worktree to new path
  CTRL-L      View full git log with diffs

Examples:
  wt                  Open interactive selector
  wt feature-x        Create/switch to 'feature-x' worktree
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
    local branch_name=$(basename "$name")

    # Check if worktree with this branch already exists
    local existing_path=$(git worktree list | grep -E "\[${branch_name}\]$" | awk '{print $1}')
    if [[ -n "$existing_path" ]]; then
      cd "$existing_path"
      return 0
    fi

    local new_path
    # If user specified a path with /, use it as-is; otherwise put it in .worktrees/
    if [[ "$name" == */* ]]; then
      new_path="$root/$name"
    else
      local worktrees_dir="$root/.worktrees"
      [[ ! -d "$worktrees_dir" ]] && mkdir -p "$worktrees_dir"
      new_path="$worktrees_dir/$name"
    fi
    git worktree add "$new_path" -b "$branch_name" && cd "$new_path"
    if $copy_envrc && [[ -f "$root/.envrc" ]]; then
      cp "$root/.envrc" "$new_path/.envrc"
      direnv allow
    fi
  else
    while true; do
      local result=$(git worktree list | \
        fzf --height 40% --reverse \
            --header 'ENTER: cd | CTRL-A: create from query | CTRL-D: delete | CTRL-R: move | CTRL-L: log' \
            --preview 'git -C $(echo {} | awk '\''{print $1}'\'') log --stat --format=medium --color -10' \
            --preview-window 'right:60%:wrap' \
            --print-query \
            --expect=ctrl-a,ctrl-d,ctrl-r \
            --bind 'ctrl-l:execute(git -C $(echo {} | awk '\''{print $1}'\'') log -p --color | less -R)')

      local query=$(echo "$result" | sed -n '1p')
      local key=$(echo "$result" | sed -n '2p')
      local selection=$(echo "$result" | sed -n '3p')

      case "$key" in
        ctrl-a)
          [[ -z "$query" ]] && continue
          local root=$(git rev-parse --show-toplevel)
          local worktrees_dir="$root/.worktrees"
          mkdir -p "$worktrees_dir"
          local new_path="$worktrees_dir/$query"
          if git worktree add "$new_path" -b "$query"; then
            cd "$new_path"
            return 0
          fi
          sleep 1
          ;;
        ctrl-d)
          [[ -z "$selection" ]] && continue
          local main_wt=$(git worktree list | head -1 | awk '{print $1}')
          local wt_path=$(echo "$selection" | awk '{print $1}')
          if [[ "$wt_path" == "$main_wt" ]]; then
            echo "Error: cannot delete main worktree"
            sleep 1
            continue
          fi
          if git worktree remove "$wt_path"; then
            echo "Deleted $wt_path"
            sleep 1
          fi
          ;;
        ctrl-r)
          [[ -z "$selection" ]] && continue
          local main_wt=$(git worktree list | head -1 | awk '{print $1}')
          local wt_path=$(echo "$selection" | awk '{print $1}')
          if [[ "$wt_path" == "$main_wt" ]]; then
            echo "Error: cannot move main worktree"
            sleep 1
            continue
          fi
          local root=$(git rev-parse --show-toplevel)
          echo -n "New name (or path): "
          read new_path </dev/tty
          [[ -z "$new_path" ]] && continue
          local full_new_path
          # Absolute path - use as-is
          if [[ "$new_path" == /* ]]; then
            full_new_path="$new_path"
          # Relative path with slash - relative to repo root
          elif [[ "$new_path" == */* ]]; then
            full_new_path="$root/$new_path"
          # Just a name - keep in .worktrees/
          else
            mkdir -p "$root/.worktrees"
            full_new_path="$root/.worktrees/$new_path"
          fi
          if git worktree move "$wt_path" "$full_new_path"; then
            echo "Moved to $full_new_path"
            sleep 1
          fi
          ;;
        *)
          [[ -n "$selection" ]] && cd "$(echo "$selection" | awk '{print $1}')"
          return 0
          ;;
      esac
    done
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
      echo "  -f  Force re-login" >&2
      echo "  -q  Quiet mode" >&2
      return 1
      ;;
    esac
  done

  # Check if token is valid (file-based check, no network call)
  local adc_file="${HOME}/.config/gcloud/application_default_credentials.json"
  local cache_file="${HOME}/.config/gcloud/.glogin_check"
  local now=$(date +%s)
  local cache_age=3600  # Check at most once per hour

  if [[ -f "$cache_file" ]]; then
    local last_check=$(cat "$cache_file")
    if (( now - last_check < cache_age )) && [[ $force == false ]]; then
      [[ $quiet == false ]] && echo "GCP auth checked recently, skipping."
      return 0
    fi
  fi

  # Quick check: does ADC file exist and is it recent?
  if [[ $force == false ]] && [[ -f "$adc_file" ]]; then
    # Try a quick token check
    if gcloud auth application-default print-access-token &>/dev/null; then
      echo "$now" > "$cache_file"
      [[ $quiet == false ]] && echo "Already logged in to Google Cloud."
      return 0
    fi
  fi

  # Need to login - CLI auth + ADC with all scopes
  echo "Logging into Google Cloud..."
  gcloud auth login && \
  gcloud auth application-default login \
    --scopes=openid,https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/spreadsheets && \
  echo "$now" > "$cache_file"
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
