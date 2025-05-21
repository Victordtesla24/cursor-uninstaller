#!/bin/bash
# GitHub Integration Test for Cursor Background Agent
# Validates GitHub connectivity and authentication

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
GIT_LOG="${LOG_DIR}/test-github-integration.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] GITHUB-TEST: $1" | tee -a "${GIT_LOG}"
}

# Function to run tests with better output handling
run_test() {
  local test_name="$1"
  local command="$2"
  local output_file="${3:-/dev/null}"
  
  log "${BLUE}ℹ Testing: ${test_name}${NC}"
  
  # Run the command and capture its exit code
  set +e  # Temporarily disable exit on error
  eval "$command" > "$output_file" 2>&1
  local exit_code=$?
  set -e  # Re-enable exit on error
  
  # Always show output if available
  if [ -s "$output_file" ]; then
    log "${BLUE}ℹ Command output:${NC}"
    while IFS= read -r line; do
      log "${BLUE}ℹ | ${line}${NC}"
    done < "$output_file"
  else
    log "${BLUE}ℹ Command produced no output${NC}"
  fi
  
  # Report success or failure based on exit code
  if [ $exit_code -eq 0 ]; then
    log "${GREEN}✓ ${test_name}: PASSED${NC}"
    return 0
  else
    log "${RED}✗ ${test_name}: FAILED (Exit Code: ${exit_code})${NC}"
    return 1
  fi
}

# Track failures
FAILURES=0

# Test setup file
GITHUB_SETUP_FILE="${CURSOR_DIR}/github-setup.sh"

# Start testing
log "${BLUE}${BOLD}====== Starting GitHub Integration Tests ======${NC}"

# Test 1: Check Git version and configuration
log "${BLUE}ℹ "
log "${BLUE}Checking Git configuration...${NC}"

if command -v git &> /dev/null; then
  # Check Git version
  git_output=$(mktemp)
  if run_test "Git version" "git --version" "$git_output"; then
    git_version=$(cat "$git_output" | tr -d '\r\n')
    log "${GREEN}✓ Git available: ${git_version}${NC}"
  else
    log "${RED}✗ Unable to determine Git version${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  rm -f "$git_output"
  
  # Check Git configuration
  git_config_output=$(mktemp)
  if run_test "Git configuration" "git config --list" "$git_config_output"; then
    git_user=$(grep "^user.name" "$git_config_output" 2>/dev/null || echo "user.name not set")
    git_email=$(grep "^user.email" "$git_config_output" 2>/dev/null || echo "user.email not set")
    
    log "${GREEN}✓ Git configuration available${NC}"
    log "${BLUE}ℹ Git user: ${git_user}${NC}"
    log "${BLUE}ℹ Git email: ${git_email}${NC}"
    
    # Warn about missing user/email configuration
    if ! grep -q "^user.name" "$git_config_output"; then
      log "${RED}✗ Git user.name is not configured${NC}"
      FAILURES=$((FAILURES + 1))
    fi
    
    if ! grep -q "^user.email" "$git_config_output"; then
      log "${RED}✗ Git user.email is not configured${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    log "${RED}✗ Unable to retrieve Git configuration${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  rm -f "$git_config_output"
else
  log "${RED}✗ Git is not installed${NC}"
  log "${RED}✗ Git is required for GitHub integration with Background Agent${NC}"
  log "${RED}✗ Install Git and configure user.name and user.email before proceeding${NC}"
  FAILURES=$((FAILURES + 1))
  # Critical error, cannot continue without Git
  exit 1
fi

# Test 2: Check GitHub connectivity
log "${BLUE}ℹ "
log "${BLUE}Checking GitHub connectivity...${NC}"

connectivity_output=$(mktemp)
if run_test "GitHub connectivity" "curl -s https://api.github.com/status -o ${connectivity_output}"; then
  if grep -q "\"status\":\"good\"" "${connectivity_output}"; then
    log "${GREEN}✓ GitHub API is accessible and reporting good status${NC}"
  else
    # GitHub is accessible but may have issues
    log "${YELLOW}⚠ GitHub API is accessible but status might not be optimal:${NC}"
    cat "${connectivity_output}" | while IFS= read -r line; do
      log "${YELLOW}ℹ | ${line}${NC}"
    done
    # Not counting as a failure as long as we can connect
  fi
else
  log "${RED}✗ Unable to connect to GitHub API${NC}"
  log "${RED}✗ This may affect Background Agent's ability to interact with GitHub repositories${NC}"
  FAILURES=$((FAILURES + 1))
fi
rm -f "${connectivity_output}"

# Test 3: Check GitHub setup script existence
log "${BLUE}ℹ "
log "${BLUE}Checking GitHub setup script...${NC}"

if [ -f "${GITHUB_SETUP_FILE}" ]; then
  log "${GREEN}✓ GitHub setup script exists at ${GITHUB_SETUP_FILE}${NC}"
  
  # Check if script is executable
  if [ -x "${GITHUB_SETUP_FILE}" ]; then
    log "${GREEN}✓ GitHub setup script is executable${NC}"
  else
    log "${RED}✗ GitHub setup script is not executable${NC}"
    log "${YELLOW}⚠ Attempting to make script executable...${NC}"
    
    chmod_output=$(mktemp)
    if run_test "Make script executable" "chmod +x ${GITHUB_SETUP_FILE}" "$chmod_output"; then
      log "${GREEN}✓ GitHub setup script is now executable${NC}"
    else
      log "${RED}✗ Failed to make GitHub setup script executable${NC}"
      FAILURES=$((FAILURES + 1))
    fi
    rm -f "$chmod_output"
  fi
  
  # Check script content
  script_content_output=$(mktemp)
  if run_test "Script content check" "grep -E 'github|git|token|auth' \"${GITHUB_SETUP_FILE}\"" "$script_content_output"; then
    log "${GREEN}✓ GitHub setup script appears to contain relevant GitHub configuration code${NC}"
  else
    log "${RED}✗ GitHub setup script may not contain expected GitHub configuration code${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  rm -f "$script_content_output"
  
  # Validate script syntax
  syntax_output=$(mktemp)
  if run_test "Script syntax check" "bash -n \"${GITHUB_SETUP_FILE}\"" "$syntax_output"; then
    log "${GREEN}✓ GitHub setup script has valid syntax${NC}"
  else
    log "${RED}✗ GitHub setup script has syntax errors${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  rm -f "$syntax_output"
else
  log "${RED}✗ GitHub setup script not found at ${GITHUB_SETUP_FILE}${NC}"
  log "${RED}✗ This file is required for proper GitHub integration with the Background Agent${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 4: Check environment.json for GitHub configurations
log "${BLUE}ℹ "
log "${BLUE}Checking environment.json for GitHub settings...${NC}"

ENVIRONMENT_JSON="${CURSOR_DIR}/environment.json"
if [ -f "${ENVIRONMENT_JSON}" ]; then
  # Use grep to check for GitHub-related fields since jq may not be available
  env_output=$(mktemp)
  if run_test "GitHub environment variables" "grep -E 'GITHUB|GIT|TOKEN|OAUTH|SSH' \"${ENVIRONMENT_JSON}\"" "$env_output"; then
    log "${GREEN}✓ environment.json contains GitHub-related configuration${NC}"
  else
    log "${RED}✗ environment.json may not contain required GitHub configuration${NC}"
    log "${RED}✗ The Background Agent requires proper GitHub token configuration to function with private repositories${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  rm -f "$env_output"
  
  # Check for environment script call that might set up GitHub
  if grep -q "github-setup.sh" "${ENVIRONMENT_JSON}"; then
    log "${GREEN}✓ environment.json references GitHub setup script${NC}"
  else
    log "${RED}✗ environment.json does not reference GitHub setup script${NC}"
    log "${RED}✗ This may prevent the Background Agent from properly authenticating with GitHub${NC}"
    FAILURES=$((FAILURES + 1))
  fi
else
  log "${RED}✗ environment.json not found at ${ENVIRONMENT_JSON}${NC}"
  log "${RED}✗ This file is required for Background Agent configuration${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 5: Check for GitHub authentication
log "${BLUE}ℹ "
log "${BLUE}Checking GitHub authentication...${NC}"

# Check if there's a token or SSH key configured
auth_check_output=$(mktemp)

# Avoid exposing actual tokens in logs
if run_test "GitHub token check" "grep -l -E 'GITHUB_TOKEN|GH_TOKEN|GITHUB_PAT' ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile ~/.gitconfig ~/.git-credentials ${CURSOR_DIR}/*.sh 2>/dev/null || echo 'No token found'" "$auth_check_output"; then
  if ! grep -q "No token found" "$auth_check_output"; then
    log "${GREEN}✓ GitHub token configuration found${NC}"
  else
    log "${YELLOW}⚠ GitHub token configuration not found in standard locations${NC}"
    log "${YELLOW}⚠ This may be by design if using SSH keys or if token is provided via environment.json${NC}"
    # Not a failure, just a warning
  fi
else
  log "${RED}✗ Unable to check for GitHub token configuration${NC}"
  FAILURES=$((FAILURES + 1))
fi
rm -f "$auth_check_output"

# Check for SSH keys
ssh_check_output=$(mktemp)
if run_test "GitHub SSH key check" "find ~/.ssh -name 'id_*' -not -name '*.pub' 2>/dev/null | wc -l" "$ssh_check_output"; then
  ssh_key_count=$(cat "$ssh_check_output" | tr -d '\r\n' | tr -d ' ')
  if [ "$ssh_key_count" -gt 0 ]; then
    log "${GREEN}✓ SSH keys found (${ssh_key_count} keys)${NC}"
    
    # Check SSH agent
    ssh_agent_output=$(mktemp)
    if run_test "SSH agent check" "ssh-add -l 2>/dev/null || echo 'SSH agent not running'" "$ssh_agent_output"; then
      if ! grep -q "SSH agent not running" "$ssh_agent_output" && ! grep -q "The agent has no identities" "$ssh_agent_output"; then
        log "${GREEN}✓ SSH agent is running with keys${NC}"
      else
        log "${YELLOW}⚠ SSH agent is not running or has no identities${NC}"
        log "${YELLOW}⚠ This may prevent the Background Agent from using SSH authentication with GitHub${NC}"
      fi
    else
      log "${RED}✗ Unable to check SSH agent status${NC}"
      FAILURES=$((FAILURES + 1))
    fi
    rm -f "$ssh_agent_output"
  else
    log "${YELLOW}⚠ No SSH keys found${NC}"
    log "${YELLOW}⚠ This is only a concern if you are using SSH authentication with GitHub${NC}"
  fi
else
  log "${RED}✗ Unable to check for SSH keys${NC}"
  FAILURES=$((FAILURES + 1))
fi
rm -f "$ssh_check_output"

# Test 6: Test GitHub API authentication
log "${BLUE}ℹ "
log "${BLUE}Testing GitHub API authentication (anonymously)...${NC}"

# Test unauthenticated API call (rate limited but should work)
api_check_output=$(mktemp)
if run_test "GitHub API anonymous access" "curl -s -o ${api_check_output} https://api.github.com/rate_limit"; then
  if grep -q "\"resources\":" "${api_check_output}"; then
    log "${GREEN}✓ Anonymous GitHub API access is working${NC}"
    
    # Display rate limits
    rate_limit=$(grep -o '\"limit\":[0-9]*' "${api_check_output}" | head -1 | cut -d':' -f2)
    rate_remaining=$(grep -o '\"remaining\":[0-9]*' "${api_check_output}" | head -1 | cut -d':' -f2)
    log "${BLUE}ℹ Rate limit: ${rate_limit}, Remaining: ${rate_remaining}${NC}"
    
    # Check if we're authenticated (higher rate limits)
    if [ -n "$rate_limit" ] && [ "$rate_limit" -gt 60 ]; then
      log "${GREEN}✓ Authenticated GitHub API access detected (higher rate limits)${NC}"
    else
      log "${YELLOW}⚠ Anonymous GitHub API access detected (lower rate limits)${NC}"
      log "${YELLOW}⚠ This may affect Background Agent's ability to perform GitHub operations${NC}"
      # Not counting as a failure as anonymous access can still work
    fi
  else
    log "${RED}✗ GitHub API access did not return expected data${NC}"
    FAILURES=$((FAILURES + 1))
  fi
else
  log "${RED}✗ GitHub API access failed${NC}"
  FAILURES=$((FAILURES + 1))
fi
rm -f "${api_check_output}"

# Test 7: Check that GitHub is properly referenced in the environment.json main config sections
log "${BLUE}ℹ "
log "${BLUE}Checking GitHub references in environment.json sections...${NC}"

if [ -f "${ENVIRONMENT_JSON}" ]; then
  sections=("environments" "build" "start" "tasks")
  sections_checked=0
  for section in "${sections[@]}"; do
    section_output=$(mktemp)
    if run_test "Section check: ${section}" "grep -A 20 '\"${section}\"' \"${ENVIRONMENT_JSON}\" | grep -E 'git|github'" "$section_output"; then
      log "${GREEN}✓ Section '${section}' contains GitHub/Git references${NC}"
      sections_checked=$((sections_checked + 1))
    else
      log "${YELLOW}⚠ Section '${section}' might not contain GitHub/Git references${NC}"
      log "${YELLOW}⚠ This is expected for some sections but may be a concern for others${NC}"
    fi
    rm -f "$section_output"
  done
  
  if [ "$sections_checked" -gt 0 ]; then
    log "${GREEN}✓ Found GitHub/Git references in ${sections_checked} environment.json sections${NC}"
  else
    log "${RED}✗ No GitHub/Git references found in environment.json sections${NC}"
    log "${RED}✗ This may indicate improper Background Agent configuration for GitHub integration${NC}"
    FAILURES=$((FAILURES + 1))
  fi
else
  log "${RED}✗ environment.json not found for GitHub reference check${NC}"
  # Already counted as a failure above
fi

# Summarize test results
log "${BLUE}ℹ "
log "${BLUE}====== GitHub Integration Test Summary ======${NC}"
log "${BLUE}Total failures: ${FAILURES}${NC}"

if [ ${FAILURES} -eq 0 ]; then
  log "${GREEN}✓ All GitHub integration tests passed successfully${NC}"
  exit 0
else
  log "${RED}✗ GitHub integration tests completed with ${FAILURES} failures${NC}"
  log "${RED}✗ Please address the issues above to ensure Background Agent can integrate with GitHub${NC}"
  exit 1
fi
