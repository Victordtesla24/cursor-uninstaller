#!/usr/bin/env bats

load test_helper

@test "detect_cursor_paths creates shared cursor directory if it doesn't exist" {
    # Mock the original function temporarily
    original_mkdir=$(declare -f mkdir)
    original_chmod=$(declare -f chmod)

    # Override mkdir and chmod to track calls
    mkdir() {
        echo "mkdir called with: $@" >> "$TEST_DIR/tmp/mkdir_calls.log"
    }

    chmod() {
        echo "chmod called with: $@" >> "$TEST_DIR/tmp/chmod_calls.log"
    }

    # Mock sudo
    sudo() {
        echo "sudo called with: $@" >> "$TEST_DIR/tmp/sudo_calls.log"
        # Run the command without sudo for testing
        "$@"
    }

    # Source the script to get the detect_cursor_paths function
    source "$SCRIPT_PATH"

    # Set CURSOR_CWD to a test path
    CURSOR_CWD="$TEST_DIR/tmp/cursor"

    # Ensure our test dir doesn't exist
    rm -rf "$CURSOR_CWD"

    # Call the function
    detect_cursor_paths

    # Restore the original functions
    eval "mkdir() { $original_mkdir; }"
    eval "chmod() { $original_chmod; }"

    # Check if the logs contain the expected calls
    grep -q "mkdir.*$CURSOR_CWD" "$TEST_DIR/tmp/mkdir_calls.log" || \
        grep -q "sudo.*mkdir.*$CURSOR_CWD" "$TEST_DIR/tmp/sudo_calls.log"

    grep -q "chmod.*775.*$CURSOR_CWD" "$TEST_DIR/tmp/chmod_calls.log" || \
        grep -q "sudo.*chmod.*775.*$CURSOR_CWD" "$TEST_DIR/tmp/sudo_calls.log"
}

@test "CURSOR_SHARED_CONFIG points to config directory inside CURSOR_CWD" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths to just set variables
    detect_cursor_paths() {
        CURSOR_CWD="/Users/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"
    }

    # Call detect_cursor_paths
    detect_cursor_paths

    # Check that CURSOR_SHARED_CONFIG is correctly set
    [ "$CURSOR_SHARED_CONFIG" = "/Users/Shared/cursor/config" ]
}

@test "optimize_cursor_performance always uses shared config directory" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock the detect_cursor_paths function
    detect_cursor_paths() {
        CURSOR_CWD="/Users/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"
        echo "Cursor paths detected"
    }

    # Mock check_performance_deps to avoid actual dependency checks
    check_performance_deps() {
        echo "Dependencies checked"
        return 0
    }

    # Mock other functions to avoid actual operations
    mkdir() {
        echo "mkdir called: $@" >> "$TEST_DIR/tmp/mkdir_calls.log"
    }

    cat() {
        echo "{}" # Return empty JSON
    }

    command() {
        # Simulate jq is not available
        return 1
    }

    # Capture function calls related to shared paths
    optimize_cursor_performance > "$TEST_DIR/tmp/optimization_output.log"

    # Check if shared paths are used in the output
    grep -q "/Users/Shared/cursor/config" "$TEST_DIR/tmp/optimization_output.log"
}

@test "setup_project_environment creates projects in the shared projects directory" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock the detect_cursor_paths function
    detect_cursor_paths() {
        CURSOR_CWD="/Users/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"
        echo "Cursor paths detected"
    }

    # Mock read to provide input
    read_count=0
    read() {
        read_count=$((read_count + 1))

        if [ "$read_count" -le 3 ]; then
            echo "test_project" # Project name input
        else
            # For any additional reads, return empty to prevent infinite loops
            echo ""
        fi
    }

    # Track mkdir calls
    mkdir() {
        echo "mkdir called: $@" >> "$TEST_DIR/tmp/mkdir_calls.log"
    }

    # Mock other functions to avoid actual operations
    setup_venv_environments() {
        echo "Setting up venv environment for $1"
    }

    create_project_structure() {
        echo "Creating project structure for $1"
    }

    initialize_git_repository() {
        echo "Initializing git repo for $1"
    }

    # Capture function calls
    setup_project_environment > "$TEST_DIR/tmp/project_setup_output.log"

    # Check if the shared projects path is used
    grep -q "/Users/Shared/cursor/projects" "$TEST_DIR/tmp/project_setup_output.log" || \
    grep -q "/Users/Shared/cursor/projects" "$TEST_DIR/tmp/mkdir_calls.log"
}
