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

# Split into segments (quoted text stripped, so commit-message text mentioning
# --amend or --force doesn't match). Keep rewrite segments that START with git
# (optionally after env assignments), each paired with the dir it runs in:
# `git -C <dir>`, else the nearest preceding `cd <dir>`, else cwd. Pairing per
# segment matters because one multi-line command can cd into several repos.
PAIRS=$(perl -0pe 's/\x27[^\x27]*\x27//gs; s/"(?:[^"\\]|\\.)*"//gs' <<<"$CMD" | tr ';|&' '\n' |
  sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' |
  awk -v cwd="$CWD" '
    /^cd [^ ]+$/ { dir = substr($0, 4); next }
    /^([A-Z_]+=[^ ]* +)*git / && (/ commit( .*)? --amend/ || / push( .*)? (-f|--force|--force-with-lease[^ ]*|--force-if-includes|\+[^ ]+)( |$)/) {
      d = (dir != "" ? dir : cwd)
      if (match($0, /git -C [^ ]+/)) d = substr($0, RSTART + 7, RLENGTH - 7)
      print d "\t" $0
    }') || true
[ -z "$PAIRS" ] && exit 0

deny() {
  jq -cn --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

# Returns if the rewrite in SEG (run in DIR) is fine; denies (and exits) if not.
check() {
  local DIR=$1 SEG=$2 BRANCH PR NUM AUTHOR REPO HUMANS
  DIR=${DIR/#\~/$HOME}
  [[ "$DIR" != /* ]] && DIR="$CWD/$DIR"
  cd "$DIR" 2>/dev/null || deny "no-rewrite-after-human-review: can't cd to '$DIR' to check the PR. Add a new commit instead."

  # Branch: the push refspec's destination if given (HEAD:foo, +foo), else current.
  BRANCH=$(grep -oE '[^ ]+:[^ ]+' <<<"$SEG" | tail -1 | sed -E 's/.*://; s#^refs/heads/##')
  [ -z "$BRANCH" ] && BRANCH=$(git branch --show-current 2>/dev/null)
  [ -z "$BRANCH" ] && return # detached HEAD, nothing on a PR

  PR=$(gh pr list --head "$BRANCH" --state open --json number,author --jq '.[0] | "\(.number) \(.author.login)"' 2>/dev/null) ||
    deny "no-rewrite-after-human-review: couldn't query the PR for '$BRANCH' (gh failed). Add a new commit instead, or run it yourself with '! <command>' if it's safe."
  { [ -z "$PR" ] || [ "$PR" = "null null" ]; } && return # no open PR
  read -r NUM AUTHOR <<<"$PR"

  REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null) || deny "no-rewrite-after-human-review: couldn't resolve the repo for PR #$NUM."
  HUMANS=$(
    for ep in "pulls/$NUM/reviews" "pulls/$NUM/comments" "issues/$NUM/comments"; do
      gh api --paginate "repos/$REPO/$ep" --jq '.[] | .user | select(.type != "Bot") | .login' || echo "__ERROR__"
    done | grep -vxF "$AUTHOR" | sort -u | paste -sd, -
  )
  case "$HUMANS" in *__ERROR__*) deny "no-rewrite-after-human-review: couldn't read reviews on $REPO#$NUM. Add a new commit instead." ;; esac
  [ -z "$HUMANS" ] && return

  deny "https://github.com/$REPO/pull/$NUM has human review from: $HUMANS. Never amend or force-push after human review: address it with a NEW commit and a plain push. (Bot-only reviews are exempt.)"
}

while IFS=$'\t' read -r dir seg; do
  check "$dir" "$seg"
done <<<"$PAIRS"
