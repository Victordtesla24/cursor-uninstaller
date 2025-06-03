#!/bin/bash

################################################################################
# Configuration Module for Cursor AI Editor Management Utility
# CENTRALIZED CONFIGURATION AND CONSTANTS
################################################################################

# Strict error handling
set -euo pipefail

# Configuration module metadata
readonly CONFIG_MODULE_VERSION="1.0.0"

# Application paths and identifiers
readonly CURSOR_APP_PATH="/Applications/Cursor.app"
readonly CURSOR_BUNDLE_ID="com.todesktop.230313mzl4w4u92"
readonly CURSOR_CLI_PATHS=(
    "/usr/local/bin/cursor"
    "/opt/homebrew/bin/cursor"
    "$HOME/.local/bin/cursor"
)

# System requirements
readonly MIN_MACOS_VERSION="10.15"
readonly MIN_MEMORY_GB=4
readonly MIN_DISK_SPACE_GB=5
readonly RECOMMENDED_MEMORY_GB=8
readonly RECOMMENDED_DISK_SPACE_GB=10

# Timeout configurations
readonly NETWORK_TIMEOUT=30
readonly PROCESS_TIMEOUT=60
readonly DMG_MOUNT_TIMEOUT=30
readonly FILE_OPERATION_TIMEOUT=120
readonly SPOTLIGHT_OPERATION_TIMEOUT=30  # For Spotlight reindex/search operations
readonly PROCESS_TERMINATION_GRACE_TIMEOUT=15 # Graceful termination period for processes

# Directory configurations
readonly TEMP_DIR="${TMPDIR:-/tmp}/cursor_uninstaller_$$"
readonly LOG_DIR="${HOME}/.cursor_management/logs"
readonly CONFIG_DIR="${HOME}/.cursor_management/config"
readonly BACKUP_DIR="${HOME}/.cursor_management/backups"

# Security settings
readonly MAX_PATH_LENGTH=4096
readonly MAX_MESSAGE_LENGTH=1000
readonly MAX_LOG_FILE_SIZE=10485760  # 10MB
readonly ENABLE_BACKUPS=true
readonly SUDO_REMOVAL_CONFIRMED=false

# Color definitions for UI
if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && [[ -z "${NO_COLOR:-}" ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly CYAN=''
    readonly BOLD=''
    readonly NC=''
fi

# Launch Services command path
readonly LAUNCH_SERVICES_CMD="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"

# Function to get Cursor user directories
get_cursor_user_dirs() {
    local -a user_dirs=(
        "$HOME/Library/Application Support/Cursor"
        "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        "$HOME/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt"
        "$HOME/Library/HTTPStorages/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/WebKit/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Logs/Cursor"
    )
    
    printf '%s\n' "${user_dirs[@]}"
}

# Function to validate configuration
validate_configuration() {
    local validation_errors=0
    
    # Validate required directories exist or can be created
    local required_dirs=("$LOG_DIR" "$CONFIG_DIR" "$BACKUP_DIR")
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if ! mkdir -p "$dir" 2>/dev/null; then
                printf '[CONFIG ERROR] Cannot create required directory: %s\n' "$dir" >&2
                ((validation_errors++))
            fi
        fi
    done
    
    # Validate timeout values
    local timeout_vars=(
        "NETWORK_TIMEOUT:$NETWORK_TIMEOUT"
        "PROCESS_TIMEOUT:$PROCESS_TIMEOUT"
        "DMG_MOUNT_TIMEOUT:$DMG_MOUNT_TIMEOUT"
        "FILE_OPERATION_TIMEOUT:$FILE_OPERATION_TIMEOUT"
        "SPOTLIGHT_OPERATION_TIMEOUT:$SPOTLIGHT_OPERATION_TIMEOUT"
        "PROCESS_TERMINATION_GRACE_TIMEOUT:$PROCESS_TERMINATION_GRACE_TIMEOUT"
    )
    
    for timeout_var in "${timeout_vars[@]}"; do
        local name="${timeout_var%%:*}"
        local value="${timeout_var##*:}"
        
        if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value <= 0 )) || (( value > 3600 )); then
            printf '[CONFIG ERROR] Invalid timeout value for %s: %s\n' "$name" "$value" >&2
            ((validation_errors++))
        fi
    done
    
    # Validate memory requirements
    if [[ ! "$MIN_MEMORY_GB" =~ ^[0-9]+$ ]] || (( MIN_MEMORY_GB <= 0 )); then
        printf '[CONFIG ERROR] Invalid minimum memory requirement: %s\n' "$MIN_MEMORY_GB" >&2
        ((validation_errors++))
    fi
    
    # Validate disk space requirements
    if [[ ! "$MIN_DISK_SPACE_GB" =~ ^[0-9]+$ ]] || (( MIN_DISK_SPACE_GB <= 0 )); then
        printf '[CONFIG ERROR] Invalid minimum disk space requirement: %s\n' "$MIN_DISK_SPACE_GB" >&2
        ((validation_errors++))
    fi
    
    return $validation_errors
}

# Function to display configuration summary
display_configuration_summary() {
    printf '\n%sConfiguration Summary:%s\n' "$BOLD" "$NC"
    printf '%s═══════════════════════════════════════════════%s\n' "$BOLD" "$NC"
    printf '%sApplication Path:%s %s\n' "$CYAN" "$NC" "$CURSOR_APP_PATH"
    printf '%sBundle ID:%s %s\n' "$CYAN" "$NC" "$CURSOR_BUNDLE_ID"
    printf '%sMinimum Memory:%s %dGB\n' "$CYAN" "$NC" "$MIN_MEMORY_GB"
    printf '%sMinimum Disk Space:%s %dGB\n' "$CYAN" "$NC" "$MIN_DISK_SPACE_GB"
    printf '%sNetwork Timeout:%s %ds\n' "$CYAN" "$NC" "$NETWORK_TIMEOUT"
    printf '%sProcess Timeout:%s %ds\n' "$CYAN" "$NC" "$PROCESS_TIMEOUT"
    printf '%sLog Directory:%s %s\n' "$CYAN" "$NC" "$LOG_DIR"
    printf '%sBackup Directory:%s %s\n' "$CYAN" "$NC" "$BACKUP_DIR"
    printf '%sBackups Enabled:%s %s\n' "$CYAN" "$NC" "$ENABLE_BACKUPS"
    printf '\n'
}

# Function to detect environment
detect_environment() {
    # Detect operating system
    if [[ "$OSTYPE" != "darwin"* ]]; then
        printf '[CONFIG ERROR] Unsupported operating system: %s\n' "$OSTYPE" >&2
        return 1
    fi
    
    # Detect macOS version
    if command -v sw_vers >/dev/null 2>&1; then
        local macos_version
        macos_version=$(sw_vers -productVersion 2>/dev/null || echo "0.0")
        
        # Basic version check
        if [[ ! "$macos_version" =~ ^[0-9]+\.[0-9]+ ]]; then
            printf '[CONFIG WARNING] Cannot determine macOS version\n' >&2
        fi
    fi
    
    # Detect architecture
    local arch
    arch=$(uname -m 2>/dev/null || echo "unknown")
    export SYSTEM_ARCHITECTURE="$arch"
    
    # Detect shell
    local shell_name
    shell_name=$(basename "${SHELL:-/bin/bash}")
    export CURRENT_SHELL="$shell_name"
    
    # Detect terminal capabilities
    if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]; then
        export TERMINAL_INTERACTIVE=true
    else
        export TERMINAL_INTERACTIVE=false
    fi
    
    return 0
}

# Function to initialize configuration
initialize_configuration() {
    # Validate configuration
    if ! validate_configuration; then
        printf '[CONFIG ERROR] Configuration validation failed\n' >&2
        return 1
    fi
    
    # Detect environment
    if ! detect_environment; then
        printf '[CONFIG ERROR] Environment detection failed\n' >&2
        return 1
    fi
    
    # Create required directories securely
    local dirs_to_create=("$TEMP_DIR" "$LOG_DIR" "$CONFIG_DIR" "$BACKUP_DIR")
    local current_user_id
    current_user_id=$(id -u)
    
    for dir in "${dirs_to_create[@]}"; do
        if [[ -d "$dir" ]]; then
            # Directory exists, check ownership and permissions
            local dir_owner_id
            dir_owner_id=$(stat -f "%u" "$dir" 2>/dev/null || echo "-1")
            
            if [[ "$dir_owner_id" == "$current_user_id" ]]; then
                if ! chmod 700 "$dir" 2>/dev/null; then
                    printf '[CONFIG WARNING] Cannot set permissions for existing directory: %s\n' "$dir" >&2
                fi
            else
                printf '[CONFIG WARNING] Directory exists but is not owned by current user: %s\n' "$dir" >&2
                # Consider not using this directory or failing if ownership is critical
            fi
        else
            # Directory does not exist, create it
            if mkdir -p "$dir" 2>/dev/null; then
                if ! chmod 700 "$dir" 2>/dev/null; then
                    printf '[CONFIG WARNING] Cannot set permissions for new directory: %s\n' "$dir" >&2
                fi
                # Double check ownership after creation (especially if running as root then sudoing)
                local new_dir_owner_id
                new_dir_owner_id=$(stat -f "%u" "$dir" 2>/dev/null || echo "-1")
                if [[ "$new_dir_owner_id" != "$current_user_id" ]]; then
                    if ! chown "$current_user_id" "$dir" 2>/dev/null; then
                         printf '[CONFIG WARNING] Cannot set ownership for new directory: %s\n' "$dir" >&2
                    fi
                fi
            else
                printf '[CONFIG WARNING] Cannot create directory: %s\n' "$dir" >&2
            fi
        fi
    done
    
    return 0
}

# Export all configuration variables
export CURSOR_APP_PATH CURSOR_BUNDLE_ID
export MIN_MACOS_VERSION MIN_MEMORY_GB MIN_DISK_SPACE_GB
export RECOMMENDED_MEMORY_GB RECOMMENDED_DISK_SPACE_GB
export NETWORK_TIMEOUT PROCESS_TIMEOUT DMG_MOUNT_TIMEOUT FILE_OPERATION_TIMEOUT
export TEMP_DIR LOG_DIR CONFIG_DIR BACKUP_DIR
export MAX_PATH_LENGTH MAX_MESSAGE_LENGTH MAX_LOG_FILE_SIZE
export ENABLE_BACKUPS SUDO_REMOVAL_CONFIRMED
export RED GREEN YELLOW BLUE CYAN BOLD NC
export LAUNCH_SERVICES_CMD

# Export CLI paths array
export CURSOR_CLI_PATHS

# Export functions
export -f get_cursor_user_dirs validate_configuration display_configuration_summary
export -f detect_environment initialize_configuration

# Initialize configuration on load
if initialize_configuration; then
    readonly CONFIG_LOADED=true
    export CONFIG_LOADED
    
    if declare -f log_with_level >/dev/null 2>&1; then
        log_with_level "DEBUG" "Configuration module v$CONFIG_MODULE_VERSION loaded successfully"
    fi
else
    printf '[CONFIG ERROR] Failed to initialize configuration\n' >&2
    exit 1
fi 