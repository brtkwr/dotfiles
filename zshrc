# Completion caching - only rebuild once a day for performance
# ------------------------------------------------------------------------------
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

# Starship prompt
# ------------------------------------------------------------------------------
eval "$(starship init zsh)"

# Git aliases (essential only)
# ------------------------------------------------------------------------------
source ~/Code/dotfiles/git-aliases.zsh

# Fuzzy finder
# ------------------------------------------------------------------------------
eval "$(fzf --zsh)"

# Direnv
# ------------------------------------------------------------------------------
eval "$(direnv hook zsh)"

# google-cloud-sdk
# ------------------------------------------------------------------------------
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

# Docker CLI completions
# ------------------------------------------------------------------------------
fpath=(/Users/brtkwr/.docker/completions $fpath)

# Git worktree selector with fzf
wt() {
  local create=false
  local delete=false
  local copy_envrc=false
  local name=""
  local target=""

  _wt_usage() {
    cat <<USAGE
Usage: wt [-c <name>] [-e] [-d [path]] [-h]

Git worktree helper with fzf selection.

Options:
  -c <name>   Create a new worktree with branch name <name>
  -e          Copy .envrc from root and run direnv allow (use with -c)
  -d [path]   Delete a worktree (fuzzy select if no path given, use '.' for current)
  -h          Show this help message

Examples:
  wt                  Fuzzy select and cd to a worktree
  wt -c feature-x     Create worktree 'feature-x' and cd into it
  wt -c feature-x -e  Same as above, plus setup direnv
  wt -d               Fuzzy select a worktree to delete
  wt -d .             Delete the current worktree
  wt -d my-feature    Delete worktree 'my-feature'
USAGE
  }

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c) create=true; name="$2"; shift 2 ;;
      -e) copy_envrc=true; shift ;;
      -d) delete=true; shift; [[ $# -gt 0 && ! "$1" =~ ^- ]] && { target="$1"; shift; } ;;
      -h) _wt_usage; return 0 ;;
      *) _wt_usage; return 1 ;;
    esac
  done

  if ($create || $copy_envrc) && $delete; then
    echo "Error: -c/-e and -d are mutually exclusive"; return 1
  fi

  if $create; then
    [[ -z "$name" ]] && { echo "Error: -c requires a name"; return 1; }
    local root=$(git rev-parse --show-toplevel)
    local new_path="$root/$name"
    git worktree add "$new_path" -b "$name" && cd "$new_path"
    if $copy_envrc && [[ -f "$root/.envrc" ]]; then
      cp "$root/.envrc" "$new_path/.envrc"
      direnv allow
    fi
  elif $delete; then
    local to_delete
    if [[ -n "$target" ]]; then
      to_delete=$(realpath "$target")
    else
      to_delete=$(git worktree list | fzf --height 40% --reverse | awk '{print $1}')
    fi
    [[ -z "$to_delete" ]] && return 0
    local main_wt=$(git worktree list | head -1 | awk '{print $1}')
    if [[ "$to_delete" == "$main_wt" ]]; then
      echo "Error: cannot delete main worktree"; return 1
    fi
    [[ "$(realpath .)" == "$to_delete"* ]] && cd "$main_wt"
    git worktree remove "$to_delete"
  else
    local selected=$(git worktree list | fzf --height 40% --reverse | awk '{print $1}')
    [[ -n "$selected" ]] && cd "$selected"
  fi
}
