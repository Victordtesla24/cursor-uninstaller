#!/bin/bash

################################################################################
# Comprehensive Error Fixes Test Suite - PRODUCTION GRADE
# Tests all fixes applied to resolve syntax errors and shellcheck warnings
################################################################################

# shellcheck disable=SC1091,SC1090  # Disable "Not following" warnings for dynamic paths

# Set strict error handling
set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/helpers/test_functions.sh" 2>/dev/null || echo "Warning: test_functions.sh not found"

# Test configuration
export CURSOR_TEST_MODE=true
export DRY_RUN=true
export VERBOSE=true

################################################################################
# Test Results Tracking
################################################################################

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
ERRORS_FOUND=()

# Test result functions
test_pass() {
    local test_name="$1"
    ((TESTS_RUN++))
    ((TESTS_PASSED++))
    echo "✓ PASS: $test_name"
}

test_fail() {
    local test_name="$1"
    local error_msg="$2"
    ((TESTS_RUN++))
    ((TESTS_FAILED++))
    ERRORS_FOUND+=("$test_name: $error_msg")
    echo "✗ FAIL: $test_name - $error_msg"
}

test_skip() {
    local test_name="$1"
    local reason="$2"
    echo "⚠ SKIP: $test_name - $reason"
}

################################################################################
# Test Functions
################################################################################

# Test 1: Validate script syntax
test_script_syntax() {
    echo "Testing script syntax..."
    
    local scripts_to_test=(
        "$PROJECT_ROOT/uninstall_cursor.sh"
        "$PROJECT_ROOT/lib/helpers.sh"
        "$PROJECT_ROOT/lib/config.sh"
        "$PROJECT_ROOT/lib/ui.sh"
        "$PROJECT_ROOT/modules/optimization.sh"
        "$PROJECT_ROOT/modules/ai_optimization.sh"
        "$PROJECT_ROOT/modules/complete_removal.sh"
        "$PROJECT_ROOT/modules/git_integration.sh"
        "$PROJECT_ROOT/modules/installation.sh"
        "$PROJECT_ROOT/modules/uninstall.sh"
    )
    
    local syntax_errors=0
    
    for script in "${scripts_to_test[@]}"; do
        if [[ -f "$script" ]]; then
            if bash -n "$script" 2>/dev/null; then
                echo "  ✓ Syntax OK: $(basename "$script")"
            else
                echo "  ✗ Syntax ERROR: $(basename "$script")"
                ((syntax_errors++))
            fi
        else
            echo "  ⚠ Missing: $(basename "$script")"
        fi
    done
    
    if [[ $syntax_errors -eq 0 ]]; then
        test_pass "Script syntax validation"
    else
        test_fail "Script syntax validation" "$syntax_errors scripts have syntax errors"
    fi
}

# Test 2: Test execute_safely function
test_execute_safely_function() {
    echo "Testing execute_safely function..."
    
    # Source the helpers module
    if source "$PROJECT_ROOT/lib/helpers.sh" 2>/dev/null; then
        echo "  ✓ Helpers module loaded"
        
        # Test basic command execution
        if declare -f execute_safely >/dev/null 2>&1; then
            echo "  ✓ execute_safely function exists"
            
            # Test with simple command
            if execute_safely "echo 'test'" "test command" >/dev/null 2>&1; then
                echo "  ✓ Simple command execution works"
            else
                echo "  ✗ Simple command execution failed"
                test_fail "execute_safely basic test" "Simple command failed"
                return 1
            fi
            
            # Test with complex command (quoted paths)
            if execute_safely "mkdir -p \"/tmp/test path with spaces\"" "test complex command" >/dev/null 2>&1; then
                echo "  ✓ Complex command with spaces works"
                rm -rf "/tmp/test path with spaces" 2>/dev/null || true
            else
                echo "  ✗ Complex command with spaces failed"
                test_fail "execute_safely complex test" "Complex command with spaces failed"
                return 1
            fi
            
            test_pass "execute_safely function"
        else
            test_fail "execute_safely function" "Function not found"
        fi
    else
        test_fail "execute_safely function" "Could not load helpers module"
    fi
}

# Test 3: Test floating-point handling in ai_optimization.sh
test_floating_point_handling() {
    echo "Testing floating-point handling..."
    
    # Source the UI module first (provides color variables)
    if source "$PROJECT_ROOT/lib/ui.sh" 2>/dev/null; then
        echo "  ✓ UI module loaded"
    fi
    
    # Source the helpers module first (required dependency)
    if source "$PROJECT_ROOT/lib/helpers.sh" 2>/dev/null; then
        echo "  ✓ Helpers module loaded"
        
        # Source the ai_optimization module
        if source "$PROJECT_ROOT/modules/ai_optimization.sh" 2>/dev/null; then
            echo "  ✓ AI optimization module loaded"
            
            # Test the display_system_specifications function
            if declare -f display_system_specifications >/dev/null 2>&1; then
                echo "  ✓ display_system_specifications function exists"
                
                # Test execution (capture any floating-point errors) - TEMPORARILY DISABLE STRICT ERROR HANDLING
                local test_output
                set +e  # Disable exit on error temporarily
                test_output=$(display_system_specifications 2>&1)
                local exit_code=$?
                set -e  # Re-enable exit on error
                
                if [[ $exit_code -eq 0 ]]; then
                    echo "  ✓ Function executes without syntax errors"
                    
                    # Check for floating-point arithmetic errors
                    if echo "$test_output" | grep -q "invalid arithmetic operator"; then
                        test_fail "floating-point handling" "Arithmetic error still present"
                    else
                        echo "  ✓ No floating-point arithmetic errors found"
                        test_pass "floating-point handling"
                    fi
                else
                    echo "  ✗ Function failed with exit code: $exit_code"
                    echo "  ✗ Error output: $(echo "$test_output" | tail -3)"
                    test_fail "floating-point handling" "Function execution failed with code $exit_code"
                fi
            else
                test_fail "floating-point handling" "display_system_specifications function not found"
            fi
        else
            test_fail "floating-point handling" "Could not load ai_optimization module"
        fi
    else
        test_fail "floating-point handling" "Could not load helpers module"
    fi
}

# Test 4: Test optimization module execute_safely calls
test_optimization_execute_safely_calls() {
    echo "Testing optimization module execute_safely calls..."
    
    # Check for proper command formatting
    local optimization_script="$PROJECT_ROOT/modules/optimization.sh"
    
    if [[ -f "$optimization_script" ]]; then
        echo "  ✓ Optimization script exists"
        
        # Check for unquoted execute_safely calls (should not find any)
        local unquoted_calls
        unquoted_calls=$(grep -n "execute_safely [^\"']" "$optimization_script" | grep -v "execute_safely \"" || true)
        
        if [[ -z "$unquoted_calls" ]]; then
            echo "  ✓ All execute_safely calls are properly quoted"
            test_pass "optimization execute_safely calls"
        else
            echo "  ✗ Found unquoted execute_safely calls:"
            echo "$unquoted_calls"
            test_fail "optimization execute_safely calls" "Unquoted calls found"
        fi
    else
        test_fail "optimization execute_safely calls" "Optimization script not found"
    fi
}

# Test 5: Test shellcheck compliance (warnings only)
test_shellcheck_compliance() {
    echo "Testing shellcheck compliance..."
    
    if command -v shellcheck >/dev/null 2>&1; then
        echo "  ✓ shellcheck is available"
        
        local critical_errors=0
        local scripts_to_check=(
            "$PROJECT_ROOT/lib/helpers.sh"
            "$PROJECT_ROOT/modules/optimization.sh"
            "$PROJECT_ROOT/modules/ai_optimization.sh"
        )
        
        for script in "${scripts_to_check[@]}"; do
            if [[ -f "$script" ]]; then
                echo "  Checking $(basename "$script")..."
                
                # Check for critical errors (exclude warnings and info)
                local critical_issues
                critical_issues=$(shellcheck -f gcc "$script" | grep -E ": error:" || true)
                
                if [[ -n "$critical_issues" ]]; then
                    echo "  ✗ Critical shellcheck errors in $(basename "$script"):"
                    echo "$critical_issues"
                    ((critical_errors++))
                else
                    echo "  ✓ No critical shellcheck errors in $(basename "$script")"
                fi
            fi
        done
        
        if [[ $critical_errors -eq 0 ]]; then
            test_pass "shellcheck compliance (critical errors)"
        else
            test_fail "shellcheck compliance" "$critical_errors scripts have critical errors"
        fi
    else
        test_skip "shellcheck compliance" "shellcheck not available"
    fi
}

# Test 6: Test error patterns from errors.md
test_error_patterns_resolved() {
    echo "Testing that specific error patterns are resolved..."
    
    local error_patterns=(
        "syntax error: operand expected"
        "invalid arithmetic operator"
        "bash -c.*cmd.*2>&1"
        "Failed after.*attempts: write"
    )
    
    local patterns_found=0
    
    for pattern in "${error_patterns[@]}"; do
        echo "  Checking for pattern: $pattern"
        
        # Search in all shell scripts for these patterns
        local found_files
        found_files=$(grep -r "$pattern" "$PROJECT_ROOT"/*.sh "$PROJECT_ROOT"/modules/*.sh "$PROJECT_ROOT"/lib/*.sh 2>/dev/null || true)
        
        if [[ -n "$found_files" ]]; then
            echo "  ✗ Error pattern still found: $pattern"
            echo "$found_files"
            ((patterns_found++))
        else
            echo "  ✓ Error pattern not found: $pattern"
        fi
    done
    
    if [[ $patterns_found -eq 0 ]]; then
        test_pass "error pattern resolution"
    else
        test_fail "error pattern resolution" "$patterns_found error patterns still present"
    fi
}

# Test 7: Test module loading
test_module_loading() {
    echo "Testing module loading..."
    
    # Test that all modules can be loaded without errors
    local modules_to_test=(
        "$PROJECT_ROOT/lib/config.sh"
        "$PROJECT_ROOT/lib/helpers.sh"
        "$PROJECT_ROOT/lib/ui.sh"
        "$PROJECT_ROOT/modules/optimization.sh"
        "$PROJECT_ROOT/modules/ai_optimization.sh"
        "$PROJECT_ROOT/modules/complete_removal.sh"
        "$PROJECT_ROOT/modules/git_integration.sh"
        "$PROJECT_ROOT/modules/installation.sh"
        "$PROJECT_ROOT/modules/uninstall.sh"
    )
    
    local loading_errors=0
    
    for module in "${modules_to_test[@]}"; do
        if [[ -f "$module" ]]; then
            echo "  Testing $(basename "$module")..."
            
            # Test loading in a subshell to avoid side effects
            if (source "$module" 2>/dev/null); then
                echo "  ✓ $(basename "$module") loads successfully"
            else
                echo "  ✗ $(basename "$module") failed to load"
                ((loading_errors++))
            fi
        else
            echo "  ⚠ $(basename "$module") not found"
        fi
    done
    
    if [[ $loading_errors -eq 0 ]]; then
        test_pass "module loading"
    else
        test_fail "module loading" "$loading_errors modules failed to load"
    fi
}

################################################################################
# Main Test Execution
################################################################################

main() {
    echo "=================================================================================="
    echo "                    CURSOR UNINSTALLER ERROR FIXES TEST SUITE"
    echo "=================================================================================="
    echo
    echo "Testing directory: $PROJECT_ROOT"
    echo "Test mode: ${CURSOR_TEST_MODE:-false}"
    echo "Dry run: ${DRY_RUN:-false}"
    echo "Verbose: ${VERBOSE:-false}"
    echo
    echo "=================================================================================="
    echo
    
    # Run all tests
    test_script_syntax
    echo
    test_execute_safely_function
    echo
    test_floating_point_handling
    echo
    test_optimization_execute_safely_calls
    echo
    test_shellcheck_compliance
    echo
    test_error_patterns_resolved
    echo
    test_module_loading
    echo
    
    # Print final results
    echo "=================================================================================="
    echo "                              TEST RESULTS SUMMARY"
    echo "=================================================================================="
    echo
    echo "Tests run:    $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    echo
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "🎉 ALL TESTS PASSED - ERROR FIXES SUCCESSFUL!"
        echo
        echo "✓ All syntax errors have been resolved"
        echo "✓ execute_safely function works correctly"
        echo "✓ Floating-point arithmetic issues fixed"
        echo "✓ Command formatting issues resolved"
        echo "✓ Module loading works properly"
        echo
        echo "The Cursor uninstaller script should now run without the reported errors."
    else
        echo "❌ SOME TESTS FAILED - ERRORS STILL PRESENT:"
        echo
        for error in "${ERRORS_FOUND[@]}"; do
            echo "  • $error"
        done
        echo
        echo "Please review and fix the remaining issues."
    fi
    
    echo "=================================================================================="
    
    # Return appropriate exit code
    if [[ $TESTS_FAILED -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 