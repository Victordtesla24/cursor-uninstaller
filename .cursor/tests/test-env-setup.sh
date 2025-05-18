#!/bin/bash
# Environment Setup Test Script for Cursor Background Agent
# This script verifies the environment variables, directory structure, and file permissions

set -e

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define paths
TEST_DIR="$(dirname "$0")"
CURSOR_DIR="$(dirname "$TEST_DIR")"
LOG_DIR="${CURSOR_DIR}/logs"
SCRIPTS_DIR="${CURSOR_DIR}/scripts"
DOCS_DIR="${CURSOR_DIR}/docs"
LOG_FILE="${LOG_DIR}/env-setup-test.log"

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] $1" | tee -a "${LOG_FILE}"
}

# Function to test if a directory exists and is accessible
test_directory() {
  local dir_path="$1"
  local dir_name="$2"

  if [ -d "$dir_path" ]; then
    if [ -r "$dir_path" ]; then
      log "${GREEN}✓ $dir_name directory exists and is readable: $dir_path${NC}"
      return 0
    else
      log "${RED}✗ $dir_name directory exists but is not readable: $dir_path${NC}"
      return 1
    fi
  else
    log "${RED}✗ $dir_name directory does not exist: $dir_path${NC}"
    return 1
  fi
}

# Function to test if a file exists and is accessible
test_file() {
  local file_path="$1"
  local file_name="$2"
  local required="$3"

  if [ -f "$file_path" ]; then
    if [ -r "$file_path" ]; then
      log "${GREEN}✓ $file_name file exists and is readable: $file_path${NC}"
      return 0
    else
      log "${RED}✗ $file_name file exists but is not readable: $file_path${NC}"
      return 1
    fi
  else
    if [ "$required" = "true" ]; then
      log "${RED}✗ Required $file_name file does not exist: $file_path${NC}"
      return 1
    else
      log "${YELLOW}⚠ Optional $file_name file does not exist: $file_path${NC}"
      return 0
    fi
  fi
}

# Function to test if an environment variable is set
test_env_var() {
  local var_name="$1"
  local var_value="${!var_name}"

  if [ -n "$var_value" ]; then
    log "${GREEN}✓ Environment variable $var_name is set: $var_value${NC}"
    return 0
  else
    log "${RED}✗ Environment variable $var_name is not set${NC}"
    return 1
  fi
}

# Start testing
log "${BLUE}====== Starting Environment Setup Tests ======${NC}"

# Initialize test counters
total_tests=0
passed_tests=0

# Test directory structure
log "\n${BLUE}Testing directory structure...${NC}"

directories=(
  "$CURSOR_DIR:Cursor"
  "$SCRIPTS_DIR:Scripts"
  "$DOCS_DIR:Docs"
  "$TEST_DIR:Tests"
  "$LOG_DIR:Logs"
)

for dir_entry in "${directories[@]}"; do
  IFS=':' read -r dir_path dir_name <<< "$dir_entry"
  total_tests=$((total_tests + 1))
  if test_directory "$dir_path" "$dir_name"; then
    passed_tests=$((passed_tests + 1))
  fi
done

# Test required files
log "\n${BLUE}Testing required files...${NC}"

files=(
  "$CURSOR_DIR/environment.json:Environment JSON:true"
  "$CURSOR_DIR/Dockerfile:Dockerfile:true"
  "$SCRIPTS_DIR/install.sh:Install Script:true"
  "$SCRIPTS_DIR/github-setup.sh:GitHub Setup Script:true"
  "$SCRIPTS_DIR/retry-utils.sh:Retry Utilities Script:true"
  "$SCRIPTS_DIR/load-env.sh:Environment Loading Script:false"
  "$SCRIPTS_DIR/cleanup.sh:Cleanup Script:false"
  "$DOCS_DIR/README.md:README:false"
  "$DOCS_DIR/TROUBLESHOOTING.md:Troubleshooting Guide:false"
)

for file_entry in "${files[@]}"; do
  IFS=':' read -r file_path file_name required <<< "$file_entry"
  total_tests=$((total_tests + 1))
  if test_file "$file_path" "$file_name" "$required"; then
    passed_tests=$((passed_tests + 1))
  fi
done

# Test file permissions
log "\n${BLUE}Testing file permissions...${NC}"

script_files=(
  "$SCRIPTS_DIR/install.sh:Install Script"
  "$SCRIPTS_DIR/github-setup.sh:GitHub Setup Script"
  "$SCRIPTS_DIR/retry-utils.sh:Retry Utilities Script"
  "$TEST_DIR/validate_cursor_environment.sh:Environment Validation Script"
  "$TEST_DIR/test-background-agent.sh:Background Agent Test Script"
  "$TEST_DIR/test-agent-runtime.sh:Agent Runtime Test Script"
  "$TEST_DIR/run-tests.sh:Master Test Script"
)

for script_entry in "${script_files[@]}"; do
  IFS=':' read -r script_path script_name <<< "$script_entry"
  if [ -f "$script_path" ]; then
    total_tests=$((total_tests + 1))
    if [ -x "$script_path" ]; then
      log "${GREEN}✓ $script_name is executable: $script_path${NC}"
      passed_tests=$((passed_tests + 1))
    else
      log "${RED}✗ $script_name is not executable: $script_path${NC}"
      log "${YELLOW}Attempting to fix permission...${NC}"
      chmod +x "$script_path"
      if [ -x "$script_path" ]; then
        log "${GREEN}✓ Fixed permissions for $script_name: $script_path${NC}"
        passed_tests=$((passed_tests + 1))
      else
        log "${RED}✗ Failed to fix permissions for $script_name: $script_path${NC}"
      fi
    fi
  fi
done

# Test environment variables
log "\n${BLUE}Testing environment variables...${NC}"

# Load environment variables if load-env.sh exists
if [ -f "$SCRIPTS_DIR/load-env.sh" ] && [ -x "$SCRIPTS_DIR/load-env.sh" ]; then
  log "Sourcing environment variables from $SCRIPTS_DIR/load-env.sh"
  source "$SCRIPTS_DIR/load-env.sh"
fi

# Check for env.txt and try to load it if it exists
if [ -f "$CURSOR_DIR/env.txt" ]; then
  log "Found $CURSOR_DIR/env.txt. Attempting to load environment variables..."
  # Export variables from env.txt (ignoring comments)
  while IFS= read -r line; do
    if [[ "$line" =~ ^[^#].*= ]]; then
      # Extract variable name and value
      var_name="${line%%=*}"
      var_value="${line#*=}"
      # Remove any leading/trailing whitespace
      var_name="$(echo "$var_name" | xargs)"
      var_value="$(echo "$var_value" | xargs)"
      # Export the variable
      export "$var_name"="$var_value"
      log "Exported $var_name from env.txt"
    fi
  done < "$CURSOR_DIR/env.txt"
fi

# Test important environment variables
env_vars=(
  "GITHUB_REPO_URL"
  "NODE_ENV"
)

for var_name in "${env_vars[@]}"; do
  total_tests=$((total_tests + 1))
  if test_env_var "$var_name"; then
    passed_tests=$((passed_tests + 1))
  fi
done

# Check GitHub repository configuration
log "\n${BLUE}Testing GitHub repository configuration...${NC}"
total_tests=$((total_tests + 1))

GITHUB_REPO_URL="${GITHUB_REPO_URL:-https://github.com/Victordtesla24/cursor-uninstaller.git}"
if git config --get remote.origin.url > /dev/null 2>&1; then
  current_remote=$(git config --get remote.origin.url)
  if [ "$current_remote" = "$GITHUB_REPO_URL" ]; then
    log "${GREEN}✓ Git remote origin matches expected repository: $GITHUB_REPO_URL${NC}"
    passed_tests=$((passed_tests + 1))
  else
    log "${RED}✗ Git remote origin ($current_remote) does not match expected repository: $GITHUB_REPO_URL${NC}"
  fi
else
  log "${RED}✗ Git remote origin is not configured${NC}"
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
log "${BLUE}===== Environment Setup Test Summary =====${NC}"
log "Test Count: $total_tests"
log "Tests Passed: $passed_tests"
log "Success Rate: ${success_rate}%"

if [ $passed_tests -eq $total_tests ]; then
  log "${GREEN}All environment setup tests passed!${NC}"
  exit_code=0
else
  log "${RED}Some environment setup tests failed. Check logs for details.${NC}"
  exit_code=1
fi

log "${BLUE}======================================================${NC}"
exit $exit_code
