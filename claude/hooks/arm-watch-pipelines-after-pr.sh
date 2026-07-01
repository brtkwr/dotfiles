#!/bin/bash
# PostToolUse hook for Bash. When `gh pr create` succeeds and prints a PR URL,
# emit a system-reminder telling Claude to arm two-github-watch-pipelines.
#
# The user's TWO_AGENT_SKILLS_DEFAULT_GITHUB_PUSH_POST_ACTION=fix env var
# already handles this WHEN a PR is opened via the two-github-create skill.
# This hook catches the bypass path (bare `gh pr create` calls).
set -euo pipefail

INPUT=$(cat)

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
if ! echo "$CMD" | grep -qE '(^|[^A-Za-z0-9])gh pr create'; then
  exit 0
fi

STDOUT=$(echo "$INPUT" | jq -r '.tool_response.stdout // .tool_response.output // empty')
PR_URL=$(echo "$STDOUT" | grep -oE 'https://github\.com/[^/[:space:]]+/[^/[:space:]]+/pull/[0-9]+' | tail -1 || true)
if [ -z "$PR_URL" ]; then
  exit 0
fi
PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')

# Emit as additionalContext via the PostToolUse hook JSON output shape.
jq -cn --arg url "$PR_URL" --arg num "$PR_NUM" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: ("PR #" + $num + " opened via bare `gh pr create` (" + $url + "). The user has TWO_AGENT_SKILLS_DEFAULT_GITHUB_PUSH_POST_ACTION=fix set expecting `two-github-create` skill or `two-github-pr-review` skill to auto-arm two-github-autofix-pipelines / two-github-watch-pipelines after push, but bare `gh pr create` bypasses that. Arm `two-github-watch-pipelines` on PR " + $num + " now, and prefer routing future PR creation through the `two-github-create` skill so this auto-fires.")
  }
}'
