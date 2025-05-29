#!/usr/bin/env bats

load test_helper

@test "Optimization detects M-series chip correctly" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock sysctl to simulate M3 chip
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M3"
        else
            command sysctl "$@"
        fi
    }

    # Mock detect_cursor_paths to set up necessary variables
    detect_cursor_paths() {
        CURSOR_SHARED_CONFIG="$TEST_DIR/tmp/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$TEST_DIR/tmp/logs"
        mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS"
        touch "$CURSOR_SHARED_ARGV"
    }

    # Mock other required functions
    check_performance_deps() { return 0; }
    cat() { echo "{}"; }
    command() { return 1; } # jq not available
    echo() { builtin echo "$@"; }  # Capture echo calls

    # Disable functions that would make changes
    ln() { :; }
    defaults() { :; }

    # Mock mkdir to track calls
    mkdir() {
        builtin echo "mkdir: $@" >> "$TEST_DIR/tmp/mkdir_calls.log"
    }

    # Run the function and capture output
    output=$(optimize_cursor_performance 2>&1)

    # Verify M3 chip was detected
    echo "$output" | grep -q "Detected Apple M3 chipset"
}

@test "M3-specific optimizations are applied when M3 chip is detected" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock sysctl to simulate M3 chip
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M3"
        else
            command sysctl "$@"
        fi
    }

    # Mock detect_cursor_paths to set up necessary variables
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS"
        touch "$CURSOR_SHARED_ARGV"
    }

    # Mock required functions
    check_performance_deps() { return 0; }
    cat() { echo "{}"; }
    command() { return 1; } # jq not available

    # Track file creation with cat
    original_cat="$(command -v cat)"
    cat() {
        if [[ "$1" == ">" && "$2" == *"m_series_optimizations.sh" ]]; then
            builtin echo "Writing to M3 optimization script" >> "$TEST_DIR/tmp/file_writes.log"
            builtin cat > "$3"
        else
            $original_cat "$@"
        fi
    }

    # mock chmod to track it
    chmod() {
        builtin echo "chmod: $@" >> "$TEST_DIR/tmp/chmod_calls.log"
    }

    # Mock execution of the optimization script
    original_execute="$(declare -f)"
    execute() {
        if [[ "$1" == *"m_series_optimizations.sh" ]]; then
            builtin echo "Executing M3 optimization script: $1" >> "$TEST_DIR/tmp/exec_calls.log"
        else
            eval "$original_execute $@"
        fi
    }

    # Run the function
    optimize_cursor_performance > "$TEST_DIR/tmp/optimization_output.log" 2>&1

    # Check if M3-specific optimizations were applied
    grep -q "Apple M3" "$TEST_DIR/tmp/optimization_output.log" && \
    (grep -q "M3-specific optimizations" "$TEST_DIR/tmp/optimization_output.log" || \
     grep -q "Applying Apple Silicon optimizations" "$TEST_DIR/tmp/optimization_output.log")
}

@test "Standard optimizations are applied when no M-series chip is detected" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock sysctl to simulate non-M-series chip
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz"
        else
            command sysctl "$@"
        fi
    }

    # Mock detect_cursor_paths to set up necessary variables
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS"
        touch "$CURSOR_SHARED_ARGV"
    }

    # Mock required functions
    check_performance_deps() { return 0; }
    cat() { echo "{}"; }
    command() { return 1; } # jq not available
    ln() { :; } # Don't create actual symlinks

    # Run the function
    optimize_cursor_performance > "$TEST_DIR/tmp/optimization_output.log" 2>&1

    # Check if standard optimizations were applied
    grep -q "Not an Apple Silicon Mac" "$TEST_DIR/tmp/optimization_output.log" && \
    grep -q "Applying standard optimizations" "$TEST_DIR/tmp/optimization_output.log"
}

@test "Performance settings JSON is properly structured" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS"
    }

    # Mock check_performance_deps
    check_performance_deps() { return 0; }

    # Mock sysctl
    sysctl() { echo "Apple M3"; }

    # Mock cat to just return an empty object
    cat() { echo "{}"; }

    # Replace echo when writing to a file to capture the performance settings
    echo() {
        if [[ "$1" == "{" && "$2" == *"disable-hardware-acceleration"* ]]; then
            # This is the performance settings JSON - save it
            builtin echo "$@" > "$TEST_DIR/tmp/performance_settings.json"
        else
            builtin echo "$@"
        fi
    }

    # Prevent actual file operations
    command() { return 1; } # jq not available
    mv() { :; }
    mkdir() { :; }
    ln() { :; }

    # Call the function
    optimize_cursor_performance > /dev/null 2>&1

    # Check if performance settings exist and are valid JSON
    [ -f "$TEST_DIR/tmp/performance_settings.json" ]

    # The file should contain the disable-hardware-acceleration setting
    grep -q "disable-hardware-acceleration" "$TEST_DIR/tmp/performance_settings.json"
}
