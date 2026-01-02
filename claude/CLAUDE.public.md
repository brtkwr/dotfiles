## General Rules

- ALWAYS load project specific @AGENTS.md
- Always mention the specific model when signing git commits and PRs (e.g., Claude Opus 4.5, Claude Sonnet 4)
- Always use British english unless asked otherwise
- All my code lives under ~/Code/
- Always import modules at the top unless there is a risk of circular import

## Command Preferences

- Use fd instead of find to search files by name
- Always use rg instead of grep
- When using secrets from env vars in curl headers, use backticks `` `printenv VAR` `` not `$(printenv VAR)` or `$VAR` (zsh expansion issues)

## Git

- For open source projects, use conventional commit format (feat:, fix:, etc.) - no Linear tickets
- For trivial changes, use --no-verify flag when making commits
- Always create worktrees in a subdirectory
