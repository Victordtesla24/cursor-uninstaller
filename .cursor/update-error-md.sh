#!/bin/bash
# Script to update error.md with latest test run information
# This script ensures the error.md file contains the most recent test run output

set -e

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ERROR_MD="${SCRIPT_DIR}/error.md"
LATEST_RUN=$(ls -t "${WORKSPACE_ROOT}/.cursor/logs/master-test-run.log" 2>/dev/null)

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] UPDATE-ERROR-MD: $1"
}

log "Starting update of error.md file..."

# Clear existing error.md file
> "${ERROR_MD}"

# Get the current user and working directory info
CURRENT_USER="$(whoami)"
CURRENT_HOSTNAME="$(hostname)"
CURRENT_DIR="${WORKSPACE_ROOT}"

# Add the command that would have been run and the test output
echo "(\${VENV}) ${CURRENT_USER}@${CURRENT_HOSTNAME} cursor-uninstaller % cd ${CURRENT_DIR} && bash .cursor/flush-logs.sh && bash .cursor/tests/run-tests.sh" > "${ERROR_MD}"

# If we have a recent test run log, append its contents
if [ -n "${LATEST_RUN}" ] && [ -f "${LATEST_RUN}" ]; then
  cat "${LATEST_RUN}" >> "${ERROR_MD}"
  log "Updated error.md with latest test run from ${LATEST_RUN}"
else
  echo "No recent test run logs found." >> "${ERROR_MD}"
  log "No recent test run logs found to update error.md"
fi

# Add terminal prompt at the end to simulate CLI completion
echo -e "\n(\${VENV}) ${CURRENT_USER}@${CURRENT_HOSTNAME} cursor-uninstaller % " >> "${ERROR_MD}"

log "error.md update completed."
