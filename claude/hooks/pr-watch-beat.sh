#!/bin/bash
# Heartbeat for require-pr-watch.sh: a PR watcher loop runs this each
# iteration (`pr-watch-beat.sh <pr-url>...`) to prove it is still watching.
mkdir -p ~/.claude/state/pr-watch/beat
for url in "$@"; do
  touch ~/.claude/state/pr-watch/beat/"$(echo "$url" | sed -E 's#https://github.com/##; s#/pull/#_#; s#/#_#g')"
done
