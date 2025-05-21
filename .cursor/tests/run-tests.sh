#!/bin/bash
# Master Test Runner for Cursor Background Agent
# Executes all test scripts and reports results

# Enable strict mode for better error handling
set -e
set -o pipefail

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
CURSOR_DIR="${REPO_ROOT}/.cursor"
LOG_DIR="${CURSOR_DIR}/logs"
MASTER_LOG="${LOG_DIR}/run-tests.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] MASTER-TEST: $1" | tee -a "${MASTER_LOG}"
}

# Function to run a test script with improved reporting
run_test_script() {
  local test_script="$1"
  local test_name="$(basename "${test_script}")"
  local test_log="${LOG_DIR}/${test_name}.log"
  local start_time=$(date +%s)
  
  log "${BLUE}ℹ Starting test: ${test_name}${NC}"
  
  # Run the test script
  set +e # Temporarily disable exit on error
  bash "${test_script}" 2>&1 | tee "${test_log}"
  local exit_code=$?
  set -e # Re-enable exit on error
  
  local end_time=$(date +%s)
  local duration=$((end_time - start_time))
  
  # Report result
  if [ ${exit_code} -eq 0 ]; then
    log "${GREEN}✓ Test ${test_name} PASSED (${duration}s)${NC}"
    return 0
  else
    log "${RED}✗ Test ${test_name} FAILED (${duration}s, Exit Code: ${exit_code})${NC}"
    # Log location of detailed test output
    log "${RED}✗ See detailed logs at: ${test_log}${NC}"
    return 1
  fi
}

# Clear the main log file to start fresh
> "${MASTER_LOG}"

# Record current time for overall timing
OVERALL_START_TIME=$(date +%s)

# Display header
log "${BLUE}${BOLD}===============================================${NC}"
log "${BLUE}${BOLD}  CURSOR BACKGROUND AGENT TEST SUITE          ${NC}"
log "${BLUE}${BOLD}===============================================${NC}"
log "${BLUE}ℹ Starting tests at $(date)${NC}"

# Display system information
log "${BLUE}ℹ System Information:${NC}"
log "${BLUE}ℹ OS: $(uname -s) $(uname -r) $(uname -m)${NC}"
if command -v bash &> /dev/null; then
  log "${BLUE}ℹ Bash Version: $(bash --version | head -n 1)${NC}"
fi
if command -v docker &> /dev/null; then
  log "${BLUE}ℹ Docker Version: $(docker --version)${NC}"
fi
if command -v git &> /dev/null; then
  log "${BLUE}ℹ Git Version: $(git --version)${NC}"
fi
if command -v node &> /dev/null; then
  log "${BLUE}ℹ Node Version: $(node --version)${NC}"
fi
if command -v npm &> /dev/null; then
  log "${BLUE}ℹ NPM Version: $(npm --version)${NC}"
fi

# Discover test scripts
log "${BLUE}ℹ "
log "${BLUE}ℹ Discovering test scripts...${NC}"
TEST_SCRIPTS=()

# Find all test script files
while IFS= read -r script; do
  # Skip the master test script itself
  if [[ "$(basename "${script}")" != "run-tests.sh" ]]; then
    TEST_SCRIPTS+=("${script}")
  fi
done < <(find "${SCRIPT_DIR}" -name "test-*.sh" -type f | sort)

# Count test scripts
TEST_COUNT=${#TEST_SCRIPTS[@]}
log "${BLUE}ℹ Found ${TEST_COUNT} test scripts to execute${NC}"

# Track test results
PASSED_TESTS=0
FAILED_TESTS=0
FAILED_TEST_NAMES=()

# Prepare test environment
log "${BLUE}ℹ "
log "${BLUE}ℹ Preparing test environment...${NC}"

# Ensure required environment variables are set
# Source environment from load-env.sh if it exists
if [ -f "${CURSOR_DIR}/load-env.sh" ]; then
  log "${BLUE}ℹ Sourcing environment variables from ${CURSOR_DIR}/load-env.sh${NC}"
  source "${CURSOR_DIR}/load-env.sh"
fi

# Make sure all test scripts are executable
for script in "${TEST_SCRIPTS[@]}"; do
  if [ ! -x "${script}" ]; then
    log "${YELLOW}⚠ Making test script executable: $(basename "${script}")${NC}"
    chmod +x "${script}"
  fi
done

# Execute each test script
log "${BLUE}ℹ "
log "${BLUE}ℹ Executing tests...${NC}"

for script in "${TEST_SCRIPTS[@]}"; do
  if run_test_script "${script}"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    FAILED_TESTS=$((FAILED_TESTS + 1))
    FAILED_TEST_NAMES+=("$(basename "${script}")")
  fi
  log "${BLUE}ℹ Progress: ${PASSED_TESTS} passed, ${FAILED_TESTS} failed, $((TEST_COUNT - PASSED_TESTS - FAILED_TESTS)) remaining${NC}"
  echo # Add a newline for better readability
done

# Calculate overall execution time
OVERALL_END_TIME=$(date +%s)
OVERALL_DURATION=$((OVERALL_END_TIME - OVERALL_START_TIME))

# Display test summary
log "${BLUE}ℹ "
log "${BLUE}${BOLD}===============================================${NC}"
log "${BLUE}${BOLD}  TEST SUMMARY                               ${NC}"
log "${BLUE}${BOLD}===============================================${NC}"
log "${BLUE}ℹ Total Tests: ${TEST_COUNT}${NC}"
log "${GREEN}ℹ Tests Passed: ${PASSED_TESTS}${NC}"
log "${RED}ℹ Tests Failed: ${FAILED_TESTS}${NC}"
log "${BLUE}ℹ Total Execution Time: ${OVERALL_DURATION} seconds${NC}"

# List failed tests
if [ ${FAILED_TESTS} -gt 0 ]; then
  log "${RED}ℹ Failed Tests:${NC}"
  for failed_test in "${FAILED_TEST_NAMES[@]}"; do
    log "${RED}ℹ  - ${failed_test}${NC}"
  done
fi

# Display final result
if [ ${FAILED_TESTS} -eq 0 ]; then
  log "${GREEN}${BOLD}===============================================${NC}"
  log "${GREEN}${BOLD}  ALL TESTS PASSED SUCCESSFULLY               ${NC}"
  log "${GREEN}${BOLD}===============================================${NC}"
  exit 0
else
  log "${RED}${BOLD}===============================================${NC}"
  log "${RED}${BOLD}  TESTS FAILED                                ${NC}"
  log "${RED}${BOLD}===============================================${NC}"
  # Exit with total number of failed tests as error code (but max 125 to avoid shell issues)
  [ ${FAILED_TESTS} -gt 125 ] && exit 125 || exit ${FAILED_TESTS}
fi 