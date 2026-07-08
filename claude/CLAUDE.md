# User Memory

This file (`~/.claude/CLAUDE.md`) is synced via dotfiles and loads globally. Project-specific instructions live in each project's own `CLAUDE.md`.

## General Rules

- Always use British english unless asked otherwise
- When using secrets from env vars in curl headers, use backticks `` `printenv VAR` `` not `$(printenv VAR)` or `$VAR` (zsh expansion issues)
- When referencing a PR or issue, always give the full clickable `https://` URL — never just a bare `#123`, `repo#123`, or passing mention I can't click open. Applies to every PR/issue I might want to open (chat replies, summaries, status updates).

## Saving memories

Choose scope before saving an auto-memory, then write to the matching dir and update that dir's `MEMORY.md` index:

- **Global / cross-project** (tone, writing, git/PR habits, general tooling) → `~/.claude/projects/-Users-brtkwr/memory/`
- **Project-specific** (repo conventions, infra, tracker workflow) → that project's memory dir; the project's own `CLAUDE.md` names the exact path.

The harness defaults to the *current* project's dir. Override to the home dir above when the fact is genuinely global — don't let a cross-project rule get trapped in one repo's memory.

Each `MEMORY.md` line is the actionable rule itself — trigger + directive, self-sufficient — because only the index is loaded every session; individual files surface only via recall, too unreliable for an always-apply rule. Keep a separate `<name>.md` file only when there's real detail worth pulling up on demand (why, examples, edge cases). A one-line rule needs no file.

## Subagent delegation

Delegate aggressively — subagents are the default for any self-contained piece of work,
not a last resort. Anything token-heavy where only a summary needs to come back goes to
a subagent: codebase/file/PDF searches, log or dataset trawls, browser use, large-diff
reviews. The goal is keeping the main session's context small, not just cheaper tokens.

Run subagents in the background (the default) and carry on with other work — fan out
independent tasks as parallel background agents rather than doing them serially in the
main session. Don't spawn persistent teammates; one-shot background subagents (or
Workflow for fan-outs) cover it.

Match the subagent's model tier to the task:

- **haiku**: trivial classification or extraction only. Nothing that requires judgement.
- **sonnet**: mechanical work with a clear spec — searches, summarisation, boilerplate,
  simple designs, first-pass reviews.
- **opus**: design docs, architectural review, adversarial review of complex changes.
- **top tier** (fable today): complex implementation and anything where a wrong answer
  costs a re-run. When the session itself runs on the top tier, select it by omitting
  the model so the subagent inherits it — that keeps this rule from going stale when
  model names change.

Always prefix the subagent's name with its model class (e.g. `sonnet-log-trawl`,
`opus-design-review`) so it's obvious at a glance which tier is doing what.

Before spawning a fresh subagent, consider a **fork** of the current session
(`subagent_type: "fork"`) instead. A fork reads the existing conversation from the
prompt cache (~10% of input price while the cache is warm) and needs only a short
instruction, no briefing. A fresh subagent pays full cache-write rates on its own fresh
system context (tools, skills, CLAUDE.md — easily 30-50k tokens) plus the full briefing
before it does any work. So fork when the task genuinely needs the conversation context
and the current model suits it (forks always inherit the parent model). Spawn fresh when
it needs a different model or the context is irrelevant — a fork drags the whole
conversation along, making every one of its turns pricier.

Briefings (for fresh subagents): terse but self-contained. The subagent has no
conversation context — include file paths, constraints, and the expected output shape.
An ambiguous brief that forces a re-run costs more than a verbose one.

For large fan-outs (many independent subagents over a list), use Workflow rather than
hand-spawning Agents.

## Dotfiles

Config files are managed in `~/Code/brtkwr/dotfiles/`. When modifying any of these, update the source and push:

- **Claude instructions**: `~/Code/brtkwr/dotfiles/claude/CLAUDE.md`
- **Shell**: `~/Code/brtkwr/dotfiles/zshrc`, `~/Code/brtkwr/dotfiles/profile`, `~/Code/brtkwr/dotfiles/zprofile`
- **Neovim**: `~/Code/brtkwr/dotfiles/nvim/`
- **Git**: `~/Code/brtkwr/dotfiles/gitconfig`
- **Hammerspoon**: `~/Code/brtkwr/dotfiles/hammerspoon/`

@~/.claude/projects/-Users-brtkwr/memory/MEMORY.md
