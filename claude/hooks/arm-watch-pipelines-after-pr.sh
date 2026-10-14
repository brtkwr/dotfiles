#!/bin/bash
# PostToolUse hook for Bash. When `gh pr create` succeeds and prints a PR URL,
# tell Claude to subscribe_pr via the pr-events channel (agentic-utils-github plugin), else arm two-github-watch-pipelines.
#
# The user's TWO_AGENT_SKILLS_DEFAULT_GITHUB_PUSH_POST_ACTION=fix env var
# already handles this WHEN a PR is opened via the two-github-create skill.
# This hook catches the bypass path (bare `gh pr create` calls).
set -euo pipefail

INPUT=$(cat)

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
if ! echo "$CMD" | grep -qE '(^|[^A-Za-z0-9])gh pr create|create[-_]pr|pr[-_]create'; then
  exit 0
fi

STDOUT=$(echo "$INPUT" | jq -r '.tool_response.stdout // .tool_response.output // empty')
PR_URL=$(echo "$STDOUT" | grep -oE 'https://github\.com/[^/[:space:]]+/[^/[:space:]]+/pull/[0-9]+' | tail -1 || true)
if [ -z "$PR_URL" ]; then
  exit 0
fi
PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')

# Record it so require-pr-watch.sh (Stop hook) can block the turn until a
# watcher heartbeats for it.
SESSION=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
mkdir -p ~/.claude/state/pr-watch
grep -qxF "$PR_URL" ~/.claude/state/pr-watch/"$SESSION".prs 2>/dev/null || echo "$PR_URL" >> ~/.claude/state/pr-watch/"$SESSION".prs

# Emit as additionalContext via the PostToolUse hook JSON output shape.
jq -cn --arg url "$PR_URL" --arg num "$PR_NUM" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: ("PR #" + $num + " opened (" + $url + "). Watch it: if the pr-events `subscribe_pr` tool is available (from the agentic-utils-github plugin), call it with " + $url + " and react to the <channel source=\"plugin:agentic-utils-github:pr-events\"> events it pushes; it heartbeats for the Stop hook while its forwarder is alive and unsubscribes when the PR merges or closes. If that tool is missing or returns an error, arm `two-github-watch-pipelines` instead; that loop must run `~/.claude/hooks/pr-watch-beat.sh " + $url + "` every iteration or the Stop hook will block ending the turn.")
  }
}'
