#!/bin/bash
# This script validates the Cursor Background Agent environment configuration

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define status symbols
SUCCESS="✓"
ERROR="✗"
WARNING="⚠"
INFO="ℹ"

# Define the current directory and paths
CURRENT_DIR=$(pwd)
SCRIPT_DIR="$(dirname "$0")"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
TESTS_DIR="${CURSOR_DIR}/tests"
LOG_DIR="${CURSOR_DIR}/logs"

# Create the log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Define the log file
LOG_FILE="${LOG_DIR}/validate_cursor_environment.log"

# Start with a clean log file
> "${LOG_FILE}"

# Function to log messages
log() {
  local prefix="$1"
  local color="$2"
  local message="$3"
  local symbol="$4"

  # Print to console
  echo -e "${color}${symbol} ${prefix}:${NC} ${message}"

  # Log to file (without color codes)
  echo "${symbol} ${prefix}: ${message}" >> "${LOG_FILE}"
}

success() {
  log "SUCCESS" "${GREEN}" "$1" "${SUCCESS}"
}

error() {
  log "ERROR" "${RED}" "$1" "${ERROR}"
}

warning() {
  log "WARNING" "${YELLOW}" "$1" "${WARNING}"
}

info() {
  log "INFO" "${BLUE}" "$1" "${INFO}"
}

# Function to check if a file exists
check_file() {
  local file_path="$1"
  local file_name="$2"
  local required="$3"

  if [ -f "${file_path}" ]; then
    success "${file_name} exists"
    return 0
  else
    if [ "${required}" = "true" ]; then
      error "${file_name} is missing"
      return 1
    else
      warning "${file_name} is missing (recommended but optional)"
      return 2
    fi
  fi
}

# Function to check if a directory exists
check_directory() {
  local dir_path="$1"
  local dir_name="$2"
  local required="$3"

  if [ -d "${dir_path}" ]; then
    success "${dir_name} directory exists"
    return 0
  else
    if [ "${required}" = "true" ]; then
      error "${dir_name} directory is missing"
      return 1
    else
      warning "${dir_name} directory is missing (recommended but optional)"
      return 2
    fi
  fi
}

# Function to check file permissions
check_permissions() {
  local file_path="$1"
  local file_name="$2"

  if [ -f "${file_path}" ]; then
    if [ -x "${file_path}" ]; then
      success "${file_name} is executable"
      return 0
    else
      error "${file_name} is not executable"
      chmod +x "${file_path}" 2>/dev/null
      if [ -x "${file_path}" ]; then
        success "Fixed permissions for ${file_name}"
        return 0
      else
        error "Failed to make ${file_name} executable"
        return 1
      fi
    fi
  else
    warning "${file_name} not found, skipping permission check"
    return 2
  fi
}

# Print the header
echo "===== Cursor Background Agent Environment Validation ====="
echo "Running validation for all required files and directories..."

# Count success and failures
success_count=0
failure_count=0
warning_count=0

# Check Git repository
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  success "Git repository found at ${CURRENT_DIR}"
  ((success_count++))
else
  error "Not a Git repository. Background Agent requires a Git repository."
  ((failure_count++))
fi

echo -e "\n===== Checking Required Files ====="

# Check required directory structure
if check_directory "${CURSOR_DIR}" ".cursor" "true"; then
  ((success_count++))
else
  ((failure_count++))
fi

# Check required files
if check_file "${CURSOR_DIR}/environment.json" "environment.json" "true"; then
  ((success_count++))
else
  ((failure_count++))
fi

if check_file "${CURSOR_DIR}/install.sh" "install.sh" "true"; then
  ((success_count++))
else
  ((failure_count++))
fi

if check_file "${CURRENT_DIR}/Dockerfile" "Dockerfile" "true"; then
  ((success_count++))
else
  ((failure_count++))
fi

if check_file "${CURSOR_DIR}/github-setup.sh" "github-setup.sh" "true"; then
  ((success_count++))
else
  ((failure_count++))
fi

if check_file "${CURSOR_DIR}/retry-utils.sh" "retry-utils.sh" "true"; then
  ((success_count++))
else
  ((failure_count++))
fi

if check_file "${CURSOR_DIR}/background-agent-prompt.md" "background-agent-prompt.md" "false"; then
  ((success_count++))
else
  ((warning_count++))
fi

if check_file "${CURSOR_DIR}/TROUBLESHOOTING.md" "TROUBLESHOOTING.md" "false"; then
  ((success_count++))
else
  ((warning_count++))
fi

if check_file "${CURSOR_DIR}/README.md" "README.md for .cursor" "false"; then
  ((success_count++))
else
  ((warning_count++))
fi

echo -e "\n===== Checking File Permissions ====="

# Check permissions for scripts directly in .cursor/
if check_permissions "${CURSOR_DIR}/install.sh" "install.sh"; then
  ((success_count++))
else
  ((failure_count++))
fi

if check_permissions "${CURSOR_DIR}/github-setup.sh" "github-setup.sh"; then
  ((success_count++))
else
  ((failure_count++))
fi

if check_permissions "${CURSOR_DIR}/retry-utils.sh" "retry-utils.sh"; then
  ((success_count++))
else
  ((failure_count++))
fi

# Check permissions for run-tests.sh in .cursor/tests/
if check_permissions "${TESTS_DIR}/run-tests.sh" "run-tests.sh"; then
  ((success_count++))
else
  ((failure_count++))
fi

echo -e "\n===== Checking Log Directory Setup ====="

# Check log directory
if check_directory "${LOG_DIR}" "logs" "true"; then
  ((success_count++))
else
  ((failure_count++))
fi

# Check agent log file
if [ -f "${LOG_DIR}/agent.log" ] || touch "${LOG_DIR}/agent.log" 2>/dev/null; then
  success "agent.log exists"
  ((success_count++))
else
  error "Cannot create agent.log file"
  ((failure_count++))
fi

echo -e "\n===== Validating File Content ====="

# Validate environment.json content
info "Validating environment.json content with jq..."
if command -v jq &> /dev/null && [ -f "${CURSOR_DIR}/environment.json" ]; then
  if jq -e '.build' "${CURSOR_DIR}/environment.json" > /dev/null 2>&1; then
    success "environment.json has build section"
    ((success_count++))

    # Verify Dockerfile path in environment.json
    dockerfile_path=$(jq -r '.build.dockerfile' "${CURSOR_DIR}/environment.json" 2>/dev/null || echo "")
    if [ -n "${dockerfile_path}" ]; then
      success "environment.json references correct Dockerfile path: ${dockerfile_path}"
      ((success_count++))
    else
      error "environment.json does not have a valid Dockerfile path"
      ((failure_count++))
    fi
  else
    warning "environment.json does not have a build section"
    ((warning_count++))
  fi

  # Check user field
  user=$(jq -r '.user' "${CURSOR_DIR}/environment.json" 2>/dev/null || echo "")
  if [ -n "${user}" ]; then
    success "environment.json has user field: ${user}"
    ((success_count++))
  else
    error "environment.json does not have a user field"
    ((failure_count++))
  fi

  # Check install command
  install_cmd=$(jq -r '.install' "${CURSOR_DIR}/environment.json" 2>/dev/null || echo "")
  if [ -n "${install_cmd}" ]; then
    success "environment.json has install command: ${install_cmd}"
    ((success_count++))
  else
    error "environment.json does not have an install command"
    ((failure_count++))
  fi

  # Check start command
  start_cmd=$(jq -r '.start' "${CURSOR_DIR}/environment.json" 2>/dev/null || echo "")
  if [ -n "${start_cmd}" ]; then
    success "environment.json has start command: ${start_cmd}"
    ((success_count++))
  else
    error "environment.json does not have a start command"
    ((failure_count++))
  fi

  # Check terminals
  terminals_count=$(jq '.terminals | length' "${CURSOR_DIR}/environment.json" 2>/dev/null || echo "0")
  if [ "${terminals_count}" -gt 0 ]; then
    success "environment.json has ${terminals_count} terminal(s) configured"
    ((success_count++))
  else
    warning "environment.json does not have any terminals configured"
    ((warning_count++))
  fi
else
  error "Could not validate environment.json content (jq not available or file missing)"
  ((failure_count++))
fi

# Validate Dockerfile content
info "Validating Dockerfile content..."
if [ -f "${CURRENT_DIR}/Dockerfile" ]; then
  if grep -q "FROM node:.*" "${CURRENT_DIR}/Dockerfile"; then
    success "Dockerfile has FROM node instruction"
    ((success_count++))
  else
    error "Dockerfile is missing FROM node instruction"
    ((failure_count++))
  fi

  if grep -q "WORKDIR /agent_workspace" "${CURRENT_DIR}/Dockerfile"; then
    success "Dockerfile has WORKDIR /agent_workspace"
    ((success_count++))
  else
    error "Dockerfile is missing WORKDIR /agent_workspace"
    ((failure_count++))
  fi

  if grep -q "USER node" "${CURRENT_DIR}/Dockerfile"; then
    success "Dockerfile has USER node instruction"
    ((success_count++))
  else
    error "Dockerfile is missing USER node instruction"
    ((failure_count++))
  fi

  if ! grep -q "COPY" "${CURRENT_DIR}/Dockerfile"; then
    success "Dockerfile does not use COPY (as per recommendation)"
    ((success_count++))
  else
    warning "Dockerfile uses COPY instruction. For background agents, project files are typically cloned, not copied."
    ((warning_count++))
  fi
else
  error "Dockerfile not found, skipping content validation"
  ((failure_count++))
fi

echo -e "\n===== Checking GitHub Integration ====="

# Check GitHub remote configuration
if git remote -v | grep -q "origin"; then
  remote_url=$(git remote -v | grep "origin" | head -n 1)
  success "GitHub remote is configured: ${remote_url}"
  ((success_count++))
else
  error "GitHub remote (origin) is not configured"
  ((failure_count++))
fi

echo -e "\n===== Checking Common Issues ====="

# Check for error.md file which might indicate previous errors
if [ -f "${LOG_DIR}/error.md" ]; then
  warning "error.md file found. This might indicate previous errors."
  ((warning_count++))
else
  info "No error.md file found"
fi

# Check for write permissions in the current directory
if [ -w "${CURRENT_DIR}" ]; then
  success "Current directory has write permissions"
  ((success_count++))
else
  error "Current directory does not have write permissions"
  ((failure_count++))
fi

# Print summary
echo -e "\n===== Validation Summary ====="
echo "PASSED: ${success_count}"
echo "FAILED: ${failure_count}"
echo "WARNINGS: ${warning_count}"
echo ""

# Determine overall status
if [ ${failure_count} -eq 0 ]; then
  if [ ${warning_count} -eq 0 ]; then
    echo -e "${GREEN}Validation completed successfully!${NC}"
    exit 0
  else
    echo -e "${YELLOW}Validation completed with warnings. Review warnings before proceeding.${NC}"
    exit 0
  fi
else
  echo -e "${RED}Validation completed with failures. Please fix the issues before proceeding.${NC}"
  exit 1
fi
