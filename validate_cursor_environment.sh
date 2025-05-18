#!/bin/bash
# Validate Cursor Background Agent Environment
# This script checks that all necessary files and directories exist
# and have the correct structure for the Background Agent to function properly.

set -e # Exit immediately if a command exits with a non-zero status.

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== Cursor Background Agent Environment Validation =====${NC}"
echo "Running validation for all required files and directories..."

# Initialize counters
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Function to print success
print_success() {
  echo -e "${GREEN}✓ SUCCESS:${NC} $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

# Function to print error
print_error() {
  echo -e "${RED}✗ ERROR:${NC} $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

# Function to print warning
print_warning() {
  echo -e "${YELLOW}⚠ WARNING:${NC} $1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

# Function to print info
print_info() {
  echo -e "${BLUE}ℹ INFO:${NC} $1"
}

# Get repository root
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
  print_success "Git repository found at $REPO_ROOT"
else
  print_error "Not in a Git repository. The Background Agent requires a Git repository."
  exit 1
fi

# Define critical paths
CURSOR_DIR="$REPO_ROOT/.cursor"
ENV_JSON="$CURSOR_DIR/environment.json"
INSTALL_SH="$CURSOR_DIR/install.sh"
DOCKERFILE="$CURSOR_DIR/Dockerfile"
GITHUB_SETUP="$CURSOR_DIR/github-setup.sh"
RETRY_UTILS="$CURSOR_DIR/retry-utils.sh"
AGENT_PROMPT="$CURSOR_DIR/background-agent-prompt.md"
TROUBLESHOOTING="$CURSOR_DIR/TROUBLESHOOTING.md"
README="$CURSOR_DIR/README.md"
ERROR_MD="$CURSOR_DIR/error.md"
AGENT_LOG="$CURSOR_DIR/agent.log"
LOGS_DIR="$CURSOR_DIR/logs"

echo -e "\n${BLUE}===== Checking Required Files =====${NC}"

# Check for .cursor directory
if [ -d "$CURSOR_DIR" ]; then
  print_success ".cursor directory exists"
else
  print_error ".cursor directory does not exist"
  mkdir -p "$CURSOR_DIR"
  print_info "Created .cursor directory"
fi

# Check for critical configuration files
if [ -f "$ENV_JSON" ]; then 
  print_success "environment.json exists"
else 
  print_error "environment.json is missing"
fi

if [ -f "$INSTALL_SH" ]; then 
  print_success "install.sh exists"
else 
  print_error "install.sh is missing"
fi

if [ -f "$DOCKERFILE" ]; then 
  print_success "Dockerfile exists"
else 
  print_error "Dockerfile is missing"
fi

if [ -f "$GITHUB_SETUP" ]; then 
  print_success "github-setup.sh exists"
else 
  print_error "github-setup.sh is missing"
fi

if [ -f "$RETRY_UTILS" ]; then 
  print_success "retry-utils.sh exists"
else 
  print_error "retry-utils.sh is missing"
fi

if [ -f "$AGENT_PROMPT" ]; then 
  print_success "background-agent-prompt.md exists"
else 
  print_warning "background-agent-prompt.md is missing (recommended but optional)"
fi

if [ -f "$TROUBLESHOOTING" ]; then 
  print_success "TROUBLESHOOTING.md exists"
else 
  print_warning "TROUBLESHOOTING.md is missing (recommended for documentation)"
fi

if [ -f "$README" ]; then 
  print_success "README.md exists"
else 
  print_warning "README.md is missing (recommended for documentation)"
fi

echo -e "\n${BLUE}===== Checking File Permissions =====${NC}"

# Check file executability
for script in "$INSTALL_SH" "$GITHUB_SETUP" "$RETRY_UTILS"; do
  if [ -f "$script" ]; then
    if [ -x "$script" ]; then
      print_success "$(basename "$script") is executable"
    else
      print_error "$(basename "$script") is not executable"
      chmod +x "$script"
      print_info "Made $(basename "$script") executable"
    fi
  fi
done

echo -e "\n${BLUE}===== Checking Log Directory Setup =====${NC}"

# Check logs directory setup
if [ -d "$LOGS_DIR" ]; then
  print_success "logs directory exists"
else
  print_warning "logs directory does not exist"
  mkdir -p "$LOGS_DIR"
  print_info "Created logs directory"
fi

# Check agent.log file
if [ -f "$AGENT_LOG" ]; then
  print_success "agent.log exists"
else
  print_warning "agent.log does not exist"
  touch "$AGENT_LOG"
  print_info "Created empty agent.log file"
fi

echo -e "\n${BLUE}===== Validating File Content =====${NC}"

# Validate environment.json content if available
if [ -f "$ENV_JSON" ] && command -v jq &> /dev/null; then
  print_info "Validating environment.json content with jq..."
  
  # Check for required fields
  if jq -e '.build' "$ENV_JSON" >/dev/null; then
    print_success "environment.json has build section"
  else
    print_error "environment.json is missing build section"
  fi
  
  if jq -e '.build.dockerfile' "$ENV_JSON" >/dev/null; then
    dockerfile_path=$(jq -r '.build.dockerfile' "$ENV_JSON")
    if [ "$dockerfile_path" = "Dockerfile" ]; then
      print_success "environment.json references correct Dockerfile path: $dockerfile_path"
    else
      print_error "environment.json references incorrect Dockerfile path: $dockerfile_path. Should be 'Dockerfile'"
    fi
  else
    print_error "environment.json is missing build.dockerfile field"
  fi
  
  if jq -e '.user' "$ENV_JSON" >/dev/null; then
    user=$(jq -r '.user' "$ENV_JSON")
    print_success "environment.json has user field: $user"
  else
    print_error "environment.json is missing user field"
  fi
  
  if jq -e '.install' "$ENV_JSON" >/dev/null; then
    install_cmd=$(jq -r '.install' "$ENV_JSON")
    print_success "environment.json has install command: $install_cmd"
  else
    print_error "environment.json is missing install command"
  fi
  
  if jq -e '.start' "$ENV_JSON" >/dev/null; then
    start_cmd=$(jq -r '.start' "$ENV_JSON")
    print_success "environment.json has start command: $start_cmd"
  else
    print_warning "environment.json is missing start command"
  fi
  
  if jq -e '.terminals | length > 0' "$ENV_JSON" >/dev/null; then
    terminal_count=$(jq '.terminals | length' "$ENV_JSON")
    print_success "environment.json has $terminal_count terminal(s) configured"
  else
    print_warning "environment.json has no terminals configured"
  fi
elif [ -f "$ENV_JSON" ]; then
  print_warning "jq tool not found. Skipping detailed environment.json validation."
  # Basic check with grep
  if grep -q "\"build\"" "$ENV_JSON" && 
     grep -q "\"dockerfile\"" "$ENV_JSON" && 
     grep -q "\"user\"" "$ENV_JSON" && 
     grep -q "\"install\"" "$ENV_JSON"; then
    print_success "environment.json appears to have required fields (basic check)"
  else
    print_error "environment.json appears to be missing required fields (basic check)"
  fi
fi

# Validate Dockerfile content
if [ -f "$DOCKERFILE" ]; then
  print_info "Validating Dockerfile content..."
  
  # Check for proper base image
  if grep -q "FROM node:" "$DOCKERFILE"; then
    print_success "Dockerfile uses node base image"
  elif grep -q "FROM ubuntu:" "$DOCKERFILE" || grep -q "FROM debian:" "$DOCKERFILE"; then
    print_success "Dockerfile uses Ubuntu/Debian base image"
  else
    print_warning "Dockerfile may not use a recommended base image"
  fi
  
  # Ensure it installs git
  if grep -q "apt-get install.*git" "$DOCKERFILE" || grep -q "apk add.*git" "$DOCKERFILE"; then
    print_success "Dockerfile installs git"
  else
    print_warning "Dockerfile may not install git, which is required for repository cloning"
  fi
  
  # Check that it does not COPY the entire project
  if grep -q "COPY . \." "$DOCKERFILE" || grep -q "COPY \. \." "$DOCKERFILE"; then
    print_error "Dockerfile attempts to COPY the project which is not recommended. The agent will clone from GitHub."
  else
    print_success "Dockerfile does not attempt to COPY the project (good)"
  fi
  
  # Check for workspace directory
  if grep -q "agent_workspace" "$DOCKERFILE"; then
    print_success "Dockerfile references agent_workspace directory"
  else
    print_warning "Dockerfile might not set up the agent_workspace directory"
  fi
  
  # Check for non-root user
  if grep -q "USER node" "$DOCKERFILE" || grep -q "USER ubuntu" "$DOCKERFILE" || grep -q "USER \$" "$DOCKERFILE"; then
    print_success "Dockerfile switches to non-root user"
  else
    print_warning "Dockerfile might not switch to a non-root user"
  fi
fi

# Check for GitHub Integration
echo -e "\n${BLUE}===== Checking GitHub Integration =====${NC}"

# Check if remote is set to GitHub
if git remote -v | grep -q "github.com"; then
  github_remote=$(git remote -v | grep "github.com" | head -n 1)
  print_success "GitHub remote is configured: $github_remote"
else
  print_warning "GitHub remote is not configured. The Background Agent requires GitHub."
fi

echo -e "\n${BLUE}===== Checking Common Issues =====${NC}"

# Check if error.md file contains any errors
if [ -f "$ERROR_MD" ]; then
  if grep -q "ERROR:" "$ERROR_MD"; then
    print_warning "error.md contains ERROR messages that should be addressed"
    error_count=$(grep -c "ERROR:" "$ERROR_MD")
    print_info "Found $error_count ERROR message(s) in error.md"
  else
    print_success "No ERROR messages found in error.md"
  fi
else
  print_info "No error.md file found"
fi

# Check for write permissions in current directory
if touch test_write_permission.tmp 2>/dev/null; then
  rm test_write_permission.tmp
  print_success "Current directory has write permissions"
else
  print_error "Current directory does not have write permissions"
fi

# Summary
echo -e "\n${BLUE}===== Validation Summary =====${NC}"
echo -e "${GREEN}PASSED: $PASS_COUNT${NC}"
echo -e "${RED}FAILED: $FAIL_COUNT${NC}"
echo -e "${YELLOW}WARNINGS: $WARN_COUNT${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
  if [ $WARN_COUNT -eq 0 ]; then
    echo -e "\n${GREEN}Validation completed successfully with no issues!${NC}"
  else
    echo -e "\n${YELLOW}Validation completed with warnings. Review them if needed, but not critical.${NC}"
  fi
  exit 0
else
  echo -e "\n${RED}Validation completed with failures. Please fix the issues before proceeding.${NC}"
  exit 1
fi 