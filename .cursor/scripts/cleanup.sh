#!/bin/bash
# Cleanup Script for Cursor Background Agent
# This script cleans up temporary files and resources

set -e

# Define paths
SCRIPT_DIR="$(dirname "$0")"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="${CURSOR_DIR}/logs"
LOG_FILE="${LOG_DIR}/cleanup.log"

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] CLEANUP: $1" | tee -a "${LOG_FILE}"
}

# Function to safely remove files
safe_remove() {
  local path="$1"
  local force="$2"

  if [ -e "$path" ]; then
    if [ -d "$path" ] && [ ! -L "$path" ]; then
      # It's a directory, remove it recursively if force is set
      if [ "$force" = "true" ]; then
        log "Removing directory: $path"
        rm -rf "$path" && log "Successfully removed directory: $path" || log "Failed to remove directory: $path"
      else
        log "Directory will not be removed (force=false): $path"
      fi
    else
      # It's a file or symlink
      log "Removing file: $path"
      rm -f "$path" && log "Successfully removed file: $path" || log "Failed to remove file: $path"
    fi
  else
    log "Path does not exist: $path"
  fi
}

log "Starting cleanup process..."

# Clean up temporary test files
log "Cleaning up temporary test files..."
safe_remove "${CURSOR_DIR}/bg-agent-test.txt"
safe_remove "${CURSOR_DIR}/github-test.txt"
safe_remove "${CURSOR_DIR}/github-test-"*".txt" 2>/dev/null || true

# Clean up old log files
log "Cleaning up old log files..."
find "${LOG_DIR}" -type f -name "*.log" -mtime +7 -exec rm -f {} \; 2>/dev/null || true
log "Old log files (>7 days) cleaned up"

# Clean up test branches
log "Cleaning up test branches..."
# Get current branch to restore it later
current_branch=$(git branch --show-current 2>/dev/null || echo "")

# Check if we're in a git repository
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # List and delete local test branches
  test_branches=$(git branch | grep -E 'test-bg-agent-|background-agent-test-' 2>/dev/null || true)
  if [ -n "$test_branches" ]; then
    log "Found test branches to clean up:"
    echo "$test_branches" | sed 's/^/  /' | tee -a "${LOG_FILE}"

    # Delete each test branch
    echo "$test_branches" | while read -r branch; do
      branch_name=$(echo "$branch" | sed 's/^[ *]*//')
      log "Deleting local branch: $branch_name"
      git branch -D "$branch_name" >/dev/null 2>&1 && log "Successfully deleted branch: $branch_name" || log "Failed to delete branch: $branch_name"
    done
  else
    log "No test branches found to clean up"
  fi

  # Return to original branch if we changed
  if [ -n "$current_branch" ]; then
    git checkout "$current_branch" >/dev/null 2>&1 || log "Failed to return to original branch: $current_branch"
  fi
else
  log "Not in a git repository, skipping branch cleanup"
fi

# Clean up Docker resources (only if Docker is available)
if command -v docker &>/dev/null; then
  log "Docker is available, cleaning up Docker resources..."

  # Remove any cursor test images
  test_images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E 'cursor-agent-test|cursor-test' 2>/dev/null || true)
  if [ -n "$test_images" ]; then
    log "Found test Docker images to clean up:"
    echo "$test_images" | sed 's/^/  /' | tee -a "${LOG_FILE}"

    # Remove each test image
    echo "$test_images" | while read -r image; do
      log "Removing Docker image: $image"
      docker rmi "$image" >/dev/null 2>&1 && log "Successfully removed image: $image" || log "Failed to remove image: $image"
    done
  else
    log "No test Docker images found to clean up"
  fi

  # Clean up dangling images
  log "Cleaning up dangling Docker images..."
  docker image prune -f >/dev/null 2>&1 && log "Successfully cleaned up dangling images" || log "Failed to clean up dangling images"
else
  log "Docker is not available, skipping Docker cleanup"
fi

# Clean up npm cache (only if npm is available)
if command -v npm &>/dev/null; then
  log "npm is available, cleaning up npm cache..."
  npm cache clean --force >/dev/null 2>&1 && log "Successfully cleaned npm cache" || log "Failed to clean npm cache"
else
  log "npm is not available, skipping npm cache cleanup"
fi

log "Cleanup process completed successfully"
exit 0
