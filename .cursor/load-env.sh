#!/bin/bash
# Environment Variables Loader for Cursor Background Agent
# This script loads necessary environment variables from different sources

set -e

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"
LOG_DIR="${SCRIPT_DIR}/logs"
ENV_LOG="${LOG_DIR}/env-load.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[$timestamp] LOAD-ENV: $1" | tee -a "${ENV_LOG}"
}

log "Loading environment variables from various sources..."

# Function to safely load environment variables from a file
load_env_file() {
  local env_file="$1"
  local source_name="$2"
  
  if [ -f "${env_file}" ]; then
    log "Loading environment from ${source_name}..."
    
    # Load each line from the env file, ignoring comments and empty lines
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Skip comments and empty lines
      if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
        continue
      fi
      
      # Extract variable name and value
      if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
        local name="${BASH_REMATCH[1]}"
        local value="${BASH_REMATCH[2]}"
        
        # Remove quotes if present
        value="${value#\"}"
        value="${value%\"}"
        value="${value#\'}"
        value="${value%\'}"
        
        # Export the variable
        export "$name"="$value"
        log "Exported ${name} from ${source_name}"
      fi
    done < "${env_file}"
  else
    log "Environment file ${source_name} not found, skipping..."
  fi
}

# Load environment variables from different sources
# Priority (highest to lowest):
# 1. .env file in .cursor directory
# 2. env.txt in .cursor directory
# 3. .env file in repository root
# 4. env.txt in repository root

# Load from .cursor/.env (highest priority)
load_env_file "${SCRIPT_DIR}/.env" ".cursor/.env"

# Load from .cursor/env.txt
load_env_file "${SCRIPT_DIR}/env.txt" ".cursor/env.txt"

# Load from repository root .env
load_env_file "${REPO_ROOT}/.env" "repository root .env"

# Load from repository root env.txt
load_env_file "${REPO_ROOT}/env.txt" "repository root env.txt"

# Function to validate GitHub token
validate_github_token() {
  local token="$1"
  
  # Check if the token is empty or a placeholder
  if [ -z "$token" ] || [[ "$token" == *"REPLACE_THIS"* ]] || [[ "$token" == *"<"*">"* ]]; then
    log "WARNING: GitHub token appears to be invalid, empty, or a placeholder"
    return 1
  fi
  
  # Basic format check (GitHub PATs have a specific format)
  if [[ ! "$token" =~ ^github_pat_ ]]; then
    log "WARNING: GitHub token does not appear to have the correct format"
    return 1
  fi
  
  # Token seems valid based on format
  return 0
}

# After loading environment variables, validate critical ones
log "Validating critical environment variables..."

# Set default values for critical variables if not already set
: "${GITHUB_REPO_URL:=https://github.com/Victordtesla24/cursor-uninstaller.git}"
: "${NODE_ENV:=development}"
: "${PORT:=3000}"
: "${LOG_LEVEL:=debug}"
: "${GITHUB_USERNAME:=Victordtesla24}"

# Export default values
export GITHUB_REPO_URL
export NODE_ENV
export PORT
export LOG_LEVEL
export GITHUB_USERNAME

# Validate GitHub token if present
if [ -n "${GITHUB_TOKEN}" ]; then
  if validate_github_token "${GITHUB_TOKEN}"; then
    log "GitHub token validation passed"
  else
    log "WARNING: GitHub token validation failed. GitHub operations may be limited."
    log "Consider regenerating your GitHub token at https://github.com/settings/tokens"
  fi
else
  log "WARNING: GITHUB_TOKEN is not set. GitHub operations will be limited."
  log "Set GITHUB_TOKEN in your env.txt or .env file for full GitHub access."
fi

# Log the final values of important environment variables (mask sensitive values)
log "Final environment configuration:"
log "GITHUB_REPO_URL=${GITHUB_REPO_URL}"
log "GITHUB_USERNAME=${GITHUB_USERNAME}"
log "NODE_ENV=${NODE_ENV}"
log "PORT=${PORT}"
log "LOG_LEVEL=${LOG_LEVEL}"

if [ -n "${GITHUB_TOKEN}" ]; then
  log "GITHUB_TOKEN is set [value masked]"
else
  log "WARNING: GITHUB_TOKEN is not set. GitHub operations may be limited."
fi

# Check if we need to validate Docker
if command -v docker >/dev/null 2>&1; then
  log "Docker is available. Version: $(docker --version 2>/dev/null || echo 'unknown')"
  
  # Check if Docker is running
  if docker info >/dev/null 2>&1; then
    log "Docker daemon is running."
  else
    log "WARNING: Docker daemon is not running. Some features may not work."
  fi
else
  log "Docker is not available on this system."
fi

log "Environment variables loaded successfully."
