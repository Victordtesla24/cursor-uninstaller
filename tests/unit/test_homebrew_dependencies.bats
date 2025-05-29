#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/opt/homebrew"
    mkdir -p "$TEST_DIR/tmp/var/homebrew/locks"
    mkdir -p "$TEST_DIR/tmp/opt/homebrew/share/zsh/site-functions"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "check_performance_deps installs Homebrew if not present" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock command to simulate Homebrew not being installed
    command() {
        if [[ "$1" == "-v" && "$2" == "brew" ]]; then
            return 1  # brew not found
        fi
        command "$@"
    }

    # Mock bash to capture Homebrew installation script execution
    bash() {
        if [[ "$1" == "-c" && "$2" == *"Homebrew/install"* ]]; then
            echo "Would install Homebrew" >> "$TEST_DIR/tmp/executed_commands.log"
            return 0
        fi
        command bash "$@"
    }

    # Mock curl to prevent actually downloading anything
    curl() {
        echo "Would curl: $@" >> "$TEST_DIR/tmp/executed_commands.log"
        return 0
    }

    # Mock eval to capture Homebrew shellenv evaluation
    eval() {
        echo "Would eval: $@" >> "$TEST_DIR/tmp/executed_commands.log"
        return 0
    }

    # Mock uname to simulate M1/M2/M3 Mac
    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "arm64"
            return 0
        fi
        command uname "$@"
    }

    # Run the function
    run check_performance_deps

    # Should succeed
    [ "$status" -eq 0 ]

    # Check that Homebrew installation was attempted
    [ -f "$TEST_DIR/tmp/executed_commands.log" ]
    grep -q "Would install Homebrew" "$TEST_DIR/tmp/executed_commands.log" || \
    grep -q "Homebrew/install" "$TEST_DIR/tmp/executed_commands.log"
}

@test "check_performance_deps fixes Homebrew permissions" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock command to simulate Homebrew being installed
    command() {
        if [[ "$1" == "-v" && "$2" == "brew" ]]; then
            return 0  # brew found
        fi
        command "$@"
    }

    # Mock sudo to track permission fix operations
    sudo() {
        echo "sudo: $@" >> "$TEST_DIR/tmp/sudo_calls.log"
        # Actually perform the operations for testing
        if [[ "$1" == "chown" ]]; then
            # Extract the user:admin part
            local ownership="${@:2}"
            ownership=$(echo "$ownership" | cut -d' ' -f1)

            # Extract the directory part
            local directory="${@:2}"
            directory=$(echo "$directory" | cut -d' ' -f2-)

            # Create any directories being chown'd
            directory=$(echo "$directory" | sed 's/"//g')
            mkdir -p "$directory" 2>/dev/null || true

            return 0
        elif [[ "$1" == "mkdir" ]]; then
            # Create any directories
            local dir_path="${@:2}"
            dir_path=$(echo "$dir_path" | sed 's/"//g')
            mkdir -p "$dir_path" 2>/dev/null || true
            return 0
        fi
        return 0
    }

    # Mock brew to pretend it exists
    brew() {
        if [[ "$1" == "update" ]]; then
            echo "Would update Homebrew" >> "$TEST_DIR/tmp/executed_commands.log"
            return 0
        elif [[ "$1" == "install" ]]; then
            echo "Would install $2" >> "$TEST_DIR/tmp/executed_commands.log"
            return 0
        elif [[ "$1" == "update-reset" ]]; then
            echo "Would reset Homebrew" >> "$TEST_DIR/tmp/executed_commands.log"
            return 0
        elif [[ "$1" == "--cache" ]]; then
            echo "$TEST_DIR/tmp/homebrew/cache"
            return 0
        fi
        return 0
    }

    # Run the function
    run check_performance_deps

    # Should succeed
    [ "$status" -eq 0 ]

    # Check that brew commands were called
    [ -f "$TEST_DIR/tmp/executed_commands.log" ]
    grep -q "Would update Homebrew" "$TEST_DIR/tmp/executed_commands.log"

    # Check that permission fixes were attempted
    [ -f "$TEST_DIR/tmp/sudo_calls.log" ]
    grep -q "sudo: chown" "$TEST_DIR/tmp/sudo_calls.log"
}

@test "check_performance_deps fixes Homebrew update errors" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock command to simulate Homebrew being installed
    command() {
        if [[ "$1" == "-v" && "$2" == "brew" ]]; then
            return 0  # brew found
        fi
        command "$@"
    }

    # Counter to simulate Homebrew update failing first then succeeding
    update_count=0

    # Mock brew to simulate update failure then success
    brew() {
        if [[ "$1" == "update" ]]; then
            update_count=$((update_count + 1))
            if [ "$update_count" -eq 1 ]; then
                echo "Error: Failed to update Homebrew" >> "$TEST_DIR/tmp/executed_commands.log"
                return 1  # First update fails
            else
                echo "Updated Homebrew successfully" >> "$TEST_DIR/tmp/executed_commands.log"
                return 0  # Second update succeeds
            fi
        elif [[ "$1" == "install" ]]; then
            echo "Would install $2" >> "$TEST_DIR/tmp/executed_commands.log"
            return 0
        elif [[ "$1" == "update-reset" ]]; then
            echo "Reset Homebrew" >> "$TEST_DIR/tmp/executed_commands.log"
            return 0
        elif [[ "$1" == "--cache" ]]; then
            echo "$TEST_DIR/tmp/homebrew/cache"
            return 0
        fi
        return 0
    }

    # Mock rm to track cache removal
    rm() {
        echo "rm: $@" >> "$TEST_DIR/tmp/executed_commands.log"
        return 0
    }

    # Run the function
    run check_performance_deps

    # Should succeed
    [ "$status" -eq 0 ]

    # Check that brew update-reset was called after failure
    [ -f "$TEST_DIR/tmp/executed_commands.log" ]
    grep -q "Error: Failed to update Homebrew" "$TEST_DIR/tmp/executed_commands.log"
    grep -q "Reset Homebrew" "$TEST_DIR/tmp/executed_commands.log"
    grep -q "Updated Homebrew successfully" "$TEST_DIR/tmp/executed_commands.log"
}

@test "check_performance_deps installs XMLStarlet if missing" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock command to simulate Homebrew installed but XMLStarlet missing
    command() {
        if [[ "$1" == "-v" && "$2" == "brew" ]]; then
            return 0  # brew found
        elif [[ "$1" == "-v" && "$2" == "xmlstarlet" ]]; then
            return 1  # xmlstarlet not found
        fi
        command "$@"
    }

    # Mock brew to track installations
    brew() {
        if [[ "$1" == "update" ]]; then
            echo "Updated Homebrew" >> "$TEST_DIR/tmp/executed_commands.log"
            return 0
        elif [[ "$1" == "install" ]]; then
            echo "Installing $2" >> "$TEST_DIR/tmp/executed_commands.log"
            return 0
        fi
        return 0
    }

    # Run the function
    run check_performance_deps

    # Should succeed
    [ "$status" -eq 0 ]

    # Check that XMLStarlet was installed
    [ -f "$TEST_DIR/tmp/executed_commands.log" ]
    grep -q "Installing xmlstarlet" "$TEST_DIR/tmp/executed_commands.log"
}

@test "check_performance_deps handles missing Homebrew subdirectories" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock command to simulate Homebrew installed
    command() {
        if [[ "$1" == "-v" && "$2" == "brew" ]]; then
            return 0  # brew found
        fi
        command "$@"
    }

    # Mock directory checks to simulate some directories missing
    [ -d() {
        local path="$1"
        if [[ "$path" == "/opt/homebrew" ]]; then
            return 0  # Homebrew directory exists
        elif [[ "$path" == "/opt/homebrew/share/zsh/site-functions" ]]; then
            return 1  # This directory is missing
        fi
        [[ -d "$path" ]]  # Normal behavior for other paths
    }

    # Mock sudo to track directory creation
    sudo() {
        echo "sudo: $@" >> "$TEST_DIR/tmp/sudo_calls.log"
        if [[ "$1" == "mkdir" ]]; then
            mkdir -p "${@:2}" 2>/dev/null || true
        fi
        return 0
    }

    # Mock brew update to succeed
    brew() {
        if [[ "$1" == "update" ]]; then
            echo "Updated Homebrew" >> "$TEST_DIR/tmp/executed_commands.log"
            return 0
        fi
        return 0
    }

    # Run the function
    run check_performance_deps

    # Should succeed
    [ "$status" -eq 0 ]

    # Check that missing directories were created
    [ -f "$TEST_DIR/tmp/sudo_calls.log" ]
    grep -q "sudo: mkdir" "$TEST_DIR/tmp/sudo_calls.log"
}
