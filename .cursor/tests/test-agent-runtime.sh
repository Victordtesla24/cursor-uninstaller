#!/bin/bash
# Runtime Environment Test for Cursor Background Agent
# Validates the runtime behavior and environment of the background agent

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
REPO_ROOT="$(dirname "$(dirname "${SCRIPT_DIR}")")"
CURSOR_DIR="${REPO_ROOT}/.cursor"
LOG_DIR="${CURSOR_DIR}/logs"
RUNTIME_LOG="${LOG_DIR}/test-agent-runtime.log"
ENVIRONMENT_JSON="${CURSOR_DIR}/environment.json"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] RUNTIME-TEST: $1" | tee -a "${RUNTIME_LOG}"
}

# Function to run tests with output capture
run_test() {
  local test_name="$1"
  local command="$2"
  local output_file="${3:-/dev/null}"
  
  log "${BLUE}ℹ Testing: ${test_name}${NC}"
  
  if eval "$command" > "$output_file" 2>&1; then
    log "${GREEN}✓ ${test_name}: PASSED${NC}"
    # Output command results if requested
    if [ "$output_file" != "/dev/null" ] && [ -s "$output_file" ]; then
      log "${BLUE}ℹ Command output:${NC}"
      while IFS= read -r line; do
        log "${BLUE}ℹ | ${line}${NC}"
      done < "$output_file"
    fi
    return 0
  else
    local exit_code=$?
    log "${RED}✗ ${test_name}: FAILED (Exit Code: ${exit_code})${NC}"
    # Output error information
    if [ "$output_file" != "/dev/null" ] && [ -s "$output_file" ]; then
      log "${RED}✗ Error output:${NC}"
      while IFS= read -r line; do
        log "${RED}✗ | ${line}${NC}"
      done < "$output_file"
    fi
    return 1
  fi
}

# Track failures
FAILURES=0

# Start testing
log "${BLUE}${BOLD}====== Starting Background Agent Runtime Tests ======${NC}"

# Test 1: Check if environment.json exists and contains terminal configurations
log "${BLUE}ℹ "
log "${BLUE}Checking terminal configurations in environment.json...${NC}"

if [ -f "${ENVIRONMENT_JSON}" ]; then
  if ! command -v jq &> /dev/null; then
    log "${RED}✗ CRITICAL: jq command not found. jq is required for proper validation of environment.json terminals.${NC}"
    FAILURES=$((FAILURES + 1))
    run_test "jq availability for environment.json terminal validation" "false" "jq command not found."
  else
    # Use jq to validate terminal configurations - fix this command to properly escape quotes
    temp_file=$(mktemp)
    if run_test "environment.json contains terminals array and is not empty" "jq -e '.terminals | length > 0' \"${ENVIRONMENT_JSON}\"" "$temp_file"; then
      # Count terminals
      terminal_count=$(jq '.terminals | length' "${ENVIRONMENT_JSON}")
      log "${GREEN}✓ environment.json has ${terminal_count} terminal configurations${NC}"
      
      # Check each terminal configuration
      for i in $(seq 0 $(( terminal_count - 1 ))); do
        terminal_name=$(jq -r ".terminals[$i].name" "${ENVIRONMENT_JSON}" || echo "unnamed_on_error")
        terminal_cmd=$(jq -r ".terminals[$i].command" "${ENVIRONMENT_JSON}" || echo "")
        
        if [ -n "$terminal_name" ] && [ "$terminal_name" != "null" ] && [ "$terminal_name" != "unnamed_on_error" ]; then
          log "${GREEN}✓ Terminal $i has valid name: $terminal_name${NC}"
          
          if [ -n "$terminal_cmd" ] && [ "$terminal_cmd" != "null" ]; then
            log "${GREEN}✓ Terminal $terminal_name has valid command: $terminal_cmd${NC}"
            
            # Validate command syntax (basic check)
            if ! run_test "Terminal command syntax check: $terminal_name" "bash -n -c \"$terminal_cmd\""; then
              log "${YELLOW}⚠ Terminal command for $terminal_name may have syntax issues${NC}"
              # Not counting as failure since it's just a warning
              FAILURES=$((FAILURES + 1)) # Count syntax issues as failures
            fi
          else
            log "${RED}✗ Terminal $terminal_name is missing command or has invalid command${NC}"
            FAILURES=$((FAILURES + 1))
          fi
        else
          log "${RED}✗ Terminal $i is missing name or has invalid name${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      done
    else
      log "${RED}✗ environment.json does not contain a valid terminals array${NC}"
      FAILURES=$((FAILURES + 1))
    fi
    rm -f "$temp_file"
  fi
else
  log "${RED}✗ environment.json not found${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 2: Check install.sh script for runtime behavior
log "${BLUE}ℹ "
log "${BLUE}Validating install.sh runtime behavior...${NC}"

INSTALL_SCRIPT="${CURSOR_DIR}/install.sh"
if [ -f "${INSTALL_SCRIPT}" ]; then
  # Check if it creates the marker file
  if grep -q "bg-agent-install-complete.txt" "${INSTALL_SCRIPT}"; then
    log "${GREEN}✓ install.sh creates the expected marker file${NC}"
  else
    log "${RED}✗ install.sh does not create the expected marker file${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  # Check for npm installations
  if grep -q "npm install" "${INSTALL_SCRIPT}"; then
    log "${GREEN}✓ install.sh includes npm dependency installation${NC}"
  else
    log "${YELLOW}⚠ install.sh may not install npm dependencies${NC}"
    # Warning only - may not be needed in all cases
  fi
  
  # Check for git operations
  if grep -q "git " "${INSTALL_SCRIPT}"; then
    log "${GREEN}✓ install.sh includes git operations${NC}"
  else
    log "${RED}✗ install.sh does not include git operations${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  # Check for proper logging
  if grep -q "log " "${INSTALL_SCRIPT}"; then
    log "${GREEN}✓ install.sh includes proper logging${NC}"
  else
    log "${RED}✗ install.sh does not include proper logging${NC}"
    FAILURES=$((FAILURES + 1))
  fi
else
  log "${RED}✗ install.sh not found${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 3: Start script validation
log "${BLUE}ℹ "
log "${BLUE}Validating start command in environment.json...${NC}"

if [ -f "${ENVIRONMENT_JSON}" ]; then
  if command -v jq &> /dev/null; then
    start_command=$(jq -r '.start // ""' "${ENVIRONMENT_JSON}")
    if [ -n "$start_command" ] && [ "$start_command" != "null" ]; then
      log "${GREEN}✓ environment.json contains start command: $start_command${NC}"
      
      # Validate command syntax (basic check)
      if ! run_test "Start command syntax check" "bash -n -c \"$start_command\""; then
        log "${RED}✗ Start command may have syntax issues${NC}"
        FAILURES=$((FAILURES + 1))
      fi
    else
      log "${RED}✗ environment.json is missing start command${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    # Fallback without jq
    if grep -q '"start"' "${ENVIRONMENT_JSON}"; then
      log "${GREEN}✓ environment.json contains start command (basic check)${NC}"
    else
      log "${RED}✗ environment.json does not seem to contain start command${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  fi
else
  log "${RED}✗ environment.json not found${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 4: Check node and npm availability
log "${BLUE}ℹ "
log "${BLUE}Checking node and npm availability...${NC}"

if command -v node &> /dev/null; then
  node_version=$(node -v)
  log "${GREEN}✓ Node.js is available: $node_version${NC}"
else
  log "${RED}✗ Node.js is not available${NC}"
  FAILURES=$((FAILURES + 1))
fi

if command -v npm &> /dev/null; then
  npm_version=$(npm -v)
  log "${GREEN}✓ npm is available: $npm_version${NC}"
else
  log "${RED}✗ npm is not available${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 5: Check for marker file existence
log "${BLUE}ℹ "
log "${BLUE}Checking for Background Agent marker file...${NC}"

MARKER_FILE="${REPO_ROOT}/bg-agent-install-complete.txt"
if [ -f "${MARKER_FILE}" ]; then
  log "${GREEN}✓ Background Agent marker file exists${NC}"
  # Display content
  marker_content=$(cat "${MARKER_FILE}")
  log "${BLUE}ℹ Marker file content: ${marker_content}${NC}"
else
  log "${RED}✗ Background Agent marker file (${MARKER_FILE}) does not exist. This file should be created by install.sh.${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 6: Validate GitHub integration setup
log "${BLUE}ℹ "
log "${BLUE}Validating GitHub integration setup...${NC}"

GITHUB_SETUP="${CURSOR_DIR}/github-setup.sh"
if [ -f "${GITHUB_SETUP}" ]; then
  log "${GREEN}✓ GitHub setup script exists${NC}"
  
  # Check for credential handling
  if grep -q "GITHUB_TOKEN" "${GITHUB_SETUP}"; then
    log "${GREEN}✓ GitHub setup includes token handling${NC}"
  else
    log "${RED}✗ GitHub setup does not include token handling${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  # Check for repository validation
  if grep -q "verify_github_access" "${GITHUB_SETUP}" || grep -q "git ls-remote" "${GITHUB_SETUP}"; then
    log "${GREEN}✓ GitHub setup includes repository validation${NC}"
  else
    log "${RED}✗ GitHub setup does not include repository validation${NC}"
    FAILURES=$((FAILURES + 1))
  fi
else
  log "${RED}✗ GitHub setup script not found${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 7: Check log file retention
log "${BLUE}ℹ "
log "${BLUE}Checking log file retention...${NC}"

# Count log files
log_count=$(find "${LOG_DIR}" -name "*.log" | wc -l | tr -d ' ')
log "${BLUE}ℹ Found ${log_count} log files in ${LOG_DIR}${NC}"

# Check if there's a .gitkeep file to ensure directory is tracked
if [ -f "${LOG_DIR}/.gitkeep" ]; then
  log "${GREEN}✓ Log directory has .gitkeep file for Git tracking${NC}"
else
  log "${RED}✗ Log directory is missing .gitkeep file. This file is important for ensuring the logs directory is version controlled.${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 8: Check retry-utils.sh for utility functions
log "${BLUE}ℹ "
log "${BLUE}Checking retry-utils.sh for utility functions...${NC}"

RETRY_UTILS="${CURSOR_DIR}/retry-utils.sh"
if [ -f "${RETRY_UTILS}" ]; then
  log "${GREEN}✓ retry-utils.sh exists${NC}"
  
  # Check for retry function
  if grep -q "retry()" "${RETRY_UTILS}"; then
    log "${GREEN}✓ retry-utils.sh includes retry function${NC}"
  else
    log "${RED}✗ retry-utils.sh does not include retry function${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  # Check for timeout function
  if grep -q "run_with_timeout" "${RETRY_UTILS}"; then
    log "${GREEN}✓ retry-utils.sh includes timeout function${NC}"
  else
    log "${RED}✗ retry-utils.sh does not include timeout function${NC}"
    FAILURES=$((FAILURES + 1))
  fi
else
  log "${RED}✗ retry-utils.sh not found${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Summarize test results
log "${BLUE}ℹ "
log "${BLUE}====== Background Agent Runtime Test Summary ======${NC}"
log "${BLUE}ℹ Total tests failed: ${FAILURES}${NC}"

if [ ${FAILURES} -eq 0 ]; then
  log "${GREEN}✓ All Background Agent runtime tests passed${NC}"
  exit 0
else
  log "${RED}✗ Background Agent runtime tests completed with ${FAILURES} failures${NC}"
  log "${RED}✗ Please fix the issues reported above${NC}"
  # Don't fail the test suite completely, but report the correct exit code
  exit 1
fi 