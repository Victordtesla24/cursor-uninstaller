#!/bin/bash
set -e

# Setup logging (use same format as install.sh)
CURSOR_AGENT_LOG=".cursor/agent.log"
mkdir -p "$(dirname "${CURSOR_AGENT_LOG}")"
touch "${CURSOR_AGENT_LOG}"

log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[${timestamp}] $1" | tee -a "${CURSOR_AGENT_LOG}"
}

log "--- Running GitHub Setup Script ---"

# Source utility functions if available
if [ -f ".cursor/retry-utils.sh" ]; then
  log "Sourcing retry utilities..."
  source .cursor/retry-utils.sh
fi

# Function to check if git is configured properly
check_git_config() {
  log "Checking git configuration..."
  
  # Set user name and email if not already set
  if ! git config --get user.name >/dev/null 2>&1; then
    log "Setting git user.name to 'Cursor Background Agent'"
    git config --global user.name "Cursor Background Agent"
  fi
  
  if ! git config --get user.email >/dev/null 2>&1; then
    log "Setting git user.email to 'background-agent@cursor.sh'"
    git config --global user.email "background-agent@cursor.sh"
  fi
  
  # Set credential helper with longer timeout
  git config --global credential.helper 'cache --timeout=3600'
  
  log "Git configuration verified and updated if needed."
}

# Function to handle GitHub token
handle_github_token() {
  log "Handling GitHub token configuration..."
  
  # Check if we have an access token in environment
  if [[ -n "${GITHUB_TOKEN}" ]]; then
    log "Found GITHUB_TOKEN environment variable, configuring git to use it."
    
    # Remove any existing token configurations to avoid conflicts
    git config --global --unset-all url."https://x-access-token:${GITHUB_TOKEN}@github.com/".insteadOf >/dev/null 2>&1 || true
    
    # Configure git to use the token
    git config --global url."https://x-access-token:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
    log "Successfully configured git to use GitHub token."
  else
    log "No GITHUB_TOKEN environment variable found. Relying on Cursor's GitHub integration."
  fi
}

# Function to verify or set up the repository
verify_repository() {
  log "Verifying repository setup..."
  
  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "Not in a git repository. Initializing one..."
    git init
    git config --global init.defaultBranch main
    
    # Create initial commit if needed
    if [ ! -f "README.md" ]; then
      echo "# Cursor Uninstaller" > README.md
      git add README.md
      git commit -m "Initial commit"
    fi
    
    log "Repository initialized with default branch 'main'"
  fi
  
  # Check remote configuration
  if ! git remote -v 2>/dev/null | grep -q "github.com/Victordtesla24/cursor-uninstaller"; then
    log "Setting up remote for github.com/Victordtesla24/cursor-uninstaller..."
    
    if ! git remote get-url origin >/dev/null 2>&1; then
      log "Adding GitHub remote as 'origin'..."
      git remote add origin "https://github.com/Victordtesla24/cursor-uninstaller.git"
    else
      log "Updating existing 'origin' remote..."
      git remote set-url origin "https://github.com/Victordtesla24/cursor-uninstaller.git"
    fi
  fi
  
  log "Repository verification completed."
}

# Function to test GitHub access
test_github_access() {
  log "Testing GitHub access..."
  
  # Try fetching from remote, will fail if credentials are invalid
  if ! git fetch --quiet origin 2>/dev/null; then
    log "WARNING: Cannot fetch from GitHub. This may be due to missing or invalid credentials."
    log "The Background Agent will rely on Cursor's GitHub integration for access."
    return 1
  fi
  
  log "GitHub access verified successfully."
  return 0
}

# Main execution
check_git_config
handle_github_token
verify_repository
test_github_access || true  # Continue even if this fails

log "GitHub setup completed."
exit 0 