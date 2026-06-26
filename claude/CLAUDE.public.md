## User Memory

Edit the appropriate source file when updating instructions:
- `~/.claude/CLAUDE.public.md` (synced via dotfiles) / `~/.claude/CLAUDE.private.md` (not synced) / `~/.claude/CLAUDE.work.md` (Two Inc)

## General Rules

- Always use British english unless asked otherwise
- When using secrets from env vars in curl headers, use backticks `` `printenv VAR` `` not `$(printenv VAR)` or `$VAR` (zsh expansion issues)

## Dotfiles

Config files are managed in `~/Code/brtkwr/dotfiles/`. When modifying any of these, update the source and push:

- **Claude instructions**: `~/Code/brtkwr/dotfiles/claude/CLAUDE.public.md`
- **Shell**: `~/Code/brtkwr/dotfiles/zshrc`, `~/Code/brtkwr/dotfiles/profile`, `~/Code/brtkwr/dotfiles/zprofile`
- **Neovim**: `~/Code/brtkwr/dotfiles/nvim/`
- **Git**: `~/Code/brtkwr/dotfiles/gitconfig`
- **Hammerspoon**: `~/Code/brtkwr/dotfiles/hammerspoon/`
