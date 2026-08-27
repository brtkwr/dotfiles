# User Memory

This file (`~/.claude/CLAUDE.md`) is synced via dotfiles and loads globally. Project-specific instructions live in each project's own `CLAUDE.md`.

## General Rules

- Always use British english unless asked otherwise
- When using secrets from env vars in curl headers, use backticks `` `printenv VAR` `` not `$(printenv VAR)` or `$VAR` (zsh expansion issues)
- When referencing a PR or issue, always give the full clickable `https://` URL — never just a bare `#123`, `repo#123`, or passing mention I can't click open. Applies to every PR/issue I might want to open (chat replies, summaries, status updates).

## Saving memories

Auto-memory is OFF — memories are intentional. Save one only when Bharat explicitly
asks ("remember this", "save that"); never as a side effect of a task.

All global memories live in ONE place: the PRIVATE brtkwr/memories repo, mounted as the `claude/memories` submodule of dotfiles (contents never land in the public repo — only a commit pointer):

- Index: `~/.claude/MEMORY.md` (symlink -> `~/Code/brtkwr/dotfiles/claude/memories/MEMORY.md`) — loaded every session via the `@` import below.
- Detail files: `~/.claude/memory/<name>.md` (symlink -> `dotfiles/claude/memories/memory/`).

Each index line is the actionable rule itself — trigger + directive, self-sufficient —
because only the index loads every session. Add a `memory/<name>.md` file only when
there's real detail worth reading on demand (why, examples, edge cases); a one-line
rule needs no file. After any memory change, commit and push INSIDE the submodule (cd claude/memories), then commit the pointer bump in dotfiles.
Never put memory content, colleague names, or work context in the public dotfiles repo.

Project-specific memories do NOT live on this machine — they belong in the project's
own repo (its CLAUDE.md, or files it links), committed like any other code, so the
whole team and every checkout gets them. Never write to `~/.claude/projects/*/memory/`.

## Subagent delegation

Delegate aggressively — self-contained, token-heavy work (searches, log or dataset trawls,
browser use, large-diff reviews) goes to a background subagent, so the main session's
context stays small. Fan out independent tracks in parallel; use Workflow for large
fan-outs. One-shot background subagents, never persistent teammates.

Prefer a **fork** (`subagent_type: "fork"`) when the task needs this conversation's
context — it reads the warm prompt cache and needs no briefing. Spawn fresh when it needs
a different model or the context is irrelevant; brief it terse but self-contained (file
paths, constraints, expected output shape).

Model tier: **haiku** extraction only, no judgement; **sonnet** mechanical work with a
clear spec; **opus** design docs and architectural/adversarial review; **top tier** for
complex implementation — select it by *omitting* the model so it inherits the session's.
Prefix the agent name with its tier (`sonnet-log-trawl`, `opus-design-review`).

Delegating to an external CLI (codex, cswap) — read
`~/Code/brtkwr/dotfiles/claude/delegation.md` first for the exact flags, the haiku-runner
pattern, and the failure rules.

## Dotfiles

Config files are managed in `~/Code/brtkwr/dotfiles/`. When modifying any of these, update the source and push:

- **Claude instructions**: `~/Code/brtkwr/dotfiles/claude/CLAUDE.md`
- **Shell**: `~/Code/brtkwr/dotfiles/zshrc`, `~/Code/brtkwr/dotfiles/profile`, `~/Code/brtkwr/dotfiles/zprofile`
- **Neovim**: `~/Code/brtkwr/dotfiles/nvim/`
- **Git**: `~/Code/brtkwr/dotfiles/gitconfig`
- **Hammerspoon**: `~/Code/brtkwr/dotfiles/hammerspoon/`

@~/.claude/MEMORY.md
