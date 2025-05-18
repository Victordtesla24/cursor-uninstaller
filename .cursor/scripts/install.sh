#!/bin/bash
set -e

# Default repository URL if not provided through environment
: "${GITHUB_REPO_URL:=https://github.com/Victordtesla24/cursor-uninstaller.git}"

# Create log file directory if it doesn't exist - with better error handling
CURSOR_LOG_DIR=".cursor/logs"
CURSOR_AGENT_LOG=".cursor/agent.log"
CURSOR_ENV_INFO=".cursor/environment-snapshot-info.txt"

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
  for dir in ".cursor" ".cursor/logs" ".git"; do
    ensure_dir "$dir" || {
      echo "CRITICAL: Failed to create essential directory: $dir" >&2
      # Continue despite error - some directories might not be needed depending on flow
    }
  done

  # Ensure critical files exist
  ensure_file "${CURSOR_AGENT_LOG}" || echo "WARNING: Could not create agent log file" >&2
}

# Call directory initialization early
init_directories

# Setup logging with proper error handling
if ! ensure_dir "${CURSOR_LOG_DIR}"; then
  echo "WARNING: Could not create log directory. Logging to console only." >&2
  # Define a fallback log function that only prints to console
  log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${timestamp}] $1" >&2
  }
else
  # Ensure log file exists
  if ! ensure_file "${CURSOR_AGENT_LOG}"; then
    echo "WARNING: Could not create log file. Logging to console only." >&2
    # Define a fallback log function that only prints to console
    log() {
      local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
      echo "[${timestamp}] $1" >&2
    }
  else
    # Regular log function that writes to both console and log file
    log() {
      local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
      echo "[${timestamp}] $1" | tee -a "${CURSOR_AGENT_LOG}" 2>/dev/null || echo "[${timestamp}] $1" >&2
    }
  fi
fi

log "--- Running Background Agent install.sh ---"

# Source utility functions if available
if [ -f ".cursor/retry-utils.sh" ]; then
  log "Sourcing retry utilities..."
  source .cursor/retry-utils.sh
fi

# Log environment information for debugging
log "Current directory: $(pwd)"
log "User: $(whoami)"
log "Node version: $(node -v)"
log "NPM version: $(npm -v)"
log "OS info: $(cat /etc/os-release 2>/dev/null || echo 'OS info not available')"

# Function to handle errors
handle_error() {
  log "ERROR: An error occurred at line $1, exit code $2"
  # Don't exit with error on validation steps - allows for graceful continuation
  if [[ "$3" == "continue" ]]; then
    log "Continuing despite error..."
    return 0
  else
    exit $2
  fi
}

# Set up error trap for non-validation errors
trap 'handle_error $LINENO $?' ERR

# Ensure we're in the repository root directory
if [ -d "/agent_workspace" ] && [ "$(pwd)" != "/agent_workspace" ]; then
  log "Changing to /agent_workspace directory..."
  cd /agent_workspace
  # Recreate essential directories after changing directory
  init_directories
fi

# Improved git repository check and initialization
init_git_repo() {
  log "Checking git repository status..."

  if [ ! -d ".git" ]; then
    log "No git repository found. Initializing basic repository..."
    git init || { log "Failed to initialize git repository"; handle_error $LINENO $? "continue"; }

    # Configure default branch name before first commit
    git config --global init.defaultBranch main || { log "Failed to set default branch"; handle_error $LINENO $? "continue"; }

    # Create a basic README file and make initial commit if it doesn't exist
    if [ ! -f "README.md" ]; then
      echo "# Cursor Background Agent Repository" > README.md
      log "Created basic README.md file"
    fi

    git add README.md || { log "Failed to add README to git"; handle_error $LINENO $? "continue"; }
    git commit -m "Initial commit" || { log "Failed to make initial commit"; handle_error $LINENO $? "continue"; }
    log "Git repository initialized successfully."
  else
    log "Git repository already exists."
  fi
}

# Initialize git repository first
init_git_repo

# Validate GitHub repository - with graceful fallback
log "Validating GitHub repository configuration..."
if ! git remote -v 2>/dev/null | grep -q "${GITHUB_REPO_URL}"; then
  log "WARNING: GitHub repository does not match expected repository (${GITHUB_REPO_URL})"

  # Check if we can set the correct remote - using retry utility if available
  if ! git remote get-url origin >/dev/null 2>&1; then
    log "Setting GitHub repository remote..."
    if type retry >/dev/null 2>&1; then
      retry 3 2 git remote add origin "${GITHUB_REPO_URL}" || handle_error $LINENO $? "continue"
    else
      git remote add origin "${GITHUB_REPO_URL}" || handle_error $LINENO $? "continue"
    fi
  else
    log "Updating GitHub repository remote..."
    if type retry >/dev/null 2>&1; then
      retry 3 2 git remote set-url origin "${GITHUB_REPO_URL}" || handle_error $LINENO $? "continue"
    else
      git remote set-url origin "${GITHUB_REPO_URL}" || handle_error $LINENO $? "continue"
    fi
  fi
fi

# Validate GitHub credentials - with graceful fallback
log "Validating GitHub credentials..."
if ! git fetch origin --dry-run 2>/dev/null; then
  log "WARNING: Unable to fetch from GitHub. This may be due to missing credentials."
  log "The background agent will need to use GitHub credentials provided through the Cursor GitHub app."
else
  log "GitHub credentials validation successful."

  # Update local repository
  log "Updating local repository from GitHub..."
  if type retry >/dev/null 2>&1; then
    retry 3 2 git fetch origin || handle_error $LINENO $? "continue"
  else
    git fetch origin || handle_error $LINENO $? "continue"
  fi

  # Check if we're on a branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
  if [ -z "$current_branch" ]; then
    log "Not on any branch. Checking out main branch..."
    if type retry >/dev/null 2>&1; then
      retry 3 2 git checkout main || retry 3 2 git checkout master || { log "ERROR: Could not checkout main or master branch"; handle_error $LINENO $? "continue"; }
    else
      git checkout main || git checkout master || { log "ERROR: Could not checkout main or master branch"; handle_error $LINENO $? "continue"; }
    fi
  else
    log "Currently on branch: $current_branch"
  fi

  # Pull latest changes
  log "Pulling latest changes from origin..."
  if type retry >/dev/null 2>&1; then
    retry 3 2 git pull origin $(git symbolic-ref --short HEAD 2>/dev/null || echo "main") || { log "WARNING: Unable to pull latest changes"; handle_error $LINENO $? "continue"; }
  else
    git pull origin $(git symbolic-ref --short HEAD 2>/dev/null || echo "main") || { log "WARNING: Unable to pull latest changes"; handle_error $LINENO $? "continue"; }
  fi
fi

# Install root dependencies
if [ -f "package.json" ]; then
  log "Root package.json found. Running npm install in root..."
  if type run_with_timeout >/dev/null 2>&1; then
    run_with_timeout 300 npm install || { log "WARNING: npm install in root directory failed"; handle_error $LINENO $? "continue"; }
  else
    npm install || { log "WARNING: npm install in root directory failed"; handle_error $LINENO $? "continue"; }
  fi
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
    if type run_with_timeout >/dev/null 2>&1; then
      run_with_timeout 300 npm install || { log "WARNING: npm install in dashboard directory failed"; handle_error $LINENO $? "continue"; }
    else
      npm install || { log "WARNING: npm install in dashboard directory failed"; handle_error $LINENO $? "continue"; }
    fi
    log "Dashboard npm install completed."

    log "Running npx vite optimize --force in $DASHBOARD_DIR..."
    if type run_with_timeout >/dev/null 2>&1; then
      run_with_timeout 120 npx vite optimize --force || { log "WARNING: Vite optimization failed"; handle_error $LINENO $? "continue"; }
    else
      npx vite optimize --force || { log "WARNING: Vite optimization failed"; handle_error $LINENO $? "continue"; }
    fi
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

# Document the environment for snapshot purposes - ensure directory exists first
log "Documenting environment for snapshot purposes..."
# Ensure .cursor directory exists before writing to it
ensure_dir ".cursor" || log "WARNING: Failed to create .cursor directory"

# Ensure we can create the snapshot info file
if ensure_file "${CURSOR_ENV_INFO}"; then
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
  } > "${CURSOR_ENV_INFO}" || log "WARNING: Failed to write environment snapshot info"
else
  log "WARNING: Failed to create environment snapshot info file"
fi

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
      if type retry >/dev/null 2>&1; then
        if retry 3 5 git push --set-upstream origin "$git_branch" 2>/dev/null; then
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
  bash ./test-background-agent.sh || { log "WARNING: Validation tests failed, but continuing..."; handle_error $LINENO $? "continue"; }
fi

log "--- install.sh finished successfully ---"
