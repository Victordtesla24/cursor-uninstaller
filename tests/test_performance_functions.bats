#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/Shared/cursor/config"
    mkdir -p "$TEST_DIR/tmp/Shared/cursor/logs"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "check_performance_deps detects and installs Homebrew if missing" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock command to simulate Homebrew not installed
    command() {
        if [[ "$1" == "-v" && "$2" == "brew" ]]; then
            return 1  # Homebrew not found
        else
            command "$@"
        fi
    }

    # Mock curl for Homebrew installation
    curl() {
        echo "CURL: Downloading Homebrew" >> "$TEST_DIR/tmp/homebrew_operations.log"
        return 0
    }

    # Mock bash to capture Homebrew install script execution
    bash() {
        if [[ "$1" == "-c" && "$2" == *"Homebrew"* ]]; then
            echo "BASH: Installing Homebrew" >> "$TEST_DIR/tmp/homebrew_operations.log"
            return 0
        else
            command bash "$@"
        fi
    }

    # Mock eval for Homebrew PATH setup
    eval() {
        if [[ "$1" == *"brew shellenv"* ]]; then
            echo "EVAL: Setting up Homebrew PATH" >> "$TEST_DIR/tmp/homebrew_operations.log"
            return 0
        else
            builtin eval "$@"
        fi
    }

    # Run the function
    run check_performance_deps

    # Check that it attempted to install Homebrew
    [ -f "$TEST_DIR/tmp/homebrew_operations.log" ]
    grep -q "Installing Homebrew" "$TEST_DIR/tmp/homebrew_operations.log"
}

@test "check_performance_deps fixes Homebrew permissions" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock command to simulate Homebrew is installed
    command() {
        if [[ "$1" == "-v" && "$2" == "brew" ]]; then
            return 0  # Homebrew found
        else
            command "$@"
        fi
    }

    # Mock chown to track permission fixes
    chown() {
        echo "CHOWN: $@" >> "$TEST_DIR/tmp/permission_operations.log"
        return 0
    }

    # Mock sudo
    sudo() {
        if [[ "$1" == "chown" ]]; then
            echo "SUDO CHOWN: $@" >> "$TEST_DIR/tmp/permission_operations.log"
            return 0
        else
            command sudo "$@"
        fi
    }

    # Mock directory existence check
    [ () {
        if [[ "$1" == "-d" && "$2" == "/opt/homebrew" ]]; then
            return 0  # Directory exists
        else
            builtin [ "$@"
        fi
    }

    # Run the function
    run check_performance_deps

    # Check that it attempted to fix permissions
    [ -f "$TEST_DIR/tmp/permission_operations.log" ]
    grep -q "SUDO CHOWN:" "$TEST_DIR/tmp/permission_operations.log"
}

@test "check_performance_deps handles brew update failures gracefully" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock command to simulate Homebrew is installed
    command() {
        if [[ "$1" == "-v" && "$2" == "brew" ]]; then
            return 0  # Homebrew found
        else
            command "$@"
        fi
    }

    # Mock brew command with update failure
    brew() {
        if [[ "$1" == "update" ]]; then
            echo "BREW: Update failed" >> "$TEST_DIR/tmp/brew_operations.log"
            return 1  # Update fails
        elif [[ "$1" == "update-reset" ]]; then
            echo "BREW: Update reset" >> "$TEST_DIR/tmp/brew_operations.log"
            return 0
        } else {
            echo "BREW: $@" >> "$TEST_DIR/tmp/brew_operations.log"
            return 0
        }
    }

    # Mock directory existence check
    [ () {
        if [[ "$1" == "-d" && "$2" == "/opt/homebrew" ]]; then
            return 0  # Directory exists
        else
            builtin [ "$@"
        fi
    }

    # Run the function
    run check_performance_deps

    # Check that it attempted to recover from update failure
    [ -f "$TEST_DIR/tmp/brew_operations.log" ]
    grep -q "BREW: Update failed" "$TEST_DIR/tmp/brew_operations.log"
    grep -q "BREW: Update reset" "$TEST_DIR/tmp/brew_operations.log"
}

@test "optimize_cursor_performance detects M-series chip correctly" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock system commands for M3 detection
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M3"
            return 0
        fi
        command sysctl "$@"
    }

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        mkdir -p "$CURSOR_SHARED_CONFIG"
        mkdir -p "$CURSOR_SHARED_LOGS"
        echo "{}" > "$CURSOR_SHARED_ARGV"
        return 0
    }

    # Mock check_performance_deps
    check_performance_deps() {
        return 0
    }

    # Mock other functions
    cat() {
        if [[ "$1" == "$CURSOR_SHARED_ARGV" ]]; then
            echo "{}"
            return 0
        fi
        command cat "$@"
    }

    command() {
        return 1  # jq not available
    }

    ln() { return 0; }
    mkdir() { command mkdir -p "$@"; return 0; }
    chmod() { return 0; }

    # Track info messages
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    # Run the function
    optimize_cursor_performance

    # Check that it detected M3 chip
    [ -f "$TEST_DIR/tmp/info_messages.log" ]
    grep -q "Detected Apple M3" "$TEST_DIR/tmp/info_messages.log"
}

@test "optimize_cursor_performance applies M3-specific optimizations" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock system commands for M3 detection
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M3"
            return 0
        fi
        command sysctl "$@"
    }

    # Mock uname for architecture detection
    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "arm64"
            return 0
        fi
        command uname "$@"
    }

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        mkdir -p "$CURSOR_SHARED_CONFIG"
        mkdir -p "$CURSOR_SHARED_LOGS"
        echo "{}" > "$CURSOR_SHARED_ARGV"
        return 0
    }

    # Mock check_performance_deps
    check_performance_deps() {
        return 0
    }

    # Track file operations
    cat() {
        # When reading argv.json for update
        if [[ "$1" == "$CURSOR_SHARED_ARGV" ]]; then
            echo "{}"
            return 0
        # When writing to m_series_optimizations.sh
        elif [[ "$1" == ">" && "$3" == *"m_series_optimizations.sh" ]]; then
            echo "WRITING M3 OPTIMIZATIONS to $3" >> "$TEST_DIR/tmp/file_operations.log"
            command cat > "$3"
            return 0
        else
            command cat "$@"
        fi
    }

    # Run the function
    optimize_cursor_performance

    # Check that M3-specific optimizations are applied
    grep -q "metal.resource-heap-size-mb" "$CURSOR_SHARED_CONFIG/defaults/m_series_optimizations.sh" || \
    grep -q "M3-specific optimizations" "$CURSOR_SHARED_CONFIG/defaults/m_series_optimizations.sh"
}

@test "optimize_cursor_performance creates Metal optimizations for Apple Silicon" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock system commands for M1 detection
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M1"
            return 0
        fi
        command sysctl "$@"
    }

    # Mock uname for architecture detection
    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "arm64"
            return 0
        fi
        command uname "$@"
    }

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        mkdir -p "$CURSOR_SHARED_CONFIG"
        mkdir -p "$CURSOR_SHARED_LOGS"
        echo "{}" > "$CURSOR_SHARED_ARGV"
        return 0
    }

    # Mock check_performance_deps
    check_performance_deps() {
        return 0
    }

    # Run the function
    optimize_cursor_performance

    # Check for Metal-specific optimization
    grep -q "MetalEnabled -bool true" "$CURSOR_SHARED_CONFIG/defaults/m_series_optimizations.sh"
}

@test "optimize_cursor_performance creates fallback settings for non-Apple Silicon" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock system commands for Intel CPU
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Intel(R) Core(TM) i9-9900K CPU @ 3.60GHz"
            return 0
        fi
        command sysctl "$@"
    }

    # Mock uname for architecture detection
    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "x86_64"
            return 0
        fi
        command uname "$@"
    }

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        mkdir -p "$CURSOR_SHARED_CONFIG"
        mkdir -p "$CURSOR_SHARED_LOGS"
        echo "{}" > "$CURSOR_SHARED_ARGV"
        return 0
    }

    # Mock check_performance_deps
    check_performance_deps() {
        return 0
    }

    # Track info messages
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    # Run the function
    optimize_cursor_performance

    # Check for non-Apple Silicon message and standard optimizations
    [ -f "$TEST_DIR/tmp/info_messages.log" ]
    grep -q "Not an Apple Silicon Mac" "$TEST_DIR/tmp/info_messages.log"
    grep -q "Applying standard optimizations" "$TEST_DIR/tmp/info_messages.log"
}

@test "optimize_cursor_performance configures appropriate hardware acceleration" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        mkdir -p "$CURSOR_SHARED_CONFIG"
        mkdir -p "$CURSOR_SHARED_LOGS"
        echo "{}" > "$CURSOR_SHARED_ARGV"
        return 0
    }

    # Mock check_performance_deps
    check_performance_deps() {
        return 0
    }

    # Run the function
    optimize_cursor_performance

    # Verify hardware acceleration settings in argv.json
    grep -q "disable-hardware-acceleration\": false" "$CURSOR_SHARED_ARGV"
    grep -q "gpu-rasterization\": true" "$CURSOR_SHARED_ARGV"
    grep -q "ignore-gpu-blocklist\": true" "$CURSOR_SHARED_ARGV"
}

@test "reset_performance_settings removes optimizations" {
    # Source the script
    source "$SCRIPT_PATH"

    # Setup directories and files
    mkdir -p "$TEST_DIR/tmp/Library/Application Support/Cursor"
    echo '{"disable-hardware-acceleration": false, "webgl": true}' > "$TEST_DIR/tmp/Library/Application Support/Cursor/argv.json"

    # Mock CURSOR_ARGV
    CURSOR_ARGV="$TEST_DIR/tmp/Library/Application Support/Cursor/argv.json"

    # Mock defaults command to capture operations
    defaults() {
        if [[ "$1" == "delete" ]]; then
            echo "DEFAULTS DELETE: $@" >> "$TEST_DIR/tmp/defaults_operations.log"
            return 0
        else
            command defaults "$@"
        fi
    }

    # Mock jq
    jq() {
        echo "JQ: $@" >> "$TEST_DIR/tmp/jq_operations.log"
        # Simulate removing hardware acceleration setting
        echo '{}'
        return 0
    }

    # Mock sed
    sed() {
        echo "SED: $@" >> "$TEST_DIR/tmp/sed_operations.log"
        return 0
    }

    # Mock command function to claim jq is available
    command() {
        if [[ "$1" == "-v" && "$2" == "jq" ]]; then
            return 0  # jq is available
        else
            command "$@"
        fi
    }

    # Run the function
    reset_performance_settings

    # Check that defaults were deleted
    [ -f "$TEST_DIR/tmp/defaults_operations.log" ]
    grep -q "DEFAULTS DELETE: com.cursor.Cursor WebGPUEnabled" "$TEST_DIR/tmp/defaults_operations.log" || \
    grep -q "DEFAULTS DELETE: com.cursor.Cursor MetalEnabled" "$TEST_DIR/tmp/defaults_operations.log"
}

@test "check_performance_settings reports current optimization status" {
    # Source the script
    source "$SCRIPT_PATH"

    # Setup argv.json with hardware acceleration enabled
    mkdir -p "$TEST_DIR/tmp/Library/Application Support/Cursor"
    echo '{"disable-hardware-acceleration": false}' > "$TEST_DIR/tmp/Library/Application Support/Cursor/argv.json"

    # Mock CURSOR_ARGV
    CURSOR_ARGV="$TEST_DIR/tmp/Library/Application Support/Cursor/argv.json"

    # Mock defaults read to report enabled settings
    defaults() {
        if [[ "$1" == "read" && "$2" == "com.cursor.Cursor" ]]; then
            if [[ "$3" == "WebGPUEnabled" ]]; then
                echo "1"
            elif [[ "$3" == "MetalEnabled" ]]; then
                echo "1"
            else
                return 1
            fi
            return 0
        else
            command defaults "$@"
        fi
    }

    # Mock info_message
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    # Capture function output
    output=$(check_performance_settings)

    # Check that it reports the correct status
    echo "$output" | grep -q "Hardware acceleration enabled"
    echo "$output" | grep -q "WebGPU enabled"
    echo "$output" | grep -q "Metal acceleration enabled"
}

@test "enhanced_optimize_cursor_performance provides error handling" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock optimize_cursor_performance to fail
    optimize_cursor_performance() {
        return 1  # Simulate failure
    }

    # Mock message functions
    error_message() {
        echo "ERROR: $1" >> "$TEST_DIR/tmp/error_messages.log"
    }

    echo() {
        if [[ "$1" == *"YELLOW"* ]]; then
            echo "ECHO: $@" >> "$TEST_DIR/tmp/echo_operations.log"
        else
            builtin echo "$@"
        fi
    }

    # Run the enhanced wrapper
    enhanced_optimize_cursor_performance

    # Check that it handled the error
    [ -f "$TEST_DIR/tmp/echo_operations.log" ]
    grep -q "Encountered errors during performance optimization" "$TEST_DIR/tmp/echo_operations.log"
}
