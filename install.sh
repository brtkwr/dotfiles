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
link "$DOTFILES_DIR/profile" "$HOME/.profile"

# Git
link "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"

# Neovim
mkdir -p "$HOME/.config"
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Starship
link "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

# Hammerspoon
link "$DOTFILES_DIR/hammerspoon" "$HOME/.hammerspoon"

# Claude Code
mkdir -p "$HOME/.claude"
link "$DOTFILES_DIR/claude/CLAUDE.public.md" "$HOME/.claude/CLAUDE.public.md"
link "$DOTFILES_DIR/claude/build-claude-md.sh" "$HOME/.claude/build-claude-md.sh"
link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/claude/hooks" "$HOME/.claude/hooks"
# Build CLAUDE.md from all CLAUDE.*.md files
"$HOME/.claude/build-claude-md.sh"

echo "Done! Restart your shell or run: source ~/.zshrc"
