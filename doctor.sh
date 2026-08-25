#!/bin/bash
# Dotfiles drift detector. Exits non-zero if anything is out of sync.
# Run via `dotfiles-doctor` or `make doctor`. `--fix` prompts to apply each fix.

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR" || exit 1

FIX=0
[[ $1 == --fix ]] && FIX=1

problems=0
relink=0

# offer "prompt" cmd... — in --fix mode ask y/N and run cmd; returns 0 if fixed
offer() {
  local prompt="$1"; shift
  (( FIX )) || return 1
  local ans
  read -rp "  $prompt [y/N] " ans || return 1
  [[ $ans == [yY]* ]] && "$@"
}

check_link() {
  local src="$1"
  local dest="$2"
  if [[ ! -L $dest ]]; then
    echo "drift: $dest is not a symlink to $src"
    echo "  fix: cd $DOTFILES_DIR && ./install.sh"
    ((problems++)); relink=1
    return
  fi
  local actual
  actual=$(readlink "$dest")
  if [[ $actual != "$src" ]]; then
    echo "drift: $dest -> $actual (expected $src)"
    echo "  fix: cd $DOTFILES_DIR && ./install.sh"
    ((problems++)); relink=1
  fi
}

check_link "$DOTFILES_DIR/Brewfile" "$HOME/.Brewfile"
check_link "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
check_link "$DOTFILES_DIR/zprofile" "$HOME/.zprofile"
check_link "$DOTFILES_DIR/profile" "$HOME/.profile"
check_link "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
check_link "$DOTFILES_DIR/gitignore_global" "$HOME/.gitignore_global"
check_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
check_link "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
check_link "$DOTFILES_DIR/hammerspoon" "$HOME/.hammerspoon"
check_link "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
check_link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
check_link "$DOTFILES_DIR/claude/hooks" "$HOME/.claude/hooks"

# prompt to relink once, however many links drifted
if (( relink )) && offer "run ./install.sh to relink?" ./install.sh; then
  problems=0
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "drift: dotfiles repo has uncommitted changes"
  git status --short | sed 's/^/  /'
  (( FIX )) && git --no-pager diff
  if ! offer "commit all as 'sync'?" sh -c 'git add -A && git commit -m sync'; then
    echo "  fix: cd $DOTFILES_DIR && git diff  # review"
    echo "       git add -A && git commit -m 'sync'"
    ((problems++))
  fi
fi

if git log origin/main..HEAD --oneline 2>/dev/null | grep -q .; then
  echo "drift: dotfiles repo has unpushed commits"
  git log origin/main..HEAD --oneline | sed 's/^/  /'
  if ! offer "git push?" git push; then
    echo "  fix: cd $DOTFILES_DIR && git push"
    ((problems++))
  fi
fi

if (( problems == 0 )); then
  echo "dotfiles: clean ✓"
else
  echo
  echo "$problems drift issue(s). see 'fix:' lines above."
fi

exit $problems
