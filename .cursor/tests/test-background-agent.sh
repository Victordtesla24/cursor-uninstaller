#!/bin/bash
# Background Agent Core Test for Cursor Background Agent
# Validates core configuration files, structure, and integration points

set -e
set -o pipefail # Add pipefail to capture pipeline failures

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
AGENT_LOG="${LOG_DIR}/test-background-agent.sh.log" # Renamed log for clarity
ENVIRONMENT_JSON="${CURSOR_DIR}/environment.json"
INSTALL_SCRIPT="${CURSOR_DIR}/install.sh"
MARKER_FILE="${REPO_ROOT}/bg-agent-install-complete.txt"

# Ensure log directory exists
mkdir -p "${LOG_DIR}" || { echo "CRITICAL: Could not create log directory"; exit 1; }

# Function to log messages - ensures output to both stdout and log file
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] BG-AGENT-TEST: $1" | tee -a "${AGENT_LOG}"
}

# Function to run a test and capture output with improved error handling
run_test() {
  local test_name="$1"
  local test_cmd="$2"
  local output_file="$3"
  
  log "${BLUE}Running test: ${test_name}${NC}"
  if eval "$test_cmd" > "$output_file" 2>&1; then
    # If the output file has content, display it
    if [ -s "$output_file" ]; then
      log "${BLUE}ℹ Test output:${NC}"
      while IFS= read -r line; do
        log "${BLUE}ℹ | ${line}${NC}"
      done < "$output_file"
    else
      log "${BLUE}ℹ Test produced no specific output, but was successful${NC}"
    fi
    return 0
  else
    local exit_code=$?
    # If the test failed, always display output if available
    if [ -s "$output_file" ]; then
      log "${RED}✗ Error output:${NC}"
      while IFS= read -r line; do
        log "${RED}✗ | ${line}${NC}"
      done < "$output_file"
    else
      log "${RED}✗ Test failed with exit code $exit_code but produced no error output${NC}"
    fi
    return $exit_code
  fi
}

# Start with a clean log file
rm -f "${AGENT_LOG}"
touch "${AGENT_LOG}"

# Announcement for both stdout and log file
echo "===== CURSOR BACKGROUND AGENT VALIDATION TEST ====="
echo "Running comprehensive tests to verify Background Agent requirements"
echo "Test log: ${AGENT_LOG}"
echo "================================================="

# Report test start
log "${BOLD}${BLUE}Starting Background Agent Tests${NC}"
log "${BLUE}===============================${NC}"

# Initialize failure counter
FAILURES=0

# Test 1: Check for marker file that indicates successful installation
log "${BLUE}ℹ "
log "${BLUE}Testing installation marker file...${NC}"

if [ -f "${MARKER_FILE}" ]; then
  log "${GREEN}✓ Installation marker file exists${NC}"
  
  # Check if the marker file has content (not empty)
  if [ -s "${MARKER_FILE}" ]; then
    log "${GREEN}✓ Installation marker file has content${NC}"
    # Display marker file content for verification
    marker_content=$(cat "${MARKER_FILE}")
    log "${BLUE}ℹ Marker file content: ${marker_content}${NC}"
  else
    log "${RED}✗ Installation marker file is empty${NC}"
    FAILURES=$((FAILURES + 1))
  fi
else
  log "${RED}✗ Installation marker file does not exist${NC}"
  log "${RED}ℹ This file should be created by install.sh script at ${MARKER_FILE}${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 2: Check environment.json file
log "${BLUE}ℹ "
log "${BLUE}Testing environment.json file...${NC}"

if [ -f "${ENVIRONMENT_JSON}" ]; then
  log "${BLUE}ℹ Found environment.json at ${ENVIRONMENT_JSON}${NC}"
  
  # Check if jq is available
  if ! command -v jq &> /dev/null; then
    log "${RED}✗ CRITICAL: jq command not found. jq is required for proper validation of environment.json.${NC}"
    log "${RED}ℹ Please install jq (e.g., apt-get install jq, brew install jq)${NC}"
    FAILURES=$((FAILURES + 1))
    # Log a specific test failure for jq availability
    run_test "jq availability for environment.json validation" "false" <(echo "jq command not found, cannot validate environment.json fully.")
  else
    # Validate JSON syntax
    temp_file1=$(mktemp)
    if run_test "environment.json syntax check" "jq '.' \"${ENVIRONMENT_JSON}\" > /dev/null" "$temp_file1"; then
      log "${GREEN}✓ environment.json has valid JSON syntax${NC}"
      
      # Displaying basic info about environment.json
      user_value=$(jq -r '.user // "not set"' "${ENVIRONMENT_JSON}")
      install_script=$(jq -r '.install // "not set"' "${ENVIRONMENT_JSON}")
      log "${BLUE}ℹ environment.json configured with user: ${user_value}, install script: ${install_script}${NC}"
      
      # Check for required fields based on Cursor documentation
      required_fields=("user" "install" "start" "terminals" "build")
      for field in "${required_fields[@]}"; do
        if run_test "environment.json has field: $field" "jq -e '.${field}' \"${ENVIRONMENT_JSON}\"" "$temp_file1"; then
          log "${GREEN}✓ environment.json has required field: $field${NC}"
        else
          log "${RED}✗ environment.json is missing required field: $field (or its value is null/false)${NC}"
          log "${RED}ℹ According to Cursor documentation, this field is required${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      done
      
      # Check terminals configuration
      if run_test "environment.json has terminals defined and > 0" "jq -e '.terminals | length > 0' \"${ENVIRONMENT_JSON}\"" "$temp_file1"; then
        terminal_count=$(jq '.terminals | length' "${ENVIRONMENT_JSON}")
        log "${GREEN}✓ environment.json has ${terminal_count} terminals defined${NC}"
        
        # Validate each terminal
        for ((i=0; i<terminal_count; i++)); do
          terminal_name=$(jq -r ".terminals[$i].name" "${ENVIRONMENT_JSON}")
          terminal_cmd=$(jq -r ".terminals[$i].command" "${ENVIRONMENT_JSON}")
          terminal_desc=$(jq -r ".terminals[$i].description" "${ENVIRONMENT_JSON}")
          
          log "${BLUE}ℹ Checking terminal: $terminal_name${NC}"
          
          if [ -n "$terminal_name" ] && [ "$terminal_name" != "null" ]; then
            log "${GREEN}✓ Terminal has name defined: $terminal_name${NC}"
          else
            log "${RED}✗ Terminal is missing name field${NC}"
            FAILURES=$((FAILURES + 1))
          fi
          
          if [ -n "$terminal_cmd" ] && [ "$terminal_cmd" != "null" ]; then
            log "${GREEN}✓ Terminal $terminal_name has command defined: $terminal_cmd${NC}"
          else
            log "${RED}✗ Terminal $terminal_name is missing command field${NC}"
            FAILURES=$((FAILURES + 1))
          fi
          
          if [ -n "$terminal_desc" ] && [ "$terminal_desc" != "null" ]; then
            log "${GREEN}✓ Terminal $terminal_name has description defined${NC}"
          else
            log "${RED}✗ Terminal $terminal_name is missing description field${NC}"
            FAILURES=$((FAILURES + 1))
          fi
        done
      else
        log "${RED}✗ environment.json has no terminals defined${NC}"
        log "${RED}ℹ Cursor documentation requires at least one terminal definition${NC}"
        FAILURES=$((FAILURES + 1))
      fi
      
      # Check build configuration
      if run_test "environment.json has build configuration" "jq -e '.build' \"${ENVIRONMENT_JSON}\"" "$temp_file1"; then
        log "${GREEN}✓ environment.json has build configuration${NC}"
        
        # Check if Dockerfile approach is used
        if run_test "environment.json build has dockerfile" "jq -e '.build.dockerfile' \"${ENVIRONMENT_JSON}\"" "$temp_file1"; then
          dockerfile_path=$(jq -r '.build.dockerfile' "${ENVIRONMENT_JSON}")
          log "${GREEN}✓ Using Dockerfile approach: ${dockerfile_path}${NC}"
          
          # Check if the referenced Dockerfile exists
          if [ "$dockerfile_path" = "Dockerfile" ]; then
            if [ -f "${REPO_ROOT}/Dockerfile" ]; then
              log "${GREEN}✓ Referenced Dockerfile exists at repository root${NC}"
            else
              log "${RED}✗ Referenced Dockerfile does not exist at repository root${NC}"
              FAILURES=$((FAILURES + 1))
            fi
          else
            if [ -f "${REPO_ROOT}/${dockerfile_path}" ]; then
              log "${GREEN}✓ Referenced Dockerfile exists at ${dockerfile_path}${NC}"
            else
              log "${RED}✗ Referenced Dockerfile does not exist at ${dockerfile_path}${NC}"
              FAILURES=$((FAILURES + 1))
            fi
          fi
          
          # Check if context is set
          if run_test "environment.json build has context" "jq -e '.build.context' \"${ENVIRONMENT_JSON}\"" "$temp_file1"; then
            context_path=$(jq -r '.build.context' "${ENVIRONMENT_JSON}")
            log "${GREEN}✓ Build context is set to: ${context_path}${NC}"
          else
            log "${RED}✗ Build context is not specified in environment.json${NC}"
            log "${RED}ℹ Cursor documentation recommends setting the build context${NC}"
            FAILURES=$((FAILURES + 1))
          fi
        # Check if snapshot approach is used
        elif run_test "environment.json build has snapshot" "jq -e '.build.snapshot' \"${ENVIRONMENT_JSON}\"" "$temp_file1"; then
          snapshot_id=$(jq -r '.build.snapshot' "${ENVIRONMENT_JSON}")
          log "${GREEN}✓ Using snapshot approach: ${snapshot_id}${NC}"
          
          # Verify snapshot ID isn't a placeholder
          if [[ "$snapshot_id" == *"REPLACE_WITH_SNAPSHOT_ID"* ]]; then
            log "${RED}✗ Snapshot ID appears to be a placeholder: ${snapshot_id}${NC}"
            FAILURES=$((FAILURES + 1))
          elif [ ${#snapshot_id} -lt 10 ]; then
            log "${RED}✗ Snapshot ID seems suspiciously short: ${snapshot_id}${NC}"
            FAILURES=$((FAILURES + 1))
          fi
        else
          log "${RED}✗ Neither Dockerfile nor snapshot configuration found in build section${NC}"
          log "${RED}ℹ According to Cursor documentation, either dockerfile or snapshot must be specified${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      else
        log "${RED}✗ environment.json is missing build configuration${NC}"
        FAILURES=$((FAILURES + 1))
      fi
    else
      log "${RED}✗ environment.json is not valid JSON${NC}"
      FAILURES=$((FAILURES + 1))
    fi
    rm -f "$temp_file1"
  fi
else
  log "${RED}✗ environment.json not found${NC}"
  log "${RED}ℹ This file is required for the background agent at ${ENVIRONMENT_JSON}${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 3: Test install.sh script
log "${BLUE}ℹ "
log "${BLUE}Testing install.sh script...${NC}"

if [ -f "${INSTALL_SCRIPT}" ]; then
  log "${BLUE}ℹ Found install.sh at ${INSTALL_SCRIPT}${NC}"
  
  if [ -x "${INSTALL_SCRIPT}" ]; then
    log "${GREEN}✓ install.sh is executable${NC}"
    
    # Check for common issues in the script
    temp_file2=$(mktemp)
    if run_test "install.sh syntax check" "bash -n '${INSTALL_SCRIPT}'" "$temp_file2"; then
      log "${GREEN}✓ install.sh has valid syntax${NC}"
      
      # Check for necessary sections in install.sh based on Cursor docs
      required_sections=("GITHUB_REPO_URL" "mkdir -p" "git")
      for section in "${required_sections[@]}"; do
        if grep -q "$section" "${INSTALL_SCRIPT}"; then
          log "${GREEN}✓ install.sh contains required section: ${section}${NC}"
        else
          log "${RED}✗ install.sh missing required section: ${section}${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      done
      
      # Check for proper error handling in install.sh
      if grep -q "set -e" "${INSTALL_SCRIPT}"; then
        log "${GREEN}✓ install.sh contains proper error handling (set -e)${NC}"
      else
        log "${RED}✗ install.sh missing error handling (set -e)${NC}"
        log "${RED}ℹ Error handling is required to ensure scripts fail gracefully${NC}"
        FAILURES=$((FAILURES + 1))
      fi
    else
      log "${RED}✗ install.sh has syntax errors${NC}"
      FAILURES=$((FAILURES + 1))
      cat "$temp_file2"
    fi
    rm -f "$temp_file2"
    
    # Test if the script creates the required marker file correctly
    if grep -q "bg-agent-install-complete.txt" "${INSTALL_SCRIPT}"; then
      log "${GREEN}✓ install.sh creates the expected marker file${NC}"
      
      # Check the marker file creation is done properly at the end of successful installation
      if grep -q "touch.*bg-agent-install-complete.txt" "${INSTALL_SCRIPT}" || 
         grep -q "echo.*>.*bg-agent-install-complete.txt" "${INSTALL_SCRIPT}"; then
        log "${GREEN}✓ install.sh creates marker file with proper command${NC}"
      else
        log "${RED}✗ install.sh marker file creation might be incorrect${NC}"
        FAILURES=$((FAILURES + 1))
      fi
    else
      log "${RED}✗ install.sh does not create the expected marker file${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    log "${RED}✗ install.sh is not executable${NC}"
    # Attempt to fix permissions
    if chmod +x "${INSTALL_SCRIPT}"; then
      log "${YELLOW}⚠ Made install.sh executable. Please ensure this is set correctly by default.${NC}"
    else
      log "${RED}✗ CRITICAL: Failed to make install.sh executable${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  fi
else
  log "${RED}✗ install.sh not found${NC}"
  log "${RED}ℹ This file is referenced in environment.json and must exist at ${INSTALL_SCRIPT}${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 4: Check for documentation files
log "${BLUE}ℹ "
log "${BLUE}Checking documentation files...${NC}"

doc_files=(
  "${CURSOR_DIR}/README.md"
  "${CURSOR_DIR}/TROUBLESHOOTING.md"
  "${CURSOR_DIR}/background-agent-prompt.md"
)

for doc in "${doc_files[@]}"; do
  if [ -f "$doc" ]; then
    log "${GREEN}✓ Documentation file exists: $(basename "$doc")${NC}"
    
    # Check if documentation references background agent
    if grep -q "Background Agent" "$doc" || grep -q "background-agent" "$doc"; then
      log "${GREEN}✓ $(basename "$doc") contains references to Background Agent${NC}"
    else
      log "${RED}✗ $(basename "$doc") does not contain specific Background Agent documentation${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    log "${RED}✗ Documentation file missing: $(basename "$doc")${NC}"
    log "${RED}ℹ Documentation is critical for understanding how the background agent works${NC}"
    FAILURES=$((FAILURES + 1))
  fi
done

# Test 5: Check for log directory and files
log "${BLUE}ℹ "
log "${BLUE}Checking log directory structure...${NC}"

if [ -d "${LOG_DIR}" ]; then
  log "${GREEN}✓ Log directory exists at ${LOG_DIR}${NC}"
  
  # Check for .gitkeep to ensure directory is tracked
  if [ -f "${LOG_DIR}/.gitkeep" ]; then
    log "${GREEN}✓ Log directory has .gitkeep file${NC}"
  else
    log "${RED}✗ Log directory missing .gitkeep file${NC}"
    FAILURES=$((FAILURES + 1))
    # Create a .gitkeep file
    echo "# This file ensures the logs directory is tracked by Git." > "${LOG_DIR}/.gitkeep"
    echo "# The logs directory is used to store logs from the Background Agent tests." >> "${LOG_DIR}/.gitkeep"
    echo "# All log files are excluded from Git via .gitignore." >> "${LOG_DIR}/.gitkeep"
    log "${YELLOW}⚠ Created .gitkeep file in log directory${NC}"
  fi
  
  # Check if log directory is writable
  if [ -w "${LOG_DIR}" ]; then
    log "${GREEN}✓ Log directory is writable${NC}"
    # Test write capability
    test_file="${LOG_DIR}/write-test-$(date +%s).tmp"
    if echo "test" > "${test_file}" 2>/dev/null; then
      log "${GREEN}✓ Successfully wrote to log directory${NC}"
      rm -f "${test_file}"
    else
      log "${RED}✗ Cannot write to log directory despite having write permission${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    log "${RED}✗ Log directory is not writable${NC}"
    FAILURES=$((FAILURES + 1))
    # Attempt to fix permissions for testing purposes
    chmod -R u+w "${LOG_DIR}" 2>/dev/null || log "${RED}✗ Failed to make log directory writable${NC}"
  fi
else
  log "${RED}✗ Log directory does not exist at ${LOG_DIR}${NC}"
  # Attempt to create if missing, and fail if creation fails
  if ! mkdir -p "${LOG_DIR}"; then
    log "${RED}✗ CRITICAL: Failed to create missing log directory: ${LOG_DIR}${NC}"
    FAILURES=$((FAILURES + 1)) # Count this as a failure to create
  else
    log "${YELLOW}⚠ Created missing log directory: ${LOG_DIR}${NC}"
    # After creating, check writability again
    if [ -w "${LOG_DIR}" ]; then
        log "${GREEN}✓ Newly created log directory is writable${NC}"
    else
        log "${RED}✗ Newly created log directory IS NOT WRITABLE${NC}"
        FAILURES=$((FAILURES + 1))
    fi
  fi
fi

# Test 6: Verify Dockerfile against Cursor documentation requirements
log "${BLUE}ℹ "
log "${BLUE}Validating Dockerfile against Cursor requirements...${NC}"

if [ -f "${REPO_ROOT}/Dockerfile" ]; then
  log "${BLUE}ℹ Found Dockerfile at ${REPO_ROOT}/Dockerfile${NC}"
  
  # Check for required Dockerfile instructions according to Cursor docs
  required_instructions=("FROM" "WORKDIR" "RUN" "ENV" "USER")
  
  for instruction in "${required_instructions[@]}"; do
    if grep -q "^${instruction}" "${REPO_ROOT}/Dockerfile"; then
      log "${GREEN}✓ Dockerfile contains required instruction: ${instruction}${NC}"
    else
      log "${RED}✗ Dockerfile missing required instruction: ${instruction}${NC}"
      log "${RED}ℹ According to Cursor documentation, ${instruction} is required${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  done
  
  # Check for specific required packages/tools based on Cursor documentation
  required_packages=("git" "curl" "sudo" "bash" "node" "npm")
  for package in "${required_packages[@]}"; do
    if grep -q "${package}" "${REPO_ROOT}/Dockerfile"; then
      log "${GREEN}✓ Dockerfile installs required package: ${package}${NC}"
    else
      log "${RED}✗ Dockerfile may be missing required package: ${package}${NC}"
      log "${RED}ℹ This package is needed for the background agent to function properly${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  done
  
  # Check for non-root user (security best practice)
  if grep -q "^USER root" "${REPO_ROOT}/Dockerfile"; then
    log "${RED}✗ Dockerfile uses root user, which violates security best practices${NC}"
    log "${RED}ℹ Cursor documentation recommends using a non-root user like 'node'${NC}"
    FAILURES=$((FAILURES + 1))
  elif grep -q "^USER node" "${REPO_ROOT}/Dockerfile" || grep -q "^USER [^r]" "${REPO_ROOT}/Dockerfile"; then
    log "${GREEN}✓ Dockerfile properly uses non-root user${NC}"
  else
    log "${RED}✗ Could not verify non-root user in Dockerfile${NC}"
    FAILURES=$((FAILURES + 1))
  fi

  # Version pinning is checked more robustly by hadolint in test-docker-env.sh
  log "${BLUE}ℹ Note: Dockerfile package version pinning is validated by hadolint in test-docker-env.sh${NC}"
else
  log "${RED}✗ Dockerfile not found at ${REPO_ROOT}/Dockerfile${NC}"
  log "${RED}ℹ According to Cursor documentation, a Dockerfile is required for the Background Agent${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 7: Verify environment variable handling
log "${BLUE}ℹ "
log "${BLUE}Testing environment variable handling...${NC}"

if [ -f "${CURSOR_DIR}/load-env.sh" ]; then
  log "${GREEN}✓ Environment loading script exists at ${CURSOR_DIR}/load-env.sh${NC}"
  
  # Check for execution permissions
  if [ -x "${CURSOR_DIR}/load-env.sh" ]; then
    log "${GREEN}✓ Environment loading script is executable${NC}"
  else
    log "${RED}✗ Environment loading script is not executable${NC}"
    if chmod +x "${CURSOR_DIR}/load-env.sh"; then
      log "${YELLOW}⚠ Made load-env.sh executable. Ensure this is set by default.${NC}"
    else
      log "${RED}✗ CRITICAL: Failed to make load-env.sh executable${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  fi
  
  # Check content of the script
  if grep -q "export" "${CURSOR_DIR}/load-env.sh"; then
    log "${GREEN}✓ Environment script contains export statements${NC}"
    # Count exports as an additional check
    export_count=$(grep -c "export" "${CURSOR_DIR}/load-env.sh" || echo 0)
    log "${BLUE}ℹ Script contains ${export_count} export statements${NC}"
  else
    log "${RED}✗ Environment script may be missing export statements${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  # Check for env.txt file
  env_txt_paths=("${CURSOR_DIR}/env.txt" "${REPO_ROOT}/env.txt")
  env_txt_found=false
  
  for env_path in "${env_txt_paths[@]}"; do
    if [ -f "${env_path}" ]; then
      env_txt_found=true
      log "${GREEN}✓ Environment file found at: ${env_path}${NC}"
      
      # Check for actual content (while not exposing sensitive data)
      if [ -s "${env_path}" ]; then
        log "${GREEN}✓ Environment file has content${NC}"
        # Count non-comment lines as an additional check
        env_var_count=$(grep -v "^#" "${env_path}" | grep -v "^$" | wc -l | tr -d ' ' || echo 0)
        log "${BLUE}ℹ File contains approximately ${env_var_count} environment variables${NC}"
      else
        log "${RED}✗ Environment file is empty${NC}"
        FAILURES=$((FAILURES + 1))
      fi
      break
    fi
  done
  
  if [ "$env_txt_found" = false ]; then
    log "${RED}✗ No environment file (env.txt) found${NC}"
    log "${RED}ℹ This file is needed for configuring the Background Agent environment${NC}"
    FAILURES=$((FAILURES + 1))
  fi
else
  log "${RED}✗ Environment loading script not found at ${CURSOR_DIR}/load-env.sh${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 8: Check uninstall script (relevant for Cursor agent projects)
log "${BLUE}ℹ "
log "${BLUE}Checking uninstall script...${NC}"

if [ -f "${REPO_ROOT}/uninstall_cursor.sh" ]; then
  log "${GREEN}✓ Uninstall script exists at ${REPO_ROOT}/uninstall_cursor.sh${NC}"
  
  # Check execution permissions
  if [ -x "${REPO_ROOT}/uninstall_cursor.sh" ]; then
    log "${GREEN}✓ Uninstall script is executable${NC}"
  else
    log "${RED}✗ Uninstall script is not executable${NC}"
    if chmod +x "${REPO_ROOT}/uninstall_cursor.sh"; then
      log "${YELLOW}⚠ Made uninstall_cursor.sh executable. Ensure this is set by default.${NC}"
    else
      log "${RED}✗ CRITICAL: Failed to make uninstall_cursor.sh executable${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  fi
  
  # Check syntax
  temp_file3=$(mktemp)
  if run_test "uninstall.sh syntax check" "bash -n \"${REPO_ROOT}/uninstall_cursor.sh\"" "$temp_file3"; then
    log "${GREEN}✓ Uninstall script has valid syntax${NC}"
  else
    log "${RED}✗ Uninstall script has syntax errors${NC}"
    FAILURES=$((FAILURES + 1))
    cat "$temp_file3"
  fi
  rm -f "$temp_file3"
else
  log "${RED}✗ Uninstall script not found at ${REPO_ROOT}/uninstall_cursor.sh${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Final summary
log "${BLUE}ℹ "
log "${BLUE}============================${NC}"
log "${BLUE}Background Agent Test Summary${NC}"
log "${BLUE}============================${NC}"

if [ $FAILURES -eq 0 ]; then
  log "${GREEN}${BOLD}All tests passed successfully!${NC}"
  echo "===== TEST RESULT: PASS ====="
  exit 0
else
  log "${RED}${BOLD}Failed tests: $FAILURES${NC}"
  echo "===== TEST RESULT: FAIL (${FAILURES} errors) ====="
  exit 1
fi 