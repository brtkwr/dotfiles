# User Memory

This file (`~/.claude/CLAUDE.md`) is synced via dotfiles and loads globally. Project-specific instructions live in each project's own `CLAUDE.md`.

## General Rules

- Always use British english unless asked otherwise
- When using secrets from env vars in curl headers, use backticks `` `printenv VAR` `` not `$(printenv VAR)` or `$VAR` (zsh expansion issues)

## Saving memories

Choose scope before saving an auto-memory, then write to the matching dir and update that dir's `MEMORY.md` index:

- **Global / cross-project** (tone, writing, git/PR habits, general tooling) → `~/.claude/projects/-Users-brtkwr/memory/`
- **Project-specific** (repo conventions, infra, tracker workflow) → that project's memory dir; the project's own `CLAUDE.md` names the exact path.

The harness defaults to the *current* project's dir. Override to the home dir above when the fact is genuinely global — don't let a cross-project rule get trapped in one repo's memory.

## Dotfiles

Config files are managed in `~/Code/brtkwr/dotfiles/`. When modifying any of these, update the source and push:

- **Claude instructions**: `~/Code/brtkwr/dotfiles/claude/CLAUDE.md`
- **Shell**: `~/Code/brtkwr/dotfiles/zshrc`, `~/Code/brtkwr/dotfiles/profile`, `~/Code/brtkwr/dotfiles/zprofile`
- **Neovim**: `~/Code/brtkwr/dotfiles/nvim/`
- **Git**: `~/Code/brtkwr/dotfiles/gitconfig`
- **Hammerspoon**: `~/Code/brtkwr/dotfiles/hammerspoon/`

@~/.claude/projects/-Users-brtkwr/memory/MEMORY.md
