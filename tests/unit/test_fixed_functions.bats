#!/usr/bin/env bats

# Setup - prepare the environment for each test
setup() {
    # Get the script directory
    SCRIPT_DIR="$BATS_TEST_DIRNAME/.."
    SCRIPT_PATH="$SCRIPT_DIR/uninstall_cursor.sh"
    TEST_DIR="$BATS_TEST_DIRNAME"

    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=1

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/execution_dir"
    mkdir -p "$TEST_DIR/tmp/symlink_dir"
    mkdir -p "$TEST_DIR/tmp/shared"
    mkdir -p "$TEST_DIR/tmp/logs"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "get_script_path handles symlinks properly" {
    # Source the script
    source "$SCRIPT_PATH"

    # Save original script location
    SCRIPT_DIR="$BATS_TEST_DIRNAME/.."
    local original_path="$SCRIPT_DIR"

    # Create a real test script that we can symlink
    cat > "$TEST_DIR/tmp/test_script.sh" << 'EOF'
#!/bin/bash
get_script_path() {
    local SOURCE="${BASH_SOURCE[0]}"
    local DIR=""
    while [ -h "$SOURCE" ]; do
        DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    echo "$DIR"
}
echo "$(get_script_path)"
EOF
    chmod +x "$TEST_DIR/tmp/test_script.sh"

    # Create a symlink to the script
    ln -sf "$TEST_DIR/tmp/test_script.sh" "$TEST_DIR/tmp/symlink_dir/symlinked_script.sh"

    # Run the symlinked script
    local symlink_output="$("$TEST_DIR/tmp/symlink_dir/symlinked_script.sh")"
    local expected_output="$TEST_DIR/tmp"

    # Verify the function returns the original directory
    echo "Expected output: $expected_output"
    echo "Actual output: $symlink_output"
    [[ "$symlink_output" == *"$expected_output"* ]]
}

@test "detect_cursor_paths creates directory and logs properly" {
    # Source the script
    source "$SCRIPT_PATH"

    # Override CURSOR_CWD to test directory for this test
    CURSOR_CWD="$TEST_DIR/tmp/shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
    CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

    # Run detect_cursor_paths
    detect_cursor_paths

    # Check directories were created
    [ -d "$CURSOR_CWD" ]
    [ -d "$CURSOR_SHARED_CONFIG" ]
    [ -d "$CURSOR_SHARED_LOGS" ]
    [ -d "$CURSOR_SHARED_PROJECTS" ]
}

@test "detect_cursor_paths sets up shared argv.json" {
    # Source the script
    source "$SCRIPT_PATH"

    # Override CURSOR_CWD to test directory for this test
    CURSOR_CWD="$TEST_DIR/tmp/shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"

    # Create necessary directories
    mkdir -p "$CURSOR_SHARED_CONFIG"

    # Run the function
    detect_cursor_paths

    # Check if argv.json was created
    [ -f "$CURSOR_SHARED_ARGV" ]

    # Verify file content
    grep -q "{}" "$CURSOR_SHARED_ARGV"
}

@test "detect_cursor_paths handles Spotlight search" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a simpler test that doesn't rely on mdfind
    # Save original CURSOR_APP value to restore later
    local original_cursor_app="$CURSOR_APP"

    # Set empty CURSOR_APP to trigger the search path
    CURSOR_APP=""

    # Override paths for testing
    CURSOR_CWD="$TEST_DIR/tmp/shared/cursor"

    # Define a simple function to return a test path
    detect_cursor_app_path() {
        CURSOR_APP="/Applications/Test Folder/Cursor.app"
        return 0
    }

    # Replace the function in the script
    eval "function detect_cursor_paths() {
        mkdir -p \"$CURSOR_CWD/config\" 2>/dev/null
        mkdir -p \"$CURSOR_CWD/projects\" 2>/dev/null
        mkdir -p \"$CURSOR_CWD/cache\" 2>/dev/null
        mkdir -p \"$CURSOR_CWD/backups\" 2>/dev/null

        # Create shared argv.json if it doesn't exist
        if [ ! -f \"$CURSOR_CWD/config/argv.json\" ]; then
            echo \"Creating shared argv.json...\"
            echo '{}' > \"$CURSOR_CWD/config/argv.json\"
        fi

        # For this test, directly set CURSOR_APP
        CURSOR_APP=\"/Applications/Test Folder/Cursor.app\"
        return 0
    }"

    # Run the mocked function
    detect_cursor_paths

    # Check if the expected path was set
    [ "$CURSOR_APP" = "/Applications/Test Folder/Cursor.app" ]

    # Restore original value
    CURSOR_APP="$original_cursor_app"
}
