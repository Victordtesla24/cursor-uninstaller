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
DOCKERFILE_SYMLINK="${CURSOR_DIR}/Dockerfile"

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

# Start testing
log "${BLUE}${BOLD}====== Starting Docker Environment Tests ======${NC}"

# Check Docker version and configuration
if command -v docker &> /dev/null; then
    log "${BLUE}Docker information:${NC}"
    docker_info=$(docker info 2>/dev/null || echo "Docker info command failed")
    log "${BLUE}${docker_info}${NC}"
    
    log "${BLUE}Docker version:${NC}"
    docker_version=$(docker version 2>/dev/null || echo "Docker version command failed")
    log "${BLUE}${docker_version}${NC}"
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
  log "${RED}✗ Docker is not installed${NC}"
  log "${RED}✗ Docker is required to build and run the container for the Background Agent${NC}"
  log "${RED}✗ Cannot continue with Docker-specific tests without Docker installation${NC}"
  FAILURES=$((FAILURES + 1))
  # Exit with failure - Docker is required for this test
  exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
  log "${RED}✗ Docker daemon is not running${NC}"
  log "${RED}✗ Docker daemon must be running for Background Agent tests${NC}"
  log "${YELLOW}⚠ Attempting to start Docker daemon...${NC}"
  
  # Try to start Docker daemon based on system
  DOCKER_STARTED=false
  if command -v systemctl &> /dev/null; then
    if sudo systemctl start docker; then
      log "${GREEN}✓ Docker daemon started successfully using systemctl${NC}"
      DOCKER_STARTED=true
    else
      log "${RED}✗ Failed to start Docker daemon using systemctl${NC}"
    fi
  elif command -v service &> /dev/null; then
    if sudo service docker start; then
      log "${GREEN}✓ Docker daemon started successfully using service${NC}"
      DOCKER_STARTED=true
    else
      log "${RED}✗ Failed to start Docker daemon using service${NC}"
    fi
  else
    log "${RED}✗ Could not determine how to start Docker daemon${NC}"
  fi
  
  # Verify Docker daemon is now running
  if docker info &> /dev/null; then
    log "${GREEN}✓ Docker daemon is now running${NC}"
  else
    log "${RED}✗ Docker daemon is still not running${NC}"
    log "${RED}✗ Cannot continue with Docker-specific tests without running Docker daemon${NC}"
    FAILURES=$((FAILURES + 1))
    # Exit with failure - Docker daemon must be running
    exit 1
  fi
fi

# Test 1: Check Dockerfile existence and compliance with Cursor documentation
log "${BLUE}ℹ "
log "${BLUE}Checking Dockerfile existence and compliance...${NC}"

# Check if Dockerfile exists in repository root
if [ -f "${DOCKERFILE}" ]; then
  log "${GREEN}✓ Dockerfile exists at ${DOCKERFILE}${NC}"
  
  # Check if symlink exists in .cursor directory, create if missing
  if [ ! -f "${DOCKERFILE_SYMLINK}" ] || [ ! -L "${DOCKERFILE_SYMLINK}" ]; then
    log "${YELLOW}⚠ Dockerfile symlink missing in .cursor directory. Creating...${NC}"
    
    # Remove any existing broken file before creating symlink
    [ -e "${DOCKERFILE_SYMLINK}" ] && rm -f "${DOCKERFILE_SYMLINK}"
    
    # Create a relative symlink (more portable)
    cd "${CURSOR_DIR}" && ln -sf "../Dockerfile" "Dockerfile" && cd - > /dev/null
    
    # Verify symlink was created successfully
    if [ -L "${DOCKERFILE_SYMLINK}" ] && [ -f "${DOCKERFILE_SYMLINK}" ]; then
      log "${GREEN}✓ Dockerfile symlink created successfully${NC}"
    else
      log "${RED}✗ Failed to create Dockerfile symlink. This may cause Docker build failures.${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    # Verify the symlink points to the correct target
    SYMLINK_TARGET=$(readlink "${DOCKERFILE_SYMLINK}")
    if [[ "${SYMLINK_TARGET}" == "../Dockerfile" ]]; then
      log "${GREEN}✓ Dockerfile symlink exists and points to correct target${NC}"
    else
      log "${YELLOW}⚠ Dockerfile symlink exists but points to ${SYMLINK_TARGET} instead of ../Dockerfile. Fixing...${NC}"
      rm -f "${DOCKERFILE_SYMLINK}"
      cd "${CURSOR_DIR}" && ln -sf "../Dockerfile" "Dockerfile" && cd - > /dev/null
      if [ -L "${DOCKERFILE_SYMLINK}" ] && [ -f "${DOCKERFILE_SYMLINK}" ]; then
        log "${GREEN}✓ Dockerfile symlink fixed successfully${NC}"
      else
        log "${RED}✗ Failed to fix Dockerfile symlink. This may cause Docker build failures.${NC}"
        FAILURES=$((FAILURES + 1))
      fi
    fi
  fi
  
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
  log "${RED}✗ According to Cursor documentation, a Dockerfile is required for the Background Agent${NC}"
  log "${RED}✗ The Dockerfile should be in the root directory of the repository${NC}"
  FAILURES=$((FAILURES + 1))
  # Fail test - required component missing
  exit 1
fi

# Test 2: Check Docker version and capabilities
log "${BLUE}ℹ "
log "${BLUE}Checking Docker installation...${NC}"

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

# Test 3: Check environment.json docker configuration
log "${BLUE}ℹ "
log "${BLUE}Checking environment.json Docker configuration...${NC}"

ENVIRONMENT_JSON="${CURSOR_DIR}/environment.json"
if [ -f "${ENVIRONMENT_JSON}" ]; then
  if command -v jq &> /dev/null; then
    # Check if environment.json has build section with correct dockerfile path
    if jq -e '.build.dockerfile' "${ENVIRONMENT_JSON}" > /dev/null 2>&1; then
      dockerfile_path=$(jq -r '.build.dockerfile' "${ENVIRONMENT_JSON}")
      log "${GREEN}✓ environment.json references Dockerfile at: ${dockerfile_path}${NC}"
      
      # Verify the referenced Dockerfile location exists or is accessible
      if [[ "${dockerfile_path}" == "Dockerfile" ]]; then
        if [ -f "${REPO_ROOT}/Dockerfile" ]; then
          log "${GREEN}✓ Dockerfile exists at repository root${NC}"
        else
          log "${RED}✗ Dockerfile not found at repository root${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      elif [[ "${dockerfile_path}" == "/agent_workspace/Dockerfile" ]]; then
        log "${YELLOW}⚠ environment.json references Dockerfile with absolute path for container use.${NC}"
        log "${YELLOW}⚠ This path is expected to resolve inside the container. Verifying root Dockerfile exists...${NC}"
        if [ -f "${REPO_ROOT}/Dockerfile" ]; then
          log "${GREEN}✓ Dockerfile exists at repository root (will be mapped to /agent_workspace/Dockerfile in container)${NC}"
        else
          log "${RED}✗ Dockerfile not found at repository root${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      elif [[ "${dockerfile_path}" == ".." || "${dockerfile_path}" == "../Dockerfile" ]]; then
        log "${YELLOW}⚠ environment.json references Dockerfile with relative path: ${dockerfile_path}${NC}"
        if [ -f "${REPO_ROOT}/Dockerfile" ]; then
          log "${GREEN}✓ Dockerfile exists at repository root${NC}"
        else
          log "${RED}✗ Dockerfile not found at repository root${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      else
        # Check if file exists at the referenced location
        if [ -f "${REPO_ROOT}/${dockerfile_path}" ]; then
          log "${GREEN}✓ Dockerfile exists at specified path: ${dockerfile_path}${NC}"
        else
          log "${RED}✗ Dockerfile not found at specified path: ${dockerfile_path}${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      fi
      
      # Check context value
      if jq -e '.build.context' "${ENVIRONMENT_JSON}" > /dev/null 2>&1; then
        context_path=$(jq -r '.build.context' "${ENVIRONMENT_JSON}")
        log "${GREEN}✓ environment.json specifies build context: ${context_path}${NC}"
      else
        log "${RED}✗ environment.json is missing 'context' in build section${NC}"
        FAILURES=$((FAILURES + 1))
      fi
    else
      log "${RED}✗ environment.json build section missing 'dockerfile' property${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  else
    log "${RED}✗ jq not available for JSON parsing, required for proper validation${NC}"
    FAILURES=$((FAILURES + 1))
    # Perform basic check without jq
    if grep -q '"dockerfile"' "${ENVIRONMENT_JSON}"; then
      log "${GREEN}✓ environment.json contains 'dockerfile' property (basic check)${NC}"
    else
      log "${RED}✗ environment.json may be missing 'dockerfile' property (basic check)${NC}"
      FAILURES=$((FAILURES + 1))
    fi
  fi
else
  log "${RED}✗ environment.json not found at ${ENVIRONMENT_JSON}${NC}"
  FAILURES=$((FAILURES + 1))
fi

# Test 4: Build Docker image
log "${BLUE}ℹ "
log "${BLUE}Testing Docker image build...${NC}"

# Define a unique tag for our test image
TEST_TAG="cursor-agent-test:$(date +%Y%m%d%H%M%S)"

# Create a temporary file for capturing build output
build_output=$(mktemp)

# Try to build the Docker image
log "${BLUE}ℹ Building Docker image from ${DOCKERFILE}...${NC}"
if run_test "Docker image build" "docker build --no-cache -t ${TEST_TAG} -f \"${DOCKERFILE}\" \"${REPO_ROOT}\"" "$build_output"; then
  log "${GREEN}✓ Docker image built successfully${NC}"
  
  # Run container tests only if build succeeded
  # Test 5: Check container execution
  log "${BLUE}ℹ "
  log "${BLUE}Testing container execution...${NC}"
  
  # Create a temporary file for capturing container output
  container_output=$(mktemp)
  
  # Test basic container execution
  if run_test "Basic container execution" "docker run --rm ${TEST_TAG} echo 'Container test successful'" "$container_output"; then
    log "${GREEN}✓ Container executes commands successfully${NC}"
    
    # Test 6: Check environment variable propagation
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
    
    # Test 7: Check working directory
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
    
    # Test 8: Check if running as non-root user (Cursor requirement)
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
    
    # Test 9: Check required tools availability inside container
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
    
    # Test 10: Check if essential directories exist
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
    
    # Test 11: Test agent log folder creation and permissions
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
  if run_test "Docker image cleanup" "docker rmi -f ${TEST_TAG}" "$build_output"; then
    log "${GREEN}✓ Test image cleaned up successfully${NC}"
  else
    log "${YELLOW}⚠ Failed to clean up test image. It may need to be removed manually.${NC}"
    # Not a critical failure, don't exit
  fi
else
  # If the build fails, provide detailed diagnostics
  log "${RED}✗ Docker image build failed. Checking for detailed error information...${NC}"
  
  # Extract and display error output
  log "${RED}Key error information from build:${NC}"
  grep -i -E "error|failed|warnings|cannot|denied|refusing" "$build_output" | head -10 | while IFS= read -r line; do
    log "${RED}✗ | $line${NC}"
  done
  FAILURES=$((FAILURES + 1))
  
  # Try build with explicit buildx if available
  if docker buildx version &> /dev/null; then
    log "${BLUE}ℹ Docker Buildx is available, attempting alternative build method...${NC}"
    
    if run_test "Docker buildx image build" "docker buildx build --no-cache --load -t ${TEST_TAG} -f \"${DOCKERFILE}\" \"${REPO_ROOT}\"" "$build_output"; then
      log "${GREEN}✓ Docker buildx image build succeeded! Continuing with container tests...${NC}"
      # Run the same container tests as above
      # [Container tests implementation would be identical to above]
      # The detailed implementation is omitted here to avoid duplication
      # If this alternative build works, the test would continue with the container tests
      log "${YELLOW}⚠ Using buildx success path - running minimal container test${NC}"
      
      # Run a minimal test to verify the container works
      container_output=$(mktemp)
      if run_test "Basic container execution (buildx build)" "docker run --rm ${TEST_TAG} echo 'Container test successful'" "$container_output"; then
        log "${GREEN}✓ Container from buildx build executes commands successfully${NC}"
      else
        log "${RED}✗ Container from buildx build execution failed${NC}"
        FAILURES=$((FAILURES + 1))
      fi
      
      # Clean up container output file and image
      rm -f "$container_output"
      docker rmi -f ${TEST_TAG} 2>/dev/null || true
    else
      log "${RED}✗ Docker buildx build also failed${NC}"
      FAILURES=$((FAILURES + 1))
      
      # Try legacy builder as a last resort
      log "${YELLOW}⚠ Attempting legacy builder as last resort...${NC}"
      if run_test "Docker build with legacy builder" "DOCKER_BUILDKIT=0 docker build --no-cache -t ${TEST_TAG} -f \"${DOCKERFILE}\" \"${REPO_ROOT}\"" "$build_output"; then
        log "${GREEN}✓ Docker build with legacy builder succeeded!${NC}"
        
        # Run a minimal test to verify the container works
        container_output=$(mktemp)
        if run_test "Basic container execution (legacy build)" "docker run --rm ${TEST_TAG} echo 'Container test successful'" "$container_output"; then
          log "${GREEN}✓ Container from legacy build executes commands successfully${NC}"
        else
          log "${RED}✗ Container from legacy build execution failed${NC}"
          FAILURES=$((FAILURES + 1))
        fi
        
        # Clean up container output file and image
        rm -f "$container_output"
        docker rmi -f ${TEST_TAG} 2>/dev/null || true
      else
        log "${RED}✗ All Docker build methods failed${NC}"
        log "${RED}✗ Unable to build Docker image using standard builder, buildx, or legacy builder${NC}"
        log "${RED}✗ This is a critical error for the Background Agent functionality${NC}"
        FAILURES=$((FAILURES + 1))
      fi
    fi
  else
    log "${RED}✗ Docker buildx not available, cannot try alternative build methods${NC}"
    log "${RED}✗ Docker build failed with no available alternatives${NC}"
    log "${RED}✗ This is a critical error for the Background Agent functionality${NC}"
    FAILURES=$((FAILURES + 1))
  fi
fi

# Test 12: Verify Docker-specific environment variables in environment.json
log "${BLUE}ℹ "
log "${BLUE}Checking Docker environment configuration...${NC}"

if [ -f "${ENVIRONMENT_JSON}" ]; then
  # Check if start command attempts to start Docker
  if grep -q "docker" "${ENVIRONMENT_JSON}" && grep -q "start" "${ENVIRONMENT_JSON}"; then
    log "${GREEN}✓ environment.json appears to handle Docker service startup${NC}"
  else
    log "${RED}✗ environment.json does not handle Docker service startup${NC}"
    log "${RED}✗ According to Cursor documentation, the start command should include Docker service handling${NC}"
    FAILURES=$((FAILURES + 1))
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