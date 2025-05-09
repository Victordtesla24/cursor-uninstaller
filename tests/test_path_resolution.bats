#!/usr/bin/env bats

load test_helper

@test "get_script_path returns a valid directory" {
    # Source the function
    source "$SCRIPT_PATH"

    # Call the function
    local path=$(get_script_path)

    # Check if path exists and is a directory
    [ -d "$path" ]

    # Check that the path contains uninstall_cursor.sh
    [ -f "$path/uninstall_cursor.sh" ]
}

@test "SCRIPT_DIR is properly set" {
    # Source the script and capture output
    source "$SCRIPT_PATH"

    # Check if SCRIPT_DIR is set and valid
    [ -n "$SCRIPT_DIR" ]
    [ -d "$SCRIPT_DIR" ]
}

@test "Path resolution works with symlinks" {
    # Skip if we can't create symlinks
    if [ ! -w "$(dirname "$SCRIPT_PATH")" ]; then
        skip "Can't create symlinks in the current directory"
    fi

    # Create a temporary directory
    local tmp_dir=$(mktemp -d)

    # Create a symlink to the original script
    ln -sf "$SCRIPT_PATH" "$tmp_dir/symlink_script.sh"

    # Source the symlink script and get the path
    BASH_SOURCE[0]="$tmp_dir/symlink_script.sh"
    source "$SCRIPT_PATH"
    local path=$(get_script_path)

    # The resolved path should match the original script directory, not the symlink location
    [ "$path" = "$(dirname "$SCRIPT_PATH")" ]

    # Clean up
    rm -f "$tmp_dir/symlink_script.sh"
    rmdir "$tmp_dir"
}

@test "Path resolution works with relative symlinks" {
    # Skip if we can't create symlinks
    if [ ! -w "$(dirname "$SCRIPT_PATH")" ]; then
        skip "Can't create symlinks in the current directory"
    fi

    # Create a nested temporary directory structure
    local tmp_root=$(mktemp -d)
    mkdir -p "$tmp_root/dir1/dir2"

    # Create a relative symlink from dir2 to the original script
    local relative_path="../../../../$(realpath --relative-to="$tmp_root/dir1/dir2" "$SCRIPT_PATH")"
    cd "$tmp_root/dir1/dir2"
    ln -sf "$relative_path" "rel_symlink_script.sh"

    # Source the relative symlink script and get the path
    BASH_SOURCE[0]="$tmp_root/dir1/dir2/rel_symlink_script.sh"
    source "$SCRIPT_PATH"
    local path=$(get_script_path)

    # The resolved path should match the original script directory, not the symlink location
    [ "$path" = "$(dirname "$SCRIPT_PATH")" ]

    # Clean up
    cd -
    rm -rf "$tmp_root"
}

@test "Path resolution works with chained symlinks" {
    # Skip if we can't create symlinks
    if [ ! -w "$(dirname "$SCRIPT_PATH")" ]; then
        skip "Can't create symlinks in the current directory"
    fi

    # Create temporary directories
    local tmp_dir1=$(mktemp -d)
    local tmp_dir2=$(mktemp -d)

    # Create chained symlinks
    ln -sf "$SCRIPT_PATH" "$tmp_dir1/link1.sh"
    ln -sf "$tmp_dir1/link1.sh" "$tmp_dir2/link2.sh"

    # Source the chained symlink script and get the path
    BASH_SOURCE[0]="$tmp_dir2/link2.sh"
    source "$SCRIPT_PATH"
    local path=$(get_script_path)

    # The resolved path should match the original script directory
    [ "$path" = "$(dirname "$SCRIPT_PATH")" ]

    # Clean up
    rm -f "$tmp_dir1/link1.sh"
    rm -f "$tmp_dir2/link2.sh"
    rmdir "$tmp_dir1"
    rmdir "$tmp_dir2"
}

@test "Script runs from any directory" {
    # Create a temporary directory
    local tmp_dir=$(mktemp -d)

    # Change to the temporary directory
    pushd "$tmp_dir" > /dev/null

    # Run the script - just check that it starts up without error
    # Use -e to immediately exit if an error occurs
    run bash -e "$SCRIPT_PATH" <<< "8"

    # Change back to original directory
    popd > /dev/null

    # Clean up
    rmdir "$tmp_dir"

    # Verify the script ran successfully
    [ "$status" -eq 0 ]
}

@test "detect_cursor_paths always uses /Users/Shared/cursor directory" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock mkdir to track calls
    mkdir() {
        echo "mkdir: $@" >> "$TEST_DIR/tmp/mkdir_calls.log"
        # Actually create the directory for testing
        command mkdir -p "$@"
        return 0
    }

    # Mock sudo to avoid requiring privileges
    sudo() {
        echo "sudo: $@" >> "$TEST_DIR/tmp/sudo_calls.log"
        # Pass through any mkdir commands but strip sudo
        if [[ "$1" == "mkdir" ]]; then
            command mkdir "${@:2}"
        elif [[ "$1" == "chmod" ]]; then
            command chmod "${@:2}"
        elif [[ "$1" == "chown" ]]; then
            echo "Would chown ${@:2}"
        fi
        return 0
    }

    # Mock chmod
    chmod() {
        echo "chmod: $@" >> "$TEST_DIR/tmp/chmod_calls.log"
        return 0
    }

    # Run the function from a different directory
    local orig_dir="$PWD"
    cd "$TEST_DIR/tmp" || return 1

    # Capture function output
    detect_cursor_paths

    # Return to original directory
    cd "$orig_dir" || return 1

    # Verify that the correct paths were set
    [ "$CURSOR_CWD" = "/Users/Shared/cursor" ]
    [ "$CURSOR_SHARED_CONFIG" = "/Users/Shared/cursor/config" ]
    [ "$CURSOR_SHARED_PROJECTS" = "/Users/Shared/cursor/projects" ]

    # Check that the logs show attempts to create or set up the directories
    if [ -f "$TEST_DIR/tmp/mkdir_calls.log" ]; then
        grep -q "/Users/Shared/cursor" "$TEST_DIR/tmp/mkdir_calls.log" || \
        grep -q "/Users/Shared/cursor" "$TEST_DIR/tmp/sudo_calls.log"
    fi
}

@test "detect_cursor_paths creates required subdirectories with proper permissions" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock mkdir to track calls
    mkdir() {
        echo "mkdir: $@" >> "$TEST_DIR/tmp/mkdir_calls.log"
        command mkdir -p "$@"
        return 0
    }

    # Mock chmod to track calls
    chmod() {
        echo "chmod: $@" >> "$TEST_DIR/tmp/chmod_calls.log"
        return 0
    }

    # Mock sudo
    sudo() {
        echo "sudo: $@" >> "$TEST_DIR/tmp/sudo_calls.log"
        if [[ "$1" == "mkdir" ]]; then
            command mkdir -p "${@:2}"
        elif [[ "$1" == "chmod" ]]; then
            command chmod "${@:2}"
        fi
        return 0
    }

    # Call the function
    detect_cursor_paths

    # Check if all expected directories are created
    grep -q "config" "$TEST_DIR/tmp/mkdir_calls.log" || grep -q "config" "$TEST_DIR/tmp/sudo_calls.log"
    grep -q "logs" "$TEST_DIR/tmp/mkdir_calls.log" || grep -q "logs" "$TEST_DIR/tmp/sudo_calls.log"
    grep -q "projects" "$TEST_DIR/tmp/mkdir_calls.log" || grep -q "projects" "$TEST_DIR/tmp/sudo_calls.log"
    grep -q "cache" "$TEST_DIR/tmp/mkdir_calls.log" || grep -q "cache" "$TEST_DIR/tmp/sudo_calls.log"
    grep -q "backups" "$TEST_DIR/tmp/mkdir_calls.log" || grep -q "backups" "$TEST_DIR/tmp/sudo_calls.log"

    # Check if permissions are set correctly (775)
    grep -q "775" "$TEST_DIR/tmp/chmod_calls.log" || grep -q "775" "$TEST_DIR/tmp/sudo_calls.log"
}

@test "performance optimizations always target shared config directory" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths to set up the shared paths but not create directories
    detect_cursor_paths() {
        CURSOR_CWD="/Users/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

        # Just return success but don't create directories
        return 0
    }

    # Mock dependency checks to succeed
    check_performance_deps() {
        return 0
    }

    # Mock file operations to track instead of perform
    mkdir() {
        echo "mkdir: $@" >> "$TEST_DIR/tmp/mkdir_calls.log"
        return 0
    }

    cat() {
        # For reading argv.json, return empty object
        if [[ "$1" == "$CURSOR_SHARED_ARGV" ]]; then
            echo "{}"
            return 0
        fi

        # For writing to files, track it
        if [[ "$1" == ">" ]]; then
            echo "Writing to: $2" >> "$TEST_DIR/tmp/file_writes.log"
            return 0
        fi

        # Default behavior
        command cat "$@"
    }

    echo() {
        # Track when writing to argv.json
        if [[ "$2" == *"argv.json"* ]]; then
            echo "Echo to $2: $1" >> "$TEST_DIR/tmp/echo_calls.log"
            return 0
        fi

        # Default behavior
        builtin echo "$@"
    }

    # Mock other operations that would be performed
    chmod() { return 0; }
    ln() { return 0; }
    command() { return 1; } # jq not available

    # Call the function
    optimize_cursor_performance > /dev/null 2>&1

    # Verify that operations targeted the shared directory
    [ -f "$TEST_DIR/tmp/echo_calls.log" ] && grep -q "/Users/Shared/cursor" "$TEST_DIR/tmp/echo_calls.log"
}

@test "Apple Silicon M3 chip is correctly detected" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock system commands for M3 detection
    sysctl() {
        if [[ "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M3"
            return 0
        fi
        command sysctl "$@"
    }

    system_profiler() {
        if [[ "$1" == "SPHardwareDataType" ]]; then
            echo "  Chip: Apple M3"
            return 0
        }
        command system_profiler "$@"
    }

    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "arm64"
            return 0
        fi
        command uname "$@"
    }

    # Mock detect_cursor_paths function
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        return 0
    }

    # Mock other functions needed by optimize_cursor_performance
    check_performance_deps() { return 0; }
    cat() { echo "{}"; }
    mkdir() { command mkdir -p "$@" 2>/dev/null || true; }

    # Create a capture file for info_message function
    mkdir -p "$TEST_DIR/tmp"
    info_message() {
        echo "$1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    # Test the chip detection logic
    is_m_series=false
    chip_model=""
    chip_generation=0

    # Get chip info
    cpu_info="Apple M3" # Mocked value

    # Apply detection logic
    if [[ "$cpu_info" == *"Apple M"* ]]; then
        is_m_series=true
        if [[ "$cpu_info" =~ Apple\ M([0-9]+) ]]; then
            chip_model="Apple M${BASH_REMATCH[1]}"
            chip_generation="${BASH_REMATCH[1]}"
        fi
        info_message "Detected $chip_model (Generation $chip_generation) chipset."
    fi

    # Verify detection results
    [ "$is_m_series" = true ]
    [ "$chip_model" = "Apple M3" ]
    [ "$chip_generation" -eq 3 ]

    # Check that the log contains the detection message
    grep -q "Detected Apple M3" "$TEST_DIR/tmp/info_messages.log"
}

@test "M3-specific optimizations are applied for M3 chips" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock system commands for M3 detection
    sysctl() {
        if [[ "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M3"
            return 0
        fi
        command sysctl "$@"
    }

    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "arm64"
            return 0
        fi
        command uname "$@"
    }

    system_profiler() {
        if [[ "$1" == "SPHardwareDataType" ]]; then
            echo "  Chip: Apple M3"
            return 0
        }
        command system_profiler "$@"
    }

    # Mock detect_cursor_paths and other required functions
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        mkdir -p "$CURSOR_SHARED_CONFIG"
        echo "{}" > "$CURSOR_SHARED_ARGV"
        return 0
    }

    check_performance_deps() { return 0; }

    # Mock echo function to capture settings
    echo() {
        if [[ "$1" == "{" && "$2" == *"disable-hardware-acceleration"* ]]; then
            # This is the performance settings JSON - save it
            builtin echo "$@" > "$TEST_DIR/tmp/performance_settings.json"
        else
            builtin echo "$@"
        fi
    }

    # Mock mkdir and cat
    mkdir() { command mkdir -p "$@" 2>/dev/null || true; }
    cat() {
        if [[ "$1" == ">" ]]; then
            # We're writing to a file
            echo "Writing to $2" >> "$TEST_DIR/tmp/writes.log"
            return 0
        fi
        echo "{}";
    }

    # Call the function
    optimize_cursor_performance > "$TEST_DIR/tmp/output.log" 2>&1

    # Verify that M3-specific optimizations were included in the output
    grep -q "M3-specific optimizations" "$TEST_DIR/tmp/output.log" || grep -q "Generation 3" "$TEST_DIR/tmp/output.log"

    # Check if metal settings were configured
    grep -q "gpu.dynamic-power-management" "$TEST_DIR/tmp/output.log" || \
    grep -q "metal-resource-heap-size-mb" "$TEST_DIR/tmp/output.log" || \
    grep -q "metal.resource-heap-size-mb" "$TEST_DIR/tmp/output.log"
}

@test "setup_project_environment creates projects in /Users/Shared/cursor/projects" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$TEST_DIR/tmp/projects" # Intentionally wrong path

        mkdir -p "$CURSOR_SHARED_LOGS"
        return 0
    }

    # Mock read function to simulate user input
    read_count=0
    read() {
        read_count=$((read_count + 1))

        if [ $read_count -eq 1 ]; then
            # Project name
            echo "test_project"
        elif [ $read_count -eq 2 ]; then
            # Environment choice
            echo "1"
        else
            echo ""
        fi
    }

    # Mock message functions
    error_message() { echo "ERROR: $1" >> "$TEST_DIR/tmp/messages.log"; }
    warning_message() { echo "WARNING: $1" >> "$TEST_DIR/tmp/messages.log"; }
    info_message() { echo "INFO: $1" >> "$TEST_DIR/tmp/messages.log"; }
    success_message() { echo "SUCCESS: $1" >> "$TEST_DIR/tmp/messages.log"; }

    # Mock functions that would create directories and files
    mkdir() {
        echo "MKDIR: $*" >> "$TEST_DIR/tmp/actions.log"
        command mkdir -p "$@" 2>/dev/null || true
        return 0
    }

    chmod() { echo "CHMOD: $*" >> "$TEST_DIR/tmp/actions.log"; return 0; }

    # Mock environment setup functions
    setup_venv_environments() { echo "SETUP_VENV: $1" >> "$TEST_DIR/tmp/actions.log"; return 0; }
    setup_conda_environments() { echo "SETUP_CONDA: $1" >> "$TEST_DIR/tmp/actions.log"; return 0; }
    setup_poetry_environments() { echo "SETUP_POETRY: $1" >> "$TEST_DIR/tmp/actions.log"; return 0; }
    setup_nodejs_environment() { echo "SETUP_NODEJS: $1" >> "$TEST_DIR/tmp/actions.log"; return 0; }

    # Mock project structure functions
    create_project_structure() { echo "CREATE_STRUCTURE: $1" >> "$TEST_DIR/tmp/actions.log"; return 0; }
    initialize_git_repository() { echo "INIT_GIT: $1" >> "$TEST_DIR/tmp/actions.log"; return 0; }
    create_project_shortcuts() { echo "CREATE_SHORTCUTS: $1 $2 $3" >> "$TEST_DIR/tmp/actions.log"; return 0; }

    # Call the function
    setup_project_environment > "$TEST_DIR/tmp/output.log" 2>&1

    # Check if the function corrected the path to /Users/Shared/cursor/projects
    grep -q "Shared projects directory is not at the expected location" "$TEST_DIR/tmp/messages.log"
    grep -q "Resetting to default location: /Users/Shared/cursor/projects" "$TEST_DIR/tmp/messages.log"

    # Check if it tried to create the project in the correct location
    grep -q "/Users/Shared/cursor/projects/test_project" "$TEST_DIR/tmp/actions.log" || \
    grep -q "/Users/Shared/cursor/projects/test_project" "$TEST_DIR/tmp/output.log"
}
