#!/bin/bash

# Read JSON input from stdin
INPUT=$(cat)

# Extract transcript path from JSON
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')

# Get the last assistant response from the transcript
LAST_RESPONSE=$(tail -1 "$TRANSCRIPT_PATH" 2>/dev/null | jq -r 'select(.type == "assistant") | .message.content[] | select(.type == "text") | .text' | tail -1)

# Speak the response with British accent in background without blocking
nohup sh -c "stat ~/.claude/.silence >/dev/null 2>&1 || say -- '${LAST_RESPONSE:-Claude needs your input}'" >/dev/null 2>&1 &
