#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/Applications/Cursor.app/Contents/MacOS"
    mkdir -p "$TEST_DIR/tmp/Library/Application Support/Cursor"
    mkdir -p "$TEST_DIR/tmp/Library/Caches/Cursor"
    mkdir -p "$TEST_DIR/tmp/Library/Preferences"
    mkdir -p "$TEST_DIR/tmp/Library/Saved Application State/com.cursor.Cursor.savedState"
    mkdir -p "$TEST_DIR/tmp/Library/Logs/Cursor"
    mkdir -p "$TEST_DIR/tmp/Library/WebKit/com.cursor.Cursor"
    mkdir -p "$TEST_DIR/tmp/Library/IndexedDB/com.cursor.Cursor"
    mkdir -p "$TEST_DIR/tmp/Users/Shared/cursor"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "check_cursor_installation identifies installed Cursor" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test application with key components
    touch "$TEST_DIR/tmp/Applications/Cursor.app/Contents/Info.plist"
    touch "$TEST_DIR/tmp/Library/Application Support/Cursor/config.json"
    touch "$TEST_DIR/tmp/Library/Preferences/com.cursor.Cursor.plist"

    # Mock file existence checks to target test directories
    [ () {
        local arg1="$1"
        local arg2="$2"

        # Modify paths to point to our test directories
        if [[ "$arg1" == "-d" && "$arg2" == "$CURSOR_APP" ]]; then
            builtin [ -d "$TEST_DIR/tmp/Applications/Cursor.app" ]
            return $?
        elif [[ "$arg1" == "-d" && "$arg2" == "$CURSOR_SUPPORT" ]]; then
            builtin [ -d "$TEST_DIR/tmp/Library/Application Support/Cursor" ]
            return $?
        elif [[ "$arg1" == "-d" && "$arg2" == "$CURSOR_CACHE" ]]; then
            builtin [ -d "$TEST_DIR/tmp/Library/Caches/Cursor" ]
            return $?
        elif [[ "$arg1" == "-f" && "$arg2" == "$CURSOR_PREFERENCES" ]]; then
            builtin [ -f "$TEST_DIR/tmp/Library/Preferences/com.cursor.Cursor.plist" ]
            return $?
        elif [[ "$arg1" == "-d" ]]; then
            # For other directory checks
            local modified_path=$(echo "$arg2" | sed "s|/|$TEST_DIR/tmp/|")
            builtin [ -d "$modified_path" ]
            return $?
        elif [[ "$arg1" == "-f" ]]; then
            # For other file checks
            local modified_path=$(echo "$arg2" | sed "s|/|$TEST_DIR/tmp/|")
            builtin [ -f "$modified_path" ]
            return $?
        else
            builtin [ "$@" ]
            return $?
        fi
    }

    # Override check_cursor_installation to use test paths
    CURSOR_APP="$TEST_DIR/tmp/Applications/Cursor.app"
    CURSOR_SUPPORT="$TEST_DIR/tmp/Library/Application Support/Cursor"
    CURSOR_CACHE="$TEST_DIR/tmp/Library/Caches/Cursor"
    CURSOR_PREFERENCES="$TEST_DIR/tmp/Library/Preferences/com.cursor.Cursor.plist"
    CURSOR_SAVED_STATE="$TEST_DIR/tmp/Library/Saved Application State/com.cursor.Cursor.savedState"
    CURSOR_LOGS="$TEST_DIR/tmp/Library/Logs/Cursor"
    CURSOR_WEBSTORAGE="$TEST_DIR/tmp/Library/WebKit/com.cursor.Cursor"
    CURSOR_INDEXEDDB="$TEST_DIR/tmp/Library/IndexedDB/com.cursor.Cursor"
    CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"

    # Capture function output
    output=$(check_cursor_installation)

    # Check that it correctly identified the installation
    echo "$output" | grep -q "Cursor.app found in Applications"
    echo "$output" | grep -q "Application Support files found"
    echo "$output" | grep -q "Preferences found"
}

@test "uninstall_cursor removes all cursor-related files" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test files to uninstall
    touch "$TEST_DIR/tmp/Applications/Cursor.app/Contents/Info.plist"
    touch "$TEST_DIR/tmp/Library/Application Support/Cursor/storage.json"
    touch "$TEST_DIR/tmp/Library/Caches/Cursor/Cache"
    touch "$TEST_DIR/tmp/Library/Preferences/com.cursor.Cursor.plist"

    # Mock pkill to track process termination
    pkill() {
        echo "PKILL: $@" >> "$TEST_DIR/tmp/process_operations.log"
        return 0
    }

    # Mock safe_remove to track removal operations
    safe_remove() {
        echo "SAFE_REMOVE: $1" >> "$TEST_DIR/tmp/removal_operations.log"
        return 0
    }

    # Mock safe_remove_symlink to track symlink removal
    safe_remove_symlink() {
        echo "REMOVE_SYMLINK: $1" >> "$TEST_DIR/tmp/removal_operations.log"
        return 0
    }

    # Mock find to track cleanup operations
    find() {
        echo "FIND: $@" >> "$TEST_DIR/tmp/find_operations.log"
        return 0
    }

    # Mock verify_complete_removal
    verify_complete_removal() {
        echo "Verification complete" >> "$TEST_DIR/tmp/verification.log"
        return 0
    }

    # Mock run_task to track progress
    run_task() {
        local description="$1"
        shift
        echo "TASK: $description - $@" >> "$TEST_DIR/tmp/task_operations.log"
        return 0
    }

    # Mock check_sudo
    check_sudo() {
        return 0
    }

    # Run the uninstallation function
    uninstall_cursor

    # Check that it attempted to terminate Cursor processes
    [ -f "$TEST_DIR/tmp/process_operations.log" ]
    grep -q "PKILL: -f \[Cc\]ursor" "$TEST_DIR/tmp/process_operations.log"

    # Check that it attempted to remove Cursor app
    [ -f "$TEST_DIR/tmp/removal_operations.log" ]
    grep -q "SAFE_REMOVE: .*Cursor.app" "$TEST_DIR/tmp/removal_operations.log"

    # Check that it attempted to remove support directories
    grep -q "SAFE_REMOVE: .*Application Support/Cursor" "$TEST_DIR/tmp/removal_operations.log"

    # Check that it attempted to remove preferences
    grep -q "SAFE_REMOVE: .*Preferences/com.cursor.Cursor.plist" "$TEST_DIR/tmp/removal_operations.log"

    # Check that it attempted to remove symlinks
    grep -q "REMOVE_SYMLINK: /usr/local/bin/cursor" "$TEST_DIR/tmp/removal_operations.log"

    # Check that it attempted to remove caches
    grep -q "SAFE_REMOVE: .*Caches/Cursor" "$TEST_DIR/tmp/removal_operations.log"

    # Check that it performed a verification
    [ -f "$TEST_DIR/tmp/verification.log" ]
    grep -q "Verification complete" "$TEST_DIR/tmp/verification.log"
}

@test "clean_up_lingering_files removes leftover files" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock find to track cleanup operations
    find() {
        echo "FIND: $@" >> "$TEST_DIR/tmp/find_operations.log"
        return 0
    }

    # Mock clean_databases
    clean_databases() {
        echo "CLEAN_DATABASES" >> "$TEST_DIR/tmp/database_operations.log"
        return 0
    }

    # Mock run_task to track progress
    run_task() {
        local description="$1"
        shift
        echo "TASK: $description - $@" >> "$TEST_DIR/tmp/task_operations.log"
        return 0
    }

    # Mock verify_complete_removal
    verify_complete_removal() {
        echo "Verification complete" >> "$TEST_DIR/tmp/verification.log"
        return 0
    }

    # Mock check_sudo
    check_sudo() {
        return 0
    }

    # Run the cleanup function
    clean_up_lingering_files

    # Check that it attempted to clean npm files
    [ -f "$TEST_DIR/tmp/task_operations.log" ]
    grep -q "TASK: Cleaning npm files" "$TEST_DIR/tmp/task_operations.log"

    # Check that it attempted to clean temporary files
    grep -q "TASK: Cleaning temporary files" "$TEST_DIR/tmp/task_operations.log"

    # Check that it attempted to clean Library caches
    grep -q "TASK: Cleaning Library caches" "$TEST_DIR/tmp/task_operations.log"

    # Check that it attempted to clean databases
    [ -f "$TEST_DIR/tmp/database_operations.log" ]
    grep -q "CLEAN_DATABASES" "$TEST_DIR/tmp/database_operations.log"

    # Check that it performed a verification
    [ -f "$TEST_DIR/tmp/verification.log" ]
    grep -q "Verification complete" "$TEST_DIR/tmp/verification.log"
}

@test "verify_complete_removal performs thorough system scan" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock find to return different results for different scans
    find() {
        local path="$2"

        if [[ "$path" == "/Applications" ]]; then
            echo "/Applications/Cursor.app" >> "$TEST_DIR/tmp/find_results.log"
        elif [[ "$path" == "${HOME}/Library" ]]; then
            echo "${HOME}/Library/Application Support/Cursor" >> "$TEST_DIR/tmp/find_results.log"
        elif [[ "$path" == "/private/var/folders" ]]; then
            # No results
            true
        elif [[ "$path" == "/" ]]; then
            # Deep scan, no results
            true
        else
            # No results for other paths
            true
        fi

        echo "FIND: $@" >> "$TEST_DIR/tmp/find_operations.log"
        return 0
    }

    # Mock defaults to check preferences
    defaults() {
        if [[ "$1" == "read" && "$2" == "com.cursor.Cursor" ]]; then
            # Simulate finding preferences
            echo "Preferences found" >> "$TEST_DIR/tmp/defaults_results.log"
            return 0
        else
            return 1
        fi
    }

    # Mock run_task to track progress
    run_task() {
        local description="$1"
        shift
        echo "TASK: $description - $@" >> "$TEST_DIR/tmp/task_operations.log"
        eval "$@" > /dev/null 2>&1
        return 0
    }

    # Mock color variables
    YELLOW="\033[1;33m"
    GREEN="\033[0;32m"
    RED="\033[0;31m"
    NC="\033[0m"

    # Run the verification function
    output=$(verify_complete_removal)

    # Check that it scanned key locations
    [ -f "$TEST_DIR/tmp/find_operations.log" ]
    grep -q "FIND: .*/Applications" "$TEST_DIR/tmp/find_operations.log"
    grep -q "FIND: .*Library" "$TEST_DIR/tmp/find_operations.log"
    grep -q "FIND: .*/private/var/folders" "$TEST_DIR/tmp/find_operations.log"

    # Check that it found some Cursor files
    [ -f "$TEST_DIR/tmp/find_results.log" ]
    grep -q "Cursor.app" "$TEST_DIR/tmp/find_results.log"

    # Check that it reported found files in the output
    echo "$output" | grep -q "Some Cursor-related files were found"
}

@test "enhanced_uninstall_cursor provides error handling" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock uninstall_cursor to include an error
    uninstall_cursor() {
        # Simulate an error during uninstallation
        return 1
    }

    # Mock sudo refresh functions
    start_sudo_refresh() {
        echo "SUDO_REFRESH: Started" >> "$TEST_DIR/tmp/sudo_operations.log"
        SUDO_REFRESH_PID=12345
    }

    stop_sudo_refresh() {
        echo "SUDO_REFRESH: Stopped" >> "$TEST_DIR/tmp/sudo_operations.log"
        unset SUDO_REFRESH_PID
    }

    # Mock color variables and messaging
    YELLOW="\033[1;33m"
    GREEN="\033[0;32m"
    NC="\033[0m"

    echo() {
        if [[ "$1" == *"encountered non-critical errors"* || "$1" == *"Starting enhanced uninstallation"* || "$1" == *"Enhanced uninstallation process completed"* ]]; then
            builtin echo "$@" >> "$TEST_DIR/tmp/enhanced_output.log"
        else
            builtin echo "$@"
        fi
    }

    # Mock check_sudo
    check_sudo() { return 0; }

    # Run the enhanced wrapper
    enhanced_uninstall_cursor

    # Check that it handled the error gracefully
    [ -f "$TEST_DIR/tmp/enhanced_output.log" ]
    grep -q "Starting enhanced uninstallation" "$TEST_DIR/tmp/enhanced_output.log"
    grep -q "Enhanced uninstallation process completed" "$TEST_DIR/tmp/enhanced_output.log"

    # Check that sudo refresh was managed properly
    [ -f "$TEST_DIR/tmp/sudo_operations.log" ]
    grep -q "SUDO_REFRESH: Started" "$TEST_DIR/tmp/sudo_operations.log"
    grep -q "SUDO_REFRESH: Stopped" "$TEST_DIR/tmp/sudo_operations.log"
}

@test "enhanced_clean_up_lingering_files handles errors gracefully" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock clean_up_lingering_files to include an error
    clean_up_lingering_files() {
        # Simulate an error during cleanup
        return 1
    }

    # Mock sudo refresh functions
    start_sudo_refresh() {
        echo "SUDO_REFRESH: Started" >> "$TEST_DIR/tmp/sudo_operations.log"
        SUDO_REFRESH_PID=12345
    }

    stop_sudo_refresh() {
        echo "SUDO_REFRESH: Stopped" >> "$TEST_DIR/tmp/sudo_operations.log"
        unset SUDO_REFRESH_PID
    }

    # Mock color variables and messaging
    YELLOW="\033[1;33m"
    GREEN="\033[0;32m"
    NC="\033[0m"

    echo() {
        if [[ "$1" == *"encountered non-critical errors"* || "$1" == *"Starting enhanced cleanup"* || "$1" == *"Enhanced cleanup process completed"* ]]; then
            builtin echo "$@" >> "$TEST_DIR/tmp/enhanced_output.log"
        else
            builtin echo "$@"
        fi
    }

    # Mock check_sudo
    check_sudo() { return 0; }

    # Run the enhanced wrapper
    enhanced_clean_up_lingering_files

    # Check that it handled the error gracefully
    [ -f "$TEST_DIR/tmp/enhanced_output.log" ]
    grep -q "Starting enhanced cleanup" "$TEST_DIR/tmp/enhanced_output.log"
    grep -q "Enhanced cleanup process completed" "$TEST_DIR/tmp/enhanced_output.log"

    # Check that sudo refresh was managed properly
    [ -f "$TEST_DIR/tmp/sudo_operations.log" ]
    grep -q "SUDO_REFRESH: Started" "$TEST_DIR/tmp/sudo_operations.log"
    grep -q "SUDO_REFRESH: Stopped" "$TEST_DIR/tmp/sudo_operations.log"
}

@test "safe_remove handles non-existent paths gracefully" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a test file to remove
    touch "$TEST_DIR/tmp/test_file.txt"

    # Run safe_remove on existing file
    result1=$(safe_remove "$TEST_DIR/tmp/test_file.txt"; echo $?)

    # Run safe_remove on non-existent file
    result2=$(safe_remove "$TEST_DIR/tmp/nonexistent_file.txt"; echo $?)

    # Check that it handled both cases correctly
    [ "$result1" -eq 0 ]  # Should succeed for existing file
    [ "$result2" -eq 1 ]  # Should return 1 for non-existent file
}

@test "safe_remove_symlink handles non-existent symlinks gracefully" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a test symlink
    ln -sf "$TEST_DIR/tmp" "$TEST_DIR/tmp/test_symlink"

    # Run safe_remove_symlink on existing symlink
    result1=$(safe_remove_symlink "$TEST_DIR/tmp/test_symlink"; echo $?)

    # Run safe_remove_symlink on non-existent symlink
    result2=$(safe_remove_symlink "$TEST_DIR/tmp/nonexistent_symlink"; echo $?)

    # Check that it handled both cases correctly
    [ "$result1" -eq 0 ]  # Should succeed for existing symlink
    [ "$result2" -eq 0 ]  # Should still return 0 for non-existent symlink
}

@test "clean_databases removes all database directories" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test database directories
    mkdir -p "$TEST_DIR/tmp/Library/Application Support/Cursor/databases"
    mkdir -p "$TEST_DIR/tmp/Library/Application Support/Cursor/IndexedDB"
    mkdir -p "$TEST_DIR/tmp/Library/Application Support/Cursor/Local Storage"
    mkdir -p "$TEST_DIR/tmp/Library/Application Support/Cursor/Session Storage"

    # Mock safe_remove to track removal operations
    safe_remove() {
        echo "SAFE_REMOVE: $1" >> "$TEST_DIR/tmp/removal_operations.log"
        return 0
    }

    # Run the database cleanup function
    clean_databases

    # Check that it attempted to remove all database directories
    [ -f "$TEST_DIR/tmp/removal_operations.log" ]
    grep -q "SAFE_REMOVE: .*/databases" "$TEST_DIR/tmp/removal_operations.log"
    grep -q "SAFE_REMOVE: .*/IndexedDB" "$TEST_DIR/tmp/removal_operations.log"
    grep -q "SAFE_REMOVE: .*/Local Storage" "$TEST_DIR/tmp/removal_operations.log"
    grep -q "SAFE_REMOVE: .*/Session Storage" "$TEST_DIR/tmp/removal_operations.log"
}

@test "enhanced_safe_remove handles errors gracefully" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a test file with restricted permissions
    mkdir -p "$TEST_DIR/tmp/restricted"
    touch "$TEST_DIR/tmp/restricted/test_file.txt"
    chmod 000 "$TEST_DIR/tmp/restricted"  # Make directory inaccessible

    # Mock execute_safely to track calls
    execute_safely() {
        echo "EXECUTE_SAFELY: $1 - $2" >> "$TEST_DIR/tmp/execute_operations.log"
        return 0
    }

    # Run enhanced_safe_remove on restricted file
    result=$(enhanced_safe_remove "$TEST_DIR/tmp/restricted/test_file.txt"; echo $?)

    # Check that it handled the error gracefully
    [ "$result" -eq 0 ]  # Should always return 0

    # Check that it attempted proper operations
    [ -f "$TEST_DIR/tmp/execute_operations.log" ]
    grep -q "EXECUTE_SAFELY: sudo chmod -R 755" "$TEST_DIR/tmp/execute_operations.log"
    grep -q "EXECUTE_SAFELY: sudo rm -rf" "$TEST_DIR/tmp/execute_operations.log"

    # Restore permissions for cleanup
    chmod 755 "$TEST_DIR/tmp/restricted"
}

@test "execute_safely handles command failures with retries" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock warning_message to capture warnings
    warning_message() {
        echo "WARNING: $1" >> "$TEST_DIR/tmp/warning_messages.log"
    }

    # Create a test function that fails on first attempts
    attempt_count=0
    test_command() {
        attempt_count=$((attempt_count + 1))
        if [ "$attempt_count" -lt 2 ]; then
            return 1  # Fail on first attempt
        else
            return 0  # Succeed on second attempt
        fi
    }

    # Run execute_safely with our test command
    execute_safely "test_command" "Test operation" 0 2

    # Check that it retried and eventually succeeded
    [ -f "$TEST_DIR/tmp/warning_messages.log" ]
    grep -q "Non-critical error in: Test operation" "$TEST_DIR/tmp/warning_messages.log"
    grep -q "Retrying" "$TEST_DIR/tmp/warning_messages.log"

    # Verify the command was called twice
    [ "$attempt_count" -eq 2 ]
}
