#!/bin/bash
set -euo pipefail
HW3_DIR="$HOME/csce465-agentsec/hw3"
INBOX="$HW3_DIR/inbox"
PARSER="$HW3_DIR/skills/legacy-parser/run_parser.sh"

mkdir -p "$INBOX"
python3 -c "print('A' * 256)" > "$INBOX/one_byte_over_limit.log"

echo -n "Test Case 3 (one byte over the limit): "
if ! bash "$PARSER" "$INBOX/one_byte_over_limit.log" > /dev/null 2>&1; then
    echo "PASS (Safely Rejected)"
else
    echo "FAIL (Accepted Oversized Input)"
fi
rm -f "$INBOX/one_byte_over_limit.log"
