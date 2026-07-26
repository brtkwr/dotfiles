# External CLI delegation

Read this before invoking `codex exec` or `cswap run`. The in-session Agent/Workflow
rules live in `CLAUDE.md`; only the external-CLI mechanics are here.

## Priority order

1. **`codex exec` (default)** — GPT via Codex CLI, model `gpt-5.6-sol`. First choice for
   any self-contained delegated task: a second model's take, spreading token cost off my
   own quota, non-interactive research/edits.
2. **`cswap run`** — Claude Code under a different claude.ai account. Use when the work
   genuinely needs Claude (a Claude-only skill/MCP, matching this session's behaviour) or
   a different account's quota. Account 1 only supports Opus-tier and below — fable-tier
   work stays in the current session.
3. **Agent tool / Workflow** — in-session Claude subagents and fan-outs.

Always report the delegated run's token usage (and cost, for cswap) back in the summary.

## Run them through a haiku runner, not a bare Bash call

The haiku agent's only job is to invoke the CLI, read the output file, and return the
summary plus the token/cost line. This keeps the token-heavy output out of the main
session and makes the delegation show up as a named background agent
(`haiku-codex-<task>`, `haiku-cswap-<task>`) instead of an opaque shell command. The
runner *relays only* — it must not re-analyse (tier limit); codex/cswap already did the
thinking. Skip the wrapper only when the CLI was asked for a tight answer already small
enough to read directly.

## Invocation

- **codex:** `codex exec --skip-git-repo-check -s read-only --json -o ans.txt "PROMPT" 2>/dev/null`
  — answer lands in `ans.txt`; tokens from the final `turn.completed` event. No usage/quota
  readout exists at all (ChatGPT-subscription auth surfaces nothing), so gate only on a
  rate-limit *error*, never a preflight %.
- **cswap:** `cswap run 1 -- -p 'PROMPT' --model claude-sonnet-5 --output-format json 2>/dev/null > out.json`
  — MUST pass `--model <opus-or-below>`; a bare run inherits account 1's uncredited
  `claude-fable-5` default and fails with "Fable 5 requires usage credits". Answer/cost/tokens
  from `.[-1]`. Guard: check the stream's `rate_limit_event.status` — if not `allowed`, stop
  and report `resetsAt` instead of retrying.

Neither CLI exposes a usage percentage, so an "exit above 90%" preflight is impossible;
gate on these status/error signals instead. Verbose jq parsing and session-profile paths
are in the `reference_codex_delegation` / `reference_cswap_delegation` memories.

## Failure falls back to the parent, never sideways

Each haiku runner wraps exactly ONE CLI (codex OR cswap) and is a single-shot relay — a
codex runner must never fall back to cswap, nor cswap to codex. On any failure/rate-limit
it reports the failure up and stops; it does not attempt the task itself (relay-only,
wrong tier). The **parent** — the only orchestrating, capable tier — then does the work
in-session. This is the hook's exception (e). The parent may of course choose to try the
other tool as a fresh, explicit dispatch, but that is the parent's decision, not an
automatic runner-to-runner chain.
