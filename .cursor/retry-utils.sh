#!/bin/bash

# Utility functions for retry operations and logging

# Retry a command a specified number of times with exponential backoff
# Usage: retry <max_attempts> <delay> <command> [args...]
function retry() {
    local max_attempts=$1
    local delay=$2
    shift 2  # Remove the first two arguments, leaving the command and its arguments
    
    local attempt=1
    
    until "$@"; do
        if (( attempt == max_attempts )); then
            echo "Command '$*' failed after $max_attempts attempts"
            return 1
        fi
        
        echo "Command '$*' failed, attempt $attempt/$max_attempts. Retrying in ${delay}s..."
        sleep $delay
        attempt=$((attempt + 1))
        delay=$((delay * 2))  # Exponential backoff
    done
    
    return 0
}

# Run a command with a timeout
# Usage: run_with_timeout <timeout_seconds> <command> [args...]
function run_with_timeout() {
    local timeout=$1
    shift
    
    # Start the command in the background
    "$@" &
    local pid=$!
    
    # Start a subshell to kill the command after the timeout
    (
        sleep $timeout
        kill -TERM $pid 2>/dev/null
        echo "Command '$*' timed out after ${timeout}s"
    ) &
    local watchdog_pid=$!
    
    # Wait for the command to finish
    wait $pid 2>/dev/null
    local status=$?
    
    # Kill the watchdog
    kill -TERM $watchdog_pid 2>/dev/null
    
    return $status
}

# Ensure a directory exists
# Usage: ensure_dir <directory>
function ensure_dir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || return 1
    fi
    return 0
}

# Ensure a file exists
# Usage: ensure_file <file>
function ensure_file() {
    local file=$1
    if [ ! -f "$file" ]; then
        touch "$file" || return 1
    fi
    return 0
}

# Initialize logging
# Usage: init_logging <log_file>
function init_logging() {
    local log_file=$1
    ensure_dir "$(dirname "$log_file")"
    ensure_file "$log_file"
    echo "--- Logging initialized at $(date) ---" >> "$log_file"
}

# Log a message to a file and stdout
# Usage: log_message <log_file> <message>
function log_message() {
    local log_file=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message" | tee -a "$log_file"
}

# Export functions
export -f retry
export -f run_with_timeout
export -f ensure_dir
export -f ensure_file
export -f init_logging
export -f log_message 