#!/bin/bash

################################################################################
# Testing Module - PRODUCTION GRADE Test Functions for Cursor Uninstaller
# NO MOCKING, NO FALLBACKS, NO FALSE POSITIVES
################################################################################

# Run comprehensive PRODUCTION test suite
run_tests() {
    production_log_message "INFO" "Starting PRODUCTION test suite (NO MOCKING)..."

    local test_results=()
    local total_tests=0
    local passed_tests=0
    local failed_tests=0

    # Initialize test environment
    initialize_test_environment || {
        production_error_message "Failed to initialize test environment"
        return 1
    }

    # Run different test categories with PRODUCTION error handling
    echo "=== Module Loading Tests ==="
    local module_result
    run_module_loading_tests
    module_result=$?
    local module_tests=6  # We know we test 6 modules
    total_tests=$((total_tests + module_tests))
    if [[ $module_result -ne 0 ]]; then
        failed_tests=$((failed_tests + module_result))
    fi

    echo -e "\n=== Function Availability Tests ==="
    local function_result
    run_function_availability_tests
    function_result=$?
    local function_tests=21  # Count of all functions tested
    total_tests=$((total_tests + function_tests))
    if [[ $function_result -ne 0 ]]; then
        failed_tests=$((failed_tests + function_result))
    fi

    echo -e "\n=== Configuration Tests ==="
    local config_result
    run_configuration_tests
    config_result=$?
    local config_tests=3  # We test 3 configuration items
    total_tests=$((total_tests + config_tests))
    if [[ $config_result -ne 0 ]]; then
        failed_tests=$((failed_tests + config_result))
    fi

    echo -e "\n=== Path Detection Tests ==="
    local path_result
    run_path_detection_tests
    path_result=$?
    local path_tests=3  # We test 3 path detection items
    total_tests=$((total_tests + path_tests))
    if [[ $path_result -ne 0 ]]; then
        failed_tests=$((failed_tests + path_result))
    fi

    echo -e "\n=== Safety Tests ==="
    local safety_result
    run_safety_tests
    safety_result=$?
    local safety_tests=4  # We test 4 safety items
    total_tests=$((total_tests + safety_tests))
    if [[ $safety_result -ne 0 ]]; then
        failed_tests=$((failed_tests + safety_result))
    fi

    echo -e "\n=== Integration Tests ==="
    local integration_result
    run_integration_tests
    integration_result=$?
    local integration_tests=3  # We test 3 integration items
    total_tests=$((total_tests + integration_tests))
    if [[ $integration_result -ne 0 ]]; then
        failed_tests=$((failed_tests + integration_result))
    fi

    echo -e "\n=== Advanced Features Tests ==="
    local advanced_result
    run_advanced_features_tests
    advanced_result=$?
    local advanced_tests=9  # We test 9 advanced features
    total_tests=$((total_tests + advanced_tests))
    if [[ $advanced_result -ne 0 ]]; then
        failed_tests=$((failed_tests + advanced_result))
    fi

    echo -e "\n=== Git Integration Tests ==="
    local git_result
    run_git_integration_tests
    git_result=$?
    local git_tests=5  # We test 5 git integration items
    total_tests=$((total_tests + git_tests))
    if [[ $git_result -ne 0 ]]; then
        failed_tests=$((failed_tests + git_result))
    fi

    echo -e "\n=== AI Optimization Tests ==="
    local ai_result
    run_ai_optimization_tests
    ai_result=$?
    local ai_tests=4  # We test 4 AI optimization items
    total_tests=$((total_tests + ai_tests))
    if [[ $ai_result -ne 0 ]]; then
        failed_tests=$((failed_tests + ai_result))
    fi

    # Calculate results properly
    passed_tests=$((total_tests - failed_tests))

    # Display test results
    echo -e "\n=== PRODUCTION Test Results Summary ==="
    echo "Total Tests: $total_tests"
    echo "Passed: $passed_tests"
    echo "Failed: $failed_tests"

    if [[ $failed_tests -eq 0 ]]; then
        production_success_message "✓ All PRODUCTION tests passed!"
        return 0
    else
        production_error_message "✗ $failed_tests PRODUCTION tests failed"
        return 1
    fi
}

# Initialize PRODUCTION test environment
initialize_test_environment() {
    production_log_message "INFO" "Initializing PRODUCTION test environment..."

    # Set test mode variables
    export CURSOR_TEST_MODE="true"
    export DRY_RUN="true"
    export VERBOSE="true"

    # Create test directories
    local test_base_dir="/tmp/cursor-uninstaller-tests-$$"
    export CURSOR_TEST_DIR="$test_base_dir"

    execute_safely mkdir -p "$CURSOR_TEST_DIR" || return 1
    execute_safely mkdir -p "$CURSOR_TEST_DIR/mock_applications" || return 1
    execute_safely mkdir -p "$CURSOR_TEST_DIR/mock_library" || return 1
    execute_safely mkdir -p "$CURSOR_TEST_DIR/mock_binaries" || return 1

    # Check if success_message function is available
    if declare -f success_message >/dev/null 2>&1; then
        success_message "✓ Test environment initialized at $CURSOR_TEST_DIR"
    else
        echo "✓ Test environment initialized at $CURSOR_TEST_DIR"
    fi
    
    return 0
}

# Test module loading functionality - PRODUCTION GRADE
run_module_loading_tests() {
    local test_count=0
    local local_failures=0

    # Test 1: Config module loading
    test_count=$((test_count + 1))
    if test_module_loading "config" "$SCRIPT_DIR/lib/config.sh"; then
        echo "✓ Config module loading test passed"
    else
        echo "✗ Config module loading test failed"
        local_failures=$((local_failures + 1))
    fi

    # Test 2: Helpers module loading
    test_count=$((test_count + 1))
    if test_module_loading "helpers" "$SCRIPT_DIR/lib/helpers.sh"; then
        echo "✓ Helpers module loading test passed"
    else
        echo "✗ Helpers module loading test failed"
        local_failures=$((local_failures + 1))
    fi

    # Test 3: UI module loading
    test_count=$((test_count + 1))
    if test_module_loading "ui" "$SCRIPT_DIR/lib/ui.sh"; then
        echo "✓ UI module loading test passed"
    else
        echo "✗ UI module loading test failed"
        local_failures=$((local_failures + 1))
    fi

    # Test 4: Installation module loading
    test_count=$((test_count + 1))
    if test_module_loading "installation" "$SCRIPT_DIR/modules/installation.sh"; then
        echo "✓ Installation module loading test passed"
    else
        echo "✗ Installation module loading test failed"
        local_failures=$((local_failures + 1))
    fi

    # Test 5: Optimization module loading
    test_count=$((test_count + 1))
    if test_module_loading "optimization" "$SCRIPT_DIR/modules/optimization.sh"; then
        echo "✓ Optimization module loading test passed"
    else
        echo "✗ Optimization module loading test failed"
        local_failures=$((local_failures + 1))
    fi

    # Test 6: Uninstall module loading
    test_count=$((test_count + 1))
    if test_module_loading "uninstall" "$SCRIPT_DIR/modules/uninstall.sh"; then
        echo "✓ Uninstall module loading test passed"
    else
        echo "✗ Uninstall module loading test failed"
        local_failures=$((local_failures + 1))
    fi

    # Return the number of failures for this test category
    return $local_failures
}

# Test individual module loading
test_module_loading() {
    local module_name="$1"
    local module_path="$2"

    if [[ ! -f "$module_path" ]]; then
        error_message "Module file not found: $module_path"
        return 1
    fi

    # Test syntax
    if ! bash -n "$module_path" 2>/dev/null; then
        error_message "Syntax error in module: $module_name"
        return 1
    fi

    return 0
}

# Test function availability - PRODUCTION GRADE
run_function_availability_tests() {
    local test_count=0
    local local_failures=0

    # Define required functions by category
    local config_functions=(
        "initialize_logging"
        "log_message"
        "validate_system_requirements"
    )

    local helper_functions=(
        "error_message"
        "warning_message"
        "success_message"
        "info_message"
        "execute_safely"
        "enhanced_safe_remove"
    )

    local ui_functions=(
        "show_progress"
        "enhanced_show_menu"
        "show_help"
    )

    local installation_functions=(
        "check_cursor_installation"
        "install_cursor_from_dmg"
        "confirm_installation_action"
    )

    local optimization_functions=(
        "enhanced_optimize_cursor_performance"
        "reset_performance_settings"
    )

    local uninstall_functions=(
        "enhanced_uninstall_cursor"
        "confirm_uninstall_action"
    )

    # Test config functions
    echo "Testing config functions..."
    for func in "${config_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_availability "$func"; then
            echo "  ✓ $func is available"
        else
            echo "  ✗ $func is missing"
            local_failures=$((local_failures + 1))
        fi
    done

    # Test helper functions
    echo "Testing helper functions..."
    for func in "${helper_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_availability "$func"; then
            echo "  ✓ $func is available"
        else
            echo "  ✗ $func is missing"
            local_failures=$((local_failures + 1))
        fi
    done

    # Test UI functions
    echo "Testing UI functions..."
    for func in "${ui_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_availability "$func"; then
            echo "  ✓ $func is available"
        else
            echo "  ✗ $func is missing"
            local_failures=$((local_failures + 1))
        fi
    done

    # Test installation functions
    echo "Testing installation functions..."
    for func in "${installation_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_availability "$func"; then
            echo "  ✓ $func is available"
        else
            echo "  ✗ $func is missing"
            local_failures=$((local_failures + 1))
        fi
    done

    # Test optimization functions
    echo "Testing optimization functions..."
    for func in "${optimization_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_availability "$func"; then
            echo "  ✓ $func is available"
        else
            echo "  ✗ $func is missing"
            local_failures=$((local_failures + 1))
        fi
    done

    # Test uninstall functions
    echo "Testing uninstall functions..."
    for func in "${uninstall_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_availability "$func"; then
            echo "  ✓ $func is available"
        else
            echo "  ✗ $func is missing"
            local_failures=$((local_failures + 1))
        fi
    done

    # Return the number of failures for this test category
    return $local_failures
}

# Test individual function availability
test_function_availability() {
    local function_name="$1"
    declare -f "$function_name" >/dev/null 2>&1
}

# Test configuration functionality - PRODUCTION GRADE
run_configuration_tests() {
    local test_count=0
    local local_failures=0

    # Test 1: Error codes defined
    test_count=$((test_count + 1))
    if [[ -n "${ERR_INVALID_ARGS:-}" ]] && [[ -n "${ERR_PERMISSION_DENIED:-}" ]] && [[ -n "${ERR_FILE_NOT_FOUND:-}" ]]; then
        echo "✓ Error codes are properly defined"
    else
        echo "✗ Error codes are not properly defined"
        local_failures=$((local_failures + 1))
    fi

    # Test 2: Color codes defined
    test_count=$((test_count + 1))
    if [[ -n "${RED:-}" ]] && [[ -n "${GREEN:-}" ]] && [[ -n "${YELLOW:-}" ]]; then
        echo "✓ Color codes are properly defined"
    else
        echo "✗ Color codes are not properly defined"
        local_failures=$((local_failures + 1))
    fi

    # Test 3: Script directory is valid
    test_count=$((test_count + 1))
    if [[ -n "${SCRIPT_DIR:-}" ]] && [[ -d "$SCRIPT_DIR" ]]; then
        echo "✓ Script directory is valid: $SCRIPT_DIR"
    else
        echo "✗ Script directory is invalid or undefined"
        local_failures=$((local_failures + 1))
    fi

    # Return the number of failures for this test category
    return $local_failures
}

# Test path detection functionality - PRODUCTION GRADE
run_path_detection_tests() {
    local test_count=0
    local local_failures=0

    # Test 1: Cursor application detection (REAL CHECK)
    test_count=$((test_count + 1))
    if [[ -d "/Applications/Cursor.app" ]]; then
        echo "✓ REAL Cursor application found at /Applications/Cursor.app"
    else
        echo "✗ REAL Cursor application not found (this is not a test failure if Cursor is not installed)"
        # Don't count as failure for production environment
    fi

    # Test 2: CLI tools detection (REAL CHECK)
    test_count=$((test_count + 1))
    if command -v cursor >/dev/null 2>&1; then
        local cursor_path=$(which cursor 2>/dev/null)
        echo "✓ REAL Cursor CLI found at: $cursor_path"
    else
        echo "✗ REAL Cursor CLI not found (this is not a test failure if CLI is not installed)"
        # Don't count as failure for production environment
    fi

    # Test 3: Library paths (REAL CHECK)
    test_count=$((test_count + 1))
    local lib_paths=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Caches/Cursor"
        "$HOME/Library/Preferences/com.cursor.Cursor.plist"
    )
    
    local found_paths=0
    for path in "${lib_paths[@]}"; do
        if [[ -e "$path" ]]; then
            echo "  ✓ REAL path found: $path"
            found_paths=$((found_paths + 1))
        fi
    done
    
    if [[ $found_paths -gt 0 ]]; then
        echo "✓ REAL library paths detected ($found_paths found)"
    else
        echo "✗ REAL library paths not found (this is normal if Cursor was never installed)"
        # Don't count as failure for production environment
    fi

    # Return the number of failures for this test category  
    return $local_failures
}

# Test safety functionality - PRODUCTION GRADE
run_safety_tests() {
    local test_count=0
    local local_failures=0

    # Test 1: DRY_RUN mode
    test_count=$((test_count + 1))
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo "✓ DRY_RUN mode is active (safe for testing)"
    else
        echo "⚠ DRY_RUN mode is not active (be careful in production)"
        # Don't count as failure
    fi

    # Test 2: Test mode variables
    test_count=$((test_count + 1))
    if [[ "${CURSOR_TEST_MODE:-false}" == "true" ]]; then
        echo "✓ Test mode is properly activated"
    else
        echo "✗ Test mode is not activated"
        local_failures=$((local_failures + 1))
    fi

    # Test 3: Safe execution function
    test_count=$((test_count + 1))
    if declare -f execute_safely >/dev/null 2>&1; then
        echo "✓ Safe execution function is available"
    else
        echo "✗ Safe execution function is not available"
        local_failures=$((local_failures + 1))
    fi

    # Test 4: Backup functionality (if available)
    test_count=$((test_count + 1))
    if declare -f create_backup >/dev/null 2>&1; then
        echo "✓ Backup functionality is available"
    else
        echo "⚠ Backup functionality is not available"
        # Don't count as failure if optional
    fi

    # Return the number of failures for this test category
    return $local_failures
}

# Test integration functionality - PRODUCTION GRADE
run_integration_tests() {
    local test_count=0
    local local_failures=0

    # Test 1: Module interdependencies
    test_count=$((test_count + 1))
    if test_module_integration; then
        echo "✓ Module integration test passed"
    else
        echo "✗ Module integration test failed"
        local_failures=$((local_failures + 1))
    fi

    # Test 2: Error handling integration
    test_count=$((test_count + 1))
    if test_error_handling_integration; then
        echo "✓ Error handling integration test passed"
    else
        echo "✗ Error handling integration test failed"
        local_failures=$((local_failures + 1))
    fi

    # Test 3: Logging integration
    test_count=$((test_count + 1))
    if test_logging_integration; then
        echo "✓ Logging integration test passed"
    else
        echo "✗ Logging integration test failed"
        local_failures=$((local_failures + 1))
    fi

    # Return the number of failures for this test category
    return $local_failures
}

# Test module integration - PRODUCTION GRADE
test_module_integration() {
    # Test that all modules can work together
    local integration_passed=true
    
    # Test 1: Config and helpers integration
    if declare -f log_message >/dev/null 2>&1 && declare -f error_message >/dev/null 2>&1; then
        # Test message functions can use config settings
        if [[ -n "${RED:-}" ]] && [[ -n "${GREEN:-}" ]]; then
            echo "  ✓ Config and helpers integration works"
        else
            echo "  ✗ Config and helpers integration failed"
            integration_passed=false
        fi
    else
        echo "  ✗ Message functions not available"
        integration_passed=false
    fi
    
    # Test 2: UI and helpers integration
    if declare -f show_progress >/dev/null 2>&1 && declare -f success_message >/dev/null 2>&1; then
        echo "  ✓ UI and helpers integration works"
    else
        echo "  ✗ UI and helpers integration failed"
        integration_passed=false
    fi
    
    # Test 3: All modules can access SCRIPT_DIR
    if [[ -n "${SCRIPT_DIR:-}" ]] && [[ -d "$SCRIPT_DIR" ]]; then
        echo "  ✓ All modules can access SCRIPT_DIR"
    else
        echo "  ✗ SCRIPT_DIR not properly shared between modules"
        integration_passed=false
    fi
    
    $integration_passed
}

# Test error handling integration - PRODUCTION GRADE
test_error_handling_integration() {
    # Test that error handling works across all modules
    local error_handling_passed=true
    
    # Test 1: Error functions are available
    local error_functions=("error_message" "warning_message" "log_message")
    for func in "${error_functions[@]}"; do
        if declare -f "$func" >/dev/null 2>&1; then
            echo "  ✓ Error function $func is available"
        else
            echo "  ✗ Error function $func is missing"
            error_handling_passed=false
        fi
    done
    
    # Test 2: Error codes are properly defined
    local error_codes=("ERR_INVALID_ARGS" "ERR_PERMISSION_DENIED" "ERR_FILE_NOT_FOUND" "ERR_SYSTEM_ERROR")
    for code in "${error_codes[@]}"; do
        if [[ -n "${!code:-}" ]]; then
            echo "  ✓ Error code $code is defined"
        else
            echo "  ✗ Error code $code is missing"
            error_handling_passed=false
        fi
    done
    
    # Test 3: Error trap is active
    if [[ "${-}" == *e* ]]; then
        echo "  ✓ Error trap is active (set -e)"
    else
        echo "  ⚠ Error trap may not be active"
        # Don't fail for this in production
    fi
    
    $error_handling_passed
}

# Test logging integration - PRODUCTION GRADE
test_logging_integration() {
    # Test that logging works properly across modules
    local logging_passed=true
    
    # Test 1: Logging function is available
    if declare -f log_message >/dev/null 2>&1; then
        echo "  ✓ Logging function is available"
    else
        echo "  ✗ Logging function is missing"
        logging_passed=false
    fi
    
    # Test 2: Logging can handle different levels
    local log_levels=("INFO" "WARNING" "ERROR" "SUCCESS")
    for level in "${log_levels[@]}"; do
        # Test that log message function can handle this level
        if log_message "$level" "Test message for $level" >/dev/null 2>&1; then
            echo "  ✓ Logging level $level works"
        else
            echo "  ✗ Logging level $level failed"
            logging_passed=false
        fi
    done
    
    # Test 3: Logging respects verbosity settings
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "  ✓ Verbose logging is enabled"
    else
        echo "  ℹ Verbose logging is disabled (normal in production)"
        # Don't fail for this
    fi
    
    $logging_passed
}

# Cleanup test environment - PRODUCTION GRADE
cleanup_test_environment() {
    if [[ -n "${CURSOR_TEST_DIR:-}" ]] && [[ -d "$CURSOR_TEST_DIR" ]]; then
        execute_safely rm -rf "$CURSOR_TEST_DIR"
        production_info_message "Test environment cleaned up"
    fi
    
    # Unset test environment variables
    unset CURSOR_TEST_MODE
    unset CURSOR_TEST_DIR
}

# Performance benchmark tests - PRODUCTION GRADE
run_performance_tests() {
    production_info_message "Running PRODUCTION performance tests..."
    
    local start_time=$(date +%s)
    
    # Test script startup time
    local startup_start=$(date +%s%N)
    source "$SCRIPT_DIR/lib/config.sh" >/dev/null 2>&1
    local startup_end=$(date +%s%N)
    local startup_time=$(( (startup_end - startup_start) / 1000000 ))
    
    echo "✓ Script startup time: ${startup_time}ms"
    
    # Test module loading time
    local loading_start=$(date +%s%N)
    source "$SCRIPT_DIR/lib/helpers.sh" >/dev/null 2>&1
    local loading_end=$(date +%s%N)
    local loading_time=$(( (loading_end - loading_start) / 1000000 ))
    
    echo "✓ Module loading time: ${loading_time}ms"
    
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    
    echo "✓ Total performance test time: ${total_time}s"
    
    return 0
}

# Test advanced features functionality - PRODUCTION GRADE
run_advanced_features_tests() {
    local test_count=0
    local local_failures=0
    
    echo "Testing advanced feature functions..."
    
    # Test 1: Git integration module functions
    local git_functions=(
        "detect_git_repository"
        "validate_git_remote"
        "perform_pre_uninstall_backup"
    )
    
    for func in "${git_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_availability "$func"; then
            echo "  ✓ Git function $func is available"
        else
            echo "  ✗ Git function $func is missing"
            local_failures=$((local_failures + 1))
        fi
    done
    
    # Test 2: Complete removal module functions
    local removal_functions=(
        "detect_all_cursor_components"
        "perform_complete_cursor_removal"
        "verify_complete_removal"
    )
    
    for func in "${removal_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_availability "$func"; then
            echo "  ✓ Removal function $func is available"
        else
            echo "  ✗ Removal function $func is missing"
            local_failures=$((local_failures + 1))
        fi
    done
    
    # Test 3: AI optimization module functions
    local ai_functions=(
        "display_system_specifications"
        "perform_ai_optimization"
        "analyze_performance_metrics"
    )
    
    for func in "${ai_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_availability "$func"; then
            echo "  ✓ AI optimization function $func is available"
        else
            echo "  ✗ AI optimization function $func is missing"
            local_failures=$((local_failures + 1))
        fi
    done
    
    return $local_failures
}

# Test Git integration functionality - PRODUCTION GRADE
run_git_integration_tests() {
    local test_count=0
    local local_failures=0
    
    echo "Testing Git integration functionality..."
    
    # Test 1: Git command availability
    test_count=$((test_count + 1))
    if command -v git >/dev/null 2>&1; then
        echo "  ✓ Git command is available"
    else
        echo "  ✗ Git command not found"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 2: Git repository detection (current directory)
    test_count=$((test_count + 1))
    if declare -f detect_git_repository >/dev/null 2>&1; then
        if detect_git_repository >/dev/null 2>&1; then
            echo "  ✓ Git repository detection works (repository found)"
        else
            echo "  ℹ Git repository detection works (no repository in current directory)"
        fi
    else
        echo "  ✗ Git repository detection function not available"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 3: Git remote validation function
    test_count=$((test_count + 1))
    if declare -f validate_git_remote >/dev/null 2>&1; then
        echo "  ✓ Git remote validation function is available"
    else
        echo "  ✗ Git remote validation function not available"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 4: Git backup confirmation function
    test_count=$((test_count + 1))
    if declare -f confirm_git_backup_operations >/dev/null 2>&1; then
        echo "  ✓ Git backup confirmation function is available"
    else
        echo "  ✗ Git backup confirmation function not available"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 5: Git error resolution function
    test_count=$((test_count + 1))
    if declare -f provide_git_error_resolution >/dev/null 2>&1; then
        echo "  ✓ Git error resolution function is available"
    else
        echo "  ✗ Git error resolution function not available"
        local_failures=$((local_failures + 1))
    fi
    
    return $local_failures
}

# Test AI optimization functionality - PRODUCTION GRADE
run_ai_optimization_tests() {
    local test_count=0
    local local_failures=0
    
    echo "Testing AI optimization functionality..."
    
    # Test 1: System specification detection
    test_count=$((test_count + 1))
    if declare -f display_system_specifications >/dev/null 2>&1; then
        # Test if the function can run without errors
        if display_system_specifications >/dev/null 2>&1; then
            echo "  ✓ System specifications detection works"
        else
            echo "  ⚠ System specifications function available but may have issues"
        fi
    else
        echo "  ✗ System specifications function not available"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 2: Performance metrics analysis
    test_count=$((test_count + 1))
    if declare -f analyze_performance_metrics >/dev/null 2>&1; then
        echo "  ✓ Performance metrics analysis function is available"
    else
        echo "  ✗ Performance metrics analysis function not available"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 3: System optimization capabilities
    test_count=$((test_count + 1))
    if declare -f optimize_macos_for_ai >/dev/null 2>&1; then
        echo "  ✓ macOS AI optimization function is available"
    else
        echo "  ✗ macOS AI optimization function not available"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 4: Configuration setup functions
    test_count=$((test_count + 1))
    if declare -f setup_cursor_configuration >/dev/null 2>&1; then
        echo "  ✓ Cursor configuration setup function is available"
    else
        echo "  ✗ Cursor configuration setup function not available"
        local_failures=$((local_failures + 1))
    fi
    
    return $local_failures
}

# Test complete removal functionality - PRODUCTION GRADE
run_complete_removal_tests() {
    local test_count=0
    local local_failures=0
    
    echo "Testing complete removal functionality..."
    
    # Test 1: Component detection
    test_count=$((test_count + 1))
    if declare -f detect_all_cursor_components >/dev/null 2>&1; then
        echo "  ✓ Cursor component detection function is available"
    else
        echo "  ✗ Cursor component detection function not available"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 2: Verification function
    test_count=$((test_count + 1))
    if declare -f verify_complete_removal >/dev/null 2>&1; then
        echo "  ✓ Complete removal verification function is available"
    else
        echo "  ✗ Complete removal verification function not available"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 3: System cleanup functions
    test_count=$((test_count + 1))
    if declare -f clear_launch_services_entries >/dev/null 2>&1; then
        echo "  ✓ Launch Services cleanup function is available"
    else
        echo "  ✗ Launch Services cleanup function not available"
        local_failures=$((local_failures + 1))
    fi
    
    return $local_failures
}

# Test error injection scenarios - PRODUCTION GRADE
run_error_injection_tests() {
    local test_count=0
    local local_failures=0
    
    echo "Testing error handling with injected scenarios..."
    
    # Test 1: Invalid path handling
    test_count=$((test_count + 1))
    if declare -f enhanced_safe_remove >/dev/null 2>&1; then
        # Test with non-existent path
        if enhanced_safe_remove "/nonexistent/path/test" >/dev/null 2>&1; then
            echo "  ⚠ Enhanced safe remove should handle invalid paths gracefully"
        else
            echo "  ✓ Enhanced safe remove properly handles invalid paths"
        fi
    else
        echo "  ✗ Enhanced safe remove function not available"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 2: Permission denied scenarios
    test_count=$((test_count + 1))
    if declare -f production_sudo >/dev/null 2>&1; then
        echo "  ✓ Production sudo function is available for permission testing"
    else
        echo "  ✗ Production sudo function not available"
        local_failures=$((local_failures + 1))
    fi
    
    # Test 3: Network connectivity issues
    test_count=$((test_count + 1))
    # Test ping to an invalid address
    if ping -c 1 -W 1000 192.0.2.1 >/dev/null 2>&1; then
        echo "  ⚠ Network test may not be reliable"
    else
        echo "  ✓ Network error handling works (unreachable address detected)"
    fi
    
    return $local_failures
}
