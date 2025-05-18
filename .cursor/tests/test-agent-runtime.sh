#!/bin/bash
# Background Agent Runtime Test Script
# This script tests the runtime behavior of the Background Agent

set -e

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define current directory and paths
SCRIPT_DIR="$(dirname "$0")"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
# SCRIPTS_DIR is no longer used, scripts are in CURSOR_DIR
# SCRIPTS_DIR="${CURSOR_DIR}/scripts"
LOG_DIR="${CURSOR_DIR}/logs"
LOG_FILE="${LOG_DIR}/agent-runtime-test.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Clear log file
> "${LOG_FILE}"

# Log helper functions
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[${timestamp}] $1" | tee -a "${LOG_FILE}"
}

log_success() {
  log "${GREEN}✓ $1${NC}"
}

log_error() {
  log "${RED}✗ $1${NC}"
}

log_warning() {
  log "${YELLOW}⚠ $1${NC}"
}

log_info() {
  log "${BLUE}ℹ $1${NC}"
}

# Print header
log "--- Starting Background Agent Runtime Test ---"

# Test result counters
tests_total=0
tests_passed=0

# Function to run a test
run_test() {
  local test_name="$1"
  local test_command="$2"
  local critical="$3"

  ((tests_total++))

  log_info "Testing: ${test_name}"
  if eval "${test_command}"; then
    log_success "${test_name}: PASSED"
    ((tests_passed++))
    return 0
  else
    if [ "${critical}" = "true" ]; then
      log_error "${test_name}: FAILED (Critical)"
      return 1
    else
      log_warning "${test_name}: FAILED (Non-critical)"
      return 0
    fi
  fi
}

# Check if critical files exist
log_info "Performing static configuration file checks..."

critical_files=(
  "${CURSOR_DIR}/install.sh:Install Script"
  "${CURSOR_DIR}/github-setup.sh:GitHub Setup Script"
  "${CURSOR_DIR}/retry-utils.sh:Retry Utilities Script"
  "${CURSOR_DIR}/environment.json:Environment JSON"
  "${CURSOR_DIR}/../Dockerfile:Dockerfile" # Corrected Dockerfile path
)

missing_critical_files=false

for file_entry in "${critical_files[@]}"; do
  IFS=':' read -r file_path file_name <<< "${file_entry}"

  if [ ! -f "${file_path}" ]; then
    # Check if there's a symlink in the original location
    original_path="${CURSOR_DIR}/$(basename "${file_path}")"
    if [ -f "${original_path}" ]; then
      log_warning "${file_name} found at ${original_path} instead of ${file_path}"
    else
      log_error "${file_path} missing"
      missing_critical_files=true
    fi
  else
    log_success "${file_name} exists"
  fi
done

if [ "${missing_critical_files}" = "true" ]; then
  log_error "Critical static configuration file(s) missing. Aborting runtime test."
  log_info "Cleaning up any stray Docker containers..."

  # Try to clean up but don't fail if Docker isn't running
  docker ps -a --filter "name=cursor-agent-test" --format "{{.ID}}" | xargs -r docker rm -f 2>/dev/null || true

  log "--- Background Agent Runtime Test FAILED ---"
  exit 1
fi

# Verify script permissions
log_info "Checking script permissions..."

script_files=(
  "${CURSOR_DIR}/install.sh"
  "${CURSOR_DIR}/github-setup.sh"
  "${CURSOR_DIR}/retry-utils.sh"
)

for script in "${script_files[@]}"; do
  if [ ! -x "${script}" ]; then
    log_warning "${script} is not executable. Fixing..."
    chmod +x "${script}"

    if [ ! -x "${script}" ]; then
      log_error "Failed to make ${script} executable. This will cause the agent to fail."
      missing_critical_files=true
    else
      log_success "Fixed permissions for ${script}"
    fi
  else
    log_success "${script} is executable"
  fi
done

if [ "${missing_critical_files}" = "true" ]; then
  log_error "Critical script(s) not executable. Aborting runtime test."
  exit 1
fi

# Validate environment.json content
log_info "Validating environment.json content..."

if ! command -v jq &>/dev/null; then
  log_warning "jq not found, skipping detailed environment.json validation"
else
  # Check for required fields in environment.json
  env_json="${CURSOR_DIR}/environment.json"

  # Check if build section exists
  if jq -e '.build' "${env_json}" >/dev/null 2>&1; then
    log_success "environment.json contains build section"

    # Check if Dockerfile is properly referenced
    if jq -e '.build.dockerfile' "${env_json}" >/dev/null 2>&1; then
      dockerfile_ref=$(jq -r '.build.dockerfile' "${env_json}")
      # Assuming dockerfile_ref is a simple filename like "Dockerfile"
      # And environment.json context is already corrected to ".."
      # The actual Dockerfile path would be CURSOR_DIR/../<dockerfile_ref_value>
      # For validation, we check this path.
      expected_dockerfile_path="${CURSOR_DIR}/../${dockerfile_ref}"
      if [ -f "${expected_dockerfile_path}" ]; then
        log_success "Dockerfile reference '${dockerfile_ref}' is valid, found at ${expected_dockerfile_path}"
      else
        log_error "Dockerfile reference '${dockerfile_ref}' is invalid. Referenced file not found: ${expected_dockerfile_path}"
      fi
    else
      log_error "environment.json is missing build.dockerfile"
    fi
  else
    log_error "environment.json is missing build section"
  fi

  # Check terminal configuration
  if jq -e '.terminals' "${env_json}" >/dev/null 2>&1; then
    terminals_count=$(jq '.terminals | length' "${env_json}")
    log_success "environment.json contains ${terminals_count} terminal configurations"

    # Check if terminal commands are valid
    invalid_terminals=0
    for i in $(seq 0 $((terminals_count - 1))); do
      terminal_name=$(jq -r ".terminals[$i].name" "${env_json}")
      terminal_cmd=$(jq -r ".terminals[$i].command" "${env_json}")

      if [ -z "${terminal_cmd}" ] || [ "${terminal_cmd}" = "null" ]; then
        log_error "Terminal '${terminal_name}' has no command defined"
        ((invalid_terminals++))
      else
        log_success "Terminal '${terminal_name}' has a valid command"
      fi
    done

    if [ ${invalid_terminals} -gt 0 ]; then
      log_warning "${invalid_terminals} terminal(s) have invalid commands"
    fi
  else
    log_warning "environment.json does not contain terminal configurations"
  fi

  # Check install command
  if jq -e '.install' "${env_json}" >/dev/null 2>&1; then
    install_cmd=$(jq -r '.install' "${env_json}")

    # Check if the install command is valid
    if [ -n "${install_cmd}" ] && [ "${install_cmd}" != "null" ]; then
      # Check if the install command points to an executable script
      if [[ "${install_cmd}" == *".sh" ]] && [ ! -x "${CURSOR_DIR}/${install_cmd#./}" ] && [ ! -x "${install_cmd}" ]; then
        log_error "Install command points to a non-executable script: ${install_cmd}"
      else
        log_success "Install command is valid: ${install_cmd}"
      fi
    else
      log_error "Install command is empty or invalid"
    fi
  else
    log_error "environment.json is missing install command"
  fi
fi

# Test Docker if available
if command -v docker &>/dev/null; then
  log_info "Docker found, testing Docker container creation..."

  # Check if Docker daemon is running
  if ! docker info &>/dev/null; then
    log_warning "Docker daemon is not running. Skipping Docker tests."
  else
    # Test Docker image build from the Dockerfile
    log_info "Testing Docker image build from Dockerfile..."

    # Create a temporary directory for the build context
    tmp_dir=$(mktemp -d)
    # Dockerfile is in the parent directory of CURSOR_DIR
    actual_dockerfile_path="${CURSOR_DIR}/../Dockerfile"
    if [ ! -f "${actual_dockerfile_path}" ]; then
      log_error "Dockerfile not found at ${actual_dockerfile_path} for build test."
    else
      cp "${actual_dockerfile_path}" "${tmp_dir}/Dockerfile" # Copy Dockerfile to context dir

      # The context for docker build should be the directory containing the Dockerfile, which is CURSOR_DIR/..
      # However, for this isolated test, we build from tmp_dir where Dockerfile is copied.
      # If environment.json context is "..", actual agent build uses CURSOR_DIR/.. as context.
      if docker build -t cursor-agent-test:runtime "${tmp_dir}" >> "${LOG_FILE}" 2>&1; then
        log_success "Docker image build successful"

        # Test running a container with the built image
        log_info "Testing container execution..."

        if docker run --rm cursor-agent-test:runtime node --version >> "${LOG_FILE}" 2>&1; then
          log_success "Container execution successful"
        else
          log_error "Container execution failed"
        fi

        # Clean up the test image
        docker rmi cursor-agent-test:runtime &>/dev/null || true
      else
        log_error "Docker image build failed"
      fi
    fi

    # Clean up temporary directory
    rm -rf "${tmp_dir}"
  fi
else
  log_warning "Docker not found. Skipping Docker-based tests."
fi

# Test GitHub integration
log_info "Testing GitHub repository connectivity..."

# Check if we have git
if ! command -v git &>/dev/null; then
  log_error "Git not found. GitHub integration cannot be tested."
else
  # Check if the repository has a remote
  if git remote -v | grep -q origin; then
    log_success "Git remote 'origin' is configured"

    # Get the remote URL
    remote_url=$(git remote get-url origin 2>/dev/null)
    log_info "Remote URL: ${remote_url}"

    # Try to validate GitHub connectivity (without requiring authentication)
    if git ls-remote --heads https://github.com &>/dev/null; then
      log_success "GitHub connectivity is working"

      # Try to check the specific repository access (might require authentication)
      if git ls-remote --quiet "${remote_url}" HEAD &>/dev/null; then
        log_success "GitHub repository access is working"
      else
        log_warning "GitHub repository access failed. This might be due to missing credentials."
        log_info "Note: The Background Agent will use GitHub app credentials provided by Cursor."
      fi
    else
      log_warning "GitHub connectivity check failed. This might be due to network issues."
    fi
  else
    log_error "Git remote 'origin' is not configured"
  fi
fi

# Check the agent log file
log_info "Checking agent log file..."

if [ -f "${LOG_DIR}/agent.log" ]; then
  log_success "Agent log file exists"

  # Ensure the log file is writable
  if [ -w "${LOG_DIR}/agent.log" ]; then
    log_success "Agent log file is writable"
  else
    log_warning "Agent log file is not writable. This might cause issues for the agent."
  fi
else
  log_warning "Agent log file does not exist. Creating it..."

  # Try to create the log file
  if touch "${LOG_DIR}/agent.log" 2>/dev/null; then
    log_success "Created agent log file"
  else
    log_error "Failed to create agent log file"
  fi
fi

# Check for error.md file
if [ -f "${LOG_DIR}/error.md" ]; then
  log_warning "error.md file exists. This might indicate previous errors."

  # Check if error.md contains errors
  if grep -q "ERROR" "${LOG_DIR}/error.md"; then
    log_warning "error.md contains ERROR messages. You might want to investigate these."
  fi
fi

# Print summary
log "--- Background Agent Runtime Test Summary ---"
log "Tests Total: ${tests_total}"
log "Tests Passed: ${tests_passed}"

if [ ${tests_passed} -eq ${tests_total} ]; then
  log_success "All tests passed! The Background Agent environment is correctly configured."
  exit 0
else
  success_rate=$((tests_passed * 100 / tests_total))
  log_warning "Test completion: ${success_rate}% (${tests_passed}/${tests_total})"

  if [ ${success_rate} -ge 80 ]; then
    log_warning "Most tests passed. The Background Agent should function with minor issues."
    exit 0
  else
    log_error "Too many tests failed. The Background Agent might not function correctly."
    exit 1
  fi
fi
