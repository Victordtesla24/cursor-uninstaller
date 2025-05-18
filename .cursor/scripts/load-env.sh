#!/bin/bash
# Environment Variable Loading Script for Cursor Background Agent
# This script loads environment variables from .cursor/env.txt or .env files

# Define paths
SCRIPT_DIR="$(dirname "$0")"
CURSOR_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="${CURSOR_DIR}/logs"
ENV_FILE="${CURSOR_DIR}/env.txt"
DOT_ENV_FILE="${CURSOR_DIR}/.env"
LOG_FILE="${LOG_DIR}/env-load.log"

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] LOAD-ENV: $1" >> "${LOG_FILE}"
}

log "Starting environment variable loading..."

# Set default variables
: "${GITHUB_REPO_URL:=https://github.com/Victordtesla24/cursor-uninstaller.git}"
: "${NODE_ENV:=development}"
: "${LOG_LEVEL:=debug}"
: "${PORT:=3000}"

# Export default variables
export GITHUB_REPO_URL
export NODE_ENV
export LOG_LEVEL
export PORT

# Load variables from .env file if it exists
if [ -f "${DOT_ENV_FILE}" ]; then
  log "Loading environment variables from ${DOT_ENV_FILE}"

  # Read .env file and export variables
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
      continue
    fi

    # Extract variable name and value
    if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
      var_name="${BASH_REMATCH[1]}"
      var_value="${BASH_REMATCH[2]}"

      # Remove quotes if present
      var_value="${var_value#\"}"
      var_value="${var_value%\"}"
      var_value="${var_value#\'}"
      var_value="${var_value%\'}"

      # Export the variable
      export "$var_name"="$var_value"
      log "Exported $var_name from .env file"
    fi
  done < "${DOT_ENV_FILE}"
fi

# Load variables from env.txt file if it exists and .env doesn't exist
if [ ! -f "${DOT_ENV_FILE}" ] && [ -f "${ENV_FILE}" ]; then
  log "Loading environment variables from ${ENV_FILE}"

  # Read env.txt file and export variables
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
      continue
    fi

    # Extract variable name and value
    if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
      var_name="${BASH_REMATCH[1]}"
      var_value="${BASH_REMATCH[2]}"

      # Skip placeholders
      if [[ "$var_value" == "YOUR_"*"_HERE" ]] || [[ "$var_value" == "your."* ]]; then
        log "Skipping placeholder value for $var_name"
        continue
      fi

      # Remove quotes if present
      var_value="${var_value#\"}"
      var_value="${var_value%\"}"
      var_value="${var_value#\'}"
      var_value="${var_value%\'}"

      # Export the variable
      export "$var_name"="$var_value"
      log "Exported $var_name from env.txt file"
    fi
  done < "${ENV_FILE}"
fi

# Try to get GitHub token from various locations if not set
if [ -z "${GITHUB_TOKEN}" ]; then
  log "GITHUB_TOKEN is not set, attempting to find from alternate sources..."

  # Check if gh CLI is installed and authenticated
  if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
      if GH_TOKEN=$(gh auth token 2>/dev/null); then
        export GITHUB_TOKEN="${GH_TOKEN}"
        log "Exported GITHUB_TOKEN from GitHub CLI"
      fi
    fi
  fi

  # Check for git credential helper
  if [ -z "${GITHUB_TOKEN}" ]; then
    if git config --get credential.helper &> /dev/null; then
      log "Git credential helper is configured, credentials might be available to Git commands"
    fi
  fi
fi

# Log the status of important environment variables
log "Environment variable status:"
[ -n "${GITHUB_REPO_URL}" ] && log "GITHUB_REPO_URL is set" || log "GITHUB_REPO_URL is not set"
[ -n "${GITHUB_TOKEN}" ] && log "GITHUB_TOKEN is set" || log "GITHUB_TOKEN is not set"
[ -n "${NODE_ENV}" ] && log "NODE_ENV is set to ${NODE_ENV}" || log "NODE_ENV is not set"

log "Environment variable loading completed"
