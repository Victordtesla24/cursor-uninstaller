#!/bin/bash
# Log Flushing Script for Cursor Background Agent
# This script removes previous logs and creates new empty log files without backups

set -e

# Define paths
SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_DIR="${SCRIPT_DIR}/logs"

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] FLUSH-LOGS: $1"
}

log "Starting log flush process..."

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Remove any existing archive directory to prevent backups
if [ -d "${LOG_DIR}/archive" ]; then
  rm -rf "${LOG_DIR}/archive"
  log "Removed log archives directory"
fi

# Remove all log files
find "${LOG_DIR}" -type f -name "*.log" -delete
log "Removed all previous log files"

# Create empty log files for common logs
touch "${LOG_DIR}/agent.log"
touch "${LOG_DIR}/master-test-run.log"
touch "${LOG_DIR}/validate_cursor_environment.log"
touch "${LOG_DIR}/test-env-setup.sh.log"
touch "${LOG_DIR}/test-github-integration.sh.log"
touch "${LOG_DIR}/test-docker-env.sh.log"
touch "${LOG_DIR}/test-background-agent.sh.log"
touch "${LOG_DIR}/test-agent-runtime.sh.log"
touch "${LOG_DIR}/test-linting.sh.log"
touch "${LOG_DIR}/env-load.log"
touch "${LOG_DIR}/cleanup.log"
touch "${LOG_DIR}/install.log"

# Set appropriate permissions
chmod 664 "${LOG_DIR}"/*.log

log "Log flush process completed. New empty log files created."
