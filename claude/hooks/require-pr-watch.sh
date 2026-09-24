#!/bin/bash
# Stop hook: refuse to end the turn while a PR this session opened is still
# open and no watcher has heartbeated for it (pr-watch-beat.sh) in 15 min.
# PRs are recorded by arm-watch-pipelines-after-pr.sh.
set -uo pipefail

INPUT=$(cat)
SESSION=$(echo "$INPUT" | jq -r '.session_id // empty')
STATE=~/.claude/state/pr-watch
LIST="$STATE/$SESSION.prs"
[ -n "$SESSION" ] && [ -s "$LIST" ] || exit 0

unwatched=()
still_open=()
while read -r url; do
  [ -n "$url" ] || continue
  beat="$STATE/beat/$(echo "$url" | sed -E 's#https://github.com/##; s#/pull/#_#; s#/#_#g')"
  # ponytail: fresh beat skips the gh call entirely; only stale PRs cost a lookup.
  if [ -n "$(find "$beat" -mmin -15 2>/dev/null)" ]; then
    still_open+=("$url"); continue
  fi
  state=$(gh pr view "$url" --json state -q .state 2>/dev/null || echo UNKNOWN)
  case "$state" in
    MERGED|CLOSED) continue ;;  # done, drop from the list
  esac
  still_open+=("$url"); unwatched+=("$url")
done < "$LIST"

printf '%s\n' "${still_open[@]+"${still_open[@]}"}" > "$LIST"
[ ${#unwatched[@]} -eq 0 ] && exit 0

urls=$(printf '%s ' "${unwatched[@]}")
# Already continued once for this: don't loop forever, tell the user instead.
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  jq -cn --arg u "$urls" '{systemMessage: ("PRs still unwatched: " + $u)}'
  exit 0
fi
jq -cn --arg u "$urls" '{decision: "block", reason: ("These PRs you opened are still open with no live watcher: " + $u + "Arm a background watcher (Monitor or run_in_background loop) that tracks CI, review threads and merge state, and calls `~/.claude/hooks/pr-watch-beat.sh <pr-url>` every iteration. Then act on what it reports. If a PR genuinely needs no watching, run pr-watch-beat.sh for it once and say why.")}'
