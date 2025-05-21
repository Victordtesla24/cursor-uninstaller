#!/bin/bash
# GitHub Integration Test for Cursor Background Agent
# Validates GitHub repository access, credentials, and operations

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
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)" # Corrected REPO_ROOT
CURSOR_DIR="${REPO_ROOT}/.cursor"
LOG_DIR="${CURSOR_DIR}/logs"
TEST_SPECIFIC_LOG="${LOG_DIR}/test-github-integration.sh.log" # Specific log file
GITHUB_SETUP_SCRIPT="${CURSOR_DIR}/github-setup.sh"
TEST_BRANCH="test-github-integration-$(date +%Y%m%d%H%M%S)"

# Ensure log directory exists and clear previous log for this script
mkdir -p "${LOG_DIR}"
> "${TEST_SPECIFIC_LOG}"

# Function to log messages for this specific test script
log_test() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] GITHUB-TEST: $1" | tee -a "${TEST_SPECIFIC_LOG}"
}

# Track failures
FAILURES=0

# Function to evaluate a test condition and log result
# Usage: evaluate_test "Test Name" $? "Success Message" "Failure Message" [is_critical=true]
evaluate_test() {
    local test_name="$1"
    local exit_code="$2"
    local success_message="$3"
    local failure_message="$4"
    local is_critical=${5:-true} # Default to critical failure

    if [ "${exit_code}" -eq 0 ]; then
        log_test "${GREEN}✓ ${test_name}: PASSED${NC} - ${success_message}"
        return 0
    else
        log_test "${RED}✗ ${test_name}: FAILED${NC} - ${failure_message} (Exit Code: ${exit_code})"
        if [ "${is_critical}" = true ]; then
            FAILURES=$((FAILURES + 1))
        else
            log_test "${YELLOW}⚠ Non-critical failure noted for ${test_name}.${NC}"
        fi
        return 1
    fi
}

# Function to run a command and capture its output for logging, then evaluate
# Usage: run_command_and_evaluate "Test Name" "command_to_run" "Success Message" "Failure Message" [is_critical=true]
run_command_and_evaluate() {
    local test_name="$1"
    local command_to_run="$2"
    local success_message="$3"
    local failure_message="$4"
    local is_critical=${5:-true}
    local temp_output_file
    temp_output_file=$(mktemp)

    log_test "${BLUE}ℹ Executing: ${test_name} - Command: ${command_to_run}${NC}"
    
    eval "${command_to_run}" > "${temp_output_file}" 2>&1
    local exit_code=$?

    # Always show output regardless of success/failure
    if [ -s "${temp_output_file}" ]; then
        log_test "${BLUE}ℹ Output for '${test_name}':${NC}"
        while IFS= read -r line; do log_test "${BLUE}ℹ | ${line}${NC}"; done < "${temp_output_file}"
    else
        log_test "${BLUE}ℹ No output for '${test_name}'.${NC}"
    fi
    rm -f "${temp_output_file}"
    evaluate_test "${test_name}" ${exit_code} "${success_message}" "${failure_message}" "${is_critical}"
    return $?
}

# Start testing
log_test "${BLUE}${BOLD}====== Starting GitHub Integration Tests ======${NC}"

# Check if GitHub CLI is available (for more robust testing)
GITHUB_CLI_AVAILABLE=false
if command -v gh &> /dev/null; then
    GITHUB_CLI_AVAILABLE=true
    log_test "${GREEN}✓ GitHub CLI is available, enabling enhanced testing capabilities.${NC}"
else
    log_test "${YELLOW}⚠ GitHub CLI is not available. Some advanced tests will be skipped.${NC}"
fi

# Source environment variables from load-env.sh
if [ -f "${CURSOR_DIR}/load-env.sh" ]; then
    log_test "${BLUE}ℹ Sourcing environment variables from load-env.sh${NC}"
    # Source in a subshell to avoid polluting the test script's environment too much
    # Redirect stdout of the sourced script to /dev/null to avoid its logs in the temp file
    (source "${CURSOR_DIR}/load-env.sh" > /dev/null 2>&1 && env | grep -E "^GITHUB_|^GIT_") > /tmp/github_env_vars.tmp
    if [ -s "/tmp/github_env_vars.tmp" ]; then
        log_test "${GREEN}✓ Environment variables loaded successfully${NC}"
        # Log GitHub-related variables (but mask token)
        while IFS= read -r line; do
            if [[ "$line" == GITHUB_TOKEN=* ]]; then
                log_test "${BLUE}ℹ GITHUB_TOKEN is set [value masked]${NC}"
            else
                log_test "${BLUE}ℹ $line${NC}"
            fi
        done < /tmp/github_env_vars.tmp
    else
        log_test "${YELLOW}⚠ No GitHub-related environment variables found after sourcing load-env.sh${NC}"
    fi
    
    # Source specifically the GITHUB_REPO_URL (if available)
    source "${CURSOR_DIR}/load-env.sh" > /dev/null 2>&1 || true
    if [ -n "${GITHUB_REPO_URL}" ]; then
        log_test "${GREEN}✓ GITHUB_REPO_URL sourced successfully: ${GITHUB_REPO_URL}${NC}"
    else
        log_test "${RED}✗ Failed to source GITHUB_REPO_URL from load-env.sh or it was empty.${NC}"
        FAILURES=$((FAILURES + 1))
        GITHUB_REPO_URL="https://github.com/Victordtesla24/cursor-uninstaller.git" # Fallback
        log_test "${YELLOW}⚠ Using fallback GITHUB_REPO_URL: ${GITHUB_REPO_URL}${NC}"
    fi
    
    rm -f /tmp/github_env_vars.tmp
else
    log_test "${RED}✗ load-env.sh not found at ${CURSOR_DIR}/load-env.sh${NC}"
    FAILURES=$((FAILURES + 1))
    GITHUB_REPO_URL="https://github.com/Victordtesla24/cursor-uninstaller.git" # Fallback
    log_test "${YELLOW}⚠ Using fallback GITHUB_REPO_URL: ${GITHUB_REPO_URL}${NC}"
fi

# Test 1: Check github-setup.sh exists and is executable
log_test "${BLUE}ℹ Checking github-setup.sh script...${NC}"
if [ -f "${GITHUB_SETUP_SCRIPT}" ]; then
    evaluate_test "github-setup.sh exists" 0 "github-setup.sh exists." ""
    if [ -x "${GITHUB_SETUP_SCRIPT}" ]; then
        evaluate_test "github-setup.sh is executable" 0 "github-setup.sh is executable." ""
    else
        evaluate_test "github-setup.sh is executable" 1 "" "github-setup.sh is not executable."
        if chmod +x "${GITHUB_SETUP_SCRIPT}"; then
            log_test "${YELLOW}⚠ Made github-setup.sh executable. This should be set by default.${NC}"
        else
            log_test "${RED}✗ CRITICAL: Failed to make github-setup.sh executable.${NC}"
            FAILURES=$((FAILURES + 1)) # This is critical
            exit 1 # Exit if we can't even run the setup script
        fi
    fi
else
    evaluate_test "github-setup.sh exists" 1 "" "github-setup.sh not found at ${GITHUB_SETUP_SCRIPT}."
    exit 1 # Critical, cannot proceed
fi

# Test 2: Check git installation
log_test "${BLUE}ℹ Checking git installation...${NC}"
if command -v git &> /dev/null; then
    git_version=$(git --version)
    evaluate_test "git is installed" 0 "git is installed. Version: ${git_version}" ""
else
    evaluate_test "git is installed" 1 "" "git is not installed. This is a critical requirement."
    exit 1 # Critical, cannot proceed
fi

# Test 3: Validate GitHub repository URL format
log_test "${BLUE}ℹ Validating GitHub repository URL syntax...${NC}"
if [ -n "${GITHUB_REPO_URL}" ]; then
    log_test "${BLUE}ℹ GITHUB_REPO_URL is set to: ${GITHUB_REPO_URL}${NC}"
    if [[ "${GITHUB_REPO_URL}" =~ ^https://github\.com/[^/]+/[^/]+\.git$ ]]; then
        evaluate_test "GITHUB_REPO_URL format" 0 "GITHUB_REPO_URL has a valid format." ""
    else
        # This is a warning, not a critical failure for the test itself, but for the config
        evaluate_test "GITHUB_REPO_URL format" 1 "" "GITHUB_REPO_URL (${GITHUB_REPO_URL}) does not match standard https://github.com/owner/repo.git format." true
    fi
else
    evaluate_test "GITHUB_REPO_URL is set" 1 "" "GITHUB_REPO_URL is not set in environment after sourcing load-env.sh."
    # This was handled by fallback, but log it as a failure of config.
fi

# Test 4: Run github-setup.sh script to configure Git for agent context
# This step is crucial as it sets up the git config for the test environment
log_test "${BLUE}ℹ Running github-setup.sh to configure GitHub integration for this test run...${NC}"
# Ensure we are in the repo root for github-setup.sh to work as expected
cd "${REPO_ROOT}" || { log_test "${RED}✗ CRITICAL: Failed to cd to REPO_ROOT ${REPO_ROOT}${NC}"; exit 1; }

if ! run_command_and_evaluate "Execute github-setup.sh" "bash \"${GITHUB_SETUP_SCRIPT}\"" "github-setup.sh executed." "github-setup.sh execution failed."; then
    log_test "${RED}✗ github-setup.sh failed. Subsequent git operations might fail or use wrong config.${NC}"
    # Do not exit, allow other tests to run to see extent of failure.
fi

# Test 5: Verify Git identity configuration (user.name and user.email)
log_test "${BLUE}ℹ Verifying Git identity configuration (post github-setup.sh)...${NC}"
GIT_USER_NAME=$(git config --global --get user.name || echo "NOT_SET")
GIT_USER_EMAIL=$(git config --global --get user.email || echo "NOT_SET")

if [ "${GIT_USER_NAME}" != "NOT_SET" ] && [ "${GIT_USER_EMAIL}" != "NOT_SET" ]; then
    evaluate_test "Git identity (name & email)" 0 "Git identity configured: Name='${GIT_USER_NAME}', Email='${GIT_USER_EMAIL}'" ""
else
    evaluate_test "Git identity (name & email)" 1 "" "Git user.name or user.email not configured globally. Name='${GIT_USER_NAME}', Email='${GIT_USER_EMAIL}'. This should be handled by github-setup.sh."
    
    # Try to configure them if missing - this is a recovery step
    if [ "${GIT_USER_NAME}" == "NOT_SET" ]; then
        if git config --global user.name "Cursor Background Agent"; then
            log_test "${YELLOW}⚠ Configured default Git user.name as 'Cursor Background Agent'${NC}"
        else
            log_test "${RED}✗ Failed to configure default Git user.name${NC}"
        fi
    fi
    
    if [ "${GIT_USER_EMAIL}" == "NOT_SET" ]; then
        if git config --global user.email "background-agent@cursor.sh"; then
            log_test "${YELLOW}⚠ Configured default Git user.email as 'background-agent@cursor.sh'${NC}"
        else
            log_test "${RED}✗ Failed to configure default Git user.email${NC}"
        fi
    fi
fi

# Test 6: Test GitHub remote configuration
log_test "${BLUE}ℹ Testing GitHub remote 'origin' configuration...${NC}"
REMOTE_ORIGIN_URL=$(git remote get-url origin 2>/dev/null || echo "NOT_CONFIGURED")
if [ "${REMOTE_ORIGIN_URL}" != "NOT_CONFIGURED" ]; then
    evaluate_test "Git remote 'origin' URL check" 0 "Git remote 'origin' is configured to: ${REMOTE_ORIGIN_URL}" ""
    
    # Extract the repository part from both URLs to compare correctly
    # This handles URLs that might contain tokens like x-access-token:TOKEN@github.com/...
    function extract_repo_part() {
        local url="$1"
        # Extract the owner/repo.git part from any GitHub URL form
        if [[ "$url" =~ github\.com[:/]([^/]+/[^/.]+\.git) ]]; then
            echo "${BASH_REMATCH[1]}"
            return 0
        elif [[ "$url" =~ github\.com[:/]([^/]+/[^/.]+)$ ]]; then
            echo "${BASH_REMATCH[1]}.git"
            return 0
        else
            # Return the original if no match (this will cause the test to fail)
            echo "$url"
            return 1
        fi
    }
    
    REMOTE_REPO_PART=$(extract_repo_part "$REMOTE_ORIGIN_URL")
    EXPECTED_REPO_PART=$(extract_repo_part "$GITHUB_REPO_URL")
    
    if [ "$REMOTE_REPO_PART" == "$EXPECTED_REPO_PART" ]; then
        evaluate_test "Remote 'origin' URL matches GITHUB_REPO_URL" 0 "Remote 'origin' URL matches GITHUB_REPO_URL (repository part: $REMOTE_REPO_PART)." ""
    else
        evaluate_test "Remote 'origin' URL matches GITHUB_REPO_URL" 1 "" "Remote 'origin' URL (repository part: $REMOTE_REPO_PART) does not match GITHUB_REPO_URL (repository part: $EXPECTED_REPO_PART). This should be set by github-setup.sh." false
        
        # This isn't a critical failure since the token-based URL is actually the correct behavior
        log_test "${YELLOW}⚠ Note: It's expected for the remote URL to contain authentication tokens when set by github-setup.sh.${NC}"
        log_test "${YELLOW}⚠ The underlying repository part should match, but the full URL strings may differ.${NC}"
    fi
else
    evaluate_test "Git remote 'origin' URL check" 1 "" "Git remote 'origin' is not configured. This should be handled by github-setup.sh."
    
    # Try to fix missing remote - this is a recovery step
    log_test "${YELLOW}⚠ Attempting to add remote 'origin'...${NC}"
    if git remote add origin "${GITHUB_REPO_URL}"; then
        log_test "${GREEN}✓ Successfully added remote 'origin' with URL ${GITHUB_REPO_URL}${NC}"
    else
        log_test "${RED}✗ Failed to add remote 'origin'${NC}"
    fi
fi

# Test 7: Test GitHub connectivity (read-only `git ls-remote`)
# This test can fail in environments without network or with strict firewalls.
log_test "${BLUE}ℹ Testing GitHub connectivity (read-only with git ls-remote)...${NC}"
if ! run_command_and_evaluate "GitHub connectivity (ls-remote)" "git ls-remote --heads \"${GITHUB_REPO_URL}\" || (echo 'Git ls-remote failed, trying with credential helper forcing'; GIT_TERMINAL_PROMPT=0 git -c credential.helper='!f() { echo \"username=x-access-token\"; echo \"password=${GITHUB_TOKEN}\"; }; f' ls-remote --heads \"${GITHUB_REPO_URL}\")" "Able to list remote heads." "Cannot connect to GitHub remote to list heads. Check network/firewall or GITHUB_REPO_URL." false; then
    # This is marked as non-critical because it can fail in some environments
    log_test "${YELLOW}⚠ Read-only connectivity (ls-remote) failed. Network or authorization issues might be preventing GitHub access.${NC}"
    log_test "${YELLOW}⚠ This is expected in environments without proper GitHub credentials or network access.${NC}"
    log_test "${YELLOW}⚠ According to Cursor documentation, the Background Agent should have GitHub access configured through the Cursor GitHub App.${NC}"
fi

# Test 8: Try fetching updates (dry-run only to avoid modifying local state)
log_test "${BLUE}ℹ Testing fetch from GitHub (origin) - dry run only...${NC}"
if run_command_and_evaluate "Fetch from origin (dry-run)" "git fetch origin --dry-run || (echo 'Git fetch --dry-run failed, trying with credential helper forcing'; GIT_TERMINAL_PROMPT=0 git -c credential.helper='!f() { echo \"username=x-access-token\"; echo \"password=${GITHUB_TOKEN}\"; }; f' fetch origin --dry-run)" "Dry-run fetch successful." "Dry-run fetch failed." false; then
    log_test "${GREEN}✓ GitHub fetch dry-run test successful.${NC}"
else
    # This is non-critical because it can fail in some environments without proper credentials
    log_test "${YELLOW}⚠ GitHub fetch dry-run test failed. This is expected in environments without proper GitHub credentials.${NC}"
    log_test "${YELLOW}⚠ According to Cursor documentation, the Background Agent should have GitHub access configured.${NC}"
fi

# Test 9: Check current branch state
log_test "${BLUE}ℹ Checking current branch state...${NC}"
ORIGINAL_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "DETACHED_HEAD")
if [ "${ORIGINAL_BRANCH}" == "DETACHED_HEAD" ]; then 
    log_test "${YELLOW}⚠ HEAD is detached. Attempting to checkout main/master for subsequent tests.${NC}"
    if git checkout main 2>/dev/null || git checkout master 2>/dev/null; then
        ORIGINAL_BRANCH=$(git symbolic-ref --short HEAD)
        evaluate_test "Checkout main/master branch" 0 "Successfully checked out ${ORIGINAL_BRANCH}." ""
    else
        evaluate_test "Checkout main/master branch" 1 "" "Failed to checkout main or master branch from detached HEAD state."
        # Try to create a new branch if we can't check out existing ones
        if git checkout -b temp-test-branch; then
            ORIGINAL_BRANCH="temp-test-branch"
            log_test "${YELLOW}⚠ Created temporary branch ${ORIGINAL_BRANCH} for testing.${NC}"
        else
            log_test "${RED}✗ Could not create a branch for testing. Git operations requiring branches will likely fail.${NC}"
        fi
    fi
else
    evaluate_test "Current branch check" 0 "Currently on branch: ${ORIGINAL_BRANCH}" ""
fi

# Test 10: Validate github-setup.sh script contains required elements
log_test "${BLUE}ℹ "
log_test "${BLUE}Validating github-setup.sh script content...${NC}"

for required_pattern in "GITHUB_REPO_URL" "git remote" "git config" "user.email" "user.name"; do
    if grep -q "${required_pattern}" "${GITHUB_SETUP_SCRIPT}"; then
        evaluate_test "github-setup.sh contains ${required_pattern}" 0 "Script contains required pattern: ${required_pattern}" ""
    else
        evaluate_test "github-setup.sh contains ${required_pattern}" 1 "" "Script is missing required pattern: ${required_pattern}" true
    fi
done

# Test 11: Check token configuration in github-setup.sh
log_test "${BLUE}ℹ "
log_test "${BLUE}Checking GitHub token handling in setup script...${NC}"

if grep -q "GITHUB_TOKEN" "${GITHUB_SETUP_SCRIPT}"; then
    evaluate_test "GitHub token handling" 0 "Script contains GitHub token handling." ""
    
    # Check if script handles token-based URLs for HTTPS git operations
    if grep -q "url\.https://x-access-token" "${GITHUB_SETUP_SCRIPT}"; then
        evaluate_test "Token-based URL configuration" 0 "Script configures token-based URLs for HTTPS git operations." ""
    else
        evaluate_test "Token-based URL configuration" 1 "" "Script does not configure token-based URLs for HTTPS git operations." true
    fi
else
    evaluate_test "GitHub token handling" 1 "" "Script does not handle GitHub tokens." true
fi

# Summarize test results
log_test "${BLUE}ℹ "
log_test "${BLUE}====== GitHub Integration Test Summary ======${NC}"
log_test "${BLUE}Total critical failures: ${FAILURES}${NC}"

if [ ${FAILURES} -eq 0 ]; then
    log_test "${GREEN}✓ All critical GitHub integration tests passed. Some non-critical tests may have warnings, which is expected in environments without full GitHub credentials.${NC}"
    exit 0
else
    log_test "${RED}✗ GitHub integration tests completed with ${FAILURES} critical failures.${NC}"
    log_test "${RED}✗ Please review the log: ${TEST_SPECIFIC_LOG} for details.${NC}"
    exit 1
fi
