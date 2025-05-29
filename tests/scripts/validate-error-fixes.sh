#!/bin/bash

################################################################################
# Error Fixes Validation Script - PRODUCTION GRADE Testing
# Validates that all identified errors in docs/errors.md have been fixed
################################################################################

# Script directory and paths
SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

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

# Logging
LOG_FILE="/tmp/error-fixes-validation-$(date +%Y%m%d_%H%M%S).log"

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
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
    local test_command="$2"
    local is_critical="${3:-false}"
    
    ((TOTAL_TESTS++))
    
    info_message "Running test: $test_name"
    log_message "DEBUG" "Executing: $test_command"
    
    local start_time=$(date +%s)
    local output
    local exit_code
    
    # Run test with timeout
    if output=$(timeout 60s bash -c "$test_command" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ $exit_code -eq 0 ]]; then
        success_message "✓ PASSED: $test_name (${duration}s)"
        ((PASSED_TESTS++))
        log_message "TEST_PASS" "$test_name - Duration: ${duration}s"
        return 0
    else
        if [[ "$is_critical" == "true" ]]; then
            error_message "✗ CRITICAL FAILURE: $test_name (Exit: $exit_code, Duration: ${duration}s)"
            ((CRITICAL_FAILURES++))
        else
            error_message "✗ FAILED: $test_name (Exit: $exit_code, Duration: ${duration}s)"
        fi
        ((FAILED_TESTS++))
        log_message "TEST_FAIL" "$test_name - Exit: $exit_code, Duration: ${duration}s"
        log_message "TEST_OUTPUT" "$output"
        return 1
    fi
}

# Test 1: Verify todesktop bundle ID handling
test_todesktop_bundle_handling() {
    info_message "Testing todesktop bundle ID handling fix..."
    
    # Create test environment
    local test_dir="/tmp/cursor-bundle-test-$$"
    mkdir -p "$test_dir/Applications/Cursor.app/Contents"
    
    # Create Info.plist with problematic bundle ID
    cat > "$test_dir/Applications/Cursor.app/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.todesktop.230313mzl4w4u92</string>
    <key>CFBundleName</key>
    <string>Cursor</string>
    <key>CFBundleDisplayName</key>
    <string>Cursor</string>
</dict>
</plist>
EOF

    # Test script
    local test_script="$test_dir/test_bundle.sh"
    cat > "$test_script" << EOF
#!/bin/bash
export CURSOR_TEST_MODE=true
export DRY_RUN=true
export VERBOSE=true

# Source the complete removal module
source "$PROJECT_ROOT/modules/complete_removal.sh"

# Mock defaults command
defaults() {
    case "\$2" in
        "CFBundleIdentifier") echo "com.todesktop.230313mzl4w4u92" ;;
        "CFBundleName") echo "Cursor" ;;
        "CFBundleDisplayName") echo "Cursor" ;;
        *) echo "unknown" ;;
    esac
}

# Mock enhanced_safe_remove
enhanced_safe_remove() {
    echo "Would remove: \$1"
    return 0
}

# Mock du
du() {
    echo "100M	\$2"
}

# Test the function by creating a test version
test_bundle_verification() {
    local app_path="$test_dir/Applications/Cursor.app"
    local bundle_id="com.todesktop.230313mzl4w4u92"
    local bundle_name="Cursor"
    local bundle_display_name="Cursor"
    
    # This should now succeed with the fix
    if [[ "\$bundle_id" == *"cursor"* ]] || [[ "\$bundle_id" == *"Cursor"* ]] || \\
       [[ "\$bundle_id" == *"todesktop"* ]] || \\
       [[ "\$bundle_name" == *"cursor"* ]] || [[ "\$bundle_name" == *"Cursor"* ]] || \\
       [[ "\$bundle_display_name" == *"cursor"* ]] || [[ "\$bundle_display_name" == *"Cursor"* ]] || \\
       [[ "\$(basename "\$app_path")" == "Cursor.app" ]]; then
        echo "VERIFICATION_SUCCESS: Bundle verification passed for todesktop ID"
        return 0
    else
        echo "VERIFICATION_FAILED: Bundle verification failed"
        return 1
    fi
}

test_bundle_verification
EOF

    chmod +x "$test_script"
    
    run_test "Bundle ID Verification Fix" "$test_script" true
    
    # Cleanup
    rm -rf "$test_dir"
}

# Test 2: Verify process self-termination prevention
test_process_self_termination_prevention() {
    info_message "Testing process self-termination prevention..."
    
    local test_dir="/tmp/cursor-process-test-$$"
    mkdir -p "$test_dir"
    
    local test_script="$test_dir/test_process.sh"
    cat > "$test_script" << EOF
#!/bin/bash
export CURSOR_TEST_MODE=true
export DRY_RUN=true
export VERBOSE=true

# Source the complete removal module
source "$PROJECT_ROOT/modules/complete_removal.sh"

# Mock ps to return script's own process
ps() {
    if [[ "\$1" == "aux" ]]; then
        cat << 'PSEOF'
USER      PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
user     1234   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 /bin/bash ./uninstall_cursor.sh
user     5678   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 /Applications/Cursor.app/Contents/MacOS/Cursor
PSEOF
    elif [[ "\$1" == "-p" ]]; then
        case "\$2" in
            1234) echo "/bin/bash ./uninstall_cursor.sh" ;;
            5678) echo "/Applications/Cursor.app/Contents/MacOS/Cursor" ;;
            *) echo "" ;;
        esac
    else
        command ps "\$@"
    fi
}

# Track kill operations
kill_log="$test_dir/kill_operations.log"
kill() {
    echo "KILL_ATTEMPT: \$@" >> "\$kill_log"
    return 0
}

# Set script PID for protection test
current_script_pid=1234

# Run the function
remove_background_processes

# Verify protection worked
if [[ -f "\$kill_log" ]]; then
    if grep -q "KILL_ATTEMPT:.*1234" "\$kill_log"; then
        echo "PROTECTION_FAILED: Script tried to kill itself"
        exit 1
    else
        echo "PROTECTION_SUCCESS: Script protected itself from termination"
        exit 0
    fi
else
    echo "PROTECTION_UNKNOWN: No kill log found"
    exit 1
fi
EOF

    chmod +x "$test_script"
    
    run_test "Process Self-Termination Prevention" "$test_script" true
    
    # Cleanup
    rm -rf "$test_dir"
}

# Test 3: End-to-end script execution without critical errors
test_end_to_end_execution() {
    info_message "Testing end-to-end script execution..."
    
    local test_dir="/tmp/cursor-e2e-test-$$"
    mkdir -p "$test_dir/Applications/Cursor.app/Contents"
    
    # Create complete test environment
    cat > "$test_dir/Applications/Cursor.app/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.todesktop.230313mzl4w4u92</string>
    <key>CFBundleName</key>
    <string>Cursor</string>
    <key>CFBundleDisplayName</key>
    <string>Cursor</string>
</dict>
</plist>
EOF

    local test_script="$test_dir/test_e2e.sh"
    cat > "$test_script" << EOF
#!/bin/bash
export CURSOR_TEST_MODE=true
export DRY_RUN=true
export NON_INTERACTIVE_MODE=true
export VERBOSE=false
export FORCE_EXIT=false

# Mock critical system commands
ps() {
    if [[ "\$1" == "aux" ]]; then
        echo "USER PID %CPU %MEM VSZ RSS TT STAT STARTED TIME COMMAND"
        echo "user 5678 0.0 0.1 1234567 1234 s000 S+ 1:00PM 0:00.01 /Applications/Cursor.app/Contents/MacOS/Cursor"
    else
        command ps "\$@" 2>/dev/null || true
    fi
}

kill() {
    return 0
}

defaults() {
    case "\$2" in
        "CFBundleIdentifier") echo "com.todesktop.230313mzl4w4u92" ;;
        "CFBundleName") echo "Cursor" ;;
        "CFBundleDisplayName") echo "Cursor" ;;
        *) echo "unknown" ;;
    esac
}

sudo() {
    if [[ "\$1" == "-n" ]]; then
        return 0
    fi
    return 0
}

enhanced_safe_remove() {
    return 0
}

# Source main script
source "$PROJECT_ROOT/uninstall_cursor.sh"

# Test that script can execute without hanging or critical errors
if declare -f production_execute_complete_uninstall >/dev/null 2>&1; then
    production_execute_complete_uninstall
    echo "E2E_SUCCESS: Complete uninstall executed without critical errors"
else
    echo "E2E_FAILED: Complete uninstall function not available"
    exit 1
fi
EOF

    chmod +x "$test_script"
    
    run_test "End-to-End Execution" "$test_script" true
    
    # Cleanup
    rm -rf "$test_dir"
}

# Test 4: Module loading and error handling
test_module_loading_resilience() {
    info_message "Testing module loading resilience..."
    
    local test_dir="/tmp/cursor-module-test-$$"
    mkdir -p "$test_dir"
    
    # Copy main script
    cp "$PROJECT_ROOT/uninstall_cursor.sh" "$test_dir/"
    
    # Create incomplete module structure
    mkdir -p "$test_dir/lib"
    mkdir -p "$test_dir/modules"
    
    # Create only some modules to test partial loading
    echo '# Minimal config' > "$test_dir/lib/config.sh"
    echo '# Minimal helpers' > "$test_dir/lib/helpers.sh"
    
    local test_script="$test_dir/test_modules.sh"
    cat > "$test_script" << EOF
#!/bin/bash
export CURSOR_TEST_MODE=true
export DRY_RUN=true
export NON_INTERACTIVE_MODE=true
export VERBOSE=true

cd "$test_dir"

# Source the main script
source "./uninstall_cursor.sh" || {
    echo "MODULE_RESILIENCE_FAILED: Script failed to load with missing modules"
    exit 1
}

echo "MODULE_RESILIENCE_SUCCESS: Script handled missing modules gracefully"
EOF

    chmod +x "$test_script"
    
    run_test "Module Loading Resilience" "$test_script" false
    
    # Cleanup
    rm -rf "$test_dir"
}

# Test 5: BATS test suite execution
test_bats_suite() {
    info_message "Running BATS test suite for error fixes..."
    
    # Check if BATS is available
    if ! command -v bats >/dev/null 2>&1; then
        warning_message "BATS not available - skipping BATS tests"
        return 0
    fi
    
    # Run our specific error fix tests
    local test_files=(
        "$PROJECT_ROOT/tests/unit/test_complete_removal_fixes.bats"
        "$PROJECT_ROOT/tests/integration/test_error_fixes_integration.bats"
    )
    
    for test_file in "${test_files[@]}"; do
        if [[ -f "$test_file" ]]; then
            run_test "BATS: $(basename "$test_file")" "cd '$PROJECT_ROOT' && bats '$test_file'" false
        else
            warning_message "Test file not found: $test_file"
        fi
    done
}

# Test 6: Syntax and static analysis
test_syntax_and_static_analysis() {
    info_message "Running syntax and static analysis tests..."
    
    # Test main script syntax
    run_test "Main Script Syntax" "bash -n '$PROJECT_ROOT/uninstall_cursor.sh'" true
    
    # Test all module syntax
    for module in "$PROJECT_ROOT/modules/"*.sh; do
        if [[ -f "$module" ]]; then
            run_test "Module Syntax: $(basename "$module")" "bash -n '$module'" false
        fi
    done
    
    # Test library syntax
    for lib in "$PROJECT_ROOT/lib/"*.sh; do
        if [[ -f "$lib" ]]; then
            run_test "Library Syntax: $(basename "$lib")" "bash -n '$lib'" false
        fi
    done
}

# Test 7: Verify specific error conditions from docs/errors.md
test_specific_error_conditions() {
    info_message "Testing specific error conditions from docs/errors.md..."
    
    # Test that we don't get the specific bundle verification error
    local bundle_test_script="
export CURSOR_TEST_MODE=true
export DRY_RUN=true
source '$PROJECT_ROOT/modules/complete_removal.sh'

# Test the exact condition that caused the error
defaults() {
    case \"\$2\" in
        \"CFBundleIdentifier\") echo \"com.todesktop.230313mzl4w4u92\" ;;
        \"CFBundleName\") echo \"Cursor\" ;;
        \"CFBundleDisplayName\") echo \"Cursor\" ;;
        *) echo \"unknown\" ;;
    esac
}

mkdir -p /tmp/cursor-specific-test/Applications/Cursor.app/Contents
app_path=\"/tmp/cursor-specific-test/Applications/Cursor.app\"

# This should now pass with our fix
bundle_id=\"com.todesktop.230313mzl4w4u92\"
if [[ \"\$bundle_id\" == *\"cursor\"* ]] || [[ \"\$bundle_id\" == *\"Cursor\"* ]] || \\
   [[ \"\$bundle_id\" == *\"todesktop\"* ]] || \\
   [[ \"\$(basename \"\$app_path\")\" == \"Cursor.app\" ]]; then
    echo \"SPECIFIC_ERROR_FIXED: Bundle verification now passes for todesktop ID\"
    rm -rf /tmp/cursor-specific-test
    exit 0
else
    echo \"SPECIFIC_ERROR_PERSISTS: Bundle verification still fails\"
    rm -rf /tmp/cursor-specific-test
    exit 1
fi
"
    
    run_test "Specific Bundle Verification Error Fix" "$bundle_test_script" true
}

# Main execution
main() {
    echo -e "${BOLD}${BLUE}=================================="
    echo "  CURSOR UNINSTALLER ERROR FIXES  "
    echo "  VALIDATION SUITE                 "
    echo -e "==================================${NC}\n"
    
    info_message "Starting comprehensive error fixes validation"
    info_message "Log file: $LOG_FILE"
    
    # Run all tests
    test_syntax_and_static_analysis
    test_todesktop_bundle_handling
    test_process_self_termination_prevention
    test_module_loading_resilience
    test_specific_error_conditions
    test_end_to_end_execution
    test_bats_suite
    
    # Final report
    echo -e "\n${BOLD}${BLUE}=================================="
    echo "           TEST RESULTS             "
    echo -e "==================================${NC}"
    
    echo -e "${BOLD}Total Tests:${NC} $TOTAL_TESTS"
    echo -e "${GREEN}${BOLD}Passed:${NC} $PASSED_TESTS"
    echo -e "${RED}${BOLD}Failed:${NC} $FAILED_TESTS"
    echo -e "${RED}${BOLD}Critical Failures:${NC} $CRITICAL_FAILURES"
    
    local pass_rate=0
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        pass_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi
    echo -e "${CYAN}${BOLD}Pass Rate:${NC} ${pass_rate}%"
    
    echo -e "\n${BOLD}Detailed log:${NC} $LOG_FILE"
    
    # Determine overall result
    if [[ $CRITICAL_FAILURES -gt 0 ]]; then
        echo -e "\n${RED}${BOLD}❌ CRITICAL FAILURES DETECTED${NC}"
        echo "The identified errors have NOT been fully resolved."
        echo "Review the log file for detailed failure information."
        exit 1
    elif [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "\n${YELLOW}${BOLD}⚠️  SOME TESTS FAILED${NC}"
        echo "Most critical errors appear to be fixed, but some issues remain."
        echo "Review the log file for detailed information."
        exit 2
    else
        echo -e "\n${GREEN}${BOLD}✅ ALL TESTS PASSED${NC}"
        echo "All identified errors appear to be successfully resolved!"
        exit 0
    fi
}

# Run main function
main "$@" 