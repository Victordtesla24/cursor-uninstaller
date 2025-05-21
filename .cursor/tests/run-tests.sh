#!/bin/bash
# Master Test Runner for Cursor Background Agent
# This script runs all tests and reports results

# Enable stricter error handling
set -e
set -o pipefail # This ensures pipeline failures are properly captured

# Define color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "${SCRIPT_DIR}")")"
LOG_DIR="${REPO_ROOT}/.cursor/logs"
MASTER_LOG="${LOG_DIR}/master-test-run.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}" || { echo "Failed to create log directory"; exit 1; }

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] MASTER-TEST: $1" | tee -a "${MASTER_LOG}"
}

# Start with clean logs
if [ -f "${REPO_ROOT}/.cursor/flush-logs.sh" ]; then
  bash "${REPO_ROOT}/.cursor/flush-logs.sh"
  log "${BLUE}${BOLD}====== Starting Cursor Background Agent Tests ======${NC}"
else
  # Create a clean master log if flush-logs.sh is not available
  > "${MASTER_LOG}"
  log "${BLUE}${BOLD}====== Starting Cursor Background Agent Tests ======${NC}"
  log "${RED}✗ Error: flush-logs.sh not found. This file is required for proper test execution.${NC}"
  log "${RED}✗ Please ensure the file ${REPO_ROOT}/.cursor/flush-logs.sh exists and is executable.${NC}"
  exit 1
fi

log "${BLUE}Test directory: ${SCRIPT_DIR}${NC}"
log "${BLUE}============================================================${NC}"

# Array of test scripts to run
TESTS=(
  "test-env-setup.sh"
  "test-github-integration.sh"
  "test-docker-env.sh"
  "test-background-agent.sh"
  "test-agent-runtime.sh"
  "test-linting.sh"
)

# Initialize counters
TOTAL_TESTS=${#TESTS[@]}
PASSED_TESTS=0
FAILED_TESTS=0
FAILED_TEST_NAMES=()

# Run each test
for test_script_name in "${TESTS[@]}"; do
  test_path="${SCRIPT_DIR}/${test_script_name}"
  test_log_file="${LOG_DIR}/${test_script_name}.log"
  
  # Skip if test doesn't exist but count as failure
  if [ ! -f "${test_path}" ]; then
    log "${RED}✗ Test SCRIPT NOT FOUND: ${test_script_name}${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    FAILED_TEST_NAMES+=("${test_script_name} (SCRIPT NOT FOUND)")
    continue
  fi
  
  # Ensure test is executable
  if [ ! -x "${test_path}" ]; then
    log "${RED}✗ Test script NOT EXECUTABLE: ${test_script_name}${NC}"
    # Attempt to make it executable
    if chmod +x "${test_path}"; then
        log "${YELLOW}⚠ Made ${test_script_name} executable. This should be set by default.${NC}"
    else
        log "${RED}✗ CRITICAL: Failed to make ${test_script_name} executable. Skipping.${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_TEST_NAMES+=("${test_script_name} (PERMISSION ERROR - NOT EXECUTABLE)")
        continue
    fi
  fi
  
  log "${BLUE}Running test: ${test_script_name}${NC}"
  log "${BLUE}Log file: ${test_log_file}${NC}"
  
  # Clear any previous log content for this specific test
  > "${test_log_file}" 

  # Create a temporary file to capture script output
  temp_output=$(mktemp)
  
  # Run the test script in a subshell to avoid exit issues
  # Properly capture both stdout/stderr and exit code
  (bash "${test_path}" 2>&1 | tee -a "${test_log_file}" > "${temp_output}"; exit ${PIPESTATUS[0]})
  SCRIPT_EXIT_CODE=$?

  # Verify output existence
  if [ ! -s "${temp_output}" ]; then
    log "${RED}✗ Test produced NO OUTPUT: ${test_script_name}${NC}"
    echo "ERROR: Test script produced no output" >> "${test_log_file}"
    
    # No output is always considered a failure - tests must produce diagnostic output
    if [ ${SCRIPT_EXIT_CODE} -eq 0 ]; then
      log "${RED}✗ Test returned success but produced no output. This is invalid and will be treated as a failure.${NC}"
      SCRIPT_EXIT_CODE=1 # Force failure for silent tests
    else
      log "${RED}✗ CRITICAL: Test failed with no output. Cannot diagnose issue.${NC}"
    fi
    
    # Mark as failure due to no output
    FAILED_TESTS=$((FAILED_TESTS + 1))
    FAILED_TEST_NAMES+=("${test_script_name} (NO OUTPUT)")
  else
    # Check the exit code to determine pass/fail
    if [ ${SCRIPT_EXIT_CODE} -eq 0 ]; then
      log "${GREEN}✓ Test PASSED: ${test_script_name}${NC}"
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      log "${RED}✗ Test FAILED: ${test_script_name} (Exit Code: ${SCRIPT_EXIT_CODE})${NC}"
      log "${RED}✗ See ${test_log_file} for details${NC}"
      FAILED_TESTS=$((FAILED_TESTS + 1))
      FAILED_TEST_NAMES+=("${test_script_name} (Exit Code: ${SCRIPT_EXIT_CODE})")
    fi
  fi
  
  # Clean up the temporary file
  rm -f "${temp_output}"
  
  log "${BLUE}============================================================${NC}"
done

# Calculate success rate
if [ ${TOTAL_TESTS} -gt 0 ]; then
    SUCCESS_RATE=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
else
    SUCCESS_RATE=0
fi

# Print summary
log "${BLUE}"
log "${BLUE}======================================================${NC}"
log "${BLUE}${BOLD}===== Test Run Summary =====${NC}"
log "${BLUE}Total Tests Configured: ${TOTAL_TESTS}${NC}"
log "${GREEN}Tests Passed: ${PASSED_TESTS}${NC}"
log "${RED}Tests Failed: ${FAILED_TESTS}${NC}"
log "${BLUE}Success Rate: ${SUCCESS_RATE}%${NC}"

# Print failed tests if any
if [ ${FAILED_TESTS} -gt 0 ]; then
  log "${RED}Failed tests details:${NC}"
  for failed_test_detail in "${FAILED_TEST_NAMES[@]}"; do
    log "${RED}  - ${failed_test_detail}${NC}"
  done
  log "${RED}OVERALL RESULT: FAIL${NC}"
  
  # Copy the log to error.md for easier reference
  if [ -f "${REPO_ROOT}/.cursor/update-error-md.sh" ]; then
    bash "${REPO_ROOT}/.cursor/update-error-md.sh"
  else
    log "${RED}✗ Error: update-error-md.sh not found. Unable to update error documentation.${NC}"
  fi
  
  exit 1
else
  log "${GREEN}OVERALL RESULT: PASS - All tests completed successfully${NC}"
  
  # Copy the log to error.md for easier reference (even for successful tests)
  if [ -f "${REPO_ROOT}/.cursor/update-error-md.sh" ]; then
    bash "${REPO_ROOT}/.cursor/update-error-md.sh"
  else
    log "${RED}✗ Error: update-error-md.sh not found. Unable to update error documentation.${NC}"
  fi
  
  exit 0
fi 