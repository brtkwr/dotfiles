## General Rules

- ALWAYS load project specific @AGENTS.md
- Always mention the specific model when signing git commits and PRs (e.g., Claude Opus 4.5, Claude Sonnet 4)
- Always use British english unless asked otherwise
- All my code lives under ~/Code/
- Always import modules at the top unless there is a risk of circular import

## Dotfiles

- When updating Claude instructions, edit `~/Code/dotfiles/claude/CLAUDE.public.md` (not `~/.claude/CLAUDE.md` directly)
- After editing, run `~/Code/dotfiles/claude/build-claude-md.sh` to rebuild
- Commit and push dotfiles changes

## Command Preferences

- Use fd instead of find to search files by name
- Always use rg instead of grep
- When using secrets from env vars in curl headers, use backticks `` `printenv VAR` `` not `$(printenv VAR)` or `$VAR` (zsh expansion issues)

## Git

- For open source projects, use conventional commit format (feat:, fix:, etc.) - no Linear tickets
- For trivial changes, use --no-verify flag when making commits
- Always create worktrees in a subdirectory

## Blog Posts

- When completing a substantial technical task (migrations, debugging deep issues, setting up new tooling), consider whether it would make a good blog post for ~/Code/brtkwr.com
- **Proactively suggest** writing a blog post when a session involves significant learning - don't wait to be asked
- Signs something is blog-worthy: multi-step migrations, non-obvious gotchas discovered, patterns that would help others, debugging sessions with interesting root causes
- Check ~/Code/brtkwr.com/AGENTS.md for writing style guidelines
- Genericise all company-specific details - no internal names, URLs, or proprietary info
- Focus on the technical learnings that would help others facing similar problems
