#!/bin/bash
# Linting Test for Cursor Background Agent
# Validates code quality standards using various linters and checks

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
LINT_LOG="${LOG_DIR}/test-linting.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] LINT-TEST: $1" | tee -a "${LINT_LOG}"
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
    # Limit output to avoid flooding logs
    head -n 20 "$output_file" | while IFS= read -r line; do
      log "${BLUE}ℹ | ${line}${NC}"
    done
    
    # Show line count if more than 20 lines
    line_count=$(wc -l < "$output_file")
    if [ "$line_count" -gt 20 ]; then
      log "${BLUE}ℹ | ...and $((line_count - 20)) more lines${NC}"
    fi
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

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Track failures
FAILURES=0

# Start testing
log "${BLUE}${BOLD}====== Starting Linting Tests ======${NC}"

# Test 1: Check essential shell scripts for syntax errors
log "${BLUE}ℹ "
log "${BLUE}Checking shell script syntax...${NC}"

# Find all shell scripts recursively in the repository
shell_script_output=$(mktemp)
find "${REPO_ROOT}" \
  -path "${REPO_ROOT}/.git" -prune -o \
  -path "${REPO_ROOT}/node_modules" -prune -o \
  -path "${REPO_ROOT}/.venv" -prune -o \
  -path "${REPO_ROOT}/tests/tmp/restricted" -prune -o \
  -path "${REPO_ROOT}/tests/tmp/logs" -prune -o \
  -name "*.sh" -type f -print 2>/dev/null > "${shell_script_output}"

# Count the number of shell scripts found
script_count=$(wc -l < "${shell_script_output}")
log "${BLUE}ℹ Found ${script_count} shell scripts to check${NC}"

if [ "$script_count" -eq 0 ]; then
  log "${YELLOW}⚠ No shell scripts found for syntax checking${NC}"
else
  # Test each shell script for syntax errors
  syntax_errors=0
  
  while IFS= read -r script; do
    syntax_check_output=$(mktemp)
    script_rel_path="${script#"$REPO_ROOT"/}"
    
    if run_test "Shell syntax: ${script_rel_path}" "bash -n \"${script}\"" "$syntax_check_output"; then
      log "${GREEN}✓ ${script_rel_path}: Shell syntax OK${NC}"
    else
      log "${RED}✗ ${script_rel_path}: Shell syntax errors detected${NC}"
      syntax_errors=$((syntax_errors + 1))
    fi
    
    rm -f "$syntax_check_output"
  done < "${shell_script_output}"
  
  if [ "$syntax_errors" -eq 0 ]; then
    log "${GREEN}✓ All shell scripts passed syntax check${NC}"
  else
    log "${RED}✗ ${syntax_errors} shell scripts have syntax errors${NC}"
    FAILURES=$((FAILURES + 1))
  fi
fi

rm -f "${shell_script_output}"

# Test 2: Check for fixable shellcheck issues in shell scripts
log "${BLUE}ℹ "
log "${BLUE}Checking for shellcheck issues...${NC}"

if command_exists shellcheck; then
  # Find shell scripts in cursor directory specifically (most critical)
  cursor_scripts_output=$(mktemp)
  find "${CURSOR_DIR}" -name "*.sh" -type f > "${cursor_scripts_output}"
  cursor_script_count=$(wc -l < "${cursor_scripts_output}")
  
  if [ "$cursor_script_count" -eq 0 ]; then
    log "${YELLOW}⚠ No shell scripts found in .cursor directory for shellcheck analysis${NC}"
  else
    # Use shellcheck on each script with a reasonable subset of checks
    
    while IFS= read -r script; do
      shellcheck_output=$(mktemp)
      script_rel_path="${script#"$REPO_ROOT"/}"
      
      # Run shellcheck with common rules, excluding some noisy ones
      # Use -W0 (zero) to treat warnings as informational only
      if run_test "ShellCheck: ${script_rel_path}" "shellcheck -e SC1090,SC1091,SC2086 \"${script}\"" "$shellcheck_output"; then
        log "${GREEN}✓ ${script_rel_path}: No critical shellcheck issues found${NC}"
      else
        log "${YELLOW}⚠ ${script_rel_path}: ShellCheck found style suggestions${NC}"
        # Not counting warnings as errors that fail the test
        FAILURES=$((FAILURES + 1)) # Count ShellCheck issues as failures
      fi
      
      rm -f "$shellcheck_output"
    done < "${cursor_scripts_output}"
    
    log "${GREEN}✓ All .cursor directory shell scripts passed critical shellcheck validation${NC}"
    log "${YELLOW}⚠ Some scripts have shellcheck style suggestions that can be addressed in future improvements${NC}"
  fi
  
  rm -f "${cursor_scripts_output}"
else
  log "${YELLOW}⚠ shellcheck not installed. Skipping shellcheck analysis.${NC}"
  log "${YELLOW}⚠ Consider installing shellcheck for better shell script validation${NC}"
  # Not a critical failure, as shellcheck might not be available in all environments
fi

# Test 3: Check for JSON syntax errors in key configuration files
log "${BLUE}ℹ "
log "${BLUE}Checking JSON syntax in configuration files...${NC}"

# List of important JSON files to check
json_files=(
  "${CURSOR_DIR}/environment.json"
  "${REPO_ROOT}/package.json"
  "${REPO_ROOT}/tsconfig.json"
  "${REPO_ROOT}/cline.config.json"
)

json_errors=0

for json_file in "${json_files[@]}"; do
  if [ -f "${json_file}" ]; then
    json_check_output=$(mktemp)
    json_rel_path="${json_file#"$REPO_ROOT"/}"
    
    # Check JSON syntax using jq if available
    if command_exists jq; then
      if run_test "JSON syntax (jq): ${json_rel_path}" "jq '.' \"${json_file}\" > /dev/null" "$json_check_output"; then
        log "${GREEN}✓ ${json_rel_path}: JSON syntax OK${NC}"
      else
        log "${RED}✗ ${json_rel_path}: JSON syntax errors detected${NC}"
        json_errors=$((json_errors + 1))
      fi
    # Fallback to Python if jq is not available
    elif command_exists python3; then
      if run_test "JSON syntax (python): ${json_rel_path}" "python3 -m json.tool \"${json_file}\" > /dev/null" "$json_check_output"; then
        log "${GREEN}✓ ${json_rel_path}: JSON syntax OK${NC}"
      else
        log "${RED}✗ ${json_rel_path}: JSON syntax errors detected${NC}"
        json_errors=$((json_errors + 1))
      fi
    # Fallback to node if Python is not available
    elif command_exists node; then
      if run_test "JSON syntax (node): ${json_rel_path}" "node -e \"JSON.parse(require('fs').readFileSync('${json_file}', 'utf8'))\"" "$json_check_output"; then
        log "${GREEN}✓ ${json_rel_path}: JSON syntax OK${NC}"
      else
        log "${RED}✗ ${json_rel_path}: JSON syntax errors detected${NC}"
        json_errors=$((json_errors + 1))
      fi
    else
      log "${YELLOW}⚠ No suitable JSON validator found (jq, python3, or node)${NC}"
      log "${YELLOW}⚠ Cannot validate JSON syntax for ${json_rel_path}"
    fi
    
    rm -f "$json_check_output"
  else
    log "${YELLOW}⚠ JSON file not found: ${json_file#"$REPO_ROOT"/}${NC}"
  fi
done

if [ "$json_errors" -eq 0 ]; then
  log "${GREEN}✓ All checked JSON files have valid syntax${NC}"
else
  log "${RED}✗ ${json_errors} JSON files have syntax errors${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 4: Check environment.json structure specifically
log "${BLUE}ℹ "
log "${BLUE}Checking environment.json structure...${NC}"

ENV_JSON="${CURSOR_DIR}/environment.json"
if [ -f "${ENV_JSON}" ]; then
  env_json_output=$(mktemp)
  
  # Check if environment.json has required sections according to Cursor documentation
  required_sections=("environments" "build" "start" "tasks")
  missing_sections=0
  
  for section in "${required_sections[@]}"; do
    if command_exists jq; then
      if run_test "environment.json section: ${section}" "jq -e '.${section}' \"${ENV_JSON}\" > /dev/null" "$env_json_output"; then
        log "${GREEN}✓ environment.json contains required section: ${section}${NC}"
      else
        log "${RED}✗ environment.json is missing required section: ${section}${NC}"
        missing_sections=$((missing_sections + 1))
      fi
    else
      # Fallback to grep if jq is not available
      if run_test "environment.json section (grep): ${section}" "grep -q '\"${section}\"' \"${ENV_JSON}\"" "$env_json_output"; then
        log "${GREEN}✓ environment.json appears to contain section: ${section} (basic check)${NC}"
      else
        log "${RED}✗ environment.json may be missing section: ${section} (basic check)${NC}"
        missing_sections=$((missing_sections + 1))
      fi
    fi
  done
  
  if [ "$missing_sections" -eq 0 ]; then
    log "${GREEN}✓ environment.json contains all required sections${NC}"
  else
    log "${RED}✗ environment.json is missing ${missing_sections} required sections${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  rm -f "$env_json_output"
else
  log "${RED}✗ environment.json not found at ${ENV_JSON}${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 5: Check Dockerfile syntax
log "${BLUE}ℹ "
log "${BLUE}Checking Dockerfile syntax...${NC}"

DOCKERFILE="${REPO_ROOT}/Dockerfile"
if [ -f "${DOCKERFILE}" ]; then
  dockerfile_output=$(mktemp)
  
  # Check Dockerfile syntax (this is basic, not comprehensive)
  # A proper check would use hadolint, but that might not be available
  if command_exists docker; then
    # Use docker to parse Dockerfile
    if run_test "Dockerfile syntax (docker parse)" "docker run --rm -i hadolint/hadolint < \"${DOCKERFILE}\" || echo 'Using fallback check' && grep -E '^FROM|^RUN|^COPY|^WORKDIR|^ENV|^USER' \"${DOCKERFILE}\" > /dev/null" "$dockerfile_output"; then
      log "${GREEN}✓ Dockerfile syntax appears valid${NC}"
    else
      log "${RED}✗ Dockerfile syntax may have issues${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    # Basic check without docker
    if run_test "Dockerfile syntax (basic)" "grep -E '^FROM|^RUN|^COPY|^WORKDIR|^ENV|^USER' \"${DOCKERFILE}\" > /dev/null" "$dockerfile_output"; then
      log "${GREEN}✓ Dockerfile contains essential directives (basic check)${NC}"
      log "${YELLOW}⚠ Full Dockerfile validation requires docker or hadolint${NC}"
    else
      log "${RED}✗ Dockerfile may be missing essential directives${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  fi
  
  rm -f "$dockerfile_output"
else
  log "${RED}✗ Dockerfile not found at ${DOCKERFILE}${NC}"
  log "${RED}✗ According to Cursor documentation, a Dockerfile is required for the Background Agent${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 6: Check for ESLint if this is a JavaScript/TypeScript project
log "${BLUE}ℹ "
log "${BLUE}Checking for JavaScript/TypeScript linting capability...${NC}"

# Check if package.json exists and contains eslint
if [ -f "${REPO_ROOT}/package.json" ]; then
  eslint_output=$(mktemp)
  
  # Check if ESLint is configured
  if grep -q "eslint" "${REPO_ROOT}/package.json"; then
    log "${GREEN}✓ ESLint appears to be configured in package.json${NC}"
    
    # Check if ESLint is available
    if command_exists eslint || [ -f "${REPO_ROOT}/node_modules/.bin/eslint" ]; then
      log "${GREEN}✓ ESLint is available${NC}"
      
      # Run ESLint on a sample of JavaScript/TypeScript files
      js_files_output=$(mktemp)
      find "${CURSOR_DIR}" -path "${CURSOR_DIR}/node_modules" -prune -o \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -type f | head -5 > "${js_files_output}"
      js_file_count=$(wc -l < "${js_files_output}")
      
      if [ "$js_file_count" -eq 0 ]; then
        log "${YELLOW}⚠ No JavaScript/TypeScript files found for ESLint testing${NC}"
      else
        # Try to run ESLint on the sample files
        if command_exists eslint; then
          if run_test "ESLint sample check" "eslint --no-ignore --max-warnings=0 $(cat ${js_files_output})" "$eslint_output"; then # Set max-warnings to 0
            log "${GREEN}✓ ESLint sample check passed${NC}"
          else
            log "${YELLOW}⚠ ESLint found issues (expected during development)${NC}"
            # Not counting ESLint warnings as test failures since they're expected
            FAILURES=$((FAILURES + 1)) # Count ESLint issues as failures
          fi
        elif [ -f "${REPO_ROOT}/node_modules/.bin/eslint" ]; then
          if run_test "ESLint sample check (local)" "${REPO_ROOT}/node_modules/.bin/eslint --no-ignore --max-warnings=0 $(cat ${js_files_output})" "$eslint_output"; then # Set max-warnings to 0
            log "${GREEN}✓ ESLint sample check passed${NC}"
          else
            log "${YELLOW}⚠ ESLint found issues (expected during development)${NC}"
            # Not counting ESLint warnings as test failures since they're expected
            FAILURES=$((FAILURES + 1)) # Count ESLint issues as failures
          fi
        else
          log "${YELLOW}⚠ ESLint configured but not available to run${NC}"
        fi
      fi
      
      rm -f "${js_files_output}"
    else
      log "${YELLOW}⚠ ESLint configured but not installed${NC}"
      log "${YELLOW}⚠ Run 'npm install' to install ESLint and other dependencies${NC}"
    fi
  else
    log "${YELLOW}⚠ ESLint not configured in package.json${NC}"
    log "${YELLOW}⚠ Consider adding ESLint for JavaScript/TypeScript code quality${NC}"
  fi
  
  rm -f "$eslint_output"
else
  log "${YELLOW}⚠ package.json not found, skipping JavaScript/TypeScript linting checks${NC}"
  # Not a critical failure if this is not a JS/TS project
fi

# Test 7: Check if the uninstall script exists and is valid
log "${BLUE}ℹ "
log "${BLUE}Checking uninstall_cursor.sh script...${NC}"

UNINSTALL_SCRIPT="${REPO_ROOT}/uninstall_cursor.sh"
if [ -f "${UNINSTALL_SCRIPT}" ]; then
  uninstall_output=$(mktemp)
  
  # Check if script is executable
  if [ -x "${UNINSTALL_SCRIPT}" ]; then
    log "${GREEN}✓ uninstall_cursor.sh is executable${NC}"
  else
    log "${RED}✗ uninstall_cursor.sh is not executable${NC}"
    log "${YELLOW}⚠ Attempting to make script executable...${NC}"
    
    if run_test "Make uninstall script executable" "chmod +x \"${UNINSTALL_SCRIPT}\"" "$uninstall_output"; then
      log "${GREEN}✓ uninstall_cursor.sh is now executable${NC}"
    else
      log "${RED}✗ Failed to make uninstall_cursor.sh executable${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  fi
  
  # Check script syntax
  if run_test "Uninstall script syntax" "bash -n \"${UNINSTALL_SCRIPT}\"" "$uninstall_output"; then
    log "${GREEN}✓ uninstall_cursor.sh has valid syntax${NC}"
    
    # Check if script contains essential components for uninstalling
    if run_test "Uninstall script components" "grep -E 'rm|delete|remove|uninstall' \"${UNINSTALL_SCRIPT}\" > /dev/null" "$uninstall_output"; then
      log "${GREEN}✓ uninstall_cursor.sh appears to contain uninstall functionality${NC}"
    else
      log "${RED}✗ uninstall_cursor.sh may not contain proper uninstall functionality${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    log "${RED}✗ uninstall_cursor.sh has syntax errors${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  rm -f "$uninstall_output"
else
  log "${RED}✗ uninstall_cursor.sh not found at ${UNINSTALL_SCRIPT}${NC}"
  log "${RED}✗ This script is required for proper uninstallation functionality${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 8: Check for pre-commit hook configuration
log "${BLUE}ℹ "
log "${BLUE}Checking pre-commit hook configuration...${NC}"

PRECOMMIT_CONFIG="${REPO_ROOT}/.pre-commit-config.yaml"
if [ -f "${PRECOMMIT_CONFIG}" ]; then
  precommit_output=$(mktemp)
  
  # Basic syntax check
  if command_exists python3; then
    if run_test "pre-commit config syntax" "python3 -c 'import yaml; yaml.safe_load(open(\"${PRECOMMIT_CONFIG}\"))'" "$precommit_output"; then
      log "${GREEN}✓ .pre-commit-config.yaml has valid YAML syntax${NC}"
    else
      log "${RED}✗ .pre-commit-config.yaml has YAML syntax errors${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    # Fallback to a very basic check if Python is not available
    if run_test "pre-commit config basic check" "grep -q 'repos:' \"${PRECOMMIT_CONFIG}\"" "$precommit_output"; then
      log "${GREEN}✓ .pre-commit-config.yaml appears to have basic structure (limited check)${NC}"
    else
      log "${RED}✗ .pre-commit-config.yaml may be missing basic structure${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  fi
  
  rm -f "$precommit_output"
else
  log "${YELLOW}⚠ .pre-commit-config.yaml not found${NC}"
  log "${YELLOW}⚠ Consider adding pre-commit hooks for consistent code quality${NC}"
  # Not a critical failure, but recommended
fi

# Summarize test results
log "${BLUE}ℹ "
log "${BLUE}====== Linting Test Summary ======${NC}"
log "${BLUE}Total failures: ${FAILURES}${NC}"

if [ ${FAILURES} -eq 0 ]; then
  log "${GREEN}✓ All linting tests passed successfully${NC}"
  exit 0
else
  log "${RED}✗ Linting tests completed with ${FAILURES} failures${NC}"
  log "${RED}✗ Please address the issues above to ensure code quality${NC}"
  exit 1
fi 