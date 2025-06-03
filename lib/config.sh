#!/bin/bash

################################################################################
# Production Configuration for Cursor AI Editor Management Utility
# REFACTORED: Enhanced security, validation, and maintainability
################################################################################

# Secure error handling
set -euo pipefail
readonly IFS=$' \t\n'

# Version and Build Information
readonly CURSOR_UNINSTALLER_VERSION="3.0.0"
declare CURSOR_UNINSTALLER_BUILD
CURSOR_UNINSTALLER_BUILD="$(date '+%Y%m%d%H%M%S')"
readonly CURSOR_UNINSTALLER_BUILD
readonly CURSOR_UNINSTALLER_CODENAME="REFACTORED-PRODUCTION"

# Export immutable constants
export CURSOR_UNINSTALLER_VERSION CURSOR_UNINSTALLER_BUILD CURSOR_UNINSTALLER_CODENAME

# Error codes with proper associative array
declare -r -A ERROR_CODES=(
    [SUCCESS]=0
    [GENERAL_ERROR]=1
    [PERMISSION_DENIED]=2  
    [NOT_FOUND]=3
    [SYSTEM_ERROR]=4
    [USER_CANCELLED]=5
    [NETWORK_ERROR]=6
    [TIMEOUT_ERROR]=7
    [VALIDATION_ERROR]=8
    [DEPENDENCY_ERROR]=9
    [CORRUPTION_ERROR]=10
)

# Export error codes securely
for code in "${!ERROR_CODES[@]}"; do
    declare -r "ERR_${code}=${ERROR_CODES[$code]}"
    export "ERR_${code}"
done

# Secure path handling
_normalize_path() {
    local path="$1"
    # Remove trailing slashes, resolve relative paths safely
    path="${path%/}"
    printf '%s' "$(cd "$(dirname "$path")" 2>/dev/null && pwd)/$(basename "$path")" 2>/dev/null || printf '%s' "$path"
}

# Enhanced security validation
_validate_security_context() {
    local -i validation_errors=0
    
    # Check for suspicious environment variables
    local -a suspicious_vars=("LD_PRELOAD" "DYLD_INSERT_LIBRARIES" "PROMPT_COMMAND")
    for var in "${suspicious_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            printf '[SECURITY WARNING] Suspicious environment variable detected: %s\n' "$var" >&2
            ((validation_errors++))
        fi
    done
    
    # Validate PATH for security
    if [[ "$PATH" =~ (^|:)\.(:|$) ]]; then
        printf '[SECURITY ERROR] Dangerous PATH detected (contains current directory)\n' >&2
        ((validation_errors++))
    fi
    
    return $validation_errors
}

# Enhanced system validation with security checks
validate_system_requirements() {
    local -i validation_errors=0
    
    # Security validation first
    _validate_security_context || ((validation_errors++))
    
    # Platform validation
    if [[ "$OSTYPE" != "darwin"* ]]; then
        printf '[CONFIG ERROR] This utility requires macOS - Current OS: %s\n' "$OSTYPE" >&2
        ((validation_errors++))
    fi
    
    # Memory validation with safer arithmetic
    local -i available_space_gb
    if available_space_gb=$(df -g "${TMPDIR:-/tmp}" 2>/dev/null | awk 'NR==2 {print int($4)}'); then
        if (( available_space_gb < 1 )); then
            printf '[CONFIG WARNING] Low disk space in temp directory: %dGB\n' "$available_space_gb" >&2
        fi
    else
        printf '[CONFIG WARNING] Cannot determine disk space\n' >&2
    fi
    
    return $validation_errors
}

# Secure directory setup with proper permissions
setup_directories() {
    local -i dir_creation_errors=0
    
    # Define directories with secure defaults
    local -r base_config_dir="${CURSOR_UNINSTALLER_CONFIG_DIR:-$HOME/.cursor_management}"
    
    # Validate base directory path security
    if [[ ! "$base_config_dir" =~ ^/[^[:space:]]*$ ]]; then
        printf '[CONFIG ERROR] Invalid configuration directory path\n' >&2
        return 1
    fi
    
    # Set normalized paths
    declare CONFIG_DIR LOG_DIR BACKUP_DIR TEMP_DIR
    CONFIG_DIR="$(_normalize_path "$base_config_dir")"
    readonly CONFIG_DIR
    LOG_DIR="$(_normalize_path "${CURSOR_UNINSTALLER_LOG_DIR:-$CONFIG_DIR/logs}")"
    readonly LOG_DIR
    BACKUP_DIR="$(_normalize_path "${CURSOR_UNINSTALLER_BACKUP_DIR:-$CONFIG_DIR/backups}")"
    readonly BACKUP_DIR
    TEMP_DIR="$(_normalize_path "${CURSOR_UNINSTALLER_TEMP_DIR:-${TMPDIR:-/tmp}/cursor_management_$$}")"
    readonly TEMP_DIR
    
    # Export with readonly protection
    export CONFIG_DIR LOG_DIR BACKUP_DIR TEMP_DIR
    readonly CONFIG_DIR LOG_DIR BACKUP_DIR TEMP_DIR
    
    # Create directories with secure permissions
    local -a directories=("$CONFIG_DIR" "$LOG_DIR" "$BACKUP_DIR")
    local dir
    
    for dir in "${directories[@]}"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            printf '[CONFIG ERROR] Cannot create directory: %s\n' "$dir" >&2
            ((dir_creation_errors++))
        else
            # Set secure permissions (owner only)
            if ! chmod 700 "$dir" 2>/dev/null; then
                printf '[CONFIG WARNING] Cannot set secure permissions on: %s\n' "$dir" >&2
            fi
        fi
    done
    
    # Handle temp directory specially with unique naming
    if ! mkdir -p "$TEMP_DIR" 2>/dev/null; then
        printf '[CONFIG WARNING] Cannot create temp directory, using system temp\n' >&2
        readonly TEMP_DIR="${TMPDIR:-/tmp}"
        export TEMP_DIR
    else
        chmod 700 "$TEMP_DIR" 2>/dev/null || true
    fi
    
    return $dir_creation_errors
}

# System requirements with precise version checking
readonly MIN_MACOS_VERSION="10.15"
readonly MIN_MEMORY_GB=8
readonly MIN_DISK_SPACE_GB=10

# Enhanced system validation with detailed compatibility checks
validate_system_compatibility() {
    local -i requirement_errors=0
    
    # macOS version validation with proper comparison
    if command -v sw_vers >/dev/null 2>&1; then
        local current_version major_version minor_version
        current_version=$(sw_vers -productVersion 2>/dev/null || echo "0.0")
        
        # Parse version components safely
        if [[ "$current_version" =~ ^([0-9]+)\.([0-9]+) ]]; then
            major_version="${BASH_REMATCH[1]}"
            minor_version="${BASH_REMATCH[2]}"
            
            # Version comparison logic
            if (( major_version < 10 )) || (( major_version == 10 && minor_version < 15 )); then
                printf '[CONFIG ERROR] macOS version %s is below minimum %s\n' "$current_version" "$MIN_MACOS_VERSION" >&2
                ((requirement_errors++))
            fi
        else
            printf '[CONFIG WARNING] Cannot parse macOS version: %s\n' "$current_version" >&2
        fi
    else
        printf '[CONFIG ERROR] Cannot determine macOS version\n' >&2
        ((requirement_errors++))
    fi
    
    # Memory validation with error handling
    local -i total_memory_gb
    if total_memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}'); then
        if (( total_memory_gb < MIN_MEMORY_GB )); then
            printf '[CONFIG WARNING] System memory %dGB is below recommended %dGB\n' "$total_memory_gb" "$MIN_MEMORY_GB" >&2
        fi
    else
        printf '[CONFIG WARNING] Cannot determine system memory\n' >&2
    fi
    
    # Disk space validation
    local -i available_space_gb
    if available_space_gb=$(df -g / 2>/dev/null | awk 'NR==2 {print int($4)}'); then
        if (( available_space_gb < MIN_DISK_SPACE_GB )); then
            printf '[CONFIG WARNING] Available disk space %dGB is below recommended %dGB\n' "$available_space_gb" "$MIN_DISK_SPACE_GB" >&2
        fi
    else
        printf '[CONFIG WARNING] Cannot determine disk space\n' >&2
    fi
    
    return $requirement_errors
}

# Required commands with comprehensive validation
readonly REQUIRED_COMMANDS="defaults osascript sudo pgrep pkill find xargs"

validate_required_commands() {
    local -a missing_commands=()
    local cmd
    
    # Check each command individually
    for cmd in $REQUIRED_COMMANDS; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if (( ${#missing_commands[@]} > 0 )); then
        printf '[CONFIG ERROR] Missing required commands: %s\n' "${missing_commands[*]}" >&2
        return ${#missing_commands[@]}
    fi
    
    return 0
}

# Cursor application configuration with validation
readonly CURSOR_APP_PATH="/Applications/Cursor.app"
readonly CURSOR_BUNDLE_ID="com.todesktop.230313mzl4w4u92"
export CURSOR_APP_PATH CURSOR_BUNDLE_ID

# CLI paths with priority order and validation
readonly -a CURSOR_CLI_PATHS=(
    "/usr/local/bin/cursor" 
    "/opt/homebrew/bin/cursor"
    "/usr/bin/cursor"
    "$HOME/.local/bin/cursor"
)
export CURSOR_CLI_PATHS

# Enhanced user data directory function with validation
get_cursor_user_dirs() {
    local user_home="${1:-$HOME}"
    
    # Validate user home directory
    if [[ ! -d "$user_home" ]]; then
        printf '[ERROR] Invalid user home directory: %s\n' "$user_home" >&2
        return 1
    fi
    
    local -a dirs=(
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

# System integration paths with validation
readonly LAUNCH_SERVICES_CMD="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

validate_system_paths() {
    local -i path_errors=0
    
    if [[ ! -x "$LAUNCH_SERVICES_CMD" ]]; then
        printf '[CONFIG WARNING] Launch Services command not found or not executable\n' >&2
        ((path_errors++))
    fi
    
    return $path_errors
}

# Enhanced color scheme with better fallback handling
setup_color_scheme() {
    # Check for color support and NO_COLOR compliance
    if [[ -n "${NO_COLOR:-}" ]] || [[ "${TERM:-}" == "dumb" ]] || [[ ! -t 1 ]]; then
        # No color mode
        readonly RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
    else
        # Color mode with validation
        if command -v tput >/dev/null 2>&1 && (( $(tput colors 2>/dev/null || echo 0) >= 8 )); then
            readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
            readonly BLUE='\033[0;34m' CYAN='\033[0;36m' BOLD='\033[1m' NC='\033[0m'
        else
            readonly RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
        fi
    fi
    
    # Export with readonly protection
    export RED GREEN YELLOW BLUE CYAN BOLD NC
}

# Performance configuration with adaptive settings
setup_optimization_config() {
    local -i total_memory_gb
    
    # Get system memory with error handling
    if total_memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}'); then
        # Adaptive configuration based on available memory
        if (( total_memory_gb >= 32 )); then
            readonly AI_MEMORY_LIMIT_GB=16 AI_CONTEXT_LENGTH=16384
        elif (( total_memory_gb >= 16 )); then
            readonly AI_MEMORY_LIMIT_GB=8 AI_CONTEXT_LENGTH=8192
        else
            readonly AI_MEMORY_LIMIT_GB=4 AI_CONTEXT_LENGTH=4096
        fi
    else
        # Conservative defaults
        readonly AI_MEMORY_LIMIT_GB=4 AI_CONTEXT_LENGTH=4096
    fi
    
    # Performance constants
    readonly AI_TEMPERATURE=0.05 AI_MAX_TOKENS=2048 FILE_DESCRIPTOR_LIMIT=65536
    
    # Export configuration
    export AI_MEMORY_LIMIT_GB AI_CONTEXT_LENGTH AI_TEMPERATURE AI_MAX_TOKENS FILE_DESCRIPTOR_LIMIT
}

# Timeout configuration with adaptive settings
setup_timeout_config() {
    local -i cpu_cores
    
    # Get CPU core count with error handling
    if cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null); then
        # Adaptive timeouts based on CPU performance
        if (( cpu_cores >= 8 )); then
            readonly OPERATION_TIMEOUT=180 SUDO_TIMEOUT=45 NETWORK_TIMEOUT=20
        elif (( cpu_cores >= 4 )); then
            readonly OPERATION_TIMEOUT=300 SUDO_TIMEOUT=60 NETWORK_TIMEOUT=30
        else
            readonly OPERATION_TIMEOUT=600 SUDO_TIMEOUT=90 NETWORK_TIMEOUT=45
        fi
    else
        # Conservative defaults
        readonly OPERATION_TIMEOUT=600 SUDO_TIMEOUT=90 NETWORK_TIMEOUT=45
    fi
    
    # Export timeouts
    export OPERATION_TIMEOUT SUDO_TIMEOUT NETWORK_TIMEOUT
}

# Enhanced logging configuration
setup_logging_config() {
    readonly LOG_LEVEL="${CURSOR_UNINSTALLER_LOG_LEVEL:-INFO}"
    readonly LOG_FORMAT="${CURSOR_UNINSTALLER_LOG_FORMAT:-[%Y-%m-%d %H:%M:%S] [%LEVEL%] %MESSAGE%}"
    readonly LOG_MAX_SIZE="${CURSOR_UNINSTALLER_LOG_MAX_SIZE:-10M}"
    readonly LOG_ROTATE="${CURSOR_UNINSTALLER_LOG_ROTATE:-5}"
    
    export LOG_LEVEL LOG_FORMAT LOG_MAX_SIZE LOG_ROTATE
}

# Main configuration initialization with comprehensive error handling
init_config() {
    local -i init_errors=0
    
    # Run configuration steps with proper error accumulation
    validate_system_requirements || ((init_errors++))
    setup_directories || ((init_errors++))
    validate_system_compatibility || true  # Don't fail on warnings
    validate_required_commands || ((init_errors++))
    validate_system_paths || true  # Don't fail on warnings
    
    # Setup configurations (these should not fail)
    setup_color_scheme
    setup_optimization_config
    setup_timeout_config
    setup_logging_config
    
    # Set final status
    if (( init_errors == 0 )); then
        readonly CONFIG_LOADED=true CONFIG_STATUS="READY"
    else
        readonly CONFIG_LOADED=false CONFIG_STATUS="DEGRADED"
        printf '[CONFIG ERROR] Configuration initialization failed with %d errors\n' "$init_errors" >&2
    fi
    
    export CONFIG_LOADED CONFIG_STATUS
    
    return $init_errors
}

# Initialize configuration when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced - initialize configuration
    init_config
else
    # Being executed directly - show status
    printf 'Cursor Uninstaller Configuration v%s\n' "$CURSOR_UNINSTALLER_VERSION"
    printf 'Build: %s\n' "$CURSOR_UNINSTALLER_BUILD"
    printf 'Codename: %s\n' "$CURSOR_UNINSTALLER_CODENAME"
    init_config
    printf 'Configuration Status: %s\n' "${CONFIG_STATUS:-UNKNOWN}"
fi 