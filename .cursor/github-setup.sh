#!/bin/bash
# GitHub Setup Script for Background Agent

# Source environment variables
if [ -f "$(dirname "${BASH_SOURCE[0]}")/.cursor/load-env.sh" ]; then
  source "$(dirname "${BASH_SOURCE[0]}")/.cursor/load-env.sh"
elif [ -f "./.cursor/load-env.sh" ]; then
  source "./.cursor/load-env.sh"
elif [ -f "../.cursor/load-env.sh" ]; then # If script is in .cursor/
    source "../.cursor/load-env.sh"
fi

# Default repository URL if not provided through environment
: "${GITHUB_REPO_URL:=https://github.com/Victordtesla24/cursor-uninstaller.git}"

# Corrected Log Paths relative to /agent_workspace/.cursor/
CURSOR_DIR_RELATIVE_TO_SCRIPT="$(dirname "${BASH_SOURCE[0]}")"
CURSOR_LOG_DIR="${CURSOR_DIR_RELATIVE_TO_SCRIPT}/logs"
CURSOR_AGENT_LOG="${CURSOR_LOG_DIR}/agent.log"

# Ensure directories exist with proper error handling
ensure_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir" || {
      echo "ERROR: Failed to create directory: $dir" >&2
      return 1
    }
  fi
  return 0
}

# Ensure log file exists with proper error handling
ensure_file() {
  local file="$1"
  local dir=$(dirname "$file")

  # First ensure parent directory exists
  ensure_dir "$dir" || return 1

  if [ ! -f "$file" ]; then
    touch "$file" || {
      echo "ERROR: Failed to create file: $file" >&2
      return 1
    }
  fi
  return 0
}

# Create essential directories at startup
init_directories() {
  # Create all necessary directories for the agent to function
  ensure_dir "${CURSOR_DIR_RELATIVE_TO_SCRIPT}" || { echo "CRITICAL: Failed to create essential directory: ${CURSOR_DIR_RELATIVE_TO_SCRIPT}" >&2; }
  ensure_dir "${CURSOR_LOG_DIR}" || { echo "CRITICAL: Failed to create essential directory: ${CURSOR_LOG_DIR}" >&2; }
  # .git is in workspace root, not .cursor
  ensure_dir "${CURSOR_DIR_RELATIVE_TO_SCRIPT}/../.git" || { echo "CRITICAL: Failed to create essential directory: ${CURSOR_DIR_RELATIVE_TO_SCRIPT}/../.git" >&2; }

  # Ensure critical files exist
  ensure_file "${CURSOR_AGENT_LOG}" || echo "WARNING: Could not create agent log file at ${CURSOR_AGENT_LOG}" >&2
}

# Call directory initialization early
init_directories

# Setup logging with proper error handling
if ! ensure_dir "${CURSOR_LOG_DIR}"; then
  echo "WARNING: Could not create log directory. Logging to console only." >&2
  # Define a fallback log function that only prints to console
  log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${timestamp}] GITHUB-SETUP: $1" >&2
  }
else
  # Ensure log file exists
  if ! ensure_file "${CURSOR_AGENT_LOG}"; then
    echo "WARNING: Could not create log file. Logging to console only." >&2
    # Define a fallback log function that only prints to console
    log() {
      local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
      echo "[${timestamp}] GITHUB-SETUP: $1" >&2
    }
  else
    # Regular log function that writes to both console and log file
    log() {
      local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
      echo "[${timestamp}] GITHUB-SETUP: $1" | tee -a "${CURSOR_AGENT_LOG}" 2>/dev/null || echo "[${timestamp}] GITHUB-SETUP: $1" >&2
    }
  fi
fi

log "Running GitHub setup script (from .cursor/github-setup.sh)..."

# Source retry utilities if available
if [ -f "${CURSOR_DIR_RELATIVE_TO_SCRIPT}/retry-utils.sh" ]; then
  log "Sourcing retry utilities from ${CURSOR_DIR_RELATIVE_TO_SCRIPT}/retry-utils.sh..."
  source "${CURSOR_DIR_RELATIVE_TO_SCRIPT}/retry-utils.sh"
else
  log "Retry utilities not found at ${CURSOR_DIR_RELATIVE_TO_SCRIPT}/retry-utils.sh. Creating basic retry function..."
  # Simple retry function if the full script is not available
  retry() {
    local max_attempts=$1
    local delay=$2
    shift 2
    local attempt=1

    until "$@"; do
      if [ $attempt -ge $max_attempts ]; then
        log "Command '$*' failed after $max_attempts attempts."
        return 1
      fi

      log "Command '$*' failed. Retrying in ${delay}s (attempt $attempt/$max_attempts)..."
      sleep $delay
      attempt=$((attempt + 1))
    done

    return 0
  }
fi

# Improved git repository check
check_git_repository() {
  log "Checking git repository..."

  if [ ! -d ".git" ]; then
    log "Git repository not found. Initializing..."
    git init || {
      log "Failed to initialize git repository"
      return 1
    }

    # Configure default branch name before first commit
    git config --global init.defaultBranch main || log "Failed to set default branch, continuing anyway"

    # Create a basic README file if it doesn't exist
    if [ ! -f "README.md" ]; then
      echo "# Cursor Background Agent Repository" > README.md
      log "Created basic README.md file"
    fi

    git add README.md || {
      log "Failed to add README to git"
      return 1
    }

    git commit -m "Initial commit" || {
      log "Failed to make initial commit"
      return 1
    }

    log "Git repository initialized successfully"
  else
    log "Git repository already exists"
  fi

  return 0
}

# Refresh GitHub token to ensure we have access
refresh_github_token() {
  log "Refreshing GitHub access token..."

  # Check for existing token-based URL configurations
  if git config --global --get-regexp "url.https://x-access-token:.*@github.com/.insteadOf" > /dev/null 2>&1; then
    log "Removing existing token-based URL configurations..."
    git config --global --unset-all "url.https://x-access-token:.*@github.com/.insteadOf" || log "Failed to unset existing token configurations"
  fi

  # Check if we have a GitHub token environment variable set by Cursor
  if [ -n "${GITHUB_TOKEN}" ]; then
    log "Setting up GitHub access token for repository access..."
    git config --global url."https://x-access-token:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/" || log "Failed to set token-based URL"
    log "GitHub token configuration completed."
  else
    log "No GitHub token found in environment. Cursor background agent should provide this."
    log "IMPORTANT: Make sure the Cursor GitHub app is installed and has correct permissions."
  fi

  # Check if git repository exists before trying to set remote
  if [ -d ".git" ]; then
    # Update repository remotes if they exist
    if git remote -v | grep -q "origin"; then
      log "Updating remote URL for origin..."
      git remote set-url origin "${GITHUB_REPO_URL}" || log "Failed to update remote URL"
    else
      log "Adding remote origin..."
      git remote add origin "${GITHUB_REPO_URL}" || log "Failed to add remote origin"
    fi
  else
    log "No git repository found. Please run 'git init' first."
    check_git_repository

    # Try again to add remote after initializing repo
    log "Adding remote origin after repository initialization..."
    git remote add origin "${GITHUB_REPO_URL}" || log "Failed to add remote origin after initialization"
  fi
}

# Configure git identity for the agent
configure_git_identity() {
  log "Configuring git identity for the background agent..."

  # Check if git identity is already configured
  if ! git config --get user.email > /dev/null 2>&1; then
    log "Setting up git user email..."
    git config --global user.email "background-agent@cursor.sh" || log "Failed to set git user email"
  fi

  if ! git config --get user.name > /dev/null 2>&1; then
    log "Setting up git user name..."
    git config --global user.name "Cursor Background Agent" || log "Failed to set git user name"
  fi

  log "Git identity configuration completed."
}

# Verify GitHub access and repository with better error messages
verify_github_access() {
  log "Verifying GitHub access..."

  # Try up to 3 times with increasing delay
  local attempt=1
  local max_attempts=3
  local delay=2

  while [ $attempt -le $max_attempts ]; do
    # Check if we can access GitHub
    if git ls-remote --quiet "${GITHUB_REPO_URL}" HEAD > /dev/null 2>&1; then
      log "GitHub access verified successfully."
      return 0
    else
      if [ $attempt -lt $max_attempts ]; then
        log "GitHub access failed (attempt $attempt/$max_attempts). Retrying in ${delay}s..."

        # Provide more detailed troubleshooting information
        log "Troubleshooting tips:"
        log "1. Ensure the Cursor GitHub app is installed with correct permissions"
        log "2. Check your internet connection and proxy settings"
        log "3. Verify that ${GITHUB_REPO_URL} is correct and accessible"

        sleep $delay
        delay=$((delay * 2))
        attempt=$((attempt + 1))
      else
        log "GitHub access failed after $max_attempts attempts."
        log "Please ensure GitHub integration is properly configured in Cursor."
        log "------------------------------------------------"
        log "TROUBLESHOOTING STEPS:"
        log "1. In Cursor, go to Settings and connect GitHub account"
        log "2. Ensure the GitHub app has read/write access to your repositories"
        log "3. Check if your organization has any restrictions on GitHub apps"
        log "4. Verify network/proxy allows connections to github.com"
        log "------------------------------------------------"
        return 1
      fi
    fi
  done
}

# Create a test PR branch if requested
create_test_branch() {
  if [ "$1" == "true" ]; then
    log "Creating test branch to verify GitHub integration..."
    local test_branch="bg-agent-test-$(date +%Y%m%d%H%M%S)"

    if git checkout -b "$test_branch"; then
      log "Created test branch: $test_branch"

      # Create a test file
      echo "Background agent GitHub test - $(date)" > .cursor/github-test.txt

      # Commit changes
      git add .cursor/github-test.txt
      if git commit -m "Test commit from Background Agent GitHub setup"; then
        log "Created test commit"

        # Try to push
        if git push --set-upstream origin "$test_branch"; then
          log "Successfully pushed test branch to GitHub"
        else
          log "Failed to push test branch. GitHub push access may not be configured."
          log "Check if your GitHub token has write permissions to this repository."
        fi
      else
        log "Failed to create test commit"
      fi

      # Return to original branch
      git checkout - || log "Failed to return to original branch"
    else
      log "Failed to create test branch"
    fi
  fi
}

# Main execution with improved error handling
main() {
  # Ensure we're in the correct directory
  if [ -d "/agent_workspace" ] && [ "$(pwd)" != "/agent_workspace" ]; then
    log "Changing to /agent_workspace directory..."
    cd /agent_workspace || {
      log "Failed to change to /agent_workspace directory."
      log "Continuing in current directory: $(pwd)"
    }
    # Redefine log paths assuming PWD is /agent_workspace after this block
    if [ "$(pwd)" == "/agent_workspace" ]; then
        CURSOR_LOG_DIR=".cursor/logs" # Relative to /agent_workspace
        CURSOR_AGENT_LOG=".cursor/logs/agent.log"
        # Re-ensure log dir and file after potential cd
        ensure_dir ".cursor" || true
        ensure_dir ".cursor/logs" || true
        ensure_file ".cursor/logs/agent.log" || true
    fi
    # Recreate directories after changing directory
    init_directories # This will use the potentially updated CURSOR_DIR_RELATIVE_TO_SCRIPT or new relative paths
  fi

  # Check git repository first
  check_git_repository

  # Configure git identity
  configure_git_identity

  # Refresh GitHub token
  refresh_github_token

  # Verify GitHub access with better error messages
  if verify_github_access; then
    log "GitHub setup completed successfully."
    # Uncomment the following line to create a test branch for GitHub integration
    # create_test_branch "true"
  else
    log "GitHub setup completed with warnings. Some GitHub operations may fail."
    log "Please check the log for troubleshooting steps."
  fi
}

# Run the main function and capture any errors
if ! main; then
  log "GitHub setup encountered errors. Please review the log messages above."
  # Return non-zero but don't exit to prevent breaking the installation
  # We'll let the outer script handle this
else
  log "GitHub setup completed."
fi
