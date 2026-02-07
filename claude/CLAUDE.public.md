## User Memory

When asked to update user memory/instructions, edit the appropriate source file:
- `~/.claude/CLAUDE.work.md` - Work-specific instructions (Two Inc)
- `~/.claude/CLAUDE.private.md` - Private personal instructions (not synced)
- `~/.claude/CLAUDE.public.md` - Public personal instructions (synced via dotfiles)

## General Rules

- ALWAYS load project specific @AGENTS.md
- `@` file references in CLAUDE.md/AGENTS.md must be on their own line to be resolved — inline references within a sentence won't work
- Always mention the specific model when signing git commits and PRs (e.g., Claude Opus 4.5, Claude Sonnet 4)
- Always use British english unless asked otherwise
- All my code lives under ~/Code/
- Always import modules at the top unless there is a risk of circular import

## Dotfiles

Config files are managed in `~/Code/dotfiles/`. When modifying any of these, update the source and push:

- **Claude instructions**: `~/Code/dotfiles/claude/CLAUDE.public.md`
- **Shell**: `~/Code/dotfiles/zshrc`, `~/Code/dotfiles/profile`, `~/Code/dotfiles/zprofile`
- **Neovim**: `~/Code/dotfiles/nvim/`
- **Git**: `~/Code/dotfiles/gitconfig`
- **Hammerspoon**: `~/Code/dotfiles/hammerspoon/`

After changes, commit and push to dotfiles repo.

## Command Preferences

- Use fd instead of find to search files by name
- Always use rg instead of grep
- When using secrets from env vars in curl headers, use backticks `` `printenv VAR` `` not `$(printenv VAR)` or `$VAR` (zsh expansion issues)

## Git

- **IMPORTANT**: Always pull latest changes from origin before starting work on a task
- For open source projects, use conventional commit format (feat:, fix:, etc.) - no Linear tickets
- For trivial changes, use --no-verify flag when making commits
- **IMPORTANT**: Always create worktrees in a `.worktrees/` subdirectory, never at the repository root
- Always add `.worktrees/` to .gitignore if it doesn't already exist

### **USE WORKTREES FOR EVERY NEW FEATURE**

**Always create a git worktree for each new feature or task.** This prevents:
- Stashing/unstashing conflicts when switching between work
- Accidentally mixing changes from different features
- Having to checkout branches and lose local state
- The pain of managing multiple in-progress features in a single directory

Worktrees live in `{project_dir}/.worktrees/` - e.g. `/Users/brtkwr/Code/two/checkout-api/.worktrees/my-feature`

## Blog Posts

- When completing a substantial technical task (migrations, debugging deep issues, setting up new tooling), consider whether it would make a good blog post for ~/Code/brtkwr.com
- **Proactively suggest** writing a blog post when a session involves significant learning - don't wait to be asked
- Signs something is blog-worthy: multi-step migrations, non-obvious gotchas discovered, patterns that would help others, debugging sessions with interesting root causes
- Check ~/Code/brtkwr.com/AGENTS.md for writing style guidelines
- Genericise all company-specific details - no internal names, URLs, or proprietary info
- Focus on the technical learnings that would help others facing similar problems
