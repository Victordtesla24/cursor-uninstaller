#!/bin/bash

# Utility functions for retry operations and logging

# Retry utils for background agent installation
# This script provides functions for retry logic and timeout handling

# Default repository URL if not provided through environment
: "${GITHUB_REPO_URL:=https://github.com/Victordtesla24/cursor-uninstaller.git}"

# Ensure directories exist with proper error handling
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || {
            echo "ERROR: Failed to create directory: $dir" >&2
            return 1
        }
    fi
    return 0
}

# Ensure log file exists with proper error handling
ensure_file() {
    local file="$1"
    local dir=$(dirname "$file")

    # First ensure parent directory exists
    ensure_dir "$dir" || return 1

    if [ ! -f "$file" ]; then
        touch "$file" || {
            echo "ERROR: Failed to create file: $file" >&2
            return 1
        }
    fi
    return 0
}

# Initialize logging with better error handling
init_logging() {
    local log_file="$1"
    ensure_dir "$(dirname "$log_file")" || return 1
    ensure_file "$log_file" || return 1
    echo "--- Logging initialized at $(date) ---" >> "$log_file" 2>/dev/null || {
        echo "ERROR: Failed to write to log file: $log_file" >&2
        return 1
    }
    return 0
}

# Logging function
log_retry() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_message="[$timestamp] RETRY: $message"

    # First try to write to log file, fallback to stderr if that fails
    if [ -f ".cursor/agent.log" ] && [ -w ".cursor/agent.log" ]; then
        echo "$log_message" | tee -a ".cursor/agent.log" 2>/dev/null || echo "$log_message" >&2
    else
        echo "$log_message" >&2
    fi
}

# Retry a command with exponential backoff
# Usage: retry <max_attempts> <delay> <command>
retry() {
    local max_attempts=$1
    local delay=$2
    local attempt=1
    shift 2

    until "$@"; do
        exit_code=$?

        if [ $attempt -ge $max_attempts ]; then
            log_retry "Command '$*' failed after $max_attempts attempts with exit code $exit_code."
            return $exit_code
        fi

        log_retry "Command '$*' failed with exit code $exit_code. Retrying in ${delay}s (attempt $attempt/$max_attempts)..."
        sleep $delay
        attempt=$((attempt + 1))
        delay=$((delay * 2))
    done

    return 0
}

# Run a command with a timeout
# Usage: run_with_timeout <timeout_seconds> <command>
run_with_timeout() {
    local timeout=$1
    shift

    # Use timeout command if available
    if command -v timeout &> /dev/null; then
        timeout $timeout "$@"
        return $?
    else
        # Fallback using background process and kill
        log_retry "timeout command not available, using fallback method"

        # Run the command in the background
        "$@" &
        local pid=$!

        # Start the timer
        (
            sleep $timeout
            kill -0 $pid 2>/dev/null && {
                log_retry "Command '$*' timed out after ${timeout}s, killing process $pid"
                kill -TERM $pid 2>/dev/null || kill -KILL $pid 2>/dev/null
            }
        ) &
        local timer_pid=$!

        # Wait for the command to complete
        wait $pid 2>/dev/null
        local exit_code=$?

        # Kill the timer
        kill -TERM $timer_pid 2>/dev/null || kill -KILL $timer_pid 2>/dev/null

        return $exit_code
    fi
}

# Log a message to a file and stdout with fallback
# Usage: log_message <log_file> <message>
log_message() {
    local log_file=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local formatted_message="[$timestamp] $message"

    if [ -f "$log_file" ] && [ -w "$log_file" ]; then
        echo "$formatted_message" | tee -a "$log_file" 2>/dev/null || echo "$formatted_message" >&2
    else
        echo "$formatted_message" >&2
    fi
}

# Check if the environment has GitHub access configured
check_github_access() {
    log_retry "Checking GitHub access..."

    # Check if git is installed
    if ! command -v git &> /dev/null; then
        log_retry "Git is not installed. Cannot check GitHub access."
        return 1
    fi

    # Try up to 3 times with increasing delay
    local attempt=1
    local max_attempts=3
    local delay=2

    while [ $attempt -le $max_attempts ]; do
        # Check if we can access GitHub
        if git ls-remote --quiet "${GITHUB_REPO_URL}" HEAD &> /dev/null; then
            log_retry "GitHub access check passed."
            return 0
        else
            if [ $attempt -lt $max_attempts ]; then
                log_retry "GitHub access failed (attempt $attempt/$max_attempts). Retrying in ${delay}s..."
                sleep $delay
                delay=$((delay * 2))
                attempt=$((attempt + 1))
            else
                log_retry "GitHub access failed after $max_attempts attempts. Check your credentials."
                return 1
            fi
        fi
    done

    # This should not be reached, but just in case
    return 1
}

# Export functions
export -f retry
export -f run_with_timeout
export -f ensure_dir
export -f ensure_file
export -f init_logging
export -f log_message
export -f check_github_access
