#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/Downloads"
    mkdir -p "$TEST_DIR/tmp/Applications"
    mkdir -p "$TEST_DIR/tmp/Volumes/Cursor"
    mkdir -p "$TEST_DIR/tmp/Shared/cursor/config"
    mkdir -p "$TEST_DIR/tmp/Shared/cursor/logs"
    mkdir -p "$TEST_DIR/tmp/Shared/cursor/projects"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "install_cursor_from_dmg checks for DMG existence" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock info_message to track calls
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    # Mock error_message to track calls
    error_message() {
        echo "ERROR: $1" >> "$TEST_DIR/tmp/error_messages.log"
    }

    # Mock DMG path
    local dmg_path="$TEST_DIR/tmp/Downloads/Cursor-darwin-universal.dmg"

    # First test without the DMG file
    run install_cursor_from_dmg

    # Check that it reported the missing DMG file
    [ -f "$TEST_DIR/tmp/error_messages.log" ]
    grep -q "DMG file not found" "$TEST_DIR/tmp/error_messages.log"

    # Now create the DMG file
    touch "$dmg_path"

    # Mock some functions to prevent actual installation
    hdiutil() {
        echo "HDIUTIL: $@" >> "$TEST_DIR/tmp/hdiutil_operations.log"
        if [[ "$1" == "verify" ]]; then
            return 0  # DMG verification successful
        else
            return 0
        fi
    }

    detect_cursor_paths() {
        CURSOR_SHARED_LOGS="$TEST_DIR/tmp/Shared/cursor/logs"
        mkdir -p "$CURSOR_SHARED_LOGS"
        return 0
    }

    # Run again with the DMG file present
    run install_cursor_from_dmg

    # Check that it attempted to verify the DMG
    [ -f "$TEST_DIR/tmp/hdiutil_operations.log" ]
    grep -q "HDIUTIL: verify" "$TEST_DIR/tmp/hdiutil_operations.log"
}

@test "install_cursor_from_dmg verifies DMG integrity" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a mock DMG file
    local dmg_path="$TEST_DIR/tmp/Downloads/Cursor-darwin-universal.dmg"
    dd if=/dev/zero of="$dmg_path" bs=1M count=1 2>/dev/null

    # Mock functions
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    success_message() {
        echo "SUCCESS: $1" >> "$TEST_DIR/tmp/success_messages.log"
    }

    error_message() {
        echo "ERROR: $1" >> "$TEST_DIR/tmp/error_messages.log"
    }

    # Mock hdiutil to test both success and failure scenarios
    hdiutil() {
        if [[ "$1" == "verify" ]]; then
            echo "HDIUTIL VERIFY: $@" >> "$TEST_DIR/tmp/hdiutil_operations.log"
            # Test DMG integrity verification success
            return 0
        else
            echo "HDIUTIL OTHER: $@" >> "$TEST_DIR/tmp/hdiutil_operations.log"
            return 0
        fi
    }

    detect_cursor_paths() {
        CURSOR_SHARED_LOGS="$TEST_DIR/tmp/Shared/cursor/logs"
        mkdir -p "$CURSOR_SHARED_LOGS"
        return 0
    }

    # Mock stat for file size check
    stat() {
        echo "1500000"  # 1.5MB, should be large enough
        return 0
    }

    # Run the function
    install_cursor_from_dmg

    # Check that it verified the DMG and reported success
    [ -f "$TEST_DIR/tmp/hdiutil_operations.log" ]
    grep -q "HDIUTIL VERIFY:" "$TEST_DIR/tmp/hdiutil_operations.log"

    [ -f "$TEST_DIR/tmp/success_messages.log" ]
    grep -q "DMG integrity verified successfully" "$TEST_DIR/tmp/success_messages.log"

    # Now test with a verification failure
    hdiutil() {
        if [[ "$1" == "verify" ]]; then
            echo "HDIUTIL VERIFY FAIL: $@" >> "$TEST_DIR/tmp/hdiutil_fail_operations.log"
            # Test DMG integrity verification failure
            return 1
        else
            return 0
        fi
    }

    # Run the function again
    run install_cursor_from_dmg

    # Check that it reported the verification failure
    [ -f "$TEST_DIR/tmp/error_messages.log" ]
    grep -q "DMG file is corrupted or invalid" "$TEST_DIR/tmp/error_messages.log"
}

@test "install_cursor_from_dmg checks for running Cursor instances" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a mock DMG file
    local dmg_path="$TEST_DIR/tmp/Downloads/Cursor-darwin-universal.dmg"
    touch "$dmg_path"

    # Mock functions
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    warning_message() {
        echo "WARNING: $1" >> "$TEST_DIR/tmp/warning_messages.log"
    }

    detect_cursor_paths() {
        CURSOR_SHARED_LOGS="$TEST_DIR/tmp/Shared/cursor/logs"
        mkdir -p "$CURSOR_SHARED_LOGS"
        return 0
    }

    # Mock pgrep to test with running Cursor processes
    pgrep() {
        if [[ "$2" == "Cursor" ]]; then
            echo "12345"  # Return a dummy PID
            return 0
        else
            return 1
        fi
    }

    # Mock pkill to check if it's called to terminate processes
    pkill() {
        echo "PKILL: $@" >> "$TEST_DIR/tmp/pkill_operations.log"
        return 0
    }

    # Mock hdiutil for DMG verification
    hdiutil() {
        echo "HDIUTIL: $@" >> "$TEST_DIR/tmp/hdiutil_operations.log"
        return 0
    }

    # Run the function
    install_cursor_from_dmg

    # Check that it detected and attempted to close running instances
    [ -f "$TEST_DIR/tmp/info_messages.log" ]
    grep -q "Closing any running Cursor instances" "$TEST_DIR/tmp/info_messages.log"

    [ -f "$TEST_DIR/tmp/pkill_operations.log" ]
    grep -q "PKILL: -f Cursor" "$TEST_DIR/tmp/pkill_operations.log"
}

@test "install_cursor_from_dmg correctly mounts and copies DMG" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a mock DMG file
    local dmg_path="$TEST_DIR/tmp/Downloads/Cursor-darwin-universal.dmg"
    touch "$dmg_path"

    # Create a mock Cursor.app in the mounted volume
    mkdir -p "$TEST_DIR/tmp/Volumes/Cursor/Cursor.app/Contents/MacOS"
    touch "$TEST_DIR/tmp/Volumes/Cursor/Cursor.app/Contents/Info.plist"

    # Mock functions
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    success_message() {
        echo "SUCCESS: $1" >> "$TEST_DIR/tmp/success_messages.log"
    }

    error_message() {
        echo "ERROR: $1" >> "$TEST_DIR/tmp/error_messages.log"
    }

    detect_cursor_paths() {
        CURSOR_SHARED_LOGS="$TEST_DIR/tmp/Shared/cursor/logs"
        mkdir -p "$CURSOR_SHARED_LOGS"
        return 0
    }

    # Mock hdiutil for mounting and unmounting
    hdiutil() {
        echo "HDIUTIL: $@" >> "$TEST_DIR/tmp/hdiutil_operations.log"

        if [[ "$1" == "attach" ]]; then
            # Simulate mounting success
            return 0
        elif [[ "$1" == "detach" ]]; then
            # Simulate unmounting success
            return 0
        elif [[ "$1" == "verify" ]]; then
            # Simulate verification success
            return 0
        else
            return 0
        fi
    }

    # Mock copying operations
    cp() {
        if [[ "$1" == "-R" && "$2" == *"Cursor.app"* && "$3" == *"/Applications/"* ]]; then
            echo "CP: Copying $2 to $3" >> "$TEST_DIR/tmp/cp_operations.log"
            # Actually create the directory for post-copy checks
            mkdir -p "$TEST_DIR/tmp/Applications/Cursor.app/Contents/MacOS"
            touch "$TEST_DIR/tmp/Applications/Cursor.app/Contents/Info.plist"
            return 0
        else
            command cp "$@"
        fi
    }

    # Mock pgrep and pkill
    pgrep() { return 1; }  # No running instances
    pkill() { return 0; }

    # Mock chown
    chown() {
        echo "CHOWN: $@" >> "$TEST_DIR/tmp/chown_operations.log"
        return 0
    }

    # Mock optimize_cursor_performance and setup_default_project
    optimize_cursor_performance() {
        echo "OPTIMIZE: Called" >> "$TEST_DIR/tmp/optimize_operations.log"
        return 0
    }

    setup_default_project() {
        echo "SETUP_DEFAULT: Called" >> "$TEST_DIR/tmp/setup_operations.log"
        return 0
    }

    # Mock defaults for version checking
    defaults() {
        if [[ "$1" == "read" && "$2" == *"Cursor.app/Contents/Info"* ]]; then
            echo "0.49.6"  # Return a version number
            return 0
        else
            return 1
        fi
    }

    # Run the function
    install_cursor_from_dmg

    # Check that it attempted to mount the DMG
    [ -f "$TEST_DIR/tmp/hdiutil_operations.log" ]
    grep -q "HDIUTIL: attach" "$TEST_DIR/tmp/hdiutil_operations.log"

    # Check that it copied the app
    [ -f "$TEST_DIR/tmp/cp_operations.log" ]
    grep -q "CP: Copying" "$TEST_DIR/tmp/cp_operations.log"

    # Check that it unmounted the DMG
    grep -q "HDIUTIL: detach" "$TEST_DIR/tmp/hdiutil_operations.log"

    # Check that it set permissions on the copied app
    [ -f "$TEST_DIR/tmp/chown_operations.log" ]

    # Check that it applied optimizations
    [ -f "$TEST_DIR/tmp/optimize_operations.log" ]
    grep -q "OPTIMIZE: Called" "$TEST_DIR/tmp/optimize_operations.log"

    # Check that it set up a default project
    [ -f "$TEST_DIR/tmp/setup_operations.log" ]
    grep -q "SETUP_DEFAULT: Called" "$TEST_DIR/tmp/setup_operations.log"

    # Check that it verified the version
    [ -f "$TEST_DIR/tmp/success_messages.log" ]
    grep -q "Successfully installed Cursor AI Editor version 0.49.6" "$TEST_DIR/tmp/success_messages.log"
}

@test "install_cursor_from_dmg handles mount failures gracefully" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a mock DMG file
    local dmg_path="$TEST_DIR/tmp/Downloads/Cursor-darwin-universal.dmg"
    touch "$dmg_path"

    # Mock functions
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    error_message() {
        echo "ERROR: $1" >> "$TEST_DIR/tmp/error_messages.log"
    }

    warning_message() {
        echo "WARNING: $1" >> "$TEST_DIR/tmp/warning_messages.log"
    }

    detect_cursor_paths() {
        CURSOR_SHARED_LOGS="$TEST_DIR/tmp/Shared/cursor/logs"
        mkdir -p "$CURSOR_SHARED_LOGS"
        return 0
    }

    # Mock hdiutil to simulate mount failure
    hdiutil() {
        if [[ "$1" == "verify" ]]; then
            return 0  # Verification passes
        elif [[ "$1" == "attach" ]]; then
            echo "HDIUTIL ATTACH FAIL: $@" >> "$TEST_DIR/tmp/hdiutil_operations.log"
            return 1  # Mount fails
        else
            return 0
        }
    }

    # Mock pgrep and pkill
    pgrep() { return 1; }  # No running instances
    pkill() { return 0; }

    # Run the function
    run install_cursor_from_dmg

    # Check that it reported the mount failure
    [ -f "$TEST_DIR/tmp/error_messages.log" ]
    grep -q "Failed to mount DMG file" "$TEST_DIR/tmp/error_messages.log"
}

@test "install_cursor_from_dmg handles copy failures gracefully" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a mock DMG file
    local dmg_path="$TEST_DIR/tmp/Downloads/Cursor-darwin-universal.dmg"
    touch "$dmg_path"

    # Create a mock Cursor.app in the mounted volume
    mkdir -p "$TEST_DIR/tmp/Volumes/Cursor/Cursor.app/Contents/MacOS"
    touch "$TEST_DIR/tmp/Volumes/Cursor/Cursor.app/Contents/Info.plist"

    # Mock functions
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    error_message() {
        echo "ERROR: $1" >> "$TEST_DIR/tmp/error_messages.log"
    }

    detect_cursor_paths() {
        CURSOR_SHARED_LOGS="$TEST_DIR/tmp/Shared/cursor/logs"
        mkdir -p "$CURSOR_SHARED_LOGS"
        return 0
    }

    # Mock hdiutil
    hdiutil() {
        echo "HDIUTIL: $@" >> "$TEST_DIR/tmp/hdiutil_operations.log"
        return 0
    }

    # Mock cp to simulate copy failure
    cp() {
        if [[ "$1" == "-R" && "$2" == *"Cursor.app"* ]]; then
            echo "CP FAIL: $@" >> "$TEST_DIR/tmp/cp_operations.log"
            return 1  # Copy fails
        else
            command cp "$@"
        fi
    }

    # Mock pgrep and pkill
    pgrep() { return 1; }  # No running instances
    pkill() { return 0; }

    # Run the function
    run install_cursor_from_dmg

    # Check that it reported the copy failure
    [ -f "$TEST_DIR/tmp/error_messages.log" ]
    grep -q "Failed to copy Cursor.app to Applications folder" "$TEST_DIR/tmp/error_messages.log"
}

@test "install_cursor_from_dmg handles unmount failures gracefully" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a mock DMG file
    local dmg_path="$TEST_DIR/tmp/Downloads/Cursor-darwin-universal.dmg"
    touch "$dmg_path"

    # Create a mock Cursor.app in the mounted volume
    mkdir -p "$TEST_DIR/tmp/Volumes/Cursor/Cursor.app/Contents/MacOS"
    touch "$TEST_DIR/tmp/Volumes/Cursor/Cursor.app/Contents/Info.plist"

    # Mock functions
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    warning_message() {
        echo "WARNING: $1" >> "$TEST_DIR/tmp/warning_messages.log"
    }

    detect_cursor_paths() {
        CURSOR_SHARED_LOGS="$TEST_DIR/tmp/Shared/cursor/logs"
        mkdir -p "$CURSOR_SHARED_LOGS"
        return 0
    }

    # Mock hdiutil with unmount failure
    hdiutil() {
        echo "HDIUTIL: $@" >> "$TEST_DIR/tmp/hdiutil_operations.log"

        if [[ "$1" == "detach" ]]; then
            if [[ "$3" == "-force" ]]; then
                # Force unmount succeeds
                return 0
            } else {
                # Normal unmount fails
                return 1
            }
        } else {
            return 0
        }
    }

    # Mock cp to simulate successful copy
    cp() {
        if [[ "$1" == "-R" && "$2" == *"Cursor.app"* ]]; then
            echo "CP: $@" >> "$TEST_DIR/tmp/cp_operations.log"
            mkdir -p "$TEST_DIR/tmp/Applications/Cursor.app/Contents/MacOS"
            touch "$TEST_DIR/tmp/Applications/Cursor.app/Contents/Info.plist"
            return 0
        } else {
            command cp "$@"
        }
    }

    # Mock other required functions
    pgrep() { return 1; }  # No running instances
    pkill() { return 0; }
    chown() { return 0; }
    optimize_cursor_performance() { return 0; }
    setup_default_project() { return 0; }
    defaults() { echo "0.49.6"; return 0; }

    # Run the function
    install_cursor_from_dmg

    # Check that it attempted force unmount
    [ -f "$TEST_DIR/tmp/hdiutil_operations.log" ]
    grep -q "HDIUTIL: detach.*-force" "$TEST_DIR/tmp/hdiutil_operations.log"

    # Check that it warned about unmount issues
    [ -f "$TEST_DIR/tmp/warning_messages.log" ]
    grep -q "Failed to unmount normally. Attempting force unmount" "$TEST_DIR/tmp/warning_messages.log"
}

@test "verify_cursor_installation checks app existence and version" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock functions
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"
        return 0
    }

    # Mock app existence check
    [ () {
        if [[ "$1" == "-d" && "$2" == "/Applications/Cursor.app" ]]; then
            # First test - no app installed
            return 1
        else
            builtin [ "$@"
        fi
    }

    # Run first check - no app installed
    output=$(verify_cursor_installation)

    # Verify it reports app is not installed
    echo "$output" | grep -q "Cursor AI Editor is not installed"

    # Mock app existence check - app installed
    [ () {
        if [[ "$1" == "-d" && "$2" == "/Applications/Cursor.app" ]]; then
            # Second test - app is installed
            return 0
        else
            builtin [ "$@"
        fi
    }

    # Mock defaults to return a version
    defaults() {
        if [[ "$1" == "read" && "$2" == *"Cursor.app/Contents/Info"* ]]; then
            echo "0.49.6"
            return 0
        else
            return 1
        fi
    }

    # Mock check_performance_settings
    check_performance_settings() {
        echo "Hardware acceleration enabled"
        echo "WebGPU enabled"
        return 0
    }

    # Run second check - app installed
    output=$(verify_cursor_installation)

    # Verify it reports correct version
    echo "$output" | grep -q "Cursor AI Editor version: 0.49.6"
    echo "$output" | grep -q "Hardware acceleration enabled"
}

@test "setup_default_project creates a default project environment" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"
        mkdir -p "$CURSOR_SHARED_PROJECTS"
        return 0
    }

    # Mock setup environment functions
    setup_conda_environments() {
        echo "SETUP_CONDA: $1" >> "$TEST_DIR/tmp/environment_operations.log"
        return 0
    }

    create_project_structure() {
        echo "CREATE_STRUCTURE: $1" >> "$TEST_DIR/tmp/structure_operations.log"
        return 0
    }

    initialize_git_repository() {
        echo "INIT_GIT: $1" >> "$TEST_DIR/tmp/git_operations.log"
        return 0
    }

    create_project_shortcuts() {
        echo "CREATE_SHORTCUTS: $1 $2 $3" >> "$TEST_DIR/tmp/shortcuts_operations.log"
        return 0
    }

    # Mock read to provide automated input
    export CURRENT_READ_CONTEXT="project_name"

    # Run function
    setup_default_project

    # Check that it created the project structure
    [ -f "$TEST_DIR/tmp/structure_operations.log" ]
    grep -q "CREATE_STRUCTURE: " "$TEST_DIR/tmp/structure_operations.log"

    # Check that it set up conda environments
    [ -f "$TEST_DIR/tmp/environment_operations.log" ]
    grep -q "SETUP_CONDA: " "$TEST_DIR/tmp/environment_operations.log"

    # Check that it initialized git repository
    [ -f "$TEST_DIR/tmp/git_operations.log" ]
    grep -q "INIT_GIT: " "$TEST_DIR/tmp/git_operations.log"

    # Check that it created shortcuts
    [ -f "$TEST_DIR/tmp/shortcuts_operations.log" ]
    grep -q "CREATE_SHORTCUTS: " "$TEST_DIR/tmp/shortcuts_operations.log"
}
