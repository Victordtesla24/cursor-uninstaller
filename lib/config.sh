#!/bin/bash

################################################################################
# Configuration Module - Option 1: Functional Domain Separation
# Contains all constants, settings, and environment variables
################################################################################

# Prevent multiple loading
if [[ "${CONFIG_LOADED:-}" == "true" ]]; then
    return 0
fi

################################################################################
# Core Application Constants
################################################################################

# Version and metadata
readonly SCRIPT_VERSION="1.2.0"
readonly SCRIPT_NAME="Cursor Uninstaller"
readonly AUTHOR="Enhanced Modular Version"

# Error codes
readonly ERR_SUCCESS=0
readonly ERR_GENERAL=1
readonly ERR_INVALID_ARGS=2
readonly ERR_USER_CANCEL=3
readonly ERR_PERMISSION_DENIED=4
readonly ERR_FILE_NOT_FOUND=5
readonly ERR_NETWORK_ERROR=6
readonly ERR_VALIDATION_FAILED=7
readonly ERR_BACKUP_FAILED=8
readonly ERR_RESTORE_FAILED=9
readonly ERR_INSTALLATION_FAILED=10

# Color definitions for output formatting
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly UNDERLINE='\033[4m'
readonly NC='\033[0m' # No Color

################################################################################
# Cursor Application Paths and Directories
################################################################################

# Set Cursor-related directories and files
readonly CURSOR_CWD="/Users/Shared/cursor"
readonly CURSOR_APP="/Applications/Cursor.app"
readonly CURSOR_SUPPORT="${HOME}/Library/Application Support/Cursor"
readonly CURSOR_CACHE="${HOME}/Library/Caches/Cursor"
readonly CURSOR_PREFERENCES="${HOME}/Library/Preferences/com.cursor.Cursor.plist"
readonly CURSOR_SAVED_STATE="${HOME}/Library/Saved Application State/com.cursor.Cursor.savedState"
readonly CURSOR_LOGS="${HOME}/Library/Logs/Cursor"
readonly CURSOR_WEBSTORAGE="${HOME}/Library/WebKit/com.cursor.Cursor"
readonly CURSOR_USER_DEFAULTS="com.cursor.Cursor"

# Additional system paths
readonly SYSTEM_LAUNCHD_USER="${HOME}/Library/LaunchAgents"
readonly SYSTEM_LAUNCHD_SYSTEM="/Library/LaunchDaemons"
readonly SYSTEM_APPLICATIONS="/Applications"
readonly SYSTEM_FRAMEWORKS="/Library/Frameworks"

################################################################################
# Script Configuration Paths
################################################################################

# Configuration and data directories
readonly CONFIG_DIR="${HOME}/.cursor-uninstaller"
readonly CONFIG_FILE="${CONFIG_DIR}/config.json"
readonly BACKUP_DIR="${CONFIG_DIR}/backups"
readonly LOG_DIR="${CONFIG_DIR}/logs"
readonly TEMP_DIR="${CONFIG_DIR}/temp"
readonly METRICS_DIR="${CONFIG_DIR}/metrics"

# Log files
readonly LOG_FILE="${LOG_DIR}/uninstaller.log"
readonly ERROR_LOG="${LOG_DIR}/error.log"
readonly PERFORMANCE_LOG="${LOG_DIR}/performance.log"
readonly BACKUP_LOG="${LOG_DIR}/backup.log"

################################################################################
# Performance and Optimization Settings
################################################################################

# Memory and performance constants
readonly MIN_MEMORY_GB=8
readonly RECOMMENDED_MEMORY_GB=16
readonly MAX_LOG_SIZE_MB=100
readonly LOG_RETENTION_DAYS=30
readonly BACKUP_RETENTION_DAYS=90

# Optimization settings
readonly ENABLE_METAL_PERFORMANCE="true"
readonly ENABLE_HARDWARE_ACCELERATION="true"
readonly ENABLE_GPU_ACCELERATION="true"
readonly OPTIMAL_THREAD_COUNT=4

################################################################################
# Network and Download Settings
################################################################################

# Download and installation settings
readonly CURSOR_DOWNLOAD_URL="https://downloader.cursor.sh/builds/241219-vdmh2z6/cursor-0.44.9-x64.dmg"
readonly DOWNLOAD_TIMEOUT=300
readonly MAX_DOWNLOAD_RETRIES=3
readonly CHECKSUM_VALIDATION="true"

################################################################################
# Testing and Validation Settings
################################################################################

# Test configuration
readonly TEST_TIMEOUT=30
readonly ENABLE_EXTENSIVE_TESTS="false"
readonly ENABLE_PERFORMANCE_TESTS="true"
readonly ENABLE_INTEGRATION_TESTS="true"

################################################################################
# Global Variables (Initialized with defaults)
################################################################################

# Operation mode flags
DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"
QUIET="${QUIET:-false}"
FORCE="${FORCE:-false}"
SKIP_CONFIRMATION="${SKIP_CONFIRMATION:-false}"

# Progress tracking
CURRENT_TASK=""
CURRENT_PROGRESS=0
TOTAL_TASKS=0

# Sudo management
SUDO_REFRESH_PID=""

# Temporary file tracking
TEMP_FILES=()

################################################################################
# Environment Detection and Setup
################################################################################

# Detect macOS version and architecture
detect_system_info() {
    MACOS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
    MACOS_BUILD=$(sw_vers -buildVersion 2>/dev/null || echo "unknown")
    HARDWARE_ARCH=$(uname -m 2>/dev/null || echo "unknown")

    # Determine if running on Apple Silicon
    if [[ "$HARDWARE_ARCH" == "arm64" ]]; then
        IS_APPLE_SILICON="true"
    else
        IS_APPLE_SILICON="false"
    fi

    # Set optimization flags based on hardware
    if [[ "$IS_APPLE_SILICON" == "true" ]]; then
        ENABLE_NEURAL_ENGINE="true"
        OPTIMAL_MEMORY_PRESSURE="medium"
    else
        ENABLE_NEURAL_ENGINE="false"
        OPTIMAL_MEMORY_PRESSURE="low"
    fi

    # Export for use in other modules
    export MACOS_VERSION MACOS_BUILD HARDWARE_ARCH IS_APPLE_SILICON
    export ENABLE_NEURAL_ENGINE OPTIMAL_MEMORY_PRESSURE
}

# Initialize system detection
detect_system_info

################################################################################
# Configuration File Management
################################################################################

# Default configuration structure
create_default_config() {
    cat > "$CONFIG_FILE" << EOF
{
    "version": "$SCRIPT_VERSION",
    "created": "$(date -Iseconds)",
    "settings": {
        "backup_retention_days": $BACKUP_RETENTION_DAYS,
        "log_retention_days": $LOG_RETENTION_DAYS,
        "enable_auto_backup": true,
        "enable_performance_monitoring": true,
        "enable_detailed_logging": false,
        "optimization": {
            "enable_metal_performance": $ENABLE_METAL_PERFORMANCE,
            "enable_hardware_acceleration": $ENABLE_HARDWARE_ACCELERATION,
            "enable_gpu_acceleration": $ENABLE_GPU_ACCELERATION,
            "optimal_thread_count": $OPTIMAL_THREAD_COUNT
        },
        "paths": {
            "backup_directory": "$BACKUP_DIR",
            "log_directory": "$LOG_DIR",
            "temp_directory": "$TEMP_DIR"
        }
    },
    "system": {
        "macos_version": "$MACOS_VERSION",
        "hardware_arch": "$HARDWARE_ARCH",
        "is_apple_silicon": $IS_APPLE_SILICON
    }
}
EOF
}

# Load configuration from file
load_configuration() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        mkdir -p "$CONFIG_DIR" "$BACKUP_DIR" "$LOG_DIR" "$TEMP_DIR" "$METRICS_DIR"
        create_default_config
        echo "Created default configuration at: $CONFIG_FILE"
    fi

    # Load settings from JSON file if jq is available
    if command -v jq >/dev/null 2>&1; then
        # Override defaults with file settings (only if not readonly)
        local backup_retention
        local log_retention
        backup_retention=$(jq -r '.settings.backup_retention_days // 90' "$CONFIG_FILE" 2>/dev/null || echo "90")
        log_retention=$(jq -r '.settings.log_retention_days // 30' "$CONFIG_FILE" 2>/dev/null || echo "30")

        # Note: Cannot override readonly variables, using defaults
        # BACKUP_RETENTION_DAYS and LOG_RETENTION_DAYS are readonly
    fi
}

################################################################################
# Directory Structure Initialization
################################################################################

# Initialize all required directories
initialize_directories() {
    local dirs=(
        "$CONFIG_DIR"
        "$BACKUP_DIR"
        "$LOG_DIR"
        "$TEMP_DIR"
        "$METRICS_DIR"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" || {
                echo "Error: Failed to create directory: $dir" >&2
                return 1
            }
        fi
    done

    # Set proper permissions
    chmod 755 "$CONFIG_DIR" "$BACKUP_DIR" "$LOG_DIR" "$TEMP_DIR" "$METRICS_DIR" 2>/dev/null || true

    return 0
}

################################################################################
# Cleanup Functions
################################################################################

# Cleanup temporary files on exit
cleanup_temp_files() {
    # Check if TEMP_FILES array exists and has elements
    if [[ -n "${TEMP_FILES:-}" ]] && [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
        for temp_file in "${TEMP_FILES[@]}"; do
            [[ -f "$temp_file" ]] && rm -f "$temp_file" 2>/dev/null || true
        done
    fi
    TEMP_FILES=()
}

# Register cleanup trap
trap cleanup_temp_files EXIT

################################################################################
# Module Initialization
################################################################################

# Initialize configuration system
initialize_config() {
    # Create directories
    initialize_directories || return 1

    # Load configuration
    load_configuration || return 1

    # Mark as loaded
    CONFIG_LOADED="true"

    return 0
}

# Auto-initialize if not in test mode
if [[ "${BATS_TEST_SOURCED:-}" != "1" ]]; then
    initialize_config
fi

################################################################################
# Export Important Variables
################################################################################

# Export configuration for other modules
export CONFIG_LOADED SCRIPT_VERSION SCRIPT_NAME
export CONFIG_DIR BACKUP_DIR LOG_DIR TEMP_DIR METRICS_DIR
export LOG_FILE ERROR_LOG PERFORMANCE_LOG BACKUP_LOG
export DRY_RUN VERBOSE QUIET FORCE SKIP_CONFIRMATION
