#!/bin/bash
# GitHub Setup Script for Background Agent

# Default repository URL if not provided through environment
: "${GITHUB_REPO_URL:=https://github.com/Victordtesla24/cursor-uninstaller.git}"

# Create log directory if it doesn't exist - with error handling
CURSOR_LOG_DIR=".cursor/logs"
CURSOR_AGENT_LOG=".cursor/agent.log"

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

log "Running GitHub setup script..."

# Source retry utilities if available
if [ -f ".cursor/retry-utils.sh" ]; then
  log "Sourcing retry utilities..."
  source .cursor/retry-utils.sh
else
  log "Retry utilities not found. Creating basic retry function..."
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
  fi

  # Update repository remotes if they exist
  if git remote -v | grep -q "origin"; then
    log "Updating remote URL for origin..."
    git remote set-url origin "${GITHUB_REPO_URL}" || log "Failed to update remote URL"
  else
    log "Adding remote origin..."
    git remote add origin "${GITHUB_REPO_URL}" || log "Failed to add remote origin"
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

# Verify GitHub access and repository
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
        sleep $delay
        delay=$((delay * 2))
        attempt=$((attempt + 1))
      else
        log "GitHub access failed after $max_attempts attempts. Please ensure GitHub integration is properly configured in Cursor."
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

# Main execution
main() {
  configure_git_identity
  refresh_github_token

  if verify_github_access; then
    log "GitHub setup completed successfully."
    # Uncomment the following line to create a test branch for GitHub integration
    # create_test_branch "true"
  else
    log "GitHub setup completed with warnings. Some GitHub operations may fail."
  fi
}

# Run the main function
main
