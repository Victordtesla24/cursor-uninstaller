#!/bin/bash
# Docker Environment Test for Cursor Background Agent
# Validates Docker installation, configuration, and functionality

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
DOCKER_LOG="${LOG_DIR}/test-docker-env.sh.log"
DOCKERFILE="${REPO_ROOT}/Dockerfile"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] DOCKER-TEST: $1" | tee -a "${DOCKER_LOG}"
}

# Function to run tests with better output handling
run_test() {
  local test_name="$1"
  local command="$2"
  local output_file="${3:-/dev/null}"
  
  log "${BLUE}ℹ Testing: ${test_name}${NC}"
  
  # Run the command and capture its exit code
  eval "$command" > "$output_file" 2>&1
  local exit_code=$?
  
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

# Start testing
log "${BLUE}${BOLD}====== Starting Docker Environment Tests ======${NC}"

# Test 1: Check Dockerfile existence and compliance with Cursor documentation
log "${BLUE}ℹ "
log "${BLUE}Checking Dockerfile existence and compliance...${NC}"

if [ -f "${DOCKERFILE}" ]; then
  log "${GREEN}✓ Dockerfile exists at ${DOCKERFILE}${NC}"
  
  # Check basic Dockerfile structure requirements per Cursor documentation
  log "${BLUE}ℹ Validating Dockerfile against Cursor Background Agent requirements...${NC}"
  
  # Required instructions according to Cursor documentation
  required_instructions=(
    "FROM"           # Base image
    "WORKDIR"        # Working directory (should be /agent_workspace)
    "USER"           # Non-root user (node recommended)
    "RUN"            # Commands to set up environment
    "ENV"            # Environment variables
  )
  
  for instruction in "${required_instructions[@]}"; do
    if grep -q "^${instruction}" "${DOCKERFILE}"; then
      log "${GREEN}✓ Dockerfile contains required instruction: ${instruction}${NC}"
    else
      log "${RED}✗ Dockerfile is missing required instruction: ${instruction}${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  done
  
  # Verify specific requirements from Cursor documentation
  # 1. Check for non-root user
  if grep -q "^USER root" "${DOCKERFILE}"; then
    log "${RED}✗ Dockerfile uses root user, which violates Cursor's security guidelines${NC}"
    FAILURES=$((FAILURES + 1))
  elif grep -q "^USER node" "${DOCKERFILE}"; then
    log "${GREEN}✓ Dockerfile uses recommended 'node' user${NC}"
  elif grep -q "^USER" "${DOCKERFILE}"; then
    USER_LINE=$(grep "^USER" "${DOCKERFILE}")
    log "${YELLOW}⚠ Dockerfile uses a custom user: ${USER_LINE}. Cursor recommends 'node' user.${NC}"
  else
    log "${RED}✗ Dockerfile is missing USER instruction, which will result in running as root${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  # 2. Check WORKDIR path
  if grep -q "^WORKDIR /agent_workspace" "${DOCKERFILE}"; then
    log "${GREEN}✓ Dockerfile uses recommended WORKDIR: /agent_workspace${NC}"
  elif grep -q "^WORKDIR" "${DOCKERFILE}"; then
    WORKDIR_LINE=$(grep "^WORKDIR" "${DOCKERFILE}")
    log "${YELLOW}⚠ Dockerfile uses a custom WORKDIR: ${WORKDIR_LINE}. Cursor recommends '/agent_workspace'.${NC}"
  else
    log "${RED}✗ Dockerfile is missing WORKDIR instruction${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  # 3. Check essential tools installation
  essential_tools=("git" "curl" "bash" "npm" "node")
  for tool in "${essential_tools[@]}"; do
    if grep -qi "${tool}" "${DOCKERFILE}"; then
      log "${GREEN}✓ Dockerfile includes installation of essential tool: ${tool}${NC}"
    else
      log "${RED}✗ Dockerfile might be missing essential tool: ${tool}${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  done
  
  # 4. Check for version pinning
  if grep -q "apt-get install" "${DOCKERFILE}" && ! grep -q "apt-get install.*=" "${DOCKERFILE}"; then
    log "${RED}✗ Dockerfile apt-get installations may not be using version pinning${NC}"
    FAILURES=$((FAILURES + 1))
  else
    log "${GREEN}✓ Dockerfile appears to use version pinning for package installations${NC}"
  fi
  
else
  log "${RED}✗ Dockerfile not found at ${DOCKERFILE}${NC}"
  FAILURES=$((FAILURES + 1))
  log "${RED}✗ According to Cursor documentation, a Dockerfile is required for the Background Agent${NC}"
  log "${RED}✗ The Dockerfile should be in the root directory of the repository${NC}"
  # Exit early since many subsequent tests depend on the Dockerfile
  exit 1
fi

# Test 2: Check Docker installation
log "${BLUE}ℹ "
log "${BLUE}Checking Docker installation...${NC}"

if ! command -v docker &> /dev/null; then
  log "${RED}✗ Docker is not installed${NC}"
  log "${YELLOW}⚠ Docker is required to build and run the container for the Background Agent${NC}"
  log "${YELLOW}⚠ Skipping Docker-specific tests, but validating Dockerfile structure only${NC}"
  DOCKER_AVAILABLE=false
  FAILURES=$((FAILURES + 1))
else
  DOCKER_AVAILABLE=true
  docker_version=$(docker --version)
  log "${GREEN}✓ Docker is installed: ${docker_version}${NC}"
  
  # Check Docker version
  if [[ $docker_version =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
    version="${BASH_REMATCH[0]}"
    major_version=$(echo "$version" | cut -d. -f1)
    minor_version=$(echo "$version" | cut -d. -f2)
    
    # Version requirement: Docker 20.10.x or later
    if (( major_version >= 20 )); then
      log "${GREEN}✓ Docker version ${major_version}.${minor_version}.x meets minimum requirements${NC}"
    else
      log "${RED}✗ Docker version ${major_version}.${minor_version}.x does not meet minimum requirements (20.10.x or later)${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    log "${RED}✗ Could not determine Docker version format${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  # Check Docker daemon status
  if docker info &> /dev/null; then
    log "${GREEN}✓ Docker daemon is running${NC}"
  else
    log "${RED}✗ Docker daemon is not running${NC}"
    log "${YELLOW}⚠ Starting Docker daemon...${NC}"
    
    # Try to start Docker daemon based on system
    if command -v systemctl &> /dev/null; then
      if sudo systemctl start docker; then
        log "${GREEN}✓ Docker daemon started successfully using systemctl${NC}"
      else
        log "${RED}✗ Failed to start Docker daemon using systemctl${NC}"
        DOCKER_AVAILABLE=false
        FAILURES=$((FAILURES + 1))
      fi
    elif command -v service &> /dev/null; then
      if sudo service docker start; then
        log "${GREEN}✓ Docker daemon started successfully using service${NC}"
      else
        log "${RED}✗ Failed to start Docker daemon using service${NC}"
        DOCKER_AVAILABLE=false
        FAILURES=$((FAILURES + 1))
      fi
    else
      log "${RED}✗ Could not determine how to start Docker daemon${NC}"
      DOCKER_AVAILABLE=false
      FAILURES=$((FAILURES + 1))
    fi
    
    # Verify Docker daemon is now running
    if docker info &> /dev/null; then
      log "${GREEN}✓ Docker daemon is now running${NC}"
      DOCKER_AVAILABLE=true
    else
      log "${RED}✗ Docker daemon is still not running${NC}"
      DOCKER_AVAILABLE=false
    fi
  fi
fi

# Only run Docker tests if Docker is available
if [ "$DOCKER_AVAILABLE" = true ]; then
  # Test 3: Build Docker image
  log "${BLUE}ℹ "
  log "${BLUE}Testing Docker image build...${NC}"
  
  # Define a unique tag for our test image
  TEST_TAG="cursor-agent-test:$(date +%Y%m%d%H%M%S)"
  
  # Create a temporary file for capturing build output
  build_output=$(mktemp)
  
  # Build the Docker image
  if run_test "Docker image build" "docker build -t ${TEST_TAG} -f \"${DOCKERFILE}\" \"${REPO_ROOT}\"" "$build_output"; then
    log "${GREEN}✓ Docker image built successfully${NC}"
    
    # Test 4: Check container execution
    log "${BLUE}ℹ "
    log "${BLUE}Testing container execution...${NC}"
    
    # Create a temporary file for capturing container output
    container_output=$(mktemp)
    
    # Test basic container execution
    if run_test "Basic container execution" "docker run --rm ${TEST_TAG} echo 'Container test successful'" "$container_output"; then
      log "${GREEN}✓ Container executes commands successfully${NC}"
      
      # Test 5: Check environment variable propagation
      log "${BLUE}ℹ "
      log "${BLUE}Testing environment variable propagation...${NC}"
      
      env_test_output=$(mktemp)
      if run_test "Environment variable propagation" "docker run --rm -e TEST_VAR='test_value' ${TEST_TAG} /bin/bash -c 'echo \$TEST_VAR'" "$env_test_output"; then
        env_value=$(cat "$env_test_output" | tr -d '\r\n')
        if [ "$env_value" = "test_value" ]; then
          log "${GREEN}✓ Environment variable propagation works correctly: $env_value${NC}"
        else
          log "${RED}✗ Environment variable propagation failed. Expected 'test_value', got: $env_value${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      else
        FAILURES=$((FAILURES + 1))
      fi
      rm -f "$env_test_output"
      
      # Test 6: Check working directory
      log "${BLUE}ℹ "
      log "${BLUE}Testing working directory in container...${NC}"
      
      workdir_output=$(mktemp)
      if run_test "Working directory check" "docker run --rm ${TEST_TAG} pwd" "$workdir_output"; then
        workdir_path=$(cat "$workdir_output" | tr -d '\r\n')
        if [ "$workdir_path" = "/agent_workspace" ]; then
          log "${GREEN}✓ Working directory is correctly set to: $workdir_path${NC}"
        else
          log "${RED}✗ Working directory is not correctly set. Got: $workdir_path, expected: /agent_workspace${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      else
        FAILURES=$((FAILURES + 1))
      fi
      rm -f "$workdir_output"
      
      # Test 7: Check if running as non-root user (Cursor requirement)
      log "${BLUE}ℹ "
      log "${BLUE}Testing user context in container...${NC}"
      
      user_output=$(mktemp)
      if run_test "User context check" "docker run --rm ${TEST_TAG} id" "$user_output"; then
        user_info=$(cat "$user_output")
        if echo "$user_info" | grep -q "uid=0(root)"; then
          log "${RED}✗ Container is running as root user, which violates Cursor's security guidelines${NC}"
          FAILURES=$((FAILURES + 1))
        else
          log "${GREEN}✓ Container is running as non-root user: $(echo "$user_info" | grep -o 'uid=[0-9]*')${NC}"
        fi
      else
        FAILURES=$((FAILURES + 1))
      fi
      rm -f "$user_output"
      
      # Test 8: Check required tools availability inside container
      log "${BLUE}ℹ "
      log "${BLUE}Testing tool availability inside container...${NC}"
      
      required_tools=("git" "node" "npm" "bash" "curl")
      for tool in "${required_tools[@]}"; do
        tool_output=$(mktemp)
        # Try to run the tool with --version or -v to check if it's available
        if run_test "Tool availability: ${tool}" "docker run --rm ${TEST_TAG} which ${tool}" "$tool_output"; then
          log "${GREEN}✓ Tool available in container: ${tool}${NC}"
        else
          log "${RED}✗ Required tool not available in container: ${tool}${NC}"
          FAILURES=$((FAILURES + 1))
        fi
        rm -f "$tool_output"
      done
      
      # Test 9: Check if essential directories exist
      log "${BLUE}ℹ "
      log "${BLUE}Testing essential directories in container...${NC}"
      
      essential_dirs=("/agent_workspace" "/agent_workspace/.cursor" "/agent_workspace/.cursor/logs")
      for dir in "${essential_dirs[@]}"; do
        dir_output=$(mktemp)
        if run_test "Directory existence: ${dir}" "docker run --rm ${TEST_TAG} test -d \"${dir}\" && echo \"Directory exists\"" "$dir_output"; then
          log "${GREEN}✓ Essential directory exists in container: ${dir}${NC}"
        else
          log "${RED}✗ Essential directory missing in container: ${dir}${NC}"
          FAILURES=$((FAILURES + 1))
        fi
        rm -f "$dir_output"
      done
      
      # Test 10: Test agent log folder creation and permissions
      log "${BLUE}ℹ "
      log "${BLUE}Testing container log directory permissions...${NC}"
      
      log_perm_output=$(mktemp)
      if run_test "Log directory permissions" "docker run --rm ${TEST_TAG} /bin/bash -c 'mkdir -p /agent_workspace/.cursor/logs && touch /agent_workspace/.cursor/logs/test.log && echo success'" "$log_perm_output"; then
        if grep -q "success" "$log_perm_output"; then
          log "${GREEN}✓ Container has proper permissions to create log files${NC}"
        else
          log "${RED}✗ Container output doesn't indicate success creating log files${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      else
        log "${RED}✗ Container permission test for log directory failed${NC}"
        FAILURES=$((FAILURES + 1))
      fi
      rm -f "$log_perm_output"
      
    else
      log "${RED}✗ Container execution failed${NC}"
      FAILURES=$((FAILURES + 1))
    fi
    
    # Clean up container output file
    rm -f "$container_output"
    
    # Clean up the test image
    log "${BLUE}ℹ Cleaning up test image...${NC}"
    if docker rmi -f "${TEST_TAG}" &> /dev/null; then
      log "${GREEN}✓ Test image cleaned up successfully${NC}"
    else
      log "${YELLOW}⚠ Failed to clean up test image. It may need to be removed manually.${NC}"
    fi
  else
    log "${RED}✗ Docker image build failed${NC}"
    FAILURES=$((FAILURES + 1))
  fi
  
  # Clean up build output file
  rm -f "$build_output"
else
  log "${YELLOW}⚠ Skipping Docker runtime tests as Docker is not available or not running${NC}"
  log "${YELLOW}⚠ According to Cursor documentation, Docker is required for the Background Agent${NC}"
  log "${YELLOW}⚠ Please install Docker and ensure it's running for complete testing${NC}"
fi

# Test 11: Validate environment.json build section
log "${BLUE}ℹ "
log "${BLUE}Checking environment.json build configuration...${NC}"

ENVIRONMENT_JSON="${CURSOR_DIR}/environment.json"
if [ -f "${ENVIRONMENT_JSON}" ]; then
  # Check if jq is available for JSON parsing
  if command -v jq &> /dev/null; then
    # Parse environment.json to check build configuration
    if jq -e '.build' "${ENVIRONMENT_JSON}" > /dev/null 2>&1; then
      log "${GREEN}✓ environment.json contains 'build' section${NC}"
      
      # Check if using Dockerfile approach
      if jq -e '.build.dockerfile' "${ENVIRONMENT_JSON}" > /dev/null 2>&1; then
        dockerfile_path=$(jq -r '.build.dockerfile' "${ENVIRONMENT_JSON}")
        log "${GREEN}✓ environment.json uses Dockerfile approach with: ${dockerfile_path}${NC}"
        
        # Verify dockerfile path
        if [ "${dockerfile_path}" = "Dockerfile" ]; then
          log "${GREEN}✓ Dockerfile path is correctly set to 'Dockerfile'${NC}"
        else
          log "${RED}✗ Dockerfile path should be 'Dockerfile', got: ${dockerfile_path}${NC}"
          FAILURES=$((FAILURES + 1))
        fi
        
        # Check if context is set
        if jq -e '.build.context' "${ENVIRONMENT_JSON}" > /dev/null 2>&1; then
          context_path=$(jq -r '.build.context' "${ENVIRONMENT_JSON}")
          log "${GREEN}✓ environment.json specifies build context: ${context_path}${NC}"
        else
          log "${RED}✗ environment.json is missing 'context' in build section${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      # Check if using snapshot approach
      elif jq -e '.build.snapshot' "${ENVIRONMENT_JSON}" > /dev/null 2>&1; then
        snapshot_id=$(jq -r '.build.snapshot' "${ENVIRONMENT_JSON}")
        log "${GREEN}✓ environment.json uses snapshot approach with ID: ${snapshot_id}${NC}"
        
        # Verify snapshot ID isn't a placeholder
        if [[ "${snapshot_id}" == *"REPLACE_WITH"* ]]; then
          log "${RED}✗ Snapshot ID appears to be a placeholder: ${snapshot_id}${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      else
        log "${RED}✗ environment.json build section missing both 'dockerfile' and 'snapshot'${NC}"
        FAILURES=$((FAILURES + 1))
      fi
    else
      log "${RED}✗ environment.json is missing required 'build' section${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    # Basic check without jq
    log "${YELLOW}⚠ jq not available, falling back to basic environment.json checks${NC}"
    if grep -q '"build"' "${ENVIRONMENT_JSON}" && grep -q '"dockerfile"' "${ENVIRONMENT_JSON}"; then
      log "${GREEN}✓ environment.json appears to contain build and dockerfile sections (basic check)${NC}"
    else
      log "${RED}✗ environment.json may be missing build or dockerfile sections (basic check)${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  fi
else
  log "${RED}✗ environment.json not found at ${ENVIRONMENT_JSON}${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 12: Verify Docker-specific environment variables in environment.json
log "${BLUE}ℹ "
log "${BLUE}Checking Docker environment configuration...${NC}"

if [ -f "${ENVIRONMENT_JSON}" ]; then
  # Check if start command attempts to start Docker
  if grep -q "docker" "${ENVIRONMENT_JSON}" && grep -q "start" "${ENVIRONMENT_JSON}"; then
    log "${GREEN}✓ environment.json appears to handle Docker service startup${NC}"
  else
    log "${YELLOW}⚠ environment.json might not handle Docker service startup${NC}"
    # This is just a warning, not a failure
  fi
else
  log "${RED}✗ environment.json not found for Docker configuration check${NC}"
  # Already counted as a failure above
fi

# Summarize test results
log "${BLUE}ℹ "
log "${BLUE}====== Docker Environment Test Summary ======${NC}"
log "${BLUE}Total failures: ${FAILURES}${NC}"

if [ ${FAILURES} -eq 0 ]; then
  log "${GREEN}✓ All Docker environment tests passed successfully${NC}"
  exit 0
else
  log "${RED}✗ Docker environment tests completed with ${FAILURES} failures${NC}"
  log "${RED}✗ Please address the issues above to ensure Background Agent can function correctly${NC}"
  exit 1
fi 