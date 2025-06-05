#!/bin/bash
# Main Cursor Uninstaller Script

set -euo pipefail

# Error handler
error_handler() {
    echo "Error at line $1"
    exit 1
}

trap 'error_handler $LINENO' ERR

# Execute optimization
execute_optimize() {
    bash "$PROJECT_ROOT/scripts/optimize_system.sh" optimize
}

echo "Main Cursor Uninstaller Script"
