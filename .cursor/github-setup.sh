#!/bin/bash
# GitHub setup script for background agent

# Source retry utilities if available
if [ -f ".cursor/retry-utils.sh" ]; then
  source .cursor/retry-utils.sh
fi

# Initialize logging
CURSOR_AGENT_LOG=".cursor/agent.log"
ensure_dir "$(dirname "$CURSOR_AGENT_LOG")"
ensure_file "$CURSOR_AGENT_LOG"

# Log message to the agent log file
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[${timestamp}] $1" | tee -a "${CURSOR_AGENT_LOG}"
}

log "--- Running GitHub Setup Script ---"

# Configure git if not already done
if [ -z "$(git config --global --get user.email)" ]; then
  log "Setting up git user email"
  git config --global user.email "background-agent@cursor.sh"
fi

if [ -z "$(git config --global --get user.name)" ]; then
  log "Setting up git user name"
  git config --global user.name "Cursor Background Agent"
fi

# Set git credential helper
log "Setting git credential helper"
git config --global credential.helper 'cache --timeout=3600'

# Verify GitHub repository remote
log "Verifying GitHub repository remote"
if ! git remote -v 2>/dev/null | grep -q "github.com/Victordtesla24/cursor-uninstaller"; then
  log "WARNING: GitHub repository does not match expected repository"
  
  # Check if we can set the correct remote
  if ! git remote get-url origin >/dev/null 2>&1; then
    log "Setting GitHub repository remote"
    git remote add origin https://github.com/Victordtesla24/cursor-uninstaller.git || log "WARNING: Failed to add remote"
  else
    log "Updating GitHub repository remote"
    git remote set-url origin https://github.com/Victordtesla24/cursor-uninstaller.git || log "WARNING: Failed to update remote URL"
  fi
fi

# Check if we're in a git repository, if not initialize one
if [ ! -d ".git" ]; then
  log "Not in a git repository. Initializing..."
  git init || log "WARNING: Failed to initialize git repository"
  git config --global init.defaultBranch main || log "WARNING: Failed to set default branch"
  touch README.md || log "WARNING: Failed to create README.md"
  git add README.md || log "WARNING: Failed to add README.md to git"
  git commit -m "Initial commit" || log "WARNING: Failed to create initial commit"
fi

# Test GitHub connectivity
log "Testing GitHub connectivity"
if ! git ls-remote --heads origin >/dev/null 2>&1; then
  log "WARNING: Cannot access GitHub repository. Please ensure GitHub access token is properly configured."
  log "GitHub integration may not work correctly."
else
  log "GitHub connectivity verified successfully"
  
  # Attempt to fetch the latest changes
  log "Fetching latest changes from GitHub"
  git fetch origin || log "WARNING: Failed to fetch from GitHub"
  
  # Determine current branch and ensure we're on a valid branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
  if [ -z "$current_branch" ]; then
    log "Not on any branch. Checking out main branch..."
    git checkout main || git checkout master || log "WARNING: Could not checkout main or master branch"
  else
    log "Currently on branch: $current_branch"
    
    # Pull latest changes
    log "Pulling latest changes"
    git pull origin "$current_branch" || log "WARNING: Failed to pull latest changes"
  fi
fi

log "--- GitHub Setup Complete ---" 