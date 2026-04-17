#!/bin/bash

[[ -f ~/.claude/.silence ]] && exit 0

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
PID_FILE="/tmp/speak-response-${SESSION_ID}.pid"

sleep 1

LAST_RESPONSE=$(jq -rs '
  [.[] | select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text]
  | map(select(length > 0))
  | last // ""
' "$TRANSCRIPT_PATH" 2>/dev/null)

LAST_LINE=$(echo "$LAST_RESPONSE" | awk 'NF{line=$0} END{print line}')

CLEAN=$(echo "$LAST_LINE" | sed -E \
  -e 's/\[([^]]+)\]\([^)]+\)/\1/g' \
  -e 's/`([^`]+)`/\1/g' \
  -e 's/\*\*([^*]+)\*\*/\1/g' \
  -e 's/(^|[[:space:]])\*([^*]+)\*/\1\2/g' \
  -e 's/https?:\/\/[^[:space:]]+//g')

MESSAGE="${CLEAN:-Needs your input}"

if [[ -f $PID_FILE ]]; then
  kill "$(cat "$PID_FILE")" 2>/dev/null
fi

nohup say -- "$MESSAGE" >/dev/null 2>&1 &
echo $! >"$PID_FILE"
