#!/usr/bin/env bash

# Find the script's directory
TEST_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_PATH="$TEST_DIR/../uninstall_cursor.sh"

# Ensure we're using the correct script
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: Main script not found at $SCRIPT_PATH" >&2
    exit 1
fi

# Set test mode environment variables - adding multiple flags for redundancy
# CRITICAL FIX: Ensure all test flags are set properly to prevent test suite hang
export CURSOR_TEST_MODE=true
export BATS_TEST_SOURCED=1
export TEST_MODE=true

# Add a debug message to confirm test mode is set
echo "DEBUG: Test mode flags set - CURSOR_TEST_MODE=${CURSOR_TEST_MODE}, BATS_TEST_SOURCED=${BATS_TEST_SOURCED}, TEST_MODE=${TEST_MODE}" >&2

# Set up environment
setup() {
    echo "DEBUG: setup function running. SCRIPT_PATH=$SCRIPT_PATH"
    # Create test directories if they don't exist
    mkdir -p "$TEST_DIR/tmp"

    # Create test log directories and files
    mkdir -p "$TEST_DIR/tmp/logs"
    touch "$TEST_DIR/tmp/directory_operations.log" 2>/dev/null || true
    touch "$TEST_DIR/tmp/permission_operations.log" 2>/dev/null || true
    touch "$TEST_DIR/tmp/file_operations.log" 2>/dev/null || true
    touch "$TEST_DIR/tmp/spotlight_operations.log" 2>/dev/null || true
    touch "$TEST_DIR/tmp/logging_operations.log" 2>/dev/null || true
    touch "$TEST_DIR/tmp/warnings.log" 2>/dev/null || true

    # Add initial content to make sure grepping works
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/directory_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/permission_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/file_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/spotlight_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/logging_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/warnings.log"

    # Ensure the script exists
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "Error: Script not found at: $SCRIPT_PATH" >&2
        return 1
    fi

    # Set environment variables but don't export the functions,
    # as this seems to be causing issues with the test execution
    export BATS_TEST_SOURCED=1

    # Define mock functions for consistent testing
    warning_message() {
        local msg="$1"
        echo "WARNING: $msg" >> "$TEST_DIR/tmp/warnings.log" 2>/dev/null || true
        echo "WARNING: $msg" >&2
        return 0
    }

    mock_sudo() {
        # Just echo the commands instead of running them
        echo "MOCK_SUDO: $@" >> "$TEST_DIR/tmp/directory_operations.log" 2>/dev/null
        echo "MOCK_SUDO: $@" >> "$TEST_DIR/tmp/permission_operations.log" 2>/dev/null
        return 0
    }

    # Define a test-compatible sudo function
    sudo() {
        echo "SUDO: $*" >> "$TEST_DIR/tmp/directory_operations.log" 2>/dev/null || true
        echo "SUDO: $*" >> "$TEST_DIR/tmp/permission_operations.log" 2>/dev/null || true

        # Actually execute some safe commands with sudo
        if [[ "$1" == "mkdir" || "$1" == "chmod" || "$1" == "chown" ]]; then
            command sudo "$@" 2>/dev/null || true
        fi
        return 0
    }

    # Define a mock tee function for tests
    tee() {
        local output_file="$3"
        if [[ "$output_file" == *"mdfind"* ]]; then
            echo "MDFIND: kMDItemFSName == 'Cursor.app'" >> "$TEST_DIR/tmp/spotlight_operations.log" 2>/dev/null || true
        fi
        echo "Mock tee to $output_file"
        return 0
    }
}

# Clean up after tests
teardown() {
    echo "DEBUG: teardown function running"
    # Remove temporary files created during the test
    # but keep the tmp directory itself
    # find "$TEST_DIR/tmp" -mindepth 1 -delete 2>/dev/null || true

    # Unset just the environment variable
    unset BATS_TEST_SOURCED
    unset CURSOR_TEST_MODE

    # Unset any mocks or functions we defined
    unset -f warning_message
    unset -f mock_sudo
    unset -f sudo
    unset -f tee
}

# Function to simulate a clean test environment
create_clean_environment() {
    # Create a test-specific temporary directory
    local tmp_dir="$TEST_DIR/tmp/test_$(date +%s%N)"
    mkdir -p "$tmp_dir"
    echo "$tmp_dir"
}

# Mock function for checking path existence
mock_path_exists() {
    local path="$1"
    # Simulate the path exists
    return 0
}

# This function ensures that we're not actually deleting real files
mock_safe_remove() {
    local path="$1"
    echo "MOCK_SAFE_REMOVE: Would remove $path"
    return 0
}

# This function loads only the function being tested without sourcing the entire script
# It's useful when you want to test a specific function without running the whole script
load_function() {
    local function_name="$1"
    local script="$SCRIPT_PATH"

    # Use grep and sed to extract just the function
    local function_code
    function_code=$(grep -A 1000 "^$function_name\(\)" "$script" | sed -n "/^$function_name\(\)/,/^}/p")

    # Define the function in the current shell
    eval "$function_code"
}
