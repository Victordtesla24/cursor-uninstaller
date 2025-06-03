#!/bin/bash

# Enhanced syntax validation script with comprehensive discovery
set -euo pipefail

echo "Running enhanced shellcheck and syntax validation..."

# Dynamically discover all shell scripts to prevent missing files
SCRIPT_DIRECTORIES=("scripts" "modules" "lib" "bin")
SCRIPTS_TO_CHECK=()

# Discover all .sh files in specified directories
for dir in "${SCRIPT_DIRECTORIES[@]}"; do
    if [[ -d "$dir" ]]; then
        while IFS= read -r -d '' script; do
            # Convert to relative path from current directory
            relative_script="${script#./}"
            SCRIPTS_TO_CHECK+=("$relative_script")
        done < <(find "$dir" -name "*.sh" -type f -print0 2>/dev/null)
    fi
done

# Add specific known scripts that might not follow .sh pattern
ADDITIONAL_SCRIPTS=(
    "bin/uninstall_cursor.sh"
)

# Merge additional scripts, avoiding duplicates
for additional in "${ADDITIONAL_SCRIPTS[@]}"; do
    if [[ -f "$additional" ]]; then
        # Check if already in array
        found=false
        for existing in "${SCRIPTS_TO_CHECK[@]}"; do
            if [[ "$existing" == "$additional" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == "false" ]]; then
            SCRIPTS_TO_CHECK+=("$additional")
        fi
    fi
done

# Sort the array for consistent output
if [[ ${#SCRIPTS_TO_CHECK[@]} -gt 0 ]]; then
    IFS=$'\n'
    # Use printf and read to safely handle array sorting
    {
        printf '%s\n' "${SCRIPTS_TO_CHECK[@]}" | sort
    } | {
        SCRIPTS_TO_CHECK=()
        while IFS= read -r script; do
            SCRIPTS_TO_CHECK+=("$script")
        done
    }
    unset IFS
fi

echo "Discovered ${#SCRIPTS_TO_CHECK[@]} shell scripts for validation:"
printf "  • %s\n" "${SCRIPTS_TO_CHECK[@]}"
echo ""

SYNTAX_ERRORS=0
SHELLCHECK_ERRORS=0
TOTAL_SCRIPTS=${#SCRIPTS_TO_CHECK[@]}
PROCESSED_SCRIPTS=0

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
        ((PROCESSED_SCRIPTS++))
    else
        echo "WARNING: Script not found: $script"
    fi
done

echo ""
echo "=== Enhanced ShellCheck Analysis ==="
if command -v shellcheck >/dev/null 2>&1; then
    PROCESSED_SCRIPTS=0
    for script in "${SCRIPTS_TO_CHECK[@]}"; do
        if [[ -f "$script" ]]; then
            echo -n "ShellCheck: $script ... "
            
            # Run basic shellcheck first (this catches SC1091 issues that -x might miss)
            shellcheck_basic=""
            shellcheck_basic=$(shellcheck --severity=info "$script" 2>&1 || true)
            
            # Run enhanced shellcheck with external sources (catches advanced issues)
            shellcheck_enhanced=""
            shellcheck_enhanced=$(shellcheck \
                --check-sourced \
                --external-sources \
                --severity=info \
                --source-path=SCRIPTDIR \
                -x \
                "$script" 2>&1 || true)
            
            # Combine outputs and filter for unique issues
            combined_output=""
            if [[ -n "$shellcheck_basic" ]]; then
                combined_output="$shellcheck_basic"
            fi
            if [[ -n "$shellcheck_enhanced" ]]; then
                if [[ -n "$combined_output" ]]; then
                    combined_output+="\n$shellcheck_enhanced"
                else
                    combined_output="$shellcheck_enhanced"
                fi
            fi
            
            # Filter out duplicates by error code
            unique_output=""
            if [[ -n "$combined_output" ]]; then
                unique_output=$(echo -e "$combined_output" | awk '!seen[$0]++' | grep -E 'SC[0-9]+' || echo "")
            fi
            
            if [[ -z "$unique_output" ]]; then
                echo "✓ PASS"
            else
                echo "✗ ISSUES FOUND"
                echo "  ShellCheck issues in: $script"
                echo "$unique_output" | head -30
                echo ""
                ((SHELLCHECK_ERRORS++))
            fi
            ((PROCESSED_SCRIPTS++))
        fi
    done
    
    # Additional comprehensive check for critical issues and source problems
    echo ""
    echo "=== Comprehensive Critical Issues Check ==="
    critical_issues=0
    source_issues=0
    
    for script in "${SCRIPTS_TO_CHECK[@]}"; do
        if [[ -f "$script" ]]; then
            # Check for unreachable code (SC2317) specifically
            unreachable_check=""
            if unreachable_check=$(shellcheck --severity=info --include=SC2317 "$script" 2>&1 | grep -c "SC2317" || true); then
                if [[ "$unreachable_check" -gt 0 ]]; then
                    echo "⚠ Critical: $script has $unreachable_check unreachable code warnings"
                    ((critical_issues++))
                fi
            fi
            
            # Check for quote-related issues (SC2016)
            quote_check=""
            if quote_check=$(shellcheck --severity=info --include=SC2016 "$script" 2>&1 | grep -c "SC2016" || true); then
                if [[ "$quote_check" -gt 0 ]]; then
                    echo "⚠ Critical: $script has $quote_check quote expansion issues"
                    ((critical_issues++))
                fi
            fi
            
            # Enhanced SC1091 detection - catch ALL sourcing issues
            source_check=""
            if source_check=$(shellcheck --severity=info --include=SC1091 "$script" 2>&1 | grep "SC1091" || true); then
                if [[ -n "$source_check" ]]; then
                    echo "⚠ Source Issue: $script has sourcing problems:"
                    echo "$source_check" | head -5
                    ((source_issues++))
                fi
            fi
        fi
    done
    
    total_critical=$((critical_issues + source_issues))
    if [[ "$total_critical" -gt 0 ]]; then
        echo "⚠ Total critical issues detected: $total_critical ($critical_issues code issues, $source_issues source issues)"
        echo "Run 'shellcheck scripts/*.sh modules/*.sh lib/*.sh bin/*.sh' for detailed analysis"
        ((SHELLCHECK_ERRORS++))
    else
        echo "✓ No critical issues detected"
    fi
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
echo "=== Enhanced Summary ==="
echo "Scripts discovered: $TOTAL_SCRIPTS"
echo "Scripts processed: $PROCESSED_SCRIPTS"
echo "Syntax errors: $SYNTAX_ERRORS"
echo "ShellCheck issues: $SHELLCHECK_ERRORS"

if [[ $SYNTAX_ERRORS -eq 0 ]] && [[ $SHELLCHECK_ERRORS -eq 0 ]]; then
    echo "✓ All scripts pass enhanced validation"
    exit 0
else
    echo "✗ Some scripts have issues requiring attention"
    echo "Run 'shellcheck scripts/*.sh modules/*.sh lib/*.sh bin/*.sh' for complete analysis"
    exit 1
fi 