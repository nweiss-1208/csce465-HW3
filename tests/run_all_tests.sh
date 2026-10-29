#!/bin/bash
set -euo pipefail

TEST_DIR="$(dirname "$(realpath "$0")")"

echo "================================================================"
echo "          CSCE 465/765 Task 3 Verification Test Suite           "
echo "================================================================"

bash "$TEST_DIR/test_valid_short_input.sh"
bash "$TEST_DIR/test_exactly_maximum_input.sh"
bash "$TEST_DIR/test_one_byte_over_limit.sh"
bash "$TEST_DIR/test_missing_file.sh"
bash "$TEST_DIR/test_original_exploit_payload.sh"

echo "================================================================"
