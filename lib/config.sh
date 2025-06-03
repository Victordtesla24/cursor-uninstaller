#!/bin/bash

################################################################################
# Production Configuration for Cursor AI Editor Management Utility
# ENHANCED CONFIGURATION WITH VALIDATION AND ERROR HANDLING
################################################################################

# Strict error handling for configuration
set -euo pipefail

# Version and Build Information
export CURSOR_UNINSTALLER_VERSION="2.0.0"
declare CURSOR_UNINSTALLER_BUILD
CURSOR_UNINSTALLER_BUILD="$(date '+%Y%m%d%H%M%S')"
export CURSOR_UNINSTALLER_BUILD
export CURSOR_UNINSTALLER_CODENAME="PRODUCTION-GRADE"

# Error codes - Production Grade with descriptions
declare -A ERROR_CODES=(
    [ERR_GENERAL]=1
    [ERR_PERMISSION]=2  
    [ERR_NOT_FOUND]=3
    [ERR_SYSTEM_ERROR]=4
    [ERR_USER_CANCELLED]=5
    [ERR_NETWORK]=6
    [ERR_TIMEOUT]=7
    [ERR_VALIDATION]=8
    [ERR_DEPENDENCY]=9
    [ERR_CORRUPTION]=10
)

# Export error codes
for code in "${!ERROR_CODES[@]}"; do
    export "$code=${ERROR_CODES[$code]}"
done

# Configuration validation function
validate_config() {
    local validation_errors=0
    
    # Validate required system
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "[CONFIG ERROR] This utility requires macOS - Current OS: $OSTYPE" >&2
        ((validation_errors++))
    fi
    
    # Validate disk space for temp operations
    local available_space_gb
    available_space_gb=$(df -g "${TMPDIR:-/tmp}" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
    if [[ $available_space_gb -lt 1 ]]; then
        echo "[CONFIG WARNING] Low disk space in temp directory: ${available_space_gb}GB" >&2
    fi
    
    return $validation_errors
}

# Enhanced directory management with validation
setup_directories() {
    local dir_creation_errors=0
    
    # Directory Paths with fallback options
    export CONFIG_DIR="${CURSOR_UNINSTALLER_CONFIG_DIR:-$HOME/.cursor_management}"
    export LOG_DIR="${CURSOR_UNINSTALLER_LOG_DIR:-$CONFIG_DIR/logs}"
    export BACKUP_DIR="${CURSOR_UNINSTALLER_BACKUP_DIR:-$CONFIG_DIR/backups}"
    export TEMP_DIR="${CURSOR_UNINSTALLER_TEMP_DIR:-${TMPDIR:-/tmp}/cursor_management_$$}"

    # Create directories with proper permissions
    local dirs=("$CONFIG_DIR" "$LOG_DIR" "$BACKUP_DIR")
    for dir in "${dirs[@]}"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            echo "[CONFIG ERROR] Cannot create directory: $dir" >&2
            ((dir_creation_errors++))
        else
            chmod 755 "$dir" 2>/dev/null || true
        fi
    done
    
    # Handle temp directory specially
    if ! mkdir -p "$TEMP_DIR" 2>/dev/null; then
        echo "[CONFIG WARNING] Cannot create temp directory, using system temp" >&2
        export TEMP_DIR="${TMPDIR:-/tmp}"
    fi
    
    return $dir_creation_errors
}

# System Requirements with version checking
export MIN_MACOS_VERSION="10.15"
export MIN_MEMORY_GB=8
export MIN_DISK_SPACE_GB=10

# Enhanced system validation
validate_system_requirements() {
    local requirement_errors=0
    
    # Check macOS version
    if command -v sw_vers >/dev/null 2>&1; then
        local current_version
        current_version=$(sw_vers -productVersion)
        local major_version
        major_version=$(echo "$current_version" | cut -d. -f1)
        local minor_version
        minor_version=$(echo "$current_version" | cut -d. -f2)
        
        if [[ $major_version -lt 10 ]] || [[ $major_version -eq 10 && $minor_version -lt 15 ]]; then
            echo "[CONFIG ERROR] macOS version $current_version is below minimum $MIN_MACOS_VERSION" >&2
            ((requirement_errors++))
        fi
    fi
    
    # Check memory
    local total_memory_gb
    total_memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "0")
    if [[ $total_memory_gb -lt $MIN_MEMORY_GB ]]; then
        echo "[CONFIG WARNING] System memory ${total_memory_gb}GB is below recommended ${MIN_MEMORY_GB}GB" >&2
    fi
    
    # Check available disk space
    local available_space_gb
    available_space_gb=$(df -g / 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
    if [[ $available_space_gb -lt $MIN_DISK_SPACE_GB ]]; then
        echo "[CONFIG WARNING] Available disk space ${available_space_gb}GB is below recommended ${MIN_DISK_SPACE_GB}GB" >&2
    fi
    
    return $requirement_errors
}

# Required commands with availability checking
export REQUIRED_COMMANDS="defaults osascript sudo pgrep pkill find xargs"

validate_required_commands() {
    local missing_commands=()
    
    for cmd in $REQUIRED_COMMANDS; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        echo "[CONFIG ERROR] Missing required commands: ${missing_commands[*]}" >&2
        return ${#missing_commands[@]}
    fi
    
    return 0
}

# Cursor Application Configuration with validation
export CURSOR_APP_PATH="/Applications/Cursor.app"
export CURSOR_BUNDLE_ID="com.todesktop.230313mzl4w4u92"

# CLI paths with priority order
CURSOR_CLI_PATHS=(
    "/usr/local/bin/cursor" 
    "/opt/homebrew/bin/cursor"
    "/usr/bin/cursor"
    "$HOME/.local/bin/cursor"
)
export CURSOR_CLI_PATHS

# Enhanced User Data Directories with dynamic user detection
get_cursor_user_dirs() {
    local user_home="${1:-$HOME}"
    
    local dirs=(
        "$user_home/Library/Application Support/Cursor"
        "$user_home/Library/Caches/Cursor"
        "$user_home/Library/Caches/com.todesktop.230313mzl4w4u92"
        "$user_home/Library/HTTPStorages/com.todesktop.230313mzl4w4u92"
        "$user_home/Library/HTTPStorages/com.todesktop.230313mzl4w4u92.binarycookies"
        "$user_home/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        "$user_home/Library/Preferences/ByHost/com.todesktop.230313mzl4w4u92.*.plist"
        "$user_home/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState"
        "$user_home/Library/Logs/Cursor"
        "$user_home/.cursor"
        "$user_home/.vscode-cursor"
    )
    
    printf '%s\n' "${dirs[@]}"
}

# System Integration Paths with validation
export LAUNCH_SERVICES_CMD="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

validate_system_paths() {
    local path_errors=0
    
    if [[ ! -x "$LAUNCH_SERVICES_CMD" ]]; then
        echo "[CONFIG WARNING] Launch Services command not found or not executable" >&2
        ((path_errors++))
    fi
    
    return $path_errors
}

# Color Constants with theme support
setup_color_scheme() {
    # Support for NO_COLOR environment variable
    if [[ -n "${NO_COLOR:-}" ]] || [[ "${TERM:-}" == "dumb" ]]; then
        export RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
    else
        export RED='\033[0;31m'
        export GREEN='\033[0;32m'  
        export YELLOW='\033[1;33m'
        export BLUE='\033[0;34m'
        export CYAN='\033[0;36m'
        export BOLD='\033[1m'
        export NC='\033[0m'
    fi
}

# Production Optimization Settings with adaptive configuration
setup_optimization_config() {
    # Get system memory for dynamic configuration
    local total_memory_gb
    total_memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "8")
    
    # Adaptive memory limits
    if [[ $total_memory_gb -ge 32 ]]; then
        export AI_MEMORY_LIMIT_GB=16
        export AI_CONTEXT_LENGTH=16384
    elif [[ $total_memory_gb -ge 16 ]]; then
        export AI_MEMORY_LIMIT_GB=8
        export AI_CONTEXT_LENGTH=8192
    else
        export AI_MEMORY_LIMIT_GB=4
        export AI_CONTEXT_LENGTH=4096
    fi
    
    export AI_TEMPERATURE=0.05
    export AI_MAX_TOKENS=2048
    export FILE_DESCRIPTOR_LIMIT=65536
}

# Timeout Settings with environment-based configuration
setup_timeout_config() {
    # Adjust timeouts based on system performance
    local cpu_cores
    cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "1")
    
    if [[ $cpu_cores -ge 8 ]]; then
        export OPERATION_TIMEOUT=180
        export SUDO_TIMEOUT=45
        export NETWORK_TIMEOUT=20
    elif [[ $cpu_cores -ge 4 ]]; then
        export OPERATION_TIMEOUT=300
        export SUDO_TIMEOUT=60
        export NETWORK_TIMEOUT=30
    else
        export OPERATION_TIMEOUT=600
        export SUDO_TIMEOUT=90
        export NETWORK_TIMEOUT=45
    fi
}

# Logging configuration
setup_logging_config() {
    export LOG_LEVEL="${CURSOR_UNINSTALLER_LOG_LEVEL:-INFO}"
    export LOG_FORMAT="${CURSOR_UNINSTALLER_LOG_FORMAT:-[%Y-%m-%d %H:%M:%S] [%LEVEL%] %MESSAGE%}"
    export LOG_MAX_SIZE="${CURSOR_UNINSTALLER_LOG_MAX_SIZE:-10M}"
    export LOG_ROTATE="${CURSOR_UNINSTALLER_LOG_ROTATE:-5}"
}

# Main configuration initialization
init_config() {
    local init_errors=0
    
    # Run all configuration steps
    validate_config || ((init_errors++))
    setup_directories || ((init_errors++))
    validate_system_requirements || true  # Don't fail on warnings
    validate_required_commands || ((init_errors++))
    validate_system_paths || true  # Don't fail on warnings
    setup_color_scheme
    setup_optimization_config
    setup_timeout_config
    setup_logging_config
    
    if [[ $init_errors -eq 0 ]]; then
        export CONFIG_LOADED=true
        export CONFIG_STATUS="READY"
    else
        export CONFIG_LOADED=false
        export CONFIG_STATUS="DEGRADED"
        echo "[CONFIG ERROR] Configuration initialization failed with $init_errors errors" >&2
    fi
    
    return $init_errors
}

# Initialize configuration when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced, initialize configuration
    init_config
else
    # Being executed directly, show configuration status
    echo "Cursor Uninstaller Configuration v${CURSOR_UNINSTALLER_VERSION}"
    echo "Build: ${CURSOR_UNINSTALLER_BUILD}"
    echo "Codename: ${CURSOR_UNINSTALLER_CODENAME}"
    init_config
    echo "Configuration Status: ${CONFIG_STATUS:-UNKNOWN}"
fi 