#!/bin/bash

################################################################################
# Production Configuration for Cursor AI Editor Management Utility
# NO FALLBACKS - PRODUCTION STANDARDS ONLY
################################################################################

# Error codes - Production Grade
export ERR_GENERAL=1
export ERR_PERMISSION=2  
export ERR_NOT_FOUND=3
export ERR_SYSTEM_ERROR=4
export ERR_USER_CANCELLED=5

# Directory Paths - Real System Locations
export CONFIG_DIR="$HOME/.cursor_management"
export LOG_DIR="$CONFIG_DIR/logs"
export BACKUP_DIR="$CONFIG_DIR/backups"
export TEMP_DIR="${TMPDIR:-/tmp}/cursor_management_$$"

# System Requirements - Production Standards
export MIN_MACOS_VERSION="10.15"
export MIN_MEMORY_GB=8
export MIN_DISK_SPACE_GB=10
export REQUIRED_COMMANDS="defaults osascript sudo pgrep pkill"

# Cursor Application Paths - Real Locations
export CURSOR_APP_PATH="/Applications/Cursor.app"
export CURSOR_BUNDLE_ID="com.todesktop.230313mzl4w4u92"
export CURSOR_CLI_PATHS=("/usr/local/bin/cursor" "/opt/homebrew/bin/cursor")

# User Data Directories - Complete List
export CURSOR_USER_DIRS=(
    "$HOME/Library/Application Support/Cursor"
    "$HOME/Library/Caches/Cursor"
    "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
    "$HOME/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState"
    "$HOME/Library/Logs/Cursor"
    "$HOME/.cursor"
    "$HOME/.vscode-cursor"
)

# System Integration Paths
export LAUNCH_SERVICES_CMD="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

# Color Constants for UI
export RED='\033[0;31m'
export GREEN='\033[0;32m'  
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export BOLD='\033[1m'
export NC='\033[0m'

# Production Optimization Settings
export AI_MEMORY_LIMIT_GB=8
export AI_CONTEXT_LENGTH=8192
export AI_TEMPERATURE=0.05
export AI_MAX_TOKENS=2048
export FILE_DESCRIPTOR_LIMIT=65536

# Timeout Settings - Production Values
export OPERATION_TIMEOUT=300
export SUDO_TIMEOUT=60
export NETWORK_TIMEOUT=30

# Validation performed
export CONFIG_LOADED=true 