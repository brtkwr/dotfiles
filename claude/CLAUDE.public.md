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

## Git

- **IMPORTANT**: Always pull latest changes from origin before starting work on a task
- For open source projects, use conventional commit format (feat:, fix:, etc.) - no Linear tickets
- Always create worktrees in a `.worktrees/` subdirectory, never at the repository root
- Always add `.worktrees/` to .gitignore if it doesn't already exist
- **Always create a git worktree for each new feature or task** — worktrees live in `{project_dir}/.worktrees/`

## Blog Posts

- Proactively suggest writing a blog post when a session involves significant learning (migrations, non-obvious gotchas, debugging with interesting root causes)
- Check ~/Code/brtkwr/brtkwr.com/AGENTS.md for style guidelines. Genericise all company-specific details.
- **Always create a branch and raise a PR** — never push directly to main
