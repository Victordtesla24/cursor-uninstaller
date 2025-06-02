#!/bin/bash

# Temporary syntax validation script
set -euo pipefail

echo "Running shellcheck and syntax validation..."

SCRIPTS_TO_CHECK=(
    "bin/uninstall_cursor.sh"
    "lib/config.sh"
    "lib/helpers.sh"
    "lib/ui.sh"
    "modules/installation.sh"
    "modules/optimization.sh"
    "modules/uninstall.sh"
    "modules/git_integration.sh"
    "modules/complete_removal.sh"
    "modules/ai_optimization.sh"
)

SYNTAX_ERRORS=0
SHELLCHECK_ERRORS=0

echo "=== Syntax Check ==="
for script in "${SCRIPTS_TO_CHECK[@]}"; do
    if [[ -f "$script" ]]; then
        echo -n "Checking syntax: $script ... "
        if bash -n "$script" 2>/dev/null; then
            echo "✓ PASS"
        else
            echo "✗ FAIL"
            echo "  Syntax error in: $script"
            bash -n "$script"
            ((SYNTAX_ERRORS++))
        fi
    else
        echo "WARNING: Script not found: $script"
    fi
done

echo ""
echo "=== ShellCheck Analysis ==="
if command -v shellcheck >/dev/null 2>&1; then
    for script in "${SCRIPTS_TO_CHECK[@]}"; do
        if [[ -f "$script" ]]; then
            echo -n "ShellCheck: $script ... "
            if shellcheck "$script" >/dev/null 2>&1; then
                echo "✓ PASS"
            else
                echo "✗ ISSUES FOUND"
                echo "  ShellCheck issues in: $script"
                shellcheck "$script" | head -20
                ((SHELLCHECK_ERRORS++))
            fi
        fi
    done
else
    echo "ShellCheck not available - installing..."
    if command -v brew >/dev/null 2>&1; then
        brew install shellcheck
    else
        echo "Please install shellcheck manually"
        SHELLCHECK_ERRORS=1
    fi
fi

echo ""
echo "=== Summary ==="
echo "Syntax errors: $SYNTAX_ERRORS"
echo "ShellCheck issues: $SHELLCHECK_ERRORS"

if [[ $SYNTAX_ERRORS -eq 0 ]] && [[ $SHELLCHECK_ERRORS -eq 0 ]]; then
    echo "✓ All scripts pass validation"
    exit 0
else
    echo "✗ Some scripts have issues"
    exit 1
fi 