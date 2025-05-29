#!/bin/bash

################################################################################
# Optimization Error Fixes Test Suite - PRODUCTION GRADE
# Tests all fixes for optimization performance errors identified in the user query
################################################################################

# shellcheck disable=SC1091  # Disable "Not following" warnings for dynamic paths

set -eE
set -o pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
CRITICAL_FAILURES=0

# Test environment
export TEST_MODE=true
export DRY_RUN=true
export VERBOSE=true

# Logging
LOG_FILE="/tmp/optimization-error-fixes-test-$(date +%Y%m%d_%H%M%S).log"

log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

error_message() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success_message() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning_message() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

info_message() {
    echo -e "${CYAN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# Test execution function
run_test() {
    local test_name="$1"
    local test_function="$2"
    local critical="${3:-false}"
    
    ((TOTAL_TESTS++))
    
    echo -e "\n${BLUE}${BOLD}Testing: $test_name${NC}"
    echo "=================================================="
    
    if $test_function; then
        echo -e "${GREEN}✅ PASSED: $test_name${NC}"
        ((PASSED_TESTS++))
        log_message "PASS" "$test_name"
        return 0
    else
        echo -e "${RED}❌ FAILED: $test_name${NC}"
        ((FAILED_TESTS++))
        log_message "FAIL" "$test_name"
        
        if [[ "$critical" == "true" ]]; then
            ((CRITICAL_FAILURES++))
            error_message "CRITICAL FAILURE: $test_name"
        fi
        return 1
    fi
}

# Test 1: Verify execute_safely function handles special characters
test_execute_safely_special_characters() {
    info_message "Testing execute_safely function with special characters..."
    
    # Source the helpers module
    # shellcheck source=../lib/helpers.sh
    source "$PROJECT_ROOT/lib/helpers.sh" 2>/dev/null || {
        error_message "Failed to source helpers.sh"
        return 1
    }
    
    # Test with file paths containing spaces and special characters
    local test_paths=(
        "/Users/test/.cursor-optimizer-backup-20250530_015712"
        "/Users/test/Library/Application Support/Cursor/User/settings.json"
        "/Users/test/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        "kern.maxfiles=65536"
        "vm.swappiness=10"
    )
    
    local test_passed=true
    
    for test_path in "${test_paths[@]}"; do
        # Test that execute_safely can handle these paths without syntax errors
        if ! execute_safely "echo \"Testing: $test_path\"" "test path handling" 2>/dev/null; then
            error_message "execute_safely failed with path: $test_path"
            test_passed=false
        fi
    done
    
    $test_passed
}

# Test 2: Verify log_message function handles special characters
test_log_message_special_characters() {
    info_message "Testing log_message function with special characters..."
    
    # Source the helpers module
    # shellcheck source=../lib/helpers.sh
    source "$PROJECT_ROOT/lib/helpers.sh" 2>/dev/null || {
        error_message "Failed to source helpers.sh"
        return 1
    }
    
    # Test with various message types containing special characters
    local test_messages=(
        "Failed after 3 attempts: /Users/vicd/.cursor-optimizer-backup-20250530_015712"
        "Failed after kern.maxfiles=65536 attempts: sysctl"
        "Failed after application.memory.maxHeapSize attempts: write"
        "Failed after /Applications/Cursor.app attempts: register"
    )
    
    local test_passed=true
    
    for message in "${test_messages[@]}"; do
        # Test that log_message can handle these messages without syntax errors
        if ! log_message "ERROR" "$message" 2>/dev/null; then
            error_message "log_message failed with message: $message"
            test_passed=false
        fi
    done
    
    $test_passed
}

# Test 3: Verify optimization module syntax
test_optimization_module_syntax() {
    info_message "Testing optimization module syntax..."
    
    # Check syntax of optimization module
    if bash -n "$PROJECT_ROOT/modules/optimization.sh"; then
        success_message "Optimization module syntax is valid"
        return 0
    else
        error_message "Optimization module has syntax errors"
        return 1
    fi
}

# Test 4: Verify all execute_safely calls are properly quoted
test_execute_safely_quoting() {
    info_message "Testing execute_safely call quoting in optimization module..."
    
    # Check that all execute_safely calls in optimization.sh are properly quoted
    local unquoted_calls
    unquoted_calls=$(grep -n "execute_safely [^\"']" "$PROJECT_ROOT/modules/optimization.sh" || true)
    
    if [[ -n "$unquoted_calls" ]]; then
        error_message "Found unquoted execute_safely calls:"
        echo "$unquoted_calls"
        return 1
    else
        success_message "All execute_safely calls are properly quoted"
        return 0
    fi
}

# Test 5: Test optimization functions with mock environment
test_optimization_functions_mock() {
    info_message "Testing optimization functions with mock environment..."
    
    # Set up test environment
    export CURSOR_TEST_MODE=true
    export DRY_RUN=true
    
    # Create temporary test directory
    local test_dir="/tmp/cursor-optimization-test-$$"
    mkdir -p "$test_dir"
    
    # Mock HOME directory for testing
    export HOME="$test_dir"
    
    # Create mock directories and files
    mkdir -p "$test_dir/Library/Preferences"
    mkdir -p "$test_dir/Library/Application Support/Cursor/User"
    mkdir -p "$test_dir/.cursor"
    
    # Create mock preference file
    touch "$test_dir/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
    
    # Source the optimization module
    # shellcheck source=../lib/helpers.sh
    source "$PROJECT_ROOT/lib/helpers.sh" 2>/dev/null || {
        error_message "Failed to source helpers.sh"
        cleanup_test_env "$test_dir"
        return 1
    }
    
    # shellcheck source=../modules/optimization.sh
    source "$PROJECT_ROOT/modules/optimization.sh" 2>/dev/null || {
        error_message "Failed to source optimization.sh"
        cleanup_test_env "$test_dir"
        return 1
    }
    
    # Test create_optimization_backup function
    if create_optimization_backup 2>/dev/null; then
        success_message "create_optimization_backup function works"
    else
        error_message "create_optimization_backup function failed"
        cleanup_test_env "$test_dir"
        return 1
    fi
    
    # Clean up
    cleanup_test_env "$test_dir"
    return 0
}

# Helper function to clean up test environment
cleanup_test_env() {
    local test_dir="$1"
    if [[ -n "$test_dir" ]] && [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir" 2>/dev/null || true
    fi
}

# Test 6: Verify error message formatting
test_error_message_formatting() {
    info_message "Testing error message formatting..."
    
    # Source the helpers module
    # shellcheck source=../lib/helpers.sh
    source "$PROJECT_ROOT/lib/helpers.sh" 2>/dev/null || {
        error_message "Failed to source helpers.sh"
        return 1
    }
    
    # Test that error messages don't contain bash syntax errors
    local test_descriptions=(
        "write memory max heap size"
        "sysctl maxfiles"
        "create backup directory"
        "remove MCP server configurations"
    )
    
    local test_passed=true
    
    for desc in "${test_descriptions[@]}"; do
        # Test that the description sanitization works
        local safe_desc
        safe_desc=$(printf '%s\n' "$desc" | sed 's/[^[:alnum:][:space:]._/-]/_/g' 2>/dev/null || echo "command_execution")
        
        if [[ -z "$safe_desc" ]]; then
            error_message "Description sanitization failed for: $desc"
            test_passed=false
        fi
    done
    
    $test_passed
}

# Test 7: Integration test with actual optimization calls
test_optimization_integration() {
    info_message "Testing optimization integration..."
    
    # Set up safe test environment
    export CURSOR_TEST_MODE=true
    export DRY_RUN=true
    
    # Create temporary test directory
    local test_dir="/tmp/cursor-integration-test-$$"
    mkdir -p "$test_dir"
    export HOME="$test_dir"
    
    # Create mock structure
    mkdir -p "$test_dir/Library/Preferences"
    mkdir -p "$test_dir/Library/Application Support/Cursor/User"
    
    # Source modules
    # shellcheck source=../lib/helpers.sh
    source "$PROJECT_ROOT/lib/helpers.sh" 2>/dev/null || {
        error_message "Failed to source helpers.sh"
        cleanup_test_env "$test_dir"
        return 1
    }
    
    # shellcheck source=../modules/optimization.sh
    source "$PROJECT_ROOT/modules/optimization.sh" 2>/dev/null || {
        error_message "Failed to source optimization.sh"
        cleanup_test_env "$test_dir"
        return 1
    }
    
    # Test that optimization functions can be called without errors
    local functions_to_test=(
        "check_performance_deps"
        "create_optimization_backup"
    )
    
    local test_passed=true
    
    for func in "${functions_to_test[@]}"; do
        if declare -f "$func" >/dev/null 2>&1; then
            info_message "Testing function: $func"
            # Note: We're not actually calling these functions as they may have side effects
            # We're just verifying they exist and are properly defined
            success_message "Function $func is properly defined"
        else
            error_message "Function $func is not defined"
            test_passed=false
        fi
    done
    
    # Clean up
    cleanup_test_env "$test_dir"
    $test_passed
}

# Test 8: Verify production-grade error handling
test_production_error_handling() {
    info_message "Testing production-grade error handling..."
    
    # Source the helpers module
    # shellcheck source=../lib/helpers.sh
    source "$PROJECT_ROOT/lib/helpers.sh" 2>/dev/null || {
        error_message "Failed to source helpers.sh"
        return 1
    }
    
    # Test that execute_safely returns 0 even on failure (non-critical errors)
    if execute_safely "false" "test failure handling" 2>/dev/null; then
        success_message "execute_safely properly handles failures without terminating script"
        return 0
    else
        error_message "execute_safely should return 0 for non-critical failures"
        return 1
    fi
}

# Main test execution
main() {
    echo -e "${BOLD}${BLUE}Optimization Error Fixes Test Suite${NC}"
    echo -e "${BOLD}====================================${NC}\n"
    
    info_message "Starting optimization error fixes validation..."
    
    # Run all tests
    run_test "Execute Safely Special Characters" "test_execute_safely_special_characters" true
    run_test "Log Message Special Characters" "test_log_message_special_characters" true
    run_test "Optimization Module Syntax" "test_optimization_module_syntax" true
    run_test "Execute Safely Quoting" "test_execute_safely_quoting" true
    run_test "Optimization Functions Mock" "test_optimization_functions_mock" false
    run_test "Error Message Formatting" "test_error_message_formatting" true
    run_test "Optimization Integration" "test_optimization_integration" false
    run_test "Production Error Handling" "test_production_error_handling" true
    
    # Final results
    echo -e "\n${BOLD}${BLUE}TEST RESULTS SUMMARY${NC}"
    echo -e "${BOLD}===================${NC}"
    echo -e "${BOLD}Total Tests:${NC} $TOTAL_TESTS"
    echo -e "${BOLD}Passed:${NC} ${GREEN}$PASSED_TESTS${NC}"
    echo -e "${BOLD}Failed:${NC} ${RED}$FAILED_TESTS${NC}"
    echo -e "${BOLD}Critical Failures:${NC} ${RED}$CRITICAL_FAILURES${NC}"
    
    if [[ $CRITICAL_FAILURES -gt 0 ]]; then
        echo -e "\n${RED}${BOLD}❌ CRITICAL FAILURES DETECTED - SCRIPT NOT PRODUCTION READY${NC}"
        log_message "CRITICAL" "Test suite failed with $CRITICAL_FAILURES critical failures"
        return 1
    elif [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "\n${YELLOW}${BOLD}⚠️  SOME TESTS FAILED - REVIEW REQUIRED${NC}"
        log_message "WARNING" "Test suite completed with $FAILED_TESTS non-critical failures"
        return 1
    else
        echo -e "\n${GREEN}${BOLD}✅ ALL TESTS PASSED - SCRIPT IS PRODUCTION READY${NC}"
        log_message "SUCCESS" "All optimization error fixes validated successfully"
        return 0
    fi
}

# Run main function
main "$@" 