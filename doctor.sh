#!/bin/bash
# Dotfiles drift detector. Exits non-zero if anything is out of sync.
# Run via `dotfiles-doctor` or `make doctor`.

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR" || exit 1

problems=0

check_link() {
  local src="$1"
  local dest="$2"
  if [[ ! -L $dest ]]; then
    echo "drift: $dest is not a symlink to $src"
    echo "  fix: cd $DOTFILES_DIR && ./install.sh"
    ((problems++))
    return
  fi
  local actual
  actual=$(readlink "$dest")
  if [[ $actual != "$src" ]]; then
    echo "drift: $dest -> $actual (expected $src)"
    echo "  fix: cd $DOTFILES_DIR && ./install.sh"
    ((problems++))
  fi
}

check_link "$DOTFILES_DIR/Brewfile" "$HOME/.Brewfile"
check_link "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
check_link "$DOTFILES_DIR/zprofile" "$HOME/.zprofile"
check_link "$DOTFILES_DIR/profile" "$HOME/.profile"
check_link "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
check_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
check_link "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
check_link "$DOTFILES_DIR/hammerspoon" "$HOME/.hammerspoon"
check_link "$DOTFILES_DIR/claude/CLAUDE.public.md" "$HOME/.claude/CLAUDE.public.md"
check_link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
check_link "$DOTFILES_DIR/claude/hooks" "$HOME/.claude/hooks"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "drift: dotfiles repo has uncommitted changes"
  git status --short | sed 's/^/  /'
  echo "  fix: cd $DOTFILES_DIR && git diff  # review"
  echo "       git add -A && git commit -m 'sync'"
  ((problems++))
fi

if git log origin/main..HEAD --oneline 2>/dev/null | grep -q .; then
  echo "drift: dotfiles repo has unpushed commits"
  git log origin/main..HEAD --oneline | sed 's/^/  /'
  echo "  fix: cd $DOTFILES_DIR && git push"
  ((problems++))
fi

if (( problems == 0 )); then
  echo "dotfiles: clean ✓"
else
  echo
  echo "$problems drift issue(s). see 'fix:' lines above."
fi

exit $problems
