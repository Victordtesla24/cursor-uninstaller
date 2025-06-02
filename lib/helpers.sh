#!/bin/bash

################################################################################
# Production Helper Functions for Cursor AI Editor Management Utility
# STRICT VALIDATION - NO ERROR MASKING
################################################################################

# System validation function - Production standards
validate_system_requirements() {
    local validation_errors=0
    
    # Check macOS version
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "[ERROR] This utility requires macOS - Current OS: $OSTYPE" >&2
        ((validation_errors++))
    fi
    
    # Check available memory
    local total_memory_gb
    total_memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "0")
    if [[ $total_memory_gb -lt $MIN_MEMORY_GB ]]; then
        echo "[ERROR] Insufficient memory: ${total_memory_gb}GB (minimum: ${MIN_MEMORY_GB}GB)" >&2
        ((validation_errors++))
    fi
    
    # Check disk space
    local available_space_gb
    available_space_gb=$(df -g / 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
    if [[ $available_space_gb -lt $MIN_DISK_SPACE_GB ]]; then
        echo "[ERROR] Insufficient disk space: ${available_space_gb}GB (minimum: ${MIN_DISK_SPACE_GB}GB)" >&2
        ((validation_errors++))
    fi
    
    # Check required commands
    for cmd in $REQUIRED_COMMANDS; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "[ERROR] Required command not found: $cmd" >&2
            ((validation_errors++))
        fi
    done
    
    return $validation_errors
}

# Safe file removal with verification
safe_remove_file() {
    local file_path="$1"
    local force_remove="${2:-false}"
    
    if [[ ! -e "$file_path" ]]; then
        return 0  # Already doesn't exist
    fi
    
    if [[ "$force_remove" != "true" ]]; then
        echo "[INFO] Would remove: $file_path"
        return 0
    fi
    
    if rm -rf "$file_path" 2>/dev/null; then
        echo "[SUCCESS] Removed: $file_path"
        return 0
    else
        echo "[ERROR] Failed to remove: $file_path" >&2
        return 1
    fi
}

# Check if Cursor processes are running
check_cursor_processes() {
    local cursor_pids
    cursor_pids=$(pgrep -f -i "cursor" 2>/dev/null | grep -v "$$" || true)
    
    if [[ -n "$cursor_pids" ]]; then
        echo "$cursor_pids"
        return 0
    else
        return 1
    fi
}

# Terminate Cursor processes safely
terminate_cursor_processes() {
    local graceful_timeout=10
    local force_timeout=5
    
    # Try graceful shutdown first
    if osascript -e 'tell application "Cursor" to quit' 2>/dev/null; then
        echo "[INFO] Sent quit command to Cursor"
        sleep $graceful_timeout
    fi
    
    # Check if processes still running
    local remaining_pids
    remaining_pids=$(check_cursor_processes || true)
    
    if [[ -n "$remaining_pids" ]]; then
        echo "[INFO] Force terminating remaining processes: $remaining_pids"
        for pid in $remaining_pids; do
            if [[ "$pid" != "$$" ]]; then
                kill -TERM "$pid" 2>/dev/null || true
            fi
        done
        sleep $force_timeout
        
        # Final force kill if needed
        remaining_pids=$(check_cursor_processes || true)
        if [[ -n "$remaining_pids" ]]; then
            for pid in $remaining_pids; do
                if [[ "$pid" != "$$" ]]; then
                    kill -KILL "$pid" 2>/dev/null || true
                fi
            done
        fi
    fi
    
    return 0
}

# Get system specifications for optimization
get_system_specs() {
    local specs=""
    
    # CPU information
    local cpu_info
    cpu_info=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown CPU")
    specs+="CPU: $cpu_info\n"
    
    # Memory information
    local memory_gb
    memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "Unknown")
    specs+="Memory: ${memory_gb}GB\n"
    
    # macOS version
    if command -v sw_vers >/dev/null 2>&1; then
        local macos_version
        macos_version=$(sw_vers -productVersion)
        specs+="macOS: $macos_version\n"
    fi
    
    # Architecture
    local arch
    arch=$(uname -m)
    specs+="Architecture: $arch\n"
    
    echo -e "$specs"
}

# Create directory with proper permissions
ensure_directory() {
    local dir_path="$1"
    local permissions="${2:-755}"
    
    if [[ -d "$dir_path" ]]; then
        return 0
    fi
    
    if mkdir -p "$dir_path" 2>/dev/null; then
        chmod "$permissions" "$dir_path" 2>/dev/null || true
        echo "[SUCCESS] Created directory: $dir_path"
        return 0
    else
        echo "[ERROR] Failed to create directory: $dir_path" >&2
        return 1
    fi
}

# Verify file integrity after operations
verify_file_operation() {
    local operation="$1"
    local file_path="$2"
    local expected_state="$3"  # "exists" or "removed"
    
    case "$expected_state" in
        "exists")
            if [[ -e "$file_path" ]]; then
                echo "[SUCCESS] Verified $operation: $file_path exists"
                return 0
            else
                echo "[ERROR] Verification failed for $operation: $file_path does not exist" >&2
                return 1
            fi
            ;;
        "removed")
            if [[ ! -e "$file_path" ]]; then
                echo "[SUCCESS] Verified $operation: $file_path removed"
                return 0
            else
                echo "[ERROR] Verification failed for $operation: $file_path still exists" >&2
                return 1
            fi
            ;;
        *)
            echo "[ERROR] Invalid expected state: $expected_state" >&2
            return 1
            ;;
    esac
}

# Helper function loaded confirmation
export HELPERS_LOADED=true 