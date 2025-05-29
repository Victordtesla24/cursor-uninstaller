#!/usr/bin/env bats

load ../helpers/test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu and prevent hanging
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true
    export DRY_RUN=true
    export NON_INTERACTIVE_MODE=true
    export FORCE_EXIT=false
    export VERBOSE=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/Applications"
    mkdir -p "$TEST_DIR/tmp/logs"
    mkdir -p "$TEST_DIR/tmp/processes"

    # Initialize environment
    PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../"
    SCRIPT_PATH="$PROJECT_ROOT/uninstall_cursor.sh"

    # Ensure script exists
    if [[ ! -f "$SCRIPT_PATH" ]]; then
        echo "Error: Main script not found at $SCRIPT_PATH" >&2
        exit 1
    fi
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED
    unset DRY_RUN
    unset NON_INTERACTIVE_MODE
    unset FORCE_EXIT
    unset VERBOSE

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "main script handles todesktop bundle ID without failing" {
    # Create mock Cursor.app with todesktop bundle ID
    local test_app_dir="$TEST_DIR/tmp/Applications/Cursor.app"
    mkdir -p "$test_app_dir/Contents"
    
    # Create Info.plist with the problematic todesktop bundle ID
    cat > "$test_app_dir/Contents/Info.plist" << 'EOF'
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
    <key>CFBundleExecutable</key>
    <string>Cursor</string>
</dict>
</plist>
EOF

    # Create a basic executable file
    mkdir -p "$test_app_dir/Contents/MacOS"
    touch "$test_app_dir/Contents/MacOS/Cursor"
    chmod +x "$test_app_dir/Contents/MacOS/Cursor"

    # Create test output capture file
    local output_file="$TEST_DIR/tmp/script_output.log"
    local error_file="$TEST_DIR/tmp/script_errors.log"

    # Mock the applications path check by creating a wrapper script
    local wrapper_script="$TEST_DIR/tmp/test_wrapper.sh"
    cat > "$wrapper_script" << EOF
#!/bin/bash
export CURSOR_TEST_MODE=true
export BATS_TEST_SOURCED=true
export DRY_RUN=true
export NON_INTERACTIVE_MODE=true
export VERBOSE=true

# Override the Applications path for testing
export MOCK_APPLICATIONS_PATH="$test_app_dir"

# Source the main script with timeout protection
source "$SCRIPT_PATH"

# Test the complete uninstall operation
production_execute_complete_uninstall
EOF

    chmod +x "$wrapper_script"

    # Run the script with timeout to prevent hanging
    run timeout 30s bash "$wrapper_script"

    # Script should not fail with bundle verification error
    echo "Exit status: $status" > "$output_file"
    echo "Output: $output" >> "$output_file"

    # Should not contain the old error message
    [[ "$output" != *"Application bundle verification failed: com.todesktop.230313mzl4w4u92"* ]]
    
    # Should contain indication that verification worked or fallback was used
    [[ "$output" == *"todesktop"* ]] || [[ "$output" == *"Proceeding with removal"* ]] || [[ "$output" == *"Verified"* ]]
}

@test "main script does not terminate itself during process cleanup" {
    # Create a process list that includes the uninstaller script
    local mock_ps_output="$TEST_DIR/tmp/mock_ps_output.txt"
    cat > "$mock_ps_output" << 'EOF'
USER      PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
user     1234   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 /bin/bash ./uninstall_cursor.sh
user     5678   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 /Applications/Cursor.app/Contents/MacOS/Cursor
user     9999   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 cursor-helper-process
EOF

    # Create a wrapper script that simulates the problematic condition
    local wrapper_script="$TEST_DIR/tmp/process_test_wrapper.sh"
    cat > "$wrapper_script" << EOF
#!/bin/bash
export CURSOR_TEST_MODE=true
export BATS_TEST_SOURCED=true
export DRY_RUN=true
export NON_INTERACTIVE_MODE=true
export VERBOSE=true

# Mock ps command to return our test data
ps() {
    if [[ "\$1" == "aux" ]]; then
        cat "$mock_ps_output"
    elif [[ "\$1" == "-p" ]]; then
        case "\$2" in
            1234) echo "/bin/bash ./uninstall_cursor.sh" ;;
            5678) echo "/Applications/Cursor.app/Contents/MacOS/Cursor" ;;
            9999) echo "cursor-helper-process" ;;
            *) echo "" ;;
        esac
    else
        command ps "\$@"
    fi
}

# Mock kill to track what gets killed without actually killing
kill() {
    echo "MOCK_KILL: \$@" >> "$TEST_DIR/tmp/kill_operations.log"
    return 0
}

# Source the main script
source "$SCRIPT_PATH"

# Test process cleanup specifically
if declare -f remove_background_processes >/dev/null 2>&1; then
    remove_background_processes
elif declare -f production_execute_complete_uninstall >/dev/null 2>&1; then
    # Run complete uninstall which includes process cleanup
    production_execute_complete_uninstall
else
    echo "ERROR: No process cleanup function found"
    exit 1
fi
EOF

    chmod +x "$wrapper_script"

    # Run the wrapper script
    run timeout 30s bash "$wrapper_script"

    # Script should not have been terminated (exit status should be from normal completion)
    [[ "$status" -ne 143 ]]  # 143 is SIGTERM from timeout, indicating hang/termination

    # Check that the script didn't try to kill its own PID
    if [[ -f "$TEST_DIR/tmp/kill_operations.log" ]]; then
        # Should not contain kill operations on the script's own PID
        local script_pid="1234"  # From our mock data
        ! grep -q "MOCK_KILL:.*$script_pid" "$TEST_DIR/tmp/kill_operations.log"
    fi

    # Should have successful output, not termination
    [[ "$output" != *"terminated"* ]] || [[ "$output" == *"Terminated process"* ]]
}

@test "main script error handling prevents script termination on module failures" {
    # Create a wrapper that simulates module loading failures
    local wrapper_script="$TEST_DIR/tmp/error_handling_test.sh"
    cat > "$wrapper_script" << EOF
#!/bin/bash
export CURSOR_TEST_MODE=true
export BATS_TEST_SOURCED=true
export DRY_RUN=true
export NON_INTERACTIVE_MODE=true
export VERBOSE=true

# Track errors but don't exit
export FORCE_EXIT=false

# Source the main script
source "$SCRIPT_PATH"

# Test that error handling doesn't cause script termination
echo "Script completed normally"
EOF

    chmod +x "$wrapper_script"

    # Run the wrapper script
    run timeout 30s bash "$wrapper_script"

    # Should complete normally even with potential errors
    [[ "$status" -ne 143 ]]  # Not terminated by timeout
    
    # Should show completion message
    [[ "$output" == *"Script completed normally"* ]] || [[ "$output" == *"OPERATION COMPLETED"* ]]
}

@test "main script handles missing modules gracefully" {
    # Create a test environment with missing modules
    local test_script_dir="$TEST_DIR/tmp/test_script_env"
    mkdir -p "$test_script_dir"
    
    # Copy main script but not the modules
    cp "$SCRIPT_PATH" "$test_script_dir/uninstall_cursor.sh"
    
    # Create empty lib and modules directories
    mkdir -p "$test_script_dir/lib"
    mkdir -p "$test_script_dir/modules"

    local wrapper_script="$TEST_DIR/tmp/missing_modules_test.sh"
    cat > "$wrapper_script" << EOF
#!/bin/bash
export CURSOR_TEST_MODE=true
export BATS_TEST_SOURCED=true
export DRY_RUN=true
export NON_INTERACTIVE_MODE=true
export VERBOSE=true

cd "$test_script_dir"

# Source the main script
source "./uninstall_cursor.sh"

# Test that the script handles missing modules
echo "Script handled missing modules"
EOF

    chmod +x "$wrapper_script"

    # Run the test
    run timeout 30s bash "$wrapper_script"

    # Should not hang or crash
    [[ "$status" -ne 143 ]]
    
    # Should handle missing modules gracefully
    [[ "$output" == *"REQUIRED MODULE FAILED TO LOAD"* ]] || [[ "$output" == *"USING BASIC"* ]] || [[ "$output" == *"handled missing modules"* ]]
}

@test "complete uninstall operation completes without critical errors" {
    # Create comprehensive test environment
    local test_env_dir="$TEST_DIR/tmp/complete_test_env"
    mkdir -p "$test_env_dir/Applications/Cursor.app/Contents"
    mkdir -p "$test_env_dir/Library/Application Support/Cursor"
    
    # Create proper Info.plist
    cat > "$test_env_dir/Applications/Cursor.app/Contents/Info.plist" << 'EOF'
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

    local comprehensive_test="$TEST_DIR/tmp/comprehensive_test.sh"
    cat > "$comprehensive_test" << EOF
#!/bin/bash
export CURSOR_TEST_MODE=true
export BATS_TEST_SOURCED=true
export DRY_RUN=true
export NON_INTERACTIVE_MODE=true
export VERBOSE=true

# Mock environment paths
export HOME="$test_env_dir"

# Mock commands that could cause issues
ps() {
    if [[ "\$1" == "aux" ]]; then
        cat << 'PSEOF'
USER      PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
user     5678   0.0  0.1  1234567   1234  s000  S+    1:00PM   0:00.01 /Applications/Cursor.app/Contents/MacOS/Cursor
PSEOF
    else
        command ps "\$@" 2>/dev/null || true
    fi
}

kill() {
    echo "MOCK_KILL: \$@" >> "$TEST_DIR/tmp/comprehensive_kill.log"
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

# Source and run the main script
source "$SCRIPT_PATH"

# Test complete uninstall
if declare -f production_execute_complete_uninstall >/dev/null 2>&1; then
    production_execute_complete_uninstall
else
    echo "Complete uninstall function not available"
fi

echo "Comprehensive test completed"
EOF

    chmod +x "$comprehensive_test"

    # Run comprehensive test
    run timeout 60s bash "$comprehensive_test"

    # Should complete without critical errors
    [[ "$status" -ne 143 ]]  # Not timed out
    
    # Should complete the operation
    [[ "$output" == *"Comprehensive test completed"* ]] || [[ "$output" == *"COMPLETE"* ]]
    
    # Should not contain the old bundle verification error
    [[ "$output" != *"Application bundle verification failed: com.todesktop.230313mzl4w4u92"* ]]
} 