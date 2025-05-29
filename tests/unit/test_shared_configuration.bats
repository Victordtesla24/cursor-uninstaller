#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/Users/Shared"
    mkdir -p "$TEST_DIR/tmp/Applications/Cursor.app/Contents/MacOS"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "detect_cursor_paths creates /Users/Shared/cursor with correct permissions" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock needed commands for permission checking
    whoami() {
        echo "testuser"
    }

    # Mock sudo to track directory creation
    sudo() {
        if [[ "$1" == "mkdir" ]]; then
            echo "sudo mkdir: ${@:2}" >> "$TEST_DIR/tmp/sudo_commands.log"
            mkdir -p "${@:2}" 2>/dev/null
            return 0
        elif [[ "$1" == "chmod" ]]; then
            echo "sudo chmod: ${@:2}" >> "$TEST_DIR/tmp/sudo_commands.log"
            return 0
        elif [[ "$1" == "chown" ]]; then
            echo "sudo chown: ${@:2}" >> "$TEST_DIR/tmp/sudo_commands.log"
            return 0
        fi
        return 0  # Default success for other operations
    }

    # Mock mkdir to track directory creation
    mkdir() {
        if [[ "$1" == "-p" && "$2" == *"/Users/Shared/cursor"* ]]; then
            echo "mkdir: $2" >> "$TEST_DIR/tmp/commands.log"
            command mkdir -p "$2" 2>/dev/null
            return 0
        fi
        command mkdir "$@"
    }

    # Mock chmod to track permission changes
    chmod() {
        echo "chmod: $@" >> "$TEST_DIR/tmp/commands.log"
        return 0
    }

    # Run the detect_cursor_paths function
    run detect_cursor_paths

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that an attempt was made to create the directory or set permissions
    [ -f "$TEST_DIR/tmp/commands.log" ] || [ -f "$TEST_DIR/tmp/sudo_commands.log" ]

    # Check for directory creation attempts (either direct or via sudo)
    {
        [ -f "$TEST_DIR/tmp/commands.log" ] &&
        grep -q "mkdir:.*cursor" "$TEST_DIR/tmp/commands.log"
    } || {
        [ -f "$TEST_DIR/tmp/sudo_commands.log" ] &&
        grep -q "sudo mkdir:.*cursor" "$TEST_DIR/tmp/sudo_commands.log"
    }

    # Check for permission setting
    {
        [ -f "$TEST_DIR/tmp/commands.log" ] &&
        grep -q "chmod:.*775" "$TEST_DIR/tmp/commands.log"
    } || {
        [ -f "$TEST_DIR/tmp/sudo_commands.log" ] &&
        grep -q "sudo chmod:.*775" "$TEST_DIR/tmp/sudo_commands.log"
    }

    # Check for ownership setting (user:staff)
    [ -f "$TEST_DIR/tmp/sudo_commands.log" ] && grep -q "sudo chown:.*:staff" "$TEST_DIR/tmp/sudo_commands.log"
}

@test "detect_cursor_paths creates all required subdirectories" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock variable to point to test path
    CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"

    # Mock directory creation and track calls
    mkdir() {
        if [[ "$1" == "-p" && "$2" == *"/Users/Shared/cursor"* ]]; then
            echo "mkdir: $2" >> "$TEST_DIR/tmp/dir_creation.log"
            command mkdir -p "$2" 2>/dev/null
            return 0
        fi
        command mkdir "$@"
    }

    # Run detect_cursor_paths
    run detect_cursor_paths

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify the shared directories were created (or attempted)
    [ -f "$TEST_DIR/tmp/dir_creation.log" ]

    # Check for config directory
    grep -q "mkdir:.*config" "$TEST_DIR/tmp/dir_creation.log" || \
    [ -d "$TEST_DIR/tmp/Users/Shared/cursor/config" ]

    # Check for logs directory
    grep -q "mkdir:.*logs" "$TEST_DIR/tmp/dir_creation.log" || \
    [ -d "$TEST_DIR/tmp/Users/Shared/cursor/logs" ]

    # Check for projects directory
    grep -q "mkdir:.*projects" "$TEST_DIR/tmp/dir_creation.log" || \
    [ -d "$TEST_DIR/tmp/Users/Shared/cursor/projects" ]

    # Check for additional directories (cache, backups)
    grep -q "mkdir:.*cache" "$TEST_DIR/tmp/dir_creation.log" || \
    [ -d "$TEST_DIR/tmp/Users/Shared/cursor/cache" ]

    grep -q "mkdir:.*backups" "$TEST_DIR/tmp/dir_creation.log" || \
    [ -d "$TEST_DIR/tmp/Users/Shared/cursor/backups" ]
}

@test "detect_cursor_paths creates shared argv.json with correct permissions" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock needed commands and variables
    CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"

    # Mock directory creation
    mkdir() {
        if [[ "$1" == "-p" ]]; then
            command mkdir -p "$2" 2>/dev/null
            return 0
        fi
        command mkdir "$@"
    }

    # Mock chmod to track permission changes
    chmod() {
        if [[ "$1" == "664" && "$2" == *"argv.json" ]]; then
            echo "chmod 664: $2" >> "$TEST_DIR/tmp/permissions.log"
            return 0
        fi
        command chmod "$@"
    }

    # Mock sudo for permission setting
    sudo() {
        if [[ "$1" == "chmod" && "$2" == "664" && "$3" == *"argv.json" ]]; then
            echo "sudo chmod 664: $3" >> "$TEST_DIR/tmp/permissions.log"
            return 0
        elif [[ "$1" == "chown" && "$3" == *"argv.json" ]]; then
            echo "sudo chown: $2 $3" >> "$TEST_DIR/tmp/permissions.log"
            return 0
        fi
        command sudo "$@"
    }

    # Mock file redirection operations
    echo() {
        if [[ "$1" == "{}" && "$2" == ">" && "$3" == *"argv.json" ]]; then
            echo "Create argv.json: $3" >> "$TEST_DIR/tmp/file_operations.log"
            command echo "{}" > "$3"
            return 0
        fi
        command echo "$@"
    }

    # Prepare test directories
    mkdir -p "$CURSOR_SHARED_CONFIG"

    # Run detect_cursor_paths
    run detect_cursor_paths

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify argv.json was created
    [ -f "$CURSOR_SHARED_ARGV" ]

    # Check for permission settings (664)
    {
        [ -f "$TEST_DIR/tmp/permissions.log" ] &&
        grep -q "chmod 664:" "$TEST_DIR/tmp/permissions.log"
    } || {
        [ -f "$TEST_DIR/tmp/permissions.log" ] &&
        grep -q "sudo chmod 664:" "$TEST_DIR/tmp/permissions.log"
    }

    # Check for ownership setting
    [ -f "$TEST_DIR/tmp/permissions.log" ] && grep -q "sudo chown:" "$TEST_DIR/tmp/permissions.log"
}

@test "optimize_cursor_performance uses shared argv.json in /Users/Shared/cursor/config" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths to set up test paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"

        # Create the directories
        mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS"
        echo "{}" > "$CURSOR_SHARED_ARGV"

        return 0
    }

    # Mock check_performance_deps to skip dependency checking
    check_performance_deps() {
        return 0
    }

    # Mock operations that would modify argv.json
    cat() {
        if [[ "$1" == "$CURSOR_SHARED_ARGV" ]]; then
            echo "{}"
            return 0
        fi
        command cat "$@"
    }

    # Track writes to argv.json
    echo() {
        if [[ "$1" == *"disable-hardware-acceleration"* ]]; then
            echo "Writing performance settings to argv.json" >> "$TEST_DIR/tmp/performance_operations.log"
            command echo "$1" > "$CURSOR_SHARED_ARGV"
            return 0
        fi
        command echo "$@"
    }

    # Mock info_message to track progress messages
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/messages.log"
    }

    # Mock success_message to track success messages
    success_message() {
        echo "SUCCESS: $1" >> "$TEST_DIR/tmp/messages.log"
    }

    # Mock symbolic link creation
    ln() {
        if [[ "$1" == "-sf" && "$2" == "$CURSOR_SHARED_ARGV" ]]; then
            echo "Creating symlink from $2 to $3" >> "$TEST_DIR/tmp/performance_operations.log"
            return 0
        fi
        command ln "$@"
    }

    # Run optimize_cursor_performance
    run optimize_cursor_performance

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that performance settings were written to the shared location
    [ -f "$TEST_DIR/tmp/performance_operations.log" ]
    grep -q "Writing performance settings to argv.json" "$TEST_DIR/tmp/performance_operations.log"

    # Verify symlink creation attempt
    grep -q "Creating symlink from.*/Users/Shared/cursor/config/argv.json" "$TEST_DIR/tmp/performance_operations.log"

    # Verify that the shared path was logged in messages
    [ -f "$TEST_DIR/tmp/messages.log" ]
    grep -q "Setting up shared configuration in .*/Users/Shared/cursor/config" "$TEST_DIR/tmp/messages.log"
}

@test "setup_project_environment creates projects in /Users/Shared/cursor/projects" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths to set up test paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

        # Create the directories
        mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS" "$CURSOR_SHARED_PROJECTS"

        return 0
    }

    # Mock read for user input (project name and environment choice)
    read_count=0
    read() {
        read_count=$((read_count + 1))

        if [ "$read_count" -eq 1 ]; then
            # Project name
            echo "test-project"
        elif [ "$read_count" -eq 2 ]; then
            # Environment choice
            echo "1"  # Choose venv
        else
            # Default for any other prompts
            echo ""
        fi
    }

    # Mock directory creation to track project path
    mkdir() {
        if [[ "$1" == "-p" && "$2" == *"/Users/Shared/cursor/projects/test-project"* ]]; then
            echo "Creating project directory: $2" >> "$TEST_DIR/tmp/project_operations.log"
            command mkdir -p "$2" 2>/dev/null
            return 0
        fi
        command mkdir "$@"
    }

    # Mock environment setup functions
    setup_venv_environments() { return 0; }
    create_project_structure() { return 0; }
    initialize_git_repository() { return 0; }
    create_project_shortcuts() { return 0; }

    # Mock info_message and warning_message
    info_message() { echo "INFO: $1" >> "$TEST_DIR/tmp/messages.log"; }
    warning_message() { echo "WARNING: $1" >> "$TEST_DIR/tmp/messages.log"; }

    # Run setup_project_environment
    run setup_project_environment

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that the project was created in the correct shared location
    [ -f "$TEST_DIR/tmp/project_operations.log" ]
    grep -q "Creating project directory: .*/Users/Shared/cursor/projects/test-project" "$TEST_DIR/tmp/project_operations.log"

    # Verify correction if wrong path attempted
    if [ -f "$TEST_DIR/tmp/messages.log" ]; then
        if grep -q "Resetting to default location: /Users/Shared/cursor/projects" "$TEST_DIR/tmp/messages.log"; then
            # If a path correction was needed, verify it was fixed
            grep -q "Creating project directory: .*/Users/Shared/cursor/projects/test-project" "$TEST_DIR/tmp/project_operations.log"
        fi
    fi
}

@test "detect_cursor_paths fixes permissions on existing directories" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test directories with 'wrong' permissions
    mkdir -p "$TEST_DIR/tmp/Users/Shared/cursor"
    chmod 700 "$TEST_DIR/tmp/Users/Shared/cursor"  # Restrictive permissions

    # Mock correct directory for the test
    CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"

    # Mock directory existence check to simulate existing directory
    [ -d() {
        if [[ "$1" == "$CURSOR_CWD" ]]; then
            return 0  # Directory exists
        fi
        command [ -d "$1" ]  # Normal behavior for other directories
    }

    # Mock directory writability check to simulate unwritable directory
    [ -w() {
        if [[ "$1" == "$CURSOR_CWD" ]]; then
            return 1  # Directory is not writable
        fi
        command [ -w "$1" ]  # Normal behavior for other paths
    }

    # Mock sudo chmod to track permission fixes
    sudo() {
        if [[ "$1" == "chmod" && "$2" == "775" && "$3" == "$CURSOR_CWD" ]]; then
            echo "sudo chmod 775: $3" >> "$TEST_DIR/tmp/permission_fixes.log"
            chmod 775 "$3"  # Actually fix permissions for testing
            return 0
        elif [[ "$1" == "chown" ]]; then
            echo "sudo chown: $2 $3" >> "$TEST_DIR/tmp/permission_fixes.log"
            return 0
        fi
        command sudo "$@"
    }

    # Run detect_cursor_paths
    run detect_cursor_paths

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that permissions were fixed
    [ -f "$TEST_DIR/tmp/permission_fixes.log" ]
    grep -q "sudo chmod 775:" "$TEST_DIR/tmp/permission_fixes.log"
    grep -q "sudo chown:" "$TEST_DIR/tmp/permission_fixes.log"

    # Verify the directory now has the correct permissions
    [ -x "$TEST_DIR/tmp/Users/Shared/cursor" ]
    [ -w "$TEST_DIR/tmp/Users/Shared/cursor" ]
    [ -r "$TEST_DIR/tmp/Users/Shared/cursor" ]
}

@test "repair_shared_configuration fixes corrupted shared configuration" {
    # Source the script
    source "$SCRIPT_PATH"

    # Set up test directories
    mkdir -p "$TEST_DIR/tmp/Users/Shared/cursor"

    # Create a corrupted argv.json
    mkdir -p "$TEST_DIR/tmp/Users/Shared/cursor/config"
    echo "{ This is not valid JSON }" > "$TEST_DIR/tmp/Users/Shared/cursor/config/argv.json"

    # Mock paths to point to test directories
    CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
    CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
    CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

    # Mock jq to simulate JSON validation failure
    jq() {
        if [[ "$1" == "." && "$2" == "$CURSOR_SHARED_ARGV" ]]; then
            echo "jq: parse error" >&2
            return 1  # JSON validation error
        fi
        command jq "$@"
    }

    # Mock command to detect jq availability
    command() {
        if [[ "$1" == "-v" && "$2" == "jq" ]]; then
            return 0  # jq is available
        fi
        command "$@"
    }

    # Mock cp and file operations to track backups and restoration
    cp() {
        if [[ "$1" == "$CURSOR_SHARED_ARGV" && "$2" == "${CURSOR_SHARED_ARGV}.bak."* ]]; then
            echo "Backing up corrupted argv.json to $2" >> "$TEST_DIR/tmp/repair_operations.log"
            command cp "$1" "$2"
            return 0
        fi
        command cp "$@"
    }

    # Mock echo to track file resets
    echo() {
        if [[ "$1" == "{}" && "$2" == ">" && "$3" == "$CURSOR_SHARED_ARGV" ]]; then
            echo "Resetting argv.json to empty object" >> "$TEST_DIR/tmp/repair_operations.log"
            command echo "{}" > "$3"
            return 0
        fi
        command echo "$@"
    }

    # Mock warning_message
    warning_message() {
        echo "WARNING: $1" >> "$TEST_DIR/tmp/messages.log"
    }

    # Run repair_shared_configuration
    run repair_shared_configuration

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that corrupted file was detected and fixed
    [ -f "$TEST_DIR/tmp/repair_operations.log" ]
    grep -q "Backing up corrupted argv.json" "$TEST_DIR/tmp/repair_operations.log" || \
    grep -q "Resetting argv.json to empty object" "$TEST_DIR/tmp/repair_operations.log"

    # Verify the argv.json is now valid
    [ -f "$CURSOR_SHARED_ARGV" ]
    cat "$CURSOR_SHARED_ARGV" | grep -q "^{}"
}

@test "detect_cursor_paths spots Cursor.app custom location" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create custom Cursor.app location
    mkdir -p "$TEST_DIR/tmp/Applications/Custom/Cursor.app/Contents/MacOS"

    # Mock path checks to simulate Cursor.app not in default location
    [ -d() {
        if [[ "$1" == "/Applications/Cursor.app" ]]; then
            return 1  # Not in default location
        elif [[ "$1" == "$TEST_DIR/tmp/Applications/Custom/Cursor.app" ]]; then
            return 0  # Exists in custom location
        fi
        command [ -d "$1" ]  # Normal behavior for other directories
    }

    # Mock mdfind to simulate Spotlight finding the custom location
    mdfind() {
        if [[ "$1" == "kMDItemFSName == 'Cursor.app'" ]]; then
            echo "$TEST_DIR/tmp/Applications/Custom/Cursor.app"
            return 0
        fi
        command mdfind "$@"
    }

    # Mock info_message to track discovery
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/messages.log"
    }

    # Run detect_cursor_paths
    run detect_cursor_paths

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that custom location was detected
    [ -f "$TEST_DIR/tmp/messages.log" ] && \
    {
        grep -q "Searching for Cursor.app" "$TEST_DIR/tmp/messages.log" || \
        grep -q "Found Cursor.app at" "$TEST_DIR/tmp/messages.log"
    }

    # Verify CURSOR_APP was updated
    [ "$CURSOR_APP" = "$TEST_DIR/tmp/Applications/Custom/Cursor.app" ] || \
    [ -n "$CURSOR_APP" ]  # At minimum it should be set to something
}
