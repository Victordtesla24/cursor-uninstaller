#!/bin/bash

set -e

# Utility functions for retry operations and logging

# Retry utils for background agent installation
# This script provides functions for retry logic and timeout handling

# Source environment variables if GITHUB_REPO_URL is not already set by caller
if [ -z "${GITHUB_REPO_URL}" ]; then
  if [ -f "$(dirname "${BASH_SOURCE[0]}")/.cursor/load-env.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/.cursor/load-env.sh"
  elif [ -f "./.cursor/load-env.sh" ]; then # If sourced from /agent_workspace
    source "./.cursor/load-env.sh"
  fi
fi

# Default repository URL if not provided through environment or load-env
: "${GITHUB_REPO_URL:=https://github.com/Victordtesla24/cursor-uninstaller.git}"

# Corrected Log Paths
# Assume this script is in .cursor/ and PWD is /agent_workspace when it's called by other .cursor scripts
# or determine path relative to script if sourced directly for some reason.
if [ -n "${BASH_SOURCE[0]}" ] && [ -d "$(dirname "${BASH_SOURCE[0]}")/logs" ]; then
    RETRY_UTILS_LOG_DIR="$(dirname "${BASH_SOURCE[0]}")/logs"
else # Fallback if pathing is tricky during source
    RETRY_UTILS_LOG_DIR=".cursor/logs"
fi
RETRY_UTILS_AGENT_LOG="${RETRY_UTILS_LOG_DIR}/agent.log"

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
    local dir
    dir=$(dirname "$file")

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
    # Use RETRY_UTILS_AGENT_LOG for its own init message if $1 is that log
    if [ "$log_file" == "${RETRY_UTILS_AGENT_LOG}" ]; then
        echo "--- Logging initialized by retry-utils.sh at $(date) --- patterning to ${RETRY_UTILS_AGENT_LOG}" >> "${RETRY_UTILS_AGENT_LOG}" 2>/dev/null || {
            echo "ERROR: Failed to write to log file: ${RETRY_UTILS_AGENT_LOG}" >&2
            return 1
        }
    fi
    return 0
}

# Logging function
log_retry() {
    local message="$1"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_message="[$timestamp] RETRY_UTIL: $message" # Changed prefix to RETRY_UTIL

    # First try to write to log file, fallback to stderr if that fails
    if [ -f "${RETRY_UTILS_AGENT_LOG}" ] && [ -w "${RETRY_UTILS_AGENT_LOG}" ]; then
        echo "$log_message" | tee -a "${RETRY_UTILS_AGENT_LOG}" 2>/dev/null || echo "$log_message" >&2
    else
        # Try to ensure the log directory and file exist one more time before giving up
        ensure_dir "$(dirname "${RETRY_UTILS_AGENT_LOG}")" && ensure_file "${RETRY_UTILS_AGENT_LOG}" && \
        echo "$log_message" | tee -a "${RETRY_UTILS_AGENT_LOG}" 2>/dev/null || echo "$log_message" >&2
    fi
}

# Function to retry a command with exponential backoff
# Usage: retry <max_attempts> <backoff_factor> <command>
retry() {
  local max_attempts=$1
  local backoff_factor=$2
  local cmd=("${@:3}") # Fixed SC2124: Use array assignment
  local attempts=0
  local exit_code=0
  local wait_time=1
  
  echo "Attempt $attempts/$max_attempts: ${cmd[*]}" # Use ${cmd[*]} to print array elements
  
  # Execute the command
  eval "${cmd[*]}" # Use ${cmd[*]} to execute command from array
  exit_code=$?
  
  # If command succeeds, return success
  if [[ $exit_code -eq 0 ]]; then
    echo "Command succeeded on attempt $attempts"
    return 0
  fi
  
  # If this was the last attempt, return failure
  if [[ $attempts -eq $max_attempts ]]; then
    echo "Command failed after $attempts attempts: ${cmd[*]} (exit code: $exit_code)" # Use ${cmd[*]}
    return $exit_code
  fi
  
  # Calculate backoff time
  wait_time=$(bc <<< "scale=1; $backoff_factor * $wait_time" 2>/dev/null || echo "$((backoff_factor * wait_time))")
  
  echo "Command failed (exit code: $exit_code). Retrying in $wait_time seconds..."
  sleep "$wait_time"
}

# Function to run a command with a timeout
# Usage: run_with_timeout <timeout_seconds> <command>
run_with_timeout() {
  local timeout=$1
  local cmd=("${@:2}") # Fixed SC2124: Use array assignment
  local pid=""
  local exit_code=0
  local timed_out_flag_file
  timed_out_flag_file=$(mktemp)
  echo "0" > "${timed_out_flag_file}" # 0 for not timed out, 1 for timed out
  
  echo "Running command with ${timeout}s timeout: ${cmd[*]}" # Use ${cmd[*]}
  
  # Run command in the background
  eval "${cmd[*]}" & # Use ${cmd[*]}
  pid=$!
  
  # Monitor the command with timeout
  {
    sleep "$timeout"
    # Check if the process is still running
    if ps -p $pid > /dev/null; then
      echo "Command timed out after ${timeout}s: ${cmd[*]}" # Use ${cmd[*]}
      kill -TERM $pid >/dev/null 2>&1 || true
      echo "1" > "${timed_out_flag_file}" # Set flag to 1 (timed out)
    fi
  } &  
  local monitor_pid=$!
  
  # Wait for the command to finish
  wait $pid
  exit_code=$?
  
  # Check the timed_out flag from the file
  local timed_out
  timed_out=$(<"${timed_out_flag_file}")
  rm -f "${timed_out_flag_file}"

  # Kill the monitor process if command completed before timeout
  if [[ $timed_out -eq 0 ]]; then
    kill -TERM $monitor_pid >/dev/null 2>&1 || true
    echo "Command completed in under ${timeout}s (exit code: $exit_code)"
  else
    # Return specific error code for timeouts
    exit_code=124
  fi
  
  return $exit_code
}

# Function to run a command with retries and timeout
# Usage: retry_with_timeout <max_attempts> <backoff_factor> <timeout_seconds> <command>
retry_with_timeout() {
  local max_attempts=$1
  local backoff_factor=$2
  local timeout=$3
  local cmd=("${@:4}") # Fixed SC2124: Use array assignment
  
  retry "$max_attempts" "$backoff_factor" "run_with_timeout $timeout ${cmd[*]}" # Pass cmd elements correctly
  return $?
}

# Function to safely clone a git repository with retries
# Usage: safe_git_clone <repo_url> <target_directory> [<max_attempts>] [<backoff_factor>]
safe_git_clone() {
  local repo_url=$1
  local target_dir=$2
  local max_attempts=${3:-3}
  local backoff_factor=${4:-2}
  
  # Check if directory already exists and is a git repository
  if [[ -d "$target_dir/.git" ]]; then
    echo "Git repository already exists at $target_dir. Running git fetch instead."
    (cd "$target_dir" && retry "$max_attempts" "$backoff_factor" "git fetch --all")
    return $?
  fi
  
  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$target_dir")" 2>/dev/null || true
  
  # Attempt to clone the repository
  echo "Cloning repository $repo_url to $target_dir"
  retry "$max_attempts" "$backoff_factor" "git clone $repo_url $target_dir"
  return $?
}

# Function to safely pull updates from a git repository with retries
# Usage: safe_git_pull <directory> [<branch>] [<max_attempts>] [<backoff_factor>]
safe_git_pull() {
  local target_dir=$1
  local branch=${2:-""}
  local max_attempts=${3:-3}
  local backoff_factor=${4:-2}
  
  # Check if directory is a git repository
  if [[ ! -d "$target_dir/.git" ]]; then
    echo "Error: $target_dir is not a git repository"
    return 1
  fi
  
  # Change to the repository directory
  cd "$target_dir" || return 1
  
  # Determine current branch if not specified
  if [[ -z "$branch" ]]; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main") # SC2155 is fine here as it's a common pattern for default assignment.
  fi
  
  echo "Pulling latest changes from $branch in $target_dir"
  retry "$max_attempts" "$backoff_factor" "git pull origin $branch"
  return $?
}

# Function to safely install npm dependencies with retries and timeout
# Usage: safe_npm_install <directory> [<max_attempts>] [<backoff_factor>] [<timeout>]
safe_npm_install() {
  local target_dir=$1
  local max_attempts=${2:-3}
  local backoff_factor=${3:-2}
  local timeout=${4:-300}
  
  # Check if directory exists
  if [[ ! -d "$target_dir" ]]; then
    echo "Error: Directory $target_dir does not exist"
    return 1
  fi
  
  # Change to the target directory
  cd "$target_dir" || return 1
  
  # Check if package.json exists
  if [[ ! -f "package.json" ]]; then
    echo "Error: package.json not found in $target_dir"
    return 1
  fi
  
  echo "Installing npm dependencies in $target_dir (timeout: ${timeout}s)"
  retry_with_timeout "$max_attempts" "$backoff_factor" "$timeout" "npm install"
  return $?
}

# Log a message to a file and stdout with fallback
# Usage: log_message <log_file> <message>
log_message() {
    local log_file=$1
    local message=$2
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    # Use RETRY_UTILS_AGENT_LOG if $log_file is empty or non-specific
    local target_log_file="${log_file:-${RETRY_UTILS_AGENT_LOG}}"
    local formatted_message="[$timestamp] RETRY_MSG: $message" # Changed prefix

    if [ -f "$target_log_file" ] && [ -w "$target_log_file" ]; then
        echo "$formatted_message" | tee -a "$target_log_file" 2>/dev/null || echo "$formatted_message" >&2
    else
        ensure_dir "$(dirname "${target_log_file}")" && ensure_file "${target_log_file}" && \
        echo "$formatted_message" | tee -a "$target_log_file" 2>/dev/null || echo "$formatted_message" >&2
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
export -f retry_with_timeout
export -f safe_git_clone
export -f safe_git_pull
export -f safe_npm_install
export -f ensure_dir
export -f ensure_file
export -f init_logging
export -f log_message
export -f check_github_access
