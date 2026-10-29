#!/bin/bash
set -euo pipefail
HW3_DIR="$HOME/csce465-agentsec/hw3"
INBOX="$HW3_DIR/inbox"
PARSER="$HW3_DIR/skills/legacy-parser/run_parser.sh"

mkdir -p "$INBOX"
python3 -c "print('A' * 50)" > "$INBOX/valid_short_input.log"

echo -n "Test Case 1 (valid short input): "
if bash "$PARSER" "$INBOX/valid_short_input.log" > /dev/null 2>&1; then
    echo "PASS (Accepted)"
else
    echo "FAIL"
fi
rm -f "$INBOX/valid_short_input.log"
