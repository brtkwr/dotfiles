#!/bin/bash
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

if [ ! -d "$PROJECT_DIR" ]; then
  exit 0
fi

AGENTS_FILE="$PROJECT_DIR/AGENTS.md"

if [ -f "$AGENTS_FILE" ]; then
  echo "=== AGENTS.md ==="
  cat "$AGENTS_FILE"
fi
