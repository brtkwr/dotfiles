#!/bin/bash
# PreToolUse hook for Bash. Nudge toward using the two-git-worktree skill
# when Claude is about to do a feature-branch git operation without first
# entering a worktree. Juggling multiple PR branches in the main checkout
# leads to stash/pop churn and cross-branch contamination.
#
# Soft nudge (additionalContext) rather than deny — genuine main-checkout
# ops (switching to main, aborting a rebase, running in an already-cd'd
# worktree) are still allowed. Claude sees the reminder and acts on it.
set -euo pipefail

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only match feature-branch operations. Match must be anchored at the START
# of the command (optionally after `cd <path> && `) so we don't
# false-positive on strings inside quoted commit messages, echo args, or
# heredocs that describe the pattern rather than execute it.
# `git checkout main` / `git checkout <sha>` are deliberately NOT matched -
# the pattern needs a `bharat/*` / `feat/*` / etc. prefix.
if ! echo "$CMD" | grep -qE '^(cd [^&;|]+ *&& *)?git (checkout -b (bharat|feat|fix|chore|docs|refactor|test|perf)/|checkout (bharat|feat|fix|chore|docs|refactor|test|perf)/|rebase (origin/main|origin/master|main|master)( |$))'; then
  exit 0
fi

# If the command explicitly cd's into a .worktrees/ path first, allow silently.
if echo "$CMD" | grep -qE '(^|[[:space:]]|;|&&)cd [^&;|]*\.worktrees/'; then
  exit 0
fi

jq -cn --arg cmd "$CMD" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: ("Feature-branch git op detected in main checkout: `" + ($cmd | if length > 200 then .[:200] + "..." else . end) + "`. Use the `two-git-worktree` skill FIRST to create a worktree under `.worktrees/<branch>/` before branching / rebasing / checking out a feature branch. Juggling multiple PR branches in the main checkout means stash/pop churn and cross-branch contamination on unrelated pending changes (recent example: PLAT-1775 series). If this operation is a legitimate main-checkout op (already inside a worktree from an earlier `cd`, aborting a rebase in the main checkout, working on main itself), acknowledge in one sentence and proceed. Do NOT silently proceed on a feature branch in the main checkout.")
  }
}'
