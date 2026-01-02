#!/bin/bash
# Concatenates all CLAUDE.*.md files into CLAUDE.md

CLAUDE_DIR="$HOME/.claude"
OUTPUT="$CLAUDE_DIR/CLAUDE.md"

echo "Building $OUTPUT"
: > "$OUTPUT"  # truncate

for f in "$CLAUDE_DIR"/CLAUDE.*.md; do
    [ -f "$f" ] || continue
    cat "$f" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
    echo "  + $(basename "$f")"
done

echo "Done"
