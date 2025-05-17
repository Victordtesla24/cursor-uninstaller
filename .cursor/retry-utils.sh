#!/bin/bash

# Utility functions for retrying operations
CURSOR_AGENT_LOG=".cursor/agent.log"

# Log message to the agent log file
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[${timestamp}] $1" | tee -a "${CURSOR_AGENT_LOG}"
}

# Function to retry a command with exponential backoff
# Usage: retry <max_attempts> <delay> <command>
retry() {
  local max_attempts=$1
  local delay=$2
  shift 2
  local command="$@"
  local attempt=1
  
  while true; do
    echo "Attempt $attempt of $max_attempts: $command"
    if eval "$command"; then
      echo "Command succeeded on attempt $attempt"
      return 0
    else
      echo "Command failed on attempt $attempt with exit code $?"
      if [ $attempt -ge $max_attempts ]; then
        echo "Maximum attempts reached. Giving up."
        return 1
      fi
      
      sleep_time=$((delay * attempt))
      echo "Sleeping for $sleep_time seconds before next retry..."
      sleep $sleep_time
      attempt=$((attempt + 1))
    fi
  done
}

# Function to run a command with a timeout
# Usage: run_with_timeout <timeout_seconds> <command>
run_with_timeout() {
  local timeout=$1
  shift
  local command="$@"
  
  # Create a background process
  (
    "$@" &
    cmd_pid=$!
    
    # Wait for the command to finish or timeout
    (
      sleep $timeout
      echo "Command timed out after $timeout seconds"
      kill -9 $cmd_pid 2>/dev/null
    ) &
    timeout_pid=$!
    
    # Wait for the command to finish
    wait $cmd_pid 2>/dev/null
    cmd_status=$?
    
    # Kill the timeout process
    kill -9 $timeout_pid 2>/dev/null
    
    exit $cmd_status
  )
}

# Verify that a command returns the expected output
# Usage: verify_output <expected_output_regex> <command>
verify_output() {
  local expected=$1
  shift
  local command="$@"
  
  log "Verifying output of: $command"
  
  local output
  output=$($command 2>&1)
  
  if [[ "$output" =~ $expected ]]; then
    log "Output verification successful"
    return 0
  else
    log "ERROR: Output verification failed."
    log "Expected pattern: $expected"
    log "Actual output: $output"
    return 1
  fi
}

# Check if a command exists
# Usage: command_exists <command>
command_exists() {
  command -v "$1" &> /dev/null
  return $?
}

# Run a command only if another command was successful
# Usage: if_success <condition_command> <command_to_run>
if_success() {
  local condition_command="$1"
  local command_to_run="$2"
  
  if $condition_command; then
    log "Condition met, running: $command_to_run"
    $command_to_run
    return $?
  else
    log "Condition not met, skipping: $command_to_run"
    return 0
  fi
}

# Export functions
export -f log
export -f retry
export -f run_with_timeout
export -f verify_output
export -f command_exists
export -f if_success 