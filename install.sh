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

# Homebrew
link "$DOTFILES_DIR/Brewfile" "$HOME/.Brewfile"

# Shell
link "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/zprofile" "$HOME/.zprofile"
link "$DOTFILES_DIR/profile" "$HOME/.profile"

# Secrets template (1Password)
link "$DOTFILES_DIR/secrets.tpl" "$HOME/.secrets.tpl"

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

# ~/lib dyld fallback symlinks for weasyprint/pango on macOS
# macOS SIP strips DYLD_LIBRARY_PATH at exec boundaries (e.g. /usr/bin/env),
# so we create name-compatible symlinks in ~/lib which dyld always searches.
# Using unversioned .dylib paths so these survive homebrew upgrades.
mkdir -p "$HOME/lib"
for pair in \
    "libgobject-2.0-0.dylib:/opt/homebrew/lib/libgobject-2.0.dylib" \
    "libpango-1.0-0.dylib:/opt/homebrew/lib/libpango-1.0.dylib" \
    "libharfbuzz.dylib:/opt/homebrew/lib/libharfbuzz.dylib" \
    "libfontconfig.dylib:/opt/homebrew/lib/libfontconfig.dylib" \
    "libpangoft2-1.0-0.dylib:/opt/homebrew/lib/libpangoft2-1.0.dylib"
do
    name="${pair%%:*}"
    target="${pair##*:}"
    if [ -e "$target" ]; then
        ln -sf "$target" "$HOME/lib/$name"
        echo "Linking ~/lib/$name -> $target"
    else
        echo "Skipping ~/lib/$name (target not found: $target)"
    fi
done

echo "Done! Restart your shell or run: source ~/.zshrc"
