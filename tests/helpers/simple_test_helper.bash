#!/usr/bin/env bash

# Simple test helper that completely mocks all hanging functions
# This will prevent any actual system calls or operations that could cause the tests to hang

# Find the script's directory
TEST_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set test mode flags - triple redundancy to ensure tests don't hang
export CURSOR_TEST_MODE=true
export BATS_TEST_SOURCED=1
export TEST_MODE=true

# Debug output
echo "DEBUG: Simple test helper loaded, test mode flags set" >&2

# Mock all potentially hanging functions with simple stubs
mock_get_script_path() {
  echo "/mocked/path"
}

mock_detect_cursor_paths() {
  # Just pretend this worked and return success
  echo "DEBUG: Mocked detect_cursor_paths called and returned success" >&2
  return 0
}

mock_check_sudo() {
  # Pretend sudo check passed
  echo "DEBUG: Mocked check_sudo called and returned success" >&2
  return 0
}

mock_safe_remove() {
  local path="$1"
  echo "DEBUG: Mocked safe_remove called for $path" >&2
  return 0
}

mock_clean_databases() {
  echo "DEBUG: Mocked clean_databases called" >&2
  return 0
}

mock_update_status() {
  # Do nothing
  return 0
}

mock_run_task() {
  local task_name="$1"
  shift
  echo "DEBUG: Mocked run_task called for task: $task_name" >&2
  return 0
}

mock_verify_complete_removal() {
  echo "DEBUG: Mocked verify_complete_removal called" >&2
  return 0
}

mock_uninstall_cursor() {
  echo "DEBUG: Mocked uninstall_cursor called" >&2
  return 0
}

mock_clean_up_lingering_files() {
  echo "DEBUG: Mocked clean_up_lingering_files called" >&2
  return 0
}

mock_optimize_cursor_performance() {
  echo "DEBUG: Mocked optimize_cursor_performance called" >&2
  return 0
}

# Export all mocked functions so tests can use them
export -f mock_get_script_path
export -f mock_detect_cursor_paths
export -f mock_check_sudo
export -f mock_safe_remove
export -f mock_clean_databases
export -f mock_update_status
export -f mock_run_task
export -f mock_verify_complete_removal
export -f mock_uninstall_cursor
export -f mock_clean_up_lingering_files
export -f mock_optimize_cursor_performance

# Basic test setup and teardown to ensure clean environment
setup() {
  echo "DEBUG: Simple test setup running" >&2
  # Create empty test directories as needed
  mkdir -p "$TEST_DIR/tmp" 2>/dev/null || true
}

teardown() {
  echo "DEBUG: Simple test teardown running" >&2
  # Clean up environment variables
  unset CURSOR_TEST_MODE
  unset BATS_TEST_SOURCED
  unset TEST_MODE
}
