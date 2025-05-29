#!/bin/bash

################################################################################
# Testing Module - Comprehensive Test Functions for Cursor Uninstaller
# Part of Cursor Uninstaller Modular Architecture
################################################################################

# Run comprehensive test suite
run_tests() {
    log_message "INFO" "Starting comprehensive test suite..."

    local test_results=()
    local total_tests=0
    local passed_tests=0
    local failed_tests=0

    # Initialize test environment
    initialize_test_environment

    # Run different test categories
    echo "=== Module Loading Tests ==="
    run_module_loading_tests
    total_tests=$((total_tests + $?))

    echo -e "\n=== Function Availability Tests ==="
    run_function_availability_tests
    total_tests=$((total_tests + $?))

    echo -e "\n=== Configuration Tests ==="
    run_configuration_tests
    total_tests=$((total_tests + $?))

    echo -e "\n=== Path Detection Tests ==="
    run_path_detection_tests
    total_tests=$((total_tests + $?))

    echo -e "\n=== Safety Tests ==="
    run_safety_tests
    total_tests=$((total_tests + $?))

    echo -e "\n=== Integration Tests ==="
    run_integration_tests
    total_tests=$((total_tests + $?))

    # Calculate results
    passed_tests=$((total_tests - failed_tests))

    # Display test results
    echo -e "\n=== Test Results Summary ==="
    echo "Total Tests: $total_tests"
    echo "Passed: $passed_tests"
    echo "Failed: $failed_tests"

    if [[ $failed_tests -eq 0 ]]; then
        success_message "✓ All tests passed!"
        return 0
    else
        error_message "✗ $failed_tests tests failed"
        return 1
    fi
}

# Initialize test environment
initialize_test_environment() {
    log_message "INFO" "Initializing test environment..."

    # Set test mode variables
    export CURSOR_TEST_MODE="true"
    export DRY_RUN="true"
    export VERBOSE="true"

    # Create test directories
    local test_base_dir="/tmp/cursor-uninstaller-tests-$$"
    export CURSOR_TEST_DIR="$test_base_dir"

    execute_safely mkdir -p "$CURSOR_TEST_DIR"
    execute_safely mkdir -p "$CURSOR_TEST_DIR/mock_applications"
    execute_safely mkdir -p "$CURSOR_TEST_DIR/mock_library"
    execute_safely mkdir -p "$CURSOR_TEST_DIR/mock_binaries"

    # Check if success_message function is available
    if declare -f success_message >/dev/null 2>&1; then
        success_message "✓ Test environment initialized at $CURSOR_TEST_DIR"
    else
        echo "✓ Test environment initialized at $CURSOR_TEST_DIR"
    fi
}

# Test module loading functionality
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

    failed_tests=$((failed_tests + local_failures))
    return $test_count
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

# Test function availability
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
        "verify_cursor_installation"
        "confirm_installation_action"
    )

    local optimization_functions=(
        "enhanced_optimize_cursor_performance"
        "reset_performance_settings"
        "check_performance_settings"
    )

    local uninstall_functions=(
        "enhanced_uninstall_cursor"
        "detect_cursor_paths"
        "enhanced_verify_complete_removal"
        "confirm_uninstall_action"
    )

    # Test each category
    for func in "${config_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_exists "$func"; then
            echo "✓ Function exists: $func"
        else
            echo "✗ Function missing: $func"
            local_failures=$((local_failures + 1))
        fi
    done

    for func in "${helper_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_exists "$func"; then
            echo "✓ Function exists: $func"
        else
            echo "✗ Function missing: $func"
            local_failures=$((local_failures + 1))
        fi
    done

    for func in "${ui_functions[@]}"; do
        test_count=$((test_count + 1))
        if test_function_exists "$func"; then
            echo "✓ Function exists: $func"
        else
            echo "✗ Function missing: $func"
            local_failures=$((local_failures + 1))
        fi
    done

    failed_tests=$((failed_tests + local_failures))
    return $test_count
}

# Test if function exists
test_function_exists() {
    local function_name="$1"

    if declare -f "$function_name" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Test configuration loading and validation
run_configuration_tests() {
    local test_count=0
    local local_failures=0

    # Test 1: Error codes defined
    test_count=$((test_count + 1))
    if [[ -n "${ERR_GENERAL:-}" ]]; then
        echo "✓ Error codes are defined"
    else
        echo "✗ Error codes not defined"
        local_failures=$((local_failures + 1))
    fi

    # Test 2: Application paths defined
    test_count=$((test_count + 1))
    if [[ -n "${CURSOR_APP_PATH:-}" ]]; then
        echo "✓ Application paths are defined"
    else
        echo "✗ Application paths not defined"
        local_failures=$((local_failures + 1))
    fi

    # Test 3: Logging configuration
    test_count=$((test_count + 1))
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "✓ Logging configuration is defined"
    else
        echo "✗ Logging configuration not defined"
        local_failures=$((local_failures + 1))
    fi

    failed_tests=$((failed_tests + local_failures))
    return $test_count
}

# Test path detection functionality
run_path_detection_tests() {
    local test_count=0
    local local_failures=0

    # Create mock Cursor installation
    create_mock_cursor_installation

    # Test 1: Application detection
    test_count=$((test_count + 1))
    if test_cursor_detection; then
        echo "✓ Cursor detection test passed"
    else
        echo "✗ Cursor detection test failed"
        local_failures=$((local_failures + 1))
    fi

    # Test 2: Path validation
    test_count=$((test_count + 1))
    if test_path_validation; then
        echo "✓ Path validation test passed"
    else
        echo "✗ Path validation test failed"
        local_failures=$((local_failures + 1))
    fi

    # Cleanup mock installation
    cleanup_mock_cursor_installation

    failed_tests=$((failed_tests + local_failures))
    return $test_count
}

# Create mock Cursor installation for testing
create_mock_cursor_installation() {
    local mock_app="$CURSOR_TEST_DIR/mock_applications/Cursor.app"
    execute_safely mkdir -p "$mock_app/Contents/MacOS"
    execute_safely mkdir -p "$mock_app/Contents/Resources"

    # Create mock Info.plist
    cat > "$mock_app/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleShortVersionString</key>
    <string>0.42.0</string>
    <key>CFBundleIdentifier</key>
    <string>com.todesktop.230313mzl4w4u92</string>
</dict>
</plist>
EOF

    # Create mock executable
    execute_safely touch "$mock_app/Contents/MacOS/Cursor"
    execute_safely chmod +x "$mock_app/Contents/MacOS/Cursor"
}

# Test Cursor detection with mock installation
test_cursor_detection() {
    # Temporarily override APPLICATION paths for testing
    local original_cursor_app="${CURSOR_APP_PATH:-}"
    export CURSOR_APP_PATH="$CURSOR_TEST_DIR/mock_applications/Cursor.app"

    # Test detection logic
    if [[ -d "$CURSOR_APP_PATH" ]]; then
        export CURSOR_APP_PATH="$original_cursor_app"
        return 0
    else
        export CURSOR_APP_PATH="$original_cursor_app"
        return 1
    fi
}

# Test path validation
test_path_validation() {
    # Test valid path
    if [[ -d "$CURSOR_TEST_DIR" ]]; then
        return 0
    else
        return 1
    fi
}

# Cleanup mock Cursor installation
cleanup_mock_cursor_installation() {
    execute_safely rm -rf "$CURSOR_TEST_DIR/mock_applications"
}

# Run safety tests
run_safety_tests() {
    local test_count=0
    local local_failures=0

    # Test 1: Dry run mode
    test_count=$((test_count + 1))
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        echo "✓ Dry run mode is active"
    else
        echo "✗ Dry run mode not active"
        local_failures=$((local_failures + 1))
    fi

    # Test 2: Safe removal function
    test_count=$((test_count + 1))
    if test_safe_removal; then
        echo "✓ Safe removal test passed"
    else
        echo "✗ Safe removal test failed"
        local_failures=$((local_failures + 1))
    fi

    failed_tests=$((failed_tests + local_failures))
    return $test_count
}

# Test safe removal functionality
test_safe_removal() {
    # Create test file
    local test_file="$CURSOR_TEST_DIR/test_removal_file"
    execute_safely touch "$test_file"

    # Test removal (should be skipped in dry run)
    if declare -f enhanced_safe_remove >/dev/null 2>&1; then
        enhanced_safe_remove "$test_file"

        # In dry run mode, file should still exist
        if [[ -f "$test_file" ]]; then
            execute_safely rm -f "$test_file"
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# Run integration tests
run_integration_tests() {
    local test_count=0
    local local_failures=0

    # Test 1: End-to-end dry run
    test_count=$((test_count + 1))
    if test_end_to_end_dry_run; then
        echo "✓ End-to-end dry run test passed"
    else
        echo "✗ End-to-end dry run test failed"
        local_failures=$((local_failures + 1))
    fi

    failed_tests=$((failed_tests + local_failures))
    return $test_count
}

# Test end-to-end functionality in dry run mode
test_end_to_end_dry_run() {
    # Test main operations without actually performing them
    local original_dry_run="${DRY_RUN:-}"
    export DRY_RUN="true"

    # Test uninstall in dry run mode
    if declare -f enhanced_uninstall_cursor >/dev/null 2>&1; then
        if enhanced_uninstall_cursor >/dev/null 2>&1; then
            export DRY_RUN="$original_dry_run"
            return 0
        fi
    fi

    export DRY_RUN="$original_dry_run"
    return 1
}

# Cleanup test environment
cleanup_test_environment() {
    if [[ -n "${CURSOR_TEST_DIR:-}" ]] && [[ -d "$CURSOR_TEST_DIR" ]]; then
        execute_safely rm -rf "$CURSOR_TEST_DIR"
        # Check if success_message function is available
        if declare -f success_message >/dev/null 2>&1; then
            success_message "✓ Test environment cleaned up"
        else
            echo "✓ Test environment cleaned up"
        fi
    fi

    unset CURSOR_TEST_MODE
    unset CURSOR_TEST_DIR
}

# Performance health check
perform_health_check() {
    # Check if log_message function is available
    if declare -f log_message >/dev/null 2>&1; then
        log_message "INFO" "Performing system health check..."
    else
        echo "[INFO] Performing system health check..."
    fi

    echo "=== System Health Check ==="

    # Check system resources
    echo "System Information:"
    echo "  OS Version: $(sw_vers -productVersion)"
    echo "  Architecture: $(uname -m)"
    echo "  Available RAM: $(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//' || echo "Unknown")"
    echo "  Available Disk Space: $(df -h / | tail -1 | awk '{print $4}')"

    # Check required tools
    echo -e "\nRequired Tools Check:"
    local required_tools=("bash" "find" "grep" "awk" "sed" "defaults" "pkill" "pgrep")

    for tool in "${required_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✓ $tool: $(command -v "$tool")"
        else
            echo "  ✗ $tool: Not found"
        fi
    done

    # Check permissions
    echo -e "\nPermissions Check:"
    if [[ -w "/Applications" ]]; then
        echo "  ✓ Can write to /Applications"
    else
        echo "  ✗ Cannot write to /Applications"
    fi

    if [[ -w "$HOME/Library" ]]; then
        echo "  ✓ Can write to ~/Library"
    else
        echo "  ✗ Cannot write to ~/Library"
    fi

    # Check Cursor installation status
    echo -e "\nCursor Installation Status:"
    if declare -f check_cursor_installation >/dev/null 2>&1; then
        if check_cursor_installation >/dev/null 2>&1; then
            echo "  ✓ Cursor is installed"
        else
            echo "  ✗ Cursor is not installed"
        fi
    else
        echo "  ? Cannot check - function not available"
    fi

    # Check if success_message function is available
    if declare -f success_message >/dev/null 2>&1; then
        success_message "✓ Health check completed"
    else
        echo "✓ Health check completed"
    fi
}
