#!/bin/bash
# Environment Setup Test for Cursor Background Agent
# Validates environment variables, directory structure, and file permissions

set -e

# Define color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)" # Corrected REPO_ROOT definition
CURSOR_DIR="${REPO_ROOT}/.cursor"
LOG_DIR="${CURSOR_DIR}/logs"
TEST_SPECIFIC_LOG="${LOG_DIR}/test-env-setup.sh.log" # Changed from ENV_LOG

# Ensure log directory exists and clear previous log for this script
mkdir -p "${LOG_DIR}"
true > "${TEST_SPECIFIC_LOG}"

# Function to log messages for this specific test script
log_test() {
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] ENV-SETUP-TEST: $1" | tee -a "${TEST_SPECIFIC_LOG}"
}

# Track test failures
FAILURES=0

# Function to evaluate a test condition and log result
# Usage: evaluate_test "Test Name" $? "Success Message" "Failure Message"
evaluate_test() {
    local test_name="$1"
    local exit_code="$2"
    local success_message="$3"
    local failure_message="$4"

    if [ "${exit_code}" -eq 0 ]; then
        log_test "${GREEN}✓ ${test_name}: PASSED${NC} - ${success_message}"
    else
        log_test "${RED}✗ ${test_name}: FAILED${NC} - ${failure_message} (Exit Code: ${exit_code})"
        FAILURES=$((FAILURES + 1))
    fi
    return "${exit_code}"
}

# Start testing
log_test "${BLUE}${BOLD}====== Starting Environment Setup Tests ======${NC}"


# Test 1: Check required directories
log_test "${BLUE}ℹ Checking required directories...${NC}"
required_dirs=(
  "${CURSOR_DIR}"
  "${LOG_DIR}"
  "${CURSOR_DIR}/tests"
)

for dir in "${required_dirs[@]}"; do
  if [ -d "$dir" ]; then
    evaluate_test "Directory exists: $dir" 0 "Directory $dir exists." "Directory $dir does not exist."
  else
    evaluate_test "Directory exists: $dir" 1 "" "Directory $dir does not exist."
    # Attempt to create if missing, this is a setup action not a test of creation for this script
    if ! mkdir -p "$dir"; then
        log_test "${RED}✗ CRITICAL: Failed to create directory: $dir during setup attempt.${NC}"
        FAILURES=$((FAILURES + 1)) # Critical setup failure
    else
        log_test "${YELLOW}⚠ Created missing directory during setup: $dir${NC}"
    fi
  fi
done

# Test 2: Check required scripts/files
log_test "${BLUE}ℹ Checking required scripts/files...${NC}"
required_files=(
  "${CURSOR_DIR}/environment.json"
  "${CURSOR_DIR}/install.sh"
  "${CURSOR_DIR}/github-setup.sh"
  "${CURSOR_DIR}/retry-utils.sh"
  "${CURSOR_DIR}/load-env.sh"
  "${SCRIPT_DIR}/run-tests.sh" # This script itself is not required by agent, but for test suite
  "${REPO_ROOT}/Dockerfile"
)

for file_path in "${required_files[@]}"; do
  [ -f "${file_path}" ]
  evaluate_test "File exists: ${file_path#"${REPO_ROOT}"/}" $? "File ${file_path#"${REPO_ROOT}"/} exists." "File ${file_path#"${REPO_ROOT}"/} does not exist."

  # If it's a .sh file, also check for executability
  if [[ "${file_path}" == *.sh ]]; then
    if [ -x "${file_path}" ]; then
      evaluate_test "Script is executable: ${file_path#"${REPO_ROOT}"/}" 0 "Script ${file_path#"${REPO_ROOT}"/} is executable." "Script ${file_path#"${REPO_ROOT}"/} is not executable."
    else
      evaluate_test "Script is executable: ${file_path#"${REPO_ROOT}"/}" 1 "" "Script ${file_path#"${REPO_ROOT}"/} is not executable."
      # Attempt to make executable
      if chmod +x "${file_path}"; then
        log_test "${YELLOW}⚠ Made script ${file_path#"${REPO_ROOT}"/} executable. This should be set by default.${NC}"
      else
        log_test "${RED}✗ CRITICAL: Failed to make script ${file_path#"${REPO_ROOT}"/} executable.${NC}"
        FAILURES=$((FAILURES + 1))
      fi
    fi
  fi
done

# Test 3: Validate environment.json structure
log_test "${BLUE}ℹ Validating environment.json structure...${NC}"
environment_json_path="${CURSOR_DIR}/environment.json"
if [ -f "${environment_json_path}" ]; then
  if ! command -v jq &> /dev/null; then
    log_test "${RED}✗ JQ NOT FOUND: jq command is required for comprehensive environment.json validation. Skipping detailed checks.${NC}"
    # Basic check: ensure it's not empty
    [ -s "${environment_json_path}" ]
    evaluate_test "environment.json is not empty (basic check)" $? "environment.json is not empty." "environment.json is empty or not found."
  else
    jq -e . "${environment_json_path}" > /dev/null 2>&1
    if evaluate_test "environment.json is valid JSON" $? "environment.json is valid JSON." "environment.json is not valid JSON."; then
      required_json_fields=("user" "install" "start" "terminals" "build")
      for field in "${required_json_fields[@]}"; do
        jq -e ".${field}" "${environment_json_path}" > /dev/null 2>&1
        evaluate_test "environment.json contains field: .$field" $? "Field .$field exists." "Field .$field is missing or null."
      done
      # Validate build structure specifically for Dockerfile
      jq -e '.build.dockerfile' "${environment_json_path}" > /dev/null 2>&1
      evaluate_test "environment.json .build.dockerfile field exists" $? "Field .build.dockerfile exists." "Field .build.dockerfile is missing or null."
    fi
  fi
else
  evaluate_test "environment.json exists" 1 "" "environment.json file not found at ${environment_json_path}"
fi

# Test 4: Check Dockerfile basic structure
log_test "${BLUE}ℹ Checking Dockerfile basic structure...${NC}"
dockerfile_path="${REPO_ROOT}/Dockerfile"
if [ -f "${dockerfile_path}" ]; then
  dockerfile_required_instructions=("FROM" "RUN" "WORKDIR" "USER" "CMD")
  all_instructions_found=true
  for instruction in "${dockerfile_required_instructions[@]}"; do
    if ! grep -q -E "^${instruction}[[:space:]]+" "${dockerfile_path}"; then # Added regex for robustness
      evaluate_test "Dockerfile contains ${instruction}" 1 "" "Dockerfile is missing required instruction: ${instruction}."
      all_instructions_found=false
    fi
  done
  if [ "${all_instructions_found}" = true ]; then
    evaluate_test "Dockerfile all required instructions" 0 "Dockerfile contains all basic required instructions (FROM, RUN, WORKDIR, USER, CMD)." ""
  fi
else
  evaluate_test "Dockerfile exists" 1 "" "Dockerfile not found at ${dockerfile_path}."
fi

# Test 5: Check environment variables loading script
log_test "${BLUE}ℹ Testing environment variable loading setup...${NC}"
load_env_script="${CURSOR_DIR}/load-env.sh"
if [ -f "${load_env_script}" ]; then
  # Temporarily capture environment variables before loading
  # This test does not execute load-env.sh as it might interfere with test runner env
  # It only checks its existence and basic content expectations
  evaluate_test "load-env.sh script exists" 0 "load-env.sh script exists." ""
  if grep -q "export GITHUB_REPO_URL" "${load_env_script}" && grep -q "export NODE_ENV" "${load_env_script}"; then
    evaluate_test "load-env.sh contains expected exports" 0 "load-env.sh seems to export GITHUB_REPO_URL and NODE_ENV." "load-env.sh may be missing critical export statements for GITHUB_REPO_URL or NODE_ENV."
  else
    evaluate_test "load-env.sh contains expected exports" 1 "" "load-env.sh may be missing critical export statements for GITHUB_REPO_URL or NODE_ENV."
  fi
  
  # Check for env.txt or .env file that load-env.sh would typically source
  # This is a check of setup, not a direct test of load-env.sh functionality here.
  env_txt_example_path="${CURSOR_DIR}/env.txt"
  if [ -f "${env_txt_example_path}" ]; then
    evaluate_test "env.txt example file exists" 0 "env.txt example file exists at ${env_txt_example_path}." "env.txt example file is missing from ${CURSOR_DIR}."
  else
     # Check for .env in .cursor as an alternative
     env_private_path="${CURSOR_DIR}/.env"
     if [ -f "${env_private_path}" ]; then
        evaluate_test "Private .env file exists" 0 "Private .env file exists at ${env_private_path}." "No .env or env.txt file found in ${CURSOR_DIR}."
     else
        evaluate_test "env.txt or .env file in .cursor exists" 1 "" "Neither env.txt nor .env found in ${CURSOR_DIR}. load-env.sh might not load any variables."
     fi
  fi
else
  evaluate_test "load-env.sh script exists" 1 "" "load-env.sh script not found at ${load_env_script}."
fi

# Test 6: Check log directory permissions
log_test "${BLUE}ℹ Checking log directory permissions...${NC}"
if [ -d "${LOG_DIR}" ]; then
    if [ -w "${LOG_DIR}" ]; then
        evaluate_test "Log directory is writable" 0 "Log directory ${LOG_DIR} is writable." "Log directory ${LOG_DIR} is not writable."
        # Test creating a temporary file in log_dir
        temp_log_file="${LOG_DIR}/temp_writetest_$(date +%s).log"
        if touch "${temp_log_file}"; then
            evaluate_test "Can create file in log directory" 0 "Successfully created a temp file in ${LOG_DIR}." ""
            rm -f "${temp_log_file}"
        else
            evaluate_test "Can create file in log directory" 1 "" "Failed to create a temp file in ${LOG_DIR}."
        fi    
    else
        evaluate_test "Log directory is writable" 1 "" "Log directory ${LOG_DIR} is not writable."
        # Attempt to fix permissions
        if chmod u+rwx "${LOG_DIR}"; then # Change to allow current user to write
            log_test "${YELLOW}⚠ Attempted to make ${LOG_DIR} writable for current user.${NC}"
            if [ -w "${LOG_DIR}" ]; then
                 evaluate_test "Log directory is now writable (after fix attempt)" 0 "Log directory ${LOG_DIR} is now writable." ""
            else
                 evaluate_test "Log directory is still not writable (after fix attempt)" 1 "" "Log directory ${LOG_DIR} is still not writable."
            fi
        else
            log_test "${RED}✗ CRITICAL: Failed to chmod ${LOG_DIR}.${NC}"
            FAILURES=$((FAILURES + 1))
        fi
    fi
else
    evaluate_test "Log directory exists for permission check" 1 "" "Log directory ${LOG_DIR} does not exist, cannot check writability."
fi

# Summarize test results
log_test "${BLUE}ℹ"
log_test "${BLUE}====== Environment Setup Test Summary ======${NC}"
log_test "${BLUE}Total sub-tests executed for environment setup: Check log above.${NC}"
log_test "${BLUE}Total critical failures found: ${FAILURES}${NC}"

if [ ${FAILURES} -eq 0 ]; then
  log_test "${GREEN}✓ All environment setup validation checks passed according to this script's criteria.${NC}"
  exit 0
else
  log_test "${RED}✗ Environment setup validation checks completed with ${FAILURES} critical failures.${NC}"
  log_test "${RED}✗ Please review the log: ${TEST_SPECIFIC_LOG} for details.${NC}"
  exit 1
fi 