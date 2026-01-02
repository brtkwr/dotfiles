# dotfiles

My macOS configuration files.

## Install

```bash
git clone https://github.com/brtkwr/dotfiles.git ~/Code/dotfiles
cd ~/Code/dotfiles
./install.sh
```

This creates symlinks from `$HOME` to this repo, so any changes you make are automatically tracked.

## What's included

- **zshrc** - shell config
- **zprofile** - shell profile
- **gitconfig** - git settings
- **nvim/** - Neovim config (LazyVim + ty + ruff)

## Updating

Since configs are symlinked, just edit them normally. Then:

```bash
cd ~/Code/dotfiles
git add -A
git commit -m "Update configs"
git push
```
