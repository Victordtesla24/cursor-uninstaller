#!/bin/bash
set -e

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
CURSOR_ENV_INFO="${CURSOR_DIR_RELATIVE_TO_SCRIPT}/environment-snapshot-info.txt"

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
  # Adjusted to use CURSOR_DIR_RELATIVE_TO_SCRIPT for .cursor and logs path construction
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

log "--- Running Background Agent install.sh (from .cursor/install.sh) ---"

# Source utility functions if available
# Path to retry-utils.sh should be relative to this script's location if both are in .cursor
if [ -f "${CURSOR_DIR_RELATIVE_TO_SCRIPT}/retry-utils.sh" ]; then
  log "Sourcing retry utilities from ${CURSOR_DIR_RELATIVE_TO_SCRIPT}/retry-utils.sh ..."
  source "${CURSOR_DIR_RELATIVE_TO_SCRIPT}/retry-utils.sh"
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
  # Re-initialize CURSOR_DIR_RELATIVE_TO_SCRIPT and dependent log paths if cd occurs
  # However, this script itself is expected to be in .cursor under /agent_workspace.
  # So, initial CURSOR_DIR_RELATIVE_TO_SCRIPT should be /agent_workspace/.cursor
  # The cd /agent_workspace should ideally happen *before* sourcing or path definitions if not already there.
  # For robust execution, assume this script is run from /agent_workspace, and paths are relative to that or absolute.
  # Let's redefine log paths assuming PWD is /agent_workspace after this block
  if [ "$(pwd)" == "/agent_workspace" ]; then
      CURSOR_LOG_DIR=".cursor/logs"
      CURSOR_AGENT_LOG=".cursor/logs/agent.log"
      CURSOR_ENV_INFO=".cursor/environment-snapshot-info.txt"
      # Re-ensure log dir and file after potential cd
      ensure_dir ".cursor" || true
      ensure_dir ".cursor/logs" || true
      ensure_file ".cursor/logs/agent.log" || true
  fi
  init_directories # Re-run to ensure paths if cd happened, using new relative paths
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
    # Ensure correct branch detection for pull
    current_git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
    retry 3 2 git pull origin "${current_git_branch}" || { log "WARNING: Unable to pull latest changes on branch ${current_git_branch}"; handle_error $LINENO $? "continue"; }
  else
    current_git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
    git pull origin "${current_git_branch}" || { log "WARNING: Unable to pull latest changes on branch ${current_git_branch}"; handle_error $LINENO $? "continue"; }
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
# This is a lightweight check, actual git operations test will be in test-github-integration.sh
log "Creating a marker file in the repository root (bg-agent-install-complete.txt)..."
echo "Background agent installation script completed - $(date)" > bg-agent-install-complete.txt
log "Marker file created."

# Document the environment for snapshot purposes - ensure directory exists first
log "Documenting environment for snapshot purposes (to ${CURSOR_ENV_INFO})..."
# Ensure .cursor directory exists before writing to it
# Path to CURSOR_ENV_INFO needs to be correct, e.g., .cursor/environment-snapshot-info.txt if pwd is /agent_workspace
ensure_dir "$(dirname "${CURSOR_ENV_INFO}")" || log "WARNING: Failed to create directory for snapshot info"

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

# Run basic validation test script to validate the setup files themselves
# This should be a lightweight check on .cursor files, not a full runtime test.
if [ -f ".cursor/tests/test-background-agent.sh" ]; then
  log "Running basic agent configuration validation (.cursor/tests/test-background-agent.sh)..."
  bash .cursor/tests/test-background-agent.sh || { log "WARNING: Basic agent configuration validation failed, but continuing install..."; handle_error $LINENO $? "continue"; }
else
  log "WARNING: .cursor/tests/test-background-agent.sh not found. Skipping basic validation."
fi

log "--- install.sh finished successfully ---"
