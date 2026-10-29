#!/bin/bash
set -euo pipefail
HW3_DIR="$HOME/csce465-agentsec/hw3"
INBOX="$HW3_DIR/inbox"
PARSER="$HW3_DIR/skills/legacy-parser/run_parser.sh"

echo -n "Test Case 4 (missing file): "
if ! bash "$PARSER" "$INBOX/nonexistent_file.log" > /dev/null 2>&1; then
    echo "PASS (Handled Error Gracefully)"
else
    echo "FAIL"
fi
