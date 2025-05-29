#!/bin/bash

# Test False Positive Filtering for Cursor AI Editor Detection
# This test verifies that unrelated files with "cursor" in the name are not flagged as Cursor AI Editor components

# shellcheck disable=SC1091  # Disable "Not following" warnings for dynamic paths

# Get script directory for proper path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck disable=SC2317  # Functions may be called indirectly by sourced modules
# Define production message functions for standalone test execution
production_log_message() {
    local level="${1:-INFO}"
    local message="${2:-No message provided}"
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "[$level] $message" >&2
    fi
}

# shellcheck disable=SC2317  # Functions may be called indirectly by sourced modules
production_info_message() {
    local message="$1"
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "[INFO] $message" >&2
    fi
}

# shellcheck disable=SC2317  # Functions may be called indirectly by sourced modules
production_success_message() {
    local message="$1"
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "[SUCCESS] $message" >&2
    fi
}

# shellcheck disable=SC2317  # Functions may be called indirectly by sourced modules
production_error_message() {
    local message="$1"
    echo "[ERROR] $message" >&2
}

# shellcheck disable=SC2317  # Functions may be called indirectly by sourced modules
production_warning_message() {
    local message="$1"
    echo "[WARNING] $message" >&2
}

# Set color variables for UI compatibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Export variables for module compatibility
export RED GREEN YELLOW BLUE CYAN BOLD NC
export VERBOSE="${VERBOSE:-false}"

# Source the complete removal module which contains is_cursor_ai_editor_related function
# shellcheck source=../modules/complete_removal.sh
if ! source "$SCRIPT_DIR/modules/complete_removal.sh"; then
    echo "ERROR: Failed to source complete_removal.sh" >&2
    exit 1
fi

echo "Testing False Positive Filtering for Cursor AI Editor Detection"
echo "=============================================================="

# Test cases that should NOT be considered Cursor AI Editor related (false positives)
false_positive_test_cases=(
    "/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk/usr/share/man/man3/DBIx::Class::Storage::DBI::Cursor5.34.3pm"
    "/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk/System/Library/Frameworks/AppKit.framework/Versions/C/Headers/NSCursor.h"
    "/opt/homebrew/Cellar/mongosh/2.5.0/libexec/lib/node_modules/@mongosh/cli-repl/node_modules/@mongosh/shell-api/lib/cursor.js"
    "/Applications/Firefox.app/Contents/Resources/res/cursors"
    "/Users/vicd/Documents/ANZ-Development/.venv/lib/python3.13/site-packages/sqlalchemy/engine/cursor.py"
    "/Users/vicd/Downloads/cursor_uninstaller/uninstall_cursor.sh"
    "/Library/Logs/DiagnosticReports/Cursor_2025-05-29-135741_Vics-MacBook-Air.diag"
    "/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/IOKit/IOMemoryCursor.h"
    "/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk/usr/share/man/mann/cursor.n"
    "/opt/homebrew/Cellar/neonctl/2.9.0/libexec/lib/node_modules/neonctl/node_modules/cli-cursor"
)

# Test cases that SHOULD be considered Cursor AI Editor related (true positives)
true_positive_test_cases=(
    "/Applications/Cursor.app"
    "/Applications/Cursor.app/Contents/MacOS/Cursor"
    "/Users/vicd/Library/Application Support/Cursor"
    "/Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
    "/Users/vicd/Library/Caches/Cursor"
    "/Users/vicd/.cursor"
    "/Users/vicd/.vscode-cursor"
    "/usr/local/bin/cursor"
)

echo
echo "Testing FALSE POSITIVES (should return 1 - NOT Cursor AI Editor related):"
echo "----------------------------------------------------------------------"

false_positive_count=0
false_positive_failed=0

for file in "${false_positive_test_cases[@]}"; do
    if is_cursor_ai_editor_related "$file"; then
        echo "❌ FAIL: $file was incorrectly identified as Cursor AI Editor related"
        ((false_positive_failed++))
    else
        echo "✅ PASS: $file correctly identified as NOT Cursor AI Editor related"
    fi
    ((false_positive_count++))
done

echo
echo "Testing TRUE POSITIVES (should return 0 - IS Cursor AI Editor related):"
echo "--------------------------------------------------------------------"

true_positive_count=0
true_positive_failed=0

for file in "${true_positive_test_cases[@]}"; do
    if is_cursor_ai_editor_related "$file"; then
        echo "✅ PASS: $file correctly identified as Cursor AI Editor related"
    else
        echo "❌ FAIL: $file was incorrectly identified as NOT Cursor AI Editor related"
        ((true_positive_failed++))
    fi
    ((true_positive_count++))
done

echo
echo "TEST RESULTS:"
echo "============"
echo "False Positive Tests: $((false_positive_count - false_positive_failed))/$false_positive_count passed"
echo "True Positive Tests: $((true_positive_count - true_positive_failed))/$true_positive_count passed"
echo

total_tests=$((false_positive_count + true_positive_count))
total_failed=$((false_positive_failed + true_positive_failed))
total_passed=$((total_tests - total_failed))

if [[ $total_failed -eq 0 ]]; then
    echo "🎉 ALL TESTS PASSED! ($total_passed/$total_tests)"
    exit 0
else
    echo "❌ SOME TESTS FAILED! ($total_passed/$total_tests passed, $total_failed failed)"
    exit 1
fi 