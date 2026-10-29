set -euo pipefail

HW3_DIR="$HOME/csce465-agentsec/hw3"
INBOX="$HW3_DIR/inbox"
PARSER="$HW3_DIR/legacy_log_parser"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_path>" >&2
    exit 1
fi

FILE=$(realpath -e -- "$1") || {
    echo "Error: File does not exist." >&2
    exit 1
}

INBOX_REAL=$(realpath -e -- "$INBOX")

case "$FILE" in
    "$INBOX_REAL"/*)
        ;;
    *)
        echo "Error: Access denied. File must be inside inbox/." >&2
        exit 1
        ;;
esac

if [ ! -f "$FILE" ]; then
    echo "Error: Input must be a regular file." >&2
    exit 1
fi

cd "$HW3_DIR"
exec "$PARSER" "$FILE"
