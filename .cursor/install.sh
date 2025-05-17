#!/bin/bash
set -e

# Create a log file directory if it doesn't exist
CURSOR_LOG_DIR=".cursor/logs"
CURSOR_LOG_FILE="${CURSOR_LOG_DIR}/agent.log"
CURSOR_AGENT_LOG=".cursor/agent.log"
mkdir -p "${CURSOR_LOG_DIR}"

# Setup logging function
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[${timestamp}] $1" | tee -a "${CURSOR_AGENT_LOG}"
}

log "--- Running Background Agent install.sh ---"

# Log environment information for debugging
log "Current directory: $(pwd)"
log "User: $(whoami)"
log "Node version: $(node -v)"
log "NPM version: $(npm -v)"
log "OS info: $(cat /etc/os-release 2>/dev/null || echo 'OS info not available')"

# Function to handle errors
handle_error() {
  log "ERROR: An error occurred at line $1, exit code $2"
  exit $2
}

# Set up error trap
trap 'handle_error $LINENO $?' ERR

# Ensure we're in the repository root directory
if [ -d "/agent_workspace" ] && [ "$(pwd)" != "/agent_workspace" ]; then
  log "Changing to /agent_workspace directory..."
  cd /agent_workspace
fi

# Validate GitHub repository
log "Validating GitHub repository configuration..."
if ! git remote -v | grep -q "github.com/Victordtesla24/cursor-uninstaller"; then
  log "WARNING: GitHub repository does not match expected repository (https://github.com/Victordtesla24/cursor-uninstaller.git)"
  
  # Check if we can set the correct remote
  if ! git remote get-url origin >/dev/null 2>&1; then
    log "Setting GitHub repository remote..."
    git remote add origin https://github.com/Victordtesla24/cursor-uninstaller.git
  else
    log "Updating GitHub repository remote..."
    git remote set-url origin https://github.com/Victordtesla24/cursor-uninstaller.git
  fi
fi

# Validate GitHub credentials
log "Validating GitHub credentials..."
if ! git fetch origin --dry-run 2>/dev/null; then
  log "WARNING: Unable to fetch from GitHub. This may be due to missing credentials."
  log "The background agent will need to use GitHub credentials provided through the Cursor GitHub app."
else
  log "GitHub credentials validation successful."
  
  # Update local repository
  log "Updating local repository from GitHub..."
  git fetch origin
  
  # Check if we're on a branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
  if [ -z "$current_branch" ]; then
    log "Not on any branch. Checking out main branch..."
    git checkout main || git checkout master || { log "ERROR: Could not checkout main or master branch"; }
  else
    log "Currently on branch: $current_branch"
  fi
  
  # Pull latest changes
  log "Pulling latest changes from origin..."
  git pull origin $(git symbolic-ref --short HEAD) || log "WARNING: Unable to pull latest changes"
fi

# Install root dependencies
if [ -f "package.json" ]; then
  log "Root package.json found. Running npm install in root..."
  npm install || { log "WARNING: npm install in root directory failed"; }
  log "Root npm install completed."
else
  log "No root package.json found. Skipping npm install in root."
fi

# Install ui/dashboard dependencies and optimize
DASHBOARD_DIR="ui/dashboard"
if [ -d "$DASHBOARD_DIR" ]; then
  log "Changing to $DASHBOARD_DIR directory..."
  cd "$DASHBOARD_DIR"
  if [ -f "package.json" ]; then
    log "Dashboard package.json found. Running npm install in $DASHBOARD_DIR..."
    npm install || { log "WARNING: npm install in dashboard directory failed"; }
    log "Dashboard npm install completed."

    log "Running npx vite optimize --force in $DASHBOARD_DIR..."
    npx vite optimize --force || { log "WARNING: Vite optimization failed"; }
    log "Vite optimization completed."
  else
    log "No package.json found in $DASHBOARD_DIR. Skipping dashboard setup."
  fi
  log "Changing back to root directory..."
  cd - # Go back to the previous directory (project root)
else
  log "ui/dashboard directory not found. Skipping dashboard setup."
fi

# Create a test file to verify the background agent is working
log "Creating a test file in the repository root..."
echo "Background agent installation test - $(date)" > bg-agent-test.txt
log "Test file created."

# Document the environment for snapshot purposes
log "Documenting environment for snapshot purposes..."
{
  echo "--- Environment Documentation for Snapshots ---"
  echo "Date: $(date)"
  echo "Node version: $(node -v)"
  echo "NPM version: $(npm -v)"
  echo "Global NPM packages:"
  npm list -g --depth=0
  echo "Disk usage:"
  df -h .
  echo "Git configuration:"
  git config --list
  echo "----------------------------------------"
} > .cursor/environment-snapshot-info.txt

# Create a basic git commit to test GitHub integration
if [ -f "bg-agent-test.txt" ]; then
  log "Testing GitHub integration with a sample commit..."
  git_branch="background-agent-test-$(date +%Y%m%d%H%M%S)"
  
  # Create a new branch for this test
  if git checkout -b "$git_branch" 2>/dev/null; then
    git add bg-agent-test.txt
    if git commit -m "Test commit from Background Agent setup" 2>/dev/null; then
      log "Successfully created test commit on branch $git_branch"
      
      # Try to push to remote (will fail without credentials, but agent should have them)
      log "Attempting to push to GitHub..."
      if git push --set-upstream origin "$git_branch" 2>/dev/null; then
        log "Successfully pushed to GitHub"
        
        # Try to create a pull request if gh cli is available
        if command -v gh &>/dev/null; then
          log "Creating a pull request using GitHub CLI..."
          gh pr create --title "Background Agent Test" --body "This is a test pull request created by the Background Agent setup process." || log "Failed to create pull request"
        else
          log "GitHub CLI not available. Skipping pull request creation."
        fi
      else
        log "WARNING: Failed to push to GitHub. This is expected if credentials are not available."
      fi
    else
      log "WARNING: Failed to create test commit. This is expected if no changes were made."
    fi
  else
    log "WARNING: Failed to create test branch $git_branch"
  fi
  
  # Return to the original branch
  git checkout - 2>/dev/null || log "WARNING: Failed to return to original branch"
fi

# Run test scripts to validate the setup
if [ -f "./test-background-agent.sh" ]; then
  log "Running validation tests..."
  bash ./test-background-agent.sh || log "WARNING: Validation tests failed, but continuing..."
fi

log "--- install.sh finished successfully ---"
