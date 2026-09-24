#!/bin/bash
# PreToolUse hook for Bash. Deny `git commit --amend` and force-pushes on a
# branch whose open PR has any human review or comment: human-reviewed PRs
# only ever get NEW commits. Bot reviews (codex, gemini, deepsource) and the
# PR author's own comments don't count.
#
# Fails closed: if the PR can't be checked, the rewrite is denied. Run it
# by hand with `! <command>` if it's genuinely safe.
set -uo pipefail

INPUT=$(cat)
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT")
CWD=$(jq -r '.cwd // empty' <<<"$INPUT")

# Only look at segments that START with git (optionally after cd/env), so
# commit-message text mentioning --amend or --force doesn't match.
SEG=$(sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g" <<<"$CMD" | tr ';|&' '\n' | sed -E 's/^[[:space:]]+//' |
  grep -E '^([A-Z_]+=[^ ]* +)*git ' |
  grep -E ' commit( .*)? --amend| push( .*)? (-f|--force|--force-with-lease[^ ]*|--force-if-includes|\+[^ ]+)( |$)' |
  head -1) || true
[ -z "$SEG" ] && exit 0

deny() {
  jq -cn --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

# Resolve the repo dir: `git -C <dir>`, else a leading `cd <dir> &&`, else cwd.
DIR=$(sed -nE 's/.*git -C ([^ ]+).*/\1/p' <<<"$SEG")
[ -z "$DIR" ] && DIR=$(sed -nE 's/^cd ([^&;|]+[^ &;|]) *&&.*/\1/p' <<<"$CMD")
DIR=${DIR:-$CWD}
DIR=${DIR/#\~/$HOME}
cd "$DIR" 2>/dev/null || deny "no-rewrite-after-human-review: can't cd to '$DIR' to check the PR. Add a new commit instead."

# Branch: the push refspec's destination if given (HEAD:foo, +foo), else current.
BRANCH=$(grep -oE '[^ ]+:[^ ]+' <<<"$SEG" | tail -1 | sed -E 's/.*://; s#^refs/heads/##')
[ -z "$BRANCH" ] && BRANCH=$(git branch --show-current 2>/dev/null)
[ -z "$BRANCH" ] && exit 0 # detached HEAD, nothing on a PR

PR=$(gh pr list --head "$BRANCH" --state open --json number,author --jq '.[0] | "\(.number) \(.author.login)"' 2>/dev/null) ||
  deny "no-rewrite-after-human-review: couldn't query the PR for '$BRANCH' (gh failed). Add a new commit instead, or run it yourself with '! <command>' if it's safe."
[ -z "$PR" ] || [ "$PR" = "null null" ] && exit 0 # no open PR
read -r NUM AUTHOR <<<"$PR"

REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null) || deny "no-rewrite-after-human-review: couldn't resolve the repo for PR #$NUM."
HUMANS=$(
  for ep in "pulls/$NUM/reviews" "pulls/$NUM/comments" "issues/$NUM/comments"; do
    gh api --paginate "repos/$REPO/$ep" --jq '.[] | .user | select(.type != "Bot") | .login' || echo "__ERROR__"
  done | grep -vxF "$AUTHOR" | sort -u | paste -sd, -
)
case "$HUMANS" in *__ERROR__*) deny "no-rewrite-after-human-review: couldn't read reviews on $REPO#$NUM. Add a new commit instead." ;; esac
[ -z "$HUMANS" ] && exit 0

deny "https://github.com/$REPO/pull/$NUM has human review from: $HUMANS. Never amend or force-push after human review: address it with a NEW commit and a plain push. (Bot-only reviews are exempt.)"
