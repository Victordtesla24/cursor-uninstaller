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

# Memory and performance constants - Set defaults first, will be made readonly later
LOG_RETENTION_DAYS=30
BACKUP_RETENTION_DAYS=90

# Optimization settings (these remain readonly as they're not configurable)
readonly ENABLE_METAL_PERFORMANCE="true"
readonly ENABLE_HARDWARE_ACCELERATION="true"
readonly ENABLE_GPU_ACCELERATION="true"
readonly OPTIMAL_THREAD_COUNT=4

################################################################################
# Global Variables (Initialized with defaults)
################################################################################

# Operation mode flags
VERBOSE="${VERBOSE:-false}"
QUIET="${QUIET:-false}"
FORCE="${FORCE:-false}"
SKIP_CONFIRMATION="${SKIP_CONFIRMATION:-false}"

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

    # Load settings from JSON file if jq is available to override defaults
    if command -v jq >/dev/null 2>&1; then
        # Load values from config file, falling back to current defaults
        BACKUP_RETENTION_DAYS=$(jq -r '.settings.backup_retention_days // '"$BACKUP_RETENTION_DAYS" "$CONFIG_FILE" 2>/dev/null || echo "$BACKUP_RETENTION_DAYS")
        LOG_RETENTION_DAYS=$(jq -r '.settings.log_retention_days // '"$LOG_RETENTION_DAYS" "$CONFIG_FILE" 2>/dev/null || echo "$LOG_RETENTION_DAYS")
    fi
    
    # Now make the loaded values readonly to prevent further modification
    readonly LOG_RETENTION_DAYS
    readonly BACKUP_RETENTION_DAYS
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
            if [[ -f "$temp_file" ]]; then
                rm -f "$temp_file" 2>/dev/null || true
            fi
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
export VERBOSE QUIET FORCE SKIP_CONFIRMATION
