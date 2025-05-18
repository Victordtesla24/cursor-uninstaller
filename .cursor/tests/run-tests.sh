#!/bin/bash
# Master test script for Cursor Background Agent
# This script runs all test scripts in the .cursor/tests directory

set -e

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define paths
TEST_DIR="$(dirname "$0")"
CURSOR_DIR="${TEST_DIR}/.."
LOG_DIR="${CURSOR_DIR}/logs"
MASTER_LOG="${LOG_DIR}/master-test-run.log"

# Flush logs before running tests
echo "Flushing logs before running tests..."
if [ -f "${CURSOR_DIR}/flush-logs.sh" ]; then
  bash "${CURSOR_DIR}/flush-logs.sh"
else
  echo "Warning: flush-logs.sh not found. Creating log directory and clearing logs manually."
  # Create log directory if it doesn't exist
  mkdir -p "${LOG_DIR}"
  # Remove all log files
  find "${LOG_DIR}" -type f -name "*.log" -delete 2>/dev/null || true
  # Create empty master log file
  touch "${MASTER_LOG}"
fi

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] $1" | tee -a "${MASTER_LOG}"
}

# Function to run a test script and capture its output
run_test() {
  local test_script="$1"
  local test_name="$(basename "$test_script")"
  local test_log="${LOG_DIR}/${test_name%.sh}.log"

  log "Running test: ${test_name}"
  log "Log file: ${test_log}"

  if [ -x "$test_script" ]; then
    if bash "$test_script" > "${test_log}" 2>&1; then
      log "${GREEN}✓ Test passed: ${test_name}${NC}"
      return 0
    else
      log "${RED}✗ Test failed: ${test_name} (exit code: $?)${NC}"
      log "See log file for details: ${test_log}"
      return 1
    fi
  else
    log "${RED}Error: Test script is not executable: ${test_script}${NC}"
    chmod +x "$test_script"
    log "Made script executable, attempting to run..."
    if bash "$test_script" > "${test_log}" 2>&1; then
      log "${GREEN}✓ Test passed after chmod: ${test_name}${NC}"
      return 0
    else
      log "${RED}✗ Test failed after chmod: ${test_name} (exit code: $?)${NC}"
      log "See log file for details: ${test_log}"
      return 1
    fi
  fi
}

# Start testing
log "${BLUE}====== Starting Background Agent Tests ======${NC}"
log "Test directory: ${TEST_DIR}"

# Ensure all test scripts are executable
chmod +x "${TEST_DIR}"/*.sh

# Initialize test counters
total_tests=0
passed_tests=0

# Run environment validation test first
if [ -f "${TEST_DIR}/validate_cursor_environment.sh" ]; then
  total_tests=$((total_tests + 1))
  if run_test "${TEST_DIR}/validate_cursor_environment.sh"; then
    passed_tests=$((passed_tests + 1))
  fi
else
  log "${RED}Warning: Environment validation script not found${NC}"
fi

# Run env setup test
if [ -f "${TEST_DIR}/test-env-setup.sh" ]; then
  total_tests=$((total_tests + 1))
  if run_test "${TEST_DIR}/test-env-setup.sh"; then
    passed_tests=$((passed_tests + 1))
  fi
else
  log "${RED}Warning: Environment setup test script not found${NC}"
fi

# Run GitHub integration test
if [ -f "${TEST_DIR}/test-github-integration.sh" ]; then
  total_tests=$((total_tests + 1))
  if run_test "${TEST_DIR}/test-github-integration.sh"; then
    passed_tests=$((passed_tests + 1))
  fi
else
  log "${RED}Warning: GitHub integration test script not found${NC}"
fi

# Run Docker environment test
if [ -f "${TEST_DIR}/test-docker-env.sh" ]; then
  total_tests=$((total_tests + 1))
  if run_test "${TEST_DIR}/test-docker-env.sh"; then
    passed_tests=$((passed_tests + 1))
  fi
else
  log "${RED}Warning: Docker environment test script not found${NC}"
fi

# Run background agent test
if [ -f "${TEST_DIR}/test-background-agent.sh" ]; then
  total_tests=$((total_tests + 1))
  if run_test "${TEST_DIR}/test-background-agent.sh"; then
    passed_tests=$((passed_tests + 1))
  fi
else
  log "${RED}Warning: Background agent test script not found${NC}"
fi

# Run agent runtime test
if [ -f "${TEST_DIR}/test-agent-runtime.sh" ]; then
  total_tests=$((total_tests + 1))
  if run_test "${TEST_DIR}/test-agent-runtime.sh"; then
    passed_tests=$((passed_tests + 1))
  fi
else
  log "${RED}Warning: Agent runtime test script not found${NC}"
fi

# Calculate success rate
if [ $total_tests -gt 0 ]; then
  success_rate=$(( (passed_tests * 100) / total_tests ))
else
  success_rate=0
  log "${RED}No tests were executed!${NC}"
fi

# Output summary
log "\n${BLUE}======================================================${NC}"
log "${BLUE}===== Test Run Summary =====${NC}"
log "Test Count: $total_tests"
log "Tests Passed: $passed_tests"
log "Success Rate: ${success_rate}%"

if [ $passed_tests -eq $total_tests ]; then
  log "${GREEN}All tests passed successfully${NC}"
  log "${GREEN}OVERALL RESULT: PASS${NC}"
  exit_code=0
else
  log "${RED}Some tests failed. Check logs for details.${NC}"
  log "${RED}OVERALL RESULT: FAIL${NC}"
  exit_code=1
fi

log "======================================================\n"

# Update error.md with the latest test results
if [ -f "${CURSOR_DIR}/update-error-md.sh" ]; then
  bash "${CURSOR_DIR}/update-error-md.sh"
else
  log "${RED}Warning: update-error-md.sh not found. error.md not updated.${NC}"
fi

exit $exit_code
