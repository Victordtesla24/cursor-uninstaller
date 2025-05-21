#!/bin/bash
# Cleanup Script for Cursor Background Agent
# This script cleans up temporary files, logs, and Docker containers 
# used by the Background Agent

set -e

# Determine the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/cleanup.log"

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] CLEANUP: $1" | tee -a "${LOG_FILE}" 2>/dev/null || echo -e "[$timestamp] CLEANUP: $1"
}

log "Starting cleanup of Cursor Background Agent resources..."

# Clean up Docker containers
log "Cleaning up Docker containers..."
if command -v docker &> /dev/null; then
  if docker ps -a --filter "name=cursor-agent" --format "{{.ID}}" | grep -q .; then
    docker ps -a --filter "name=cursor-agent" --format "{{.ID}}" | xargs -r docker rm -f
    log "Removed cursor-agent Docker containers"
  else
    log "No cursor-agent Docker containers found"
  fi

  # Clean up test images
  if docker images "cursor-agent-test:*" --format "{{.ID}}" | grep -q .; then
    docker images "cursor-agent-test:*" --format "{{.ID}}" | xargs -r docker rmi -f
    log "Removed cursor-agent-test Docker images"
  else
    log "No cursor-agent-test Docker images found"
  fi
else
  log "Docker not found, skipping container cleanup"
fi

# Clean up temporary files
log "Cleaning up temporary files..."
temp_files=(
  "${REPO_ROOT}/bg-agent-install-complete.txt"
  "${SCRIPT_DIR}/github-test.txt"
  "${SCRIPT_DIR}/github-test-*.txt"
  "${SCRIPT_DIR}/environment-snapshot-info.txt"
  "${SCRIPT_DIR}/environment-snapshot.json"
)

for file in "${temp_files[@]}"; do
  if ls $file 2>/dev/null; then
    rm -f $file
    log "Removed temporary file: $file"
  fi
done

# Clean up log files (rotate instead of delete)
log "Rotating log files..."
mkdir -p "${LOG_DIR}/archive" 2>/dev/null || true

# Find log files older than 7 days and move them to archive
find "${LOG_DIR}" -maxdepth 1 -name "*.log" -type f -mtime +7 -exec mv {} "${LOG_DIR}/archive/" \; 2>/dev/null || true
log "Archived older log files"

# Truncate current log files to conserve space (don't delete completely)
for log_file in "${LOG_DIR}"/*.log; do
  if [ -f "$log_file" ] && [ "$(basename "$log_file")" != "cleanup.log" ]; then
    # Save the last 100 lines of each log file
    tail -n 100 "$log_file" > "${log_file}.tmp" 2>/dev/null
    mv "${log_file}.tmp" "$log_file" 2>/dev/null
    log "Truncated log file: $(basename "$log_file")"
  fi
done

# Clean up Docker build cache if necessary
if [ -x "$(command -v docker)" ] && [ "$(docker info 2>/dev/null | grep -c "Server Version")" -gt 0 ]; then
  log "Cleaning up Docker build cache..."
  docker builder prune -f --filter "until=24h" > /dev/null 2>&1 || log "Failed to prune Docker build cache (not critical)"
fi

log "Cleanup completed successfully"
echo "Cursor Background Agent resources have been cleaned up."
