#!/bin/bash
# Dotfiles installer - creates symlinks from $HOME to this repo

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up $dest to $dest.backup"
        mv "$dest" "$dest.backup"
    fi

    if [ -L "$dest" ]; then
        rm "$dest"
    fi

    echo "Linking $dest -> $src"
    ln -s "$src" "$dest"
}

echo "Installing dotfiles from $DOTFILES_DIR"

# Shell
link "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/zprofile" "$HOME/.zprofile"

# Git
link "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"

# Neovim
mkdir -p "$HOME/.config"
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Hammerspoon
link "$DOTFILES_DIR/hammerspoon" "$HOME/.hammerspoon"

# Claude Code
mkdir -p "$HOME/.claude"
# CLAUDE.md is concatenated from base + all CLAUDE.*.md files (not symlinked)
echo "Building $HOME/.claude/CLAUDE.md"
cp "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
for f in "$HOME/.claude"/CLAUDE.*.md; do
    [ -f "$f" ] || continue
    echo "" >> "$HOME/.claude/CLAUDE.md"
    cat "$f" >> "$HOME/.claude/CLAUDE.md"
    echo "  + $(basename "$f")"
done
link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/claude/hooks" "$HOME/.claude/hooks"
link "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"

echo "Done! Restart your shell or run: source ~/.zshrc"
