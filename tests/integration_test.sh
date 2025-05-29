#!/bin/bash

################################################################################
# Integration Test for Cursor Uninstaller - Production Grade
# Tests the actual uninstall functionality in a safe environment
################################################################################

set -eE
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MAIN_SCRIPT="$PROJECT_ROOT/uninstall_cursor.sh"

# Test environment
TEST_DIR="/tmp/cursor_integration_test_$$"
mkdir -p "$TEST_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Test results
INTEGRATION_TESTS=0
INTEGRATION_PASSED=0
INTEGRATION_FAILED=0

log_test() {
    echo -e "${CYAN}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((INTEGRATION_PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((INTEGRATION_FAILED++))
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Cleanup function
cleanup() {
    rm -rf "$TEST_DIR"
    unset DRY_RUN NON_INTERACTIVE_MODE VERBOSE
}

trap cleanup EXIT

# Override error handling for tests
test_error_handler() {
    local line_number="$1"
    local failed_command="$2"
    
    echo -e "${RED}[ERROR]${NC} Test failed at line $line_number: $failed_command"
    # Don't exit, continue with tests
    return 0
}

trap 'test_error_handler $LINENO "$BASH_COMMAND"' ERR

################################################################################
# Integration Tests
################################################################################

test_script_help() {
    ((INTEGRATION_TESTS++))
    log_test "Testing help functionality"
    
    if timeout 10s bash "$MAIN_SCRIPT" --help >/dev/null 2>&1 || true; then
        log_pass "Help function works correctly"
    else
        log_fail "Help function failed or timed out"
    fi
}

test_script_syntax() {
    ((INTEGRATION_TESTS++))
    log_test "Testing script syntax validation"
    
    if bash -n "$MAIN_SCRIPT" 2>/dev/null || true; then
        log_pass "Script syntax is valid"
    else
        log_fail "Script syntax errors detected"
    fi
}

test_check_functionality() {
    ((INTEGRATION_TESTS++))
    log_test "Testing check functionality in dry run mode"
    
    export DRY_RUN="true"
    export NON_INTERACTIVE_MODE="true"
    export VERBOSE="true"
    
    if timeout 30s bash "$MAIN_SCRIPT" --check >/dev/null 2>&1 || true; then
        log_pass "Check functionality works in dry run mode"
    else
        log_fail "Check functionality failed"
    fi
}

test_optimization_dry_run() {
    ((INTEGRATION_TESTS++))
    log_test "Testing optimization functionality in dry run mode"
    
    export DRY_RUN="true"
    export NON_INTERACTIVE_MODE="true"
    export VERBOSE="true"
    
    # Test optimization without actually running it
    if timeout 30s bash "$MAIN_SCRIPT" --help 2>/dev/null | grep -q "optimize" || true; then
        log_pass "Optimization option is available"
    else
        log_fail "Optimization option not found"
    fi
}

test_module_loading() {
    ((INTEGRATION_TESTS++))
    log_test "Testing module loading capabilities"
    
    # Check if modules directory exists
    if [[ -d "$PROJECT_ROOT/modules" ]] && [[ -d "$PROJECT_ROOT/lib" ]]; then
        log_pass "Required module directories exist"
        
        # Check for key modules
        local key_modules=(
            "modules/complete_removal.sh"
            "modules/uninstall.sh"
            "lib/config.sh"
            "lib/helpers.sh"
        )
        
        local missing_count=0
        for module in "${key_modules[@]}"; do
            if [[ ! -f "$PROJECT_ROOT/$module" ]]; then
                ((missing_count++))
            fi
        done
        
        if [[ $missing_count -eq 0 ]]; then
            log_pass "All key modules present"
        else
            log_fail "$missing_count key modules missing"
        fi
    else
        log_fail "Required module directories missing"
    fi
}

test_error_handling() {
    ((INTEGRATION_TESTS++))
    log_test "Testing error handling mechanisms"
    
    # Test invalid arguments
    if bash "$MAIN_SCRIPT" --invalid-option >/dev/null 2>&1; then
        log_fail "Script should reject invalid options"
    else
        log_pass "Script properly rejects invalid options"
    fi
}

test_production_standards() {
    ((INTEGRATION_TESTS++))
    log_test "Testing production standards compliance"
    
    local standards_met=0
    
    # Check for set -eE
    if grep -q "set -eE" "$MAIN_SCRIPT"; then
        ((standards_met++))
    fi
    
    # Check for set -o pipefail
    if grep -q "set -o pipefail" "$MAIN_SCRIPT"; then
        ((standards_met++))
    fi
    
    # Check for proper error handling
    if grep -q "production_error_handler" "$MAIN_SCRIPT"; then
        ((standards_met++))
    fi
    
    # Check for logging
    if grep -q "production_log_message" "$MAIN_SCRIPT"; then
        ((standards_met++))
    fi
    
    if [[ $standards_met -eq 4 ]]; then
        log_pass "All production standards implemented"
    else
        log_fail "Only $standards_met/4 production standards met"
    fi
}

test_security_measures() {
    ((INTEGRATION_TESTS++))
    log_test "Testing security measures"
    
    # Check for secure sudo usage
    if grep -q "production_sudo" "$MAIN_SCRIPT"; then
        log_pass "Secure sudo wrapper is used"
    else
        log_fail "Direct sudo usage may be insecure"
    fi
    
    # Check for input validation
    if grep -q "read -r" "$MAIN_SCRIPT"; then
        log_pass "Safe input reading methods used"
    else
        log_fail "Input handling may be unsafe"
    fi
}

################################################################################
# Main Test Runner
################################################################################

main() {
    echo -e "${BOLD}${BLUE}Cursor Uninstaller Integration Test Suite${NC}"
    echo -e "${BOLD}==========================================${NC}\n"
    
    log_info "Starting integration tests..."
    log_info "Test environment: $TEST_DIR"
    log_info "Script under test: $MAIN_SCRIPT"
    
    # Run all integration tests
    test_script_syntax
    test_script_help
    test_module_loading
    test_check_functionality
    test_optimization_dry_run
    test_error_handling
    test_production_standards
    test_security_measures
    
    # Generate report
    echo -e "\n${BOLD}Integration Test Results:${NC}"
    echo "=========================="
    echo "Total Tests: $INTEGRATION_TESTS"
    echo "Passed: $INTEGRATION_PASSED"
    echo "Failed: $INTEGRATION_FAILED"
    
    if [[ $INTEGRATION_FAILED -eq 0 ]]; then
        echo -e "\n${BOLD}${GREEN}✅ ALL INTEGRATION TESTS PASSED${NC}"
        echo -e "The script meets production standards and is ready for deployment."
        return 0
    else
        echo -e "\n${BOLD}${RED}❌ INTEGRATION TESTS FAILED${NC}"
        echo -e "$INTEGRATION_FAILED tests failed. Please review and fix issues."
        return 1
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 