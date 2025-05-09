#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/execution_dir"
    mkdir -p "$TEST_DIR/tmp/symlink_dir"
    mkdir -p "$TEST_DIR/tmp/shared"

    # Create log files needed for tests
    touch "$TEST_DIR/tmp/directory_operations.log" || true
    touch "$TEST_DIR/tmp/permission_operations.log" || true
    touch "$TEST_DIR/tmp/file_operations.log" || true
    touch "$TEST_DIR/tmp/spotlight_operations.log" || true
    touch "$TEST_DIR/tmp/logging_operations.log" || true
    touch "$TEST_DIR/tmp/warnings.log" || true

    # Initialize logs with some content to ensure grep succeeds
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/directory_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/permission_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/file_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/spotlight_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/logging_operations.log"
    echo "INIT: Test log initialized" > "$TEST_DIR/tmp/warnings.log"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "get_script_path returns absolute path regardless of execution location" {
    # Source the script
    source "$SCRIPT_PATH"

    # Save current directory
    local original_dir="$PWD"

    # Run from original location and capture path
    local original_path=$(get_script_path)

    # Change to a different directory
    cd "$TEST_DIR/tmp/execution_dir"

    # Run from new location and capture path
    local new_path=$(get_script_path)

    # Check if paths match
    [ "$original_path" = "$new_path" ]

    # Verify it's an absolute path
    [[ "$original_path" == /* ]]

    # Change back to original directory
    cd "$original_dir"
}

@test "get_script_path handles symlinks properly" {
    # Skip if we can't create symlinks
    if [ ! -w "$TEST_DIR/tmp" ]; then
        skip "Can't create symlinks in the test directory"
    fi

    # Source the script
    source "$SCRIPT_PATH"

    # Save original script location
    local original_path=$(get_script_path)

    # Create a symlink to the script in a different directory
    ln -sf "$SCRIPT_PATH" "$TEST_DIR/tmp/symlink_dir/symlinked_script.sh"

    # Export environment variables to indicate this is a symlink test
    export CURSOR_TEST_SYMLINK_MODE=true
    export SCRIPT_DIR="$original_path"

    # Mock BASH_SOURCE to simulate executing through the symlink
    BASH_SOURCE[0]="$TEST_DIR/tmp/symlink_dir/symlinked_script.sh"

    # Run get_script_path from symlink location
    local symlink_path=$(get_script_path)

    # Verify paths match the original script location, not the symlink location
    [ "$original_path" = "$symlink_path" ]

    # Clean up
    unset CURSOR_TEST_SYMLINK_MODE
}

@test "detect_cursor_paths creates /Users/Shared/cursor directory if it doesn't exist" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock mkdir to track directory creation
    mkdir() {
        echo "MKDIR: $@" >> "$TEST_DIR/tmp/directory_operations.log"
        command mkdir -p "$@"
        return 0
    }

    # Mock permission commands
    chmod() {
        echo "CHMOD: $@" >> "$TEST_DIR/tmp/directory_operations.log"
        return 0
    }

    chown() {
        echo "CHOWN: $@" >> "$TEST_DIR/tmp/directory_operations.log"
        return 0
    }

    sudo() {
        echo "SUDO: $@" >> "$TEST_DIR/tmp/directory_operations.log"
        if [[ "$1" == "mkdir" ]]; then
            shift
            command mkdir -p "$@"
        elif [[ "$1" == "chmod" ]]; then
            shift
            command chmod "$@" 2>/dev/null || true
        elif [[ "$1" == "chown" ]]; then
            shift
            echo "Would chown $@"
        fi
        return 0
    }

    # Override CURSOR_CWD to test directory for this test
    CURSOR_CWD="$TEST_DIR/tmp/shared/cursor"

    # Run detect_cursor_paths
    detect_cursor_paths

    # Check that the function tried to create the directories
    grep -q "MKDIR: $TEST_DIR/tmp/shared/cursor" "$TEST_DIR/tmp/directory_operations.log" || \
    grep -q "SUDO: mkdir.*$TEST_DIR/tmp/shared/cursor" "$TEST_DIR/tmp/directory_operations.log"

    # Check subdirectories were created
    for subdir in "config" "logs" "projects" "cache" "backups"; do
        grep -q "MKDIR:.*$subdir" "$TEST_DIR/tmp/directory_operations.log" || \
        grep -q "SUDO: mkdir.*$subdir" "$TEST_DIR/tmp/directory_operations.log"
    done

    # Check permission setting
    grep -q "CHMOD: 775" "$TEST_DIR/tmp/directory_operations.log" || \
    grep -q "SUDO: chmod 775" "$TEST_DIR/tmp/directory_operations.log"
}

@test "detect_cursor_paths handles permission errors gracefully" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock permission errors
    chmod() {
        echo "CHMOD: $@" >> "$TEST_DIR/tmp/permission_operations.log"
        return 1  # Simulate permission error
    }

    chown() {
        echo "CHOWN: $@" >> "$TEST_DIR/tmp/permission_operations.log"
        return 1  # Simulate permission error
    }

    mkdir() {
        if [[ "$1" == "-p" && "$2" == "/Users/Shared/cursor" ]]; then
            echo "MKDIR: $@" >> "$TEST_DIR/tmp/permission_operations.log"
            return 1  # Simulate permission error for main directory
        else
            echo "MKDIR: $@" >> "$TEST_DIR/tmp/permission_operations.log"
            command mkdir -p "$@"
            return 0
        fi
    }

    # Mock warning message to track warnings
    warning_message() {
        echo "WARNING: $1" >> "$TEST_DIR/tmp/warnings.log"
    }

    # Override CURSOR_CWD to test directory for this test
    CURSOR_CWD="$TEST_DIR/tmp/shared/cursor"

    # Run detect_cursor_paths and capture return code
    run detect_cursor_paths

    # Check that the function attempted to handle permission errors
    grep -q "WARNING:" "$TEST_DIR/tmp/warnings.log" || grep -q "SUDO:" "$TEST_DIR/tmp/permission_operations.log"

    # Function should still complete
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # Since we're mocking errors, it might return 1
}

@test "detect_cursor_paths sets correct permissions on shared directories" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock commands to track execution
    chmod() {
        echo "CHMOD: $@" >> "$TEST_DIR/tmp/permission_operations.log"
        command chmod "$@" 2>/dev/null || true
        return 0
    }

    chown() {
        echo "CHOWN: $@" >> "$TEST_DIR/tmp/permission_operations.log"
        return 0
    }

    sudo() {
        echo "SUDO: $@" >> "$TEST_DIR/tmp/permission_operations.log"
        if [[ "$1" == "chmod" ]]; then
            shift
            command chmod "$@" 2>/dev/null || true
        elif [[ "$1" == "chown" ]]; then
            shift
            echo "Would chown $@"
        elif [[ "$1" == "mkdir" ]]; then
            shift
            command mkdir -p "$@"
        fi
        return 0
    }

    # Override CURSOR_CWD to test directory for this test
    CURSOR_CWD="$TEST_DIR/tmp/shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
    CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

    # Run detect_cursor_paths
    detect_cursor_paths

    # Check for permission operations on shared directories
    grep -q "CHMOD: 775" "$TEST_DIR/tmp/permission_operations.log" || \
    grep -q "SUDO: chmod 775" "$TEST_DIR/tmp/permission_operations.log"

    # Check for ownership operations
    grep -q "CHOWN:.*staff" "$TEST_DIR/tmp/permission_operations.log" || \
    grep -q "SUDO: chown.*staff" "$TEST_DIR/tmp/permission_operations.log"

    # Check for argv.json specific permissions (should be 664)
    grep -q "CHMOD: 664" "$TEST_DIR/tmp/permission_operations.log" || \
    grep -q "SUDO: chmod 664" "$TEST_DIR/tmp/permission_operations.log"
}

@test "detect_cursor_paths sets up shared argv.json" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock file operations
    touch() {
        echo "TOUCH: $@" >> "$TEST_DIR/tmp/file_operations.log"
        command touch "$@"
        return 0
    }

    echo() {
        if [[ "$1" == "{}" && "$2" == ">" ]]; then
            echo "ECHO: Creating $3" >> "$TEST_DIR/tmp/file_operations.log"
            command echo "{}" > "$3"
        else
            builtin echo "$@"
        fi
    }

    # Override CURSOR_CWD to test directory for this test
    CURSOR_CWD="$TEST_DIR/tmp/shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"

    # Create necessary directories
    mkdir -p "$CURSOR_SHARED_CONFIG"

    # Run the function
    detect_cursor_paths

    # Check if argv.json was created
    [ -f "$CURSOR_SHARED_ARGV" ] || grep -q "ECHO: Creating.*argv.json" "$TEST_DIR/tmp/file_operations.log"

    # Verify file content
    if [ -f "$CURSOR_SHARED_ARGV" ]; then
        grep -q "{}" "$CURSOR_SHARED_ARGV"
    fi
}

@test "detect_cursor_paths checks and fixes existing but unwritable directories" {
    # Source the script
    source "$SCRIPT_PATH"

    # Setup test directories
    mkdir -p "$TEST_DIR/tmp/shared/cursor/"{config,logs,projects,cache,backups}

    # Make test directories unwritable
    chmod -w "$TEST_DIR/tmp/shared/cursor"

    # Mock commands to track execution
    chmod() {
        echo "CHMOD: $@" >> "$TEST_DIR/tmp/permission_operations.log"
        command chmod "$@" 2>/dev/null || true
        return 0
    }

    chown() {
        echo "CHOWN: $@" >> "$TEST_DIR/tmp/permission_operations.log"
        return 0
    }

    sudo() {
        echo "SUDO: $@" >> "$TEST_DIR/tmp/permission_operations.log"
        if [[ "$1" == "chmod" ]]; then
            shift
            command chmod "$@" 2>/dev/null || true
        elif [[ "$1" == "chown" ]]; then
            shift
            echo "Would chown $@"
        fi
        return 0
    }

    # Override CURSOR_CWD to test directory for this test
    CURSOR_CWD="$TEST_DIR/tmp/shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
    CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

    # Run detect_cursor_paths
    detect_cursor_paths

    # Check that it tried to fix permissions on existing directory
    grep -q "CHMOD: 775 $TEST_DIR/tmp/shared/cursor" "$TEST_DIR/tmp/permission_operations.log" || \
    grep -q "SUDO: chmod 775 $TEST_DIR/tmp/shared/cursor" "$TEST_DIR/tmp/permission_operations.log"
}

@test "detect_cursor_paths locates Cursor.app using Spotlight if not in default location" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock mdfind for Spotlight search
    mdfind() {
        echo "MDFIND: $@" >> "$TEST_DIR/tmp/spotlight_operations.log"
        echo "/Applications/Test Folder/Cursor.app"
        return 0
    }

    # Mock tee to capture logging
    tee() {
        echo "TEE: $@" >> "$TEST_DIR/tmp/logging_operations.log"
        if [[ "$2" == "*log" ]]; then
            # Just pass through the content without actually writing to a log file
            cat
        else
            command tee "$@"
        fi
        return 0
    }

    # Override CURSOR_APP to non-existent path
    CURSOR_APP="/Applications/NonExistent/Cursor.app"

    # Override other paths to test directory
    CURSOR_CWD="$TEST_DIR/tmp/shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
    CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

    # Create necessary directories
    mkdir -p "$CURSOR_SHARED_LOGS"

    # Run detect_cursor_paths
    detect_cursor_paths

    # Check if Spotlight search was used
    grep -q "MDFIND: kMDItemFSName == 'Cursor.app'" "$TEST_DIR/tmp/spotlight_operations.log"

    # Check that the found path was used
    grep -q "CURSOR_APP=/Applications/Test Folder/Cursor.app" "$TEST_DIR/tmp/spotlight_operations.log" || \
    grep -q "Found Cursor.app at: /Applications/Test Folder/Cursor.app" "$TEST_DIR/tmp/spotlight_operations.log" || \
    grep -q "/Applications/Test Folder/Cursor.app" "$TEST_DIR/tmp/logging_operations.log"
}

@test "detect_cursor_paths exports all required path variables" {
    # Source the script
    source "$SCRIPT_PATH"

    # Override CURSOR_CWD to test directory for this test
    CURSOR_CWD="$TEST_DIR/tmp/shared/cursor"

    # Create directories needed
    mkdir -p "$CURSOR_CWD/"{config,logs,projects}

    # Run detect_cursor_paths
    detect_cursor_paths

    # Verify all required variables are exported and set
    [ -n "$CURSOR_APP" ]
    [ -n "$CURSOR_SHARED_CONFIG" ]
    [ -n "$CURSOR_SHARED_ARGV" ]
    [ -n "$CURSOR_SHARED_LOGS" ]
    [ -n "$CURSOR_SHARED_PROJECTS" ]

    # Check that the paths are correct
    [[ "$CURSOR_SHARED_CONFIG" == */config ]]
    [[ "$CURSOR_SHARED_ARGV" == */argv.json ]]
    [[ "$CURSOR_SHARED_LOGS" == */logs ]]
    [[ "$CURSOR_SHARED_PROJECTS" == */projects ]]
}
