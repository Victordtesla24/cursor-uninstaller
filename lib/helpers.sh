#!/bin/bash

################################################################################
# Production Helper Functions for Cursor AI Editor Management Utility
# ENHANCED UTILITIES WITH ROBUST ERROR HANDLING AND PROCESS MANAGEMENT
################################################################################

# Strict error handling
set -euo pipefail

# Enhanced logging with levels
log_with_level() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Color coding based on level
    local color=""
    case "$level" in
        "ERROR") color="$RED" ;;
        "WARNING") color="$YELLOW" ;;
        "SUCCESS") color="$GREEN" ;;
        "INFO") color="$CYAN" ;;
        "DEBUG") color="$BLUE" ;;
        *) color="$NC" ;;
    esac
    
    # Log to stderr for errors and warnings, stdout for others
    if [[ "$level" == "ERROR" || "$level" == "WARNING" ]]; then
        echo -e "${color}[$timestamp] [$level] $message${NC}" >&2
    else
        echo -e "${color}[$timestamp] [$level] $message${NC}"
    fi
    
    # Log to file if LOG_DIR is available
    if [[ -n "${LOG_DIR:-}" && -d "$LOG_DIR" ]]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_DIR/cursor_uninstaller.log"
    fi
}

# Enhanced system validation with detailed checks
validate_system_requirements() {
    local validation_errors=0
    local validation_warnings=0
    
    log_with_level "INFO" "Performing comprehensive system validation..."
    
    # Check macOS version with detailed compatibility
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_with_level "ERROR" "This utility requires macOS - Current OS: $OSTYPE"
        ((validation_errors++))
    else
        if command -v sw_vers >/dev/null 2>&1; then
            local macos_version
            macos_version=$(sw_vers -productVersion)
            local major_version
            major_version=$(echo "$macos_version" | cut -d. -f1)
            local minor_version  
            minor_version=$(echo "$macos_version" | cut -d. -f2)
            
            if [[ $major_version -lt 10 ]] || [[ $major_version -eq 10 && $minor_version -lt 15 ]]; then
                log_with_level "ERROR" "macOS version $macos_version is below minimum $MIN_MACOS_VERSION"
                ((validation_errors++))
            elif [[ $major_version -eq 10 && $minor_version -lt 16 ]]; then
                log_with_level "WARNING" "macOS $macos_version may have limited functionality"
                ((validation_warnings++))
            else
                log_with_level "SUCCESS" "macOS version $macos_version is supported"
            fi
        fi
    fi
    
    # Enhanced memory check
    local total_memory_gb
    total_memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "0")
    if [[ $total_memory_gb -lt $MIN_MEMORY_GB ]]; then
        log_with_level "WARNING" "Insufficient memory: ${total_memory_gb}GB (recommended: ${MIN_MEMORY_GB}GB+)"
        ((validation_warnings++))
    else
        log_with_level "SUCCESS" "Memory: ${total_memory_gb}GB available"
    fi
    
    # Enhanced disk space check with multiple mount points
    local root_space_gb
    root_space_gb=$(df -g / 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
    if [[ $root_space_gb -lt $MIN_DISK_SPACE_GB ]]; then
        log_with_level "WARNING" "Low disk space on /: ${root_space_gb}GB (recommended: ${MIN_DISK_SPACE_GB}GB+)"
        ((validation_warnings++))
    else
        log_with_level "SUCCESS" "Disk space: ${root_space_gb}GB available on root"
    fi
    
    # Check temp directory space
    local temp_space_gb
    temp_space_gb=$(df -g "${TMPDIR:-/tmp}" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
    if [[ $temp_space_gb -lt 2 ]]; then
        log_with_level "WARNING" "Low temp space: ${temp_space_gb}GB"
        ((validation_warnings++))
    fi
    
    # Check required commands with specific error messages
    local missing_commands=()
    for cmd in $REQUIRED_COMMANDS; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_with_level "ERROR" "Missing required commands: ${missing_commands[*]}"
        log_with_level "INFO" "Install missing commands and try again"
        ((validation_errors++))
    else
        log_with_level "SUCCESS" "All required commands available"
    fi
    
    # Check system integrity
    if ! csrutil status >/dev/null 2>&1; then
        log_with_level "WARNING" "Cannot check System Integrity Protection status"
        ((validation_warnings++))
    fi
    
    # Report validation summary
    if [[ $validation_errors -eq 0 && $validation_warnings -eq 0 ]]; then
        log_with_level "SUCCESS" "System validation passed with no issues"
    elif [[ $validation_errors -eq 0 ]]; then
        log_with_level "WARNING" "System validation passed with $validation_warnings warnings"
    else
        log_with_level "ERROR" "System validation failed with $validation_errors errors and $validation_warnings warnings"
    fi
    
    return $validation_errors
}

# Enhanced file operations with atomic operations and verification
safe_remove_file() {
    local file_path="$1"
    local force_remove="${2:-false}"
    local verify_removal="${3:-true}"
    
    if [[ ! -e "$file_path" ]]; then
        log_with_level "INFO" "File does not exist: $file_path"
        return 0
    fi
    
    # Get file info for logging
    local file_size
    file_size=$(du -sh "$file_path" 2>/dev/null | cut -f1 || echo "unknown")
    
    if [[ "$force_remove" != "true" ]]; then
        log_with_level "INFO" "Would remove: $file_path ($file_size)"
        return 0
    fi
    
    log_with_level "INFO" "Removing: $file_path ($file_size)"
    
    # Try different removal strategies
    local removal_success=false
    
    # Strategy 1: Standard removal
    if rm -rf "$file_path" 2>/dev/null; then
        removal_success=true
    # Strategy 2: Change permissions first
    elif chmod -R 755 "$file_path" 2>/dev/null && rm -rf "$file_path" 2>/dev/null; then
        removal_success=true
    # Strategy 3: Use sudo
    elif sudo rm -rf "$file_path" 2>/dev/null; then
        removal_success=true
    fi
    
    if [[ "$removal_success" == "true" ]]; then
        if [[ "$verify_removal" == "true" ]] && [[ -e "$file_path" ]]; then
            log_with_level "ERROR" "File still exists after removal: $file_path"
            return 1
        fi
        log_with_level "SUCCESS" "Removed: $file_path"
        return 0
    else
        log_with_level "ERROR" "Failed to remove: $file_path"
        return 1
    fi
}

# Enhanced process management with better detection and cleanup
check_cursor_processes() {
    local process_patterns=(
        "Cursor"
        "cursor"
        "com.todesktop.230313mzl4w4u92"
        "todesktop"
    )
    
    local found_processes=()
    
    for pattern in "${process_patterns[@]}"; do
        local pids
        pids=$(pgrep -f "$pattern" 2>/dev/null | grep -v "$$" || true)
        if [[ -n "$pids" ]]; then
            while IFS= read -r pid; do
                if [[ "$pid" != "$$" ]] && kill -0 "$pid" 2>/dev/null; then
                    local process_info
                    process_info=$(ps -p "$pid" -o comm= 2>/dev/null || echo "unknown")
                    found_processes+=("$pid:$process_info")
                fi
            done <<< "$pids"
        fi
    done
    
    if [[ ${#found_processes[@]} -gt 0 ]]; then
        printf '%s\n' "${found_processes[@]}"
        return 0
    else
        return 1
    fi
}

# Enhanced process termination with graceful shutdown and monitoring
terminate_cursor_processes() {
    local graceful_timeout="${1:-10}"
    local force_timeout="${2:-5}"
    local max_attempts="${3:-3}"
    
    log_with_level "INFO" "Initiating cursor process termination..."
    
    local attempt=1
    while [[ $attempt -le $max_attempts ]]; do
        log_with_level "INFO" "Termination attempt $attempt of $max_attempts"
        
        # Get current processes
        local cursor_processes
        if ! cursor_processes=$(check_cursor_processes); then
            log_with_level "SUCCESS" "No cursor processes found"
            return 0
        fi
        
        log_with_level "INFO" "Found cursor processes:"
        while IFS= read -r process_line; do
            local pid="${process_line%%:*}"
            local name="${process_line##*:}"
            log_with_level "INFO" "  PID $pid: $name"
        done <<< "$cursor_processes"
        
        # Step 1: Try graceful application quit
        log_with_level "INFO" "Attempting graceful shutdown..."
        if osascript -e 'tell application "Cursor" to quit' 2>/dev/null; then
            log_with_level "INFO" "Sent quit signal to Cursor application"
            
            # Wait for graceful shutdown
            local waited=0
            while [[ $waited -lt $graceful_timeout ]]; do
                if ! check_cursor_processes >/dev/null; then
                    log_with_level "SUCCESS" "Graceful shutdown completed"
                    return 0
                fi
                sleep 1
                ((waited++))
            done
        fi
        
        # Step 2: Send TERM signal
        log_with_level "INFO" "Sending TERM signal to remaining processes..."
        while IFS= read -r process_line; do
            local pid="${process_line%%:*}"
            if kill -0 "$pid" 2>/dev/null; then
                kill -TERM "$pid" 2>/dev/null || true
            fi
        done <<< "$cursor_processes"
        
        # Wait for TERM to take effect
        sleep "$force_timeout"
        
        # Step 3: Force kill if necessary
        if check_cursor_processes >/dev/null; then
            log_with_level "WARNING" "Some processes require force termination"
            local remaining_processes
            remaining_processes=$(check_cursor_processes)
            
            while IFS= read -r process_line; do
                local pid="${process_line%%:*}"
                if kill -0 "$pid" 2>/dev/null; then
                    log_with_level "INFO" "Force killing PID $pid"
                    kill -KILL "$pid" 2>/dev/null || true
                fi
            done <<< "$remaining_processes"
            
            sleep 2
        fi
        
        ((attempt++))
    done
    
    # Final check
    if check_cursor_processes >/dev/null; then
        log_with_level "ERROR" "Failed to terminate all cursor processes after $max_attempts attempts"
        return 1
    else
        log_with_level "SUCCESS" "All cursor processes terminated successfully"
        return 0
    fi
}

# Enhanced system specifications with detailed hardware info
get_system_specs() {
    local specs_output=""
    
    # CPU information with detailed specs
    if command -v sysctl >/dev/null 2>&1; then
        local cpu_brand
        cpu_brand=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown CPU")
        local cpu_cores
        cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "unknown")
        local cpu_freq
        cpu_freq=$(sysctl -n hw.cpufrequency_max 2>/dev/null | awk '{print int($1/1000000)}' || echo "unknown")
        
        specs_output+="CPU: $cpu_brand\n"
        specs_output+="CPU Cores: $cpu_cores\n"
        if [[ "$cpu_freq" != "unknown" ]]; then
            specs_output+="CPU Frequency: ${cpu_freq}MHz\n"
        fi
    fi
    
    # Memory information with detailed breakdown
    if command -v vm_stat >/dev/null 2>&1; then
        local total_memory_gb
        total_memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "unknown")
        
        local vm_info
        vm_info=$(vm_stat 2>/dev/null)
        if [[ -n "$vm_info" ]]; then
            local page_size=4096
            local free_pages
            free_pages=$(echo "$vm_info" | grep "Pages free" | awk '{print $3}' | sed 's/\.//' || echo "0")
            local active_pages
            active_pages=$(echo "$vm_info" | grep "Pages active" | awk '{print $3}' | sed 's/\.//' || echo "0")
            local inactive_pages
            inactive_pages=$(echo "$vm_info" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//' || echo "0")
            
            local free_gb=$(( (free_pages * page_size) / 1024 / 1024 / 1024 ))
            local used_gb=$(( ((active_pages + inactive_pages) * page_size) / 1024 / 1024 / 1024 ))
            
            specs_output+="Total Memory: ${total_memory_gb}GB\n"
            specs_output+="Free Memory: ${free_gb}GB\n"
            specs_output+="Used Memory: ${used_gb}GB\n"
        else
            specs_output+="Memory: ${total_memory_gb}GB\n"
        fi
    fi
    
    # macOS version with build info
    if command -v sw_vers >/dev/null 2>&1; then
        local macos_version
        macos_version=$(sw_vers -productVersion)
        local macos_build
        macos_build=$(sw_vers -buildVersion 2>/dev/null || echo "unknown")
        specs_output+="macOS: $macos_version (Build: $macos_build)\n"
    fi
    
    # Architecture with detailed info
    local arch
    arch=$(uname -m)
    specs_output+="Architecture: $arch\n"
    
    # Disk information for all mounted volumes
    if command -v df >/dev/null 2>&1; then
        local disk_info
        disk_info=$(df -h / 2>/dev/null | tail -1)
        if [[ -n "$disk_info" ]]; then
            local total_space
            total_space=$(echo "$disk_info" | awk '{print $2}')
            local used_space
            used_space=$(echo "$disk_info" | awk '{print $3}')
            local available_space
            available_space=$(echo "$disk_info" | awk '{print $4}')
            local usage_percent
            usage_percent=$(echo "$disk_info" | awk '{print $5}')
            
            specs_output+="Disk Total: $total_space\n"
            specs_output+="Disk Used: $used_space ($usage_percent)\n"
            specs_output+="Disk Available: $available_space\n"
        fi
    fi
    
    # System uptime
    local uptime_info
    uptime_info=$(uptime | awk -F'up ' '{print $2}' | awk -F', load' '{print $1}' 2>/dev/null || echo "unknown")
    if [[ "$uptime_info" != "unknown" ]]; then
        specs_output+="Uptime: $uptime_info\n"
    fi
    
    # Load average
    local load_avg
    load_avg=$(uptime | awk -F'load averages: ' '{print $2}' 2>/dev/null || echo "unknown")
    if [[ "$load_avg" != "unknown" ]]; then
        specs_output+="Load Average: $load_avg\n"
    fi
    
    echo -e "$specs_output"
}

# Enhanced directory creation with proper error handling and permissions
ensure_directory() {
    local dir_path="$1"
    local permissions="${2:-755}"
    local create_parents="${3:-true}"
    
    if [[ -d "$dir_path" ]]; then
        log_with_level "DEBUG" "Directory already exists: $dir_path"
        return 0
    fi
    
    local mkdir_flags="-p"
    if [[ "$create_parents" != "true" ]]; then
        mkdir_flags=""
    fi
    
    if mkdir $mkdir_flags "$dir_path" 2>/dev/null; then
        if chmod "$permissions" "$dir_path" 2>/dev/null; then
            log_with_level "SUCCESS" "Created directory: $dir_path (permissions: $permissions)"
        else
            log_with_level "WARNING" "Created directory but failed to set permissions: $dir_path"
        fi
        return 0
    else
        log_with_level "ERROR" "Failed to create directory: $dir_path"
        return 1
    fi
}

# Enhanced file operation verification with checksums
verify_file_operation() {
    local operation="$1"
    local file_path="$2"
    local expected_state="$3"
    local verify_checksum="${4:-false}"
    local original_checksum="${5:-}"
    
    case "$expected_state" in
        "exists")
            if [[ -e "$file_path" ]]; then
                if [[ "$verify_checksum" == "true" && -n "$original_checksum" ]]; then
                    local current_checksum
                    current_checksum=$(shasum -a 256 "$file_path" 2>/dev/null | cut -d' ' -f1 || echo "")
                    if [[ "$current_checksum" == "$original_checksum" ]]; then
                        log_with_level "SUCCESS" "Verified $operation: $file_path (checksum match)"
                    else
                        log_with_level "WARNING" "File exists but checksum differs: $file_path"
                        return 2
                    fi
                else
                    log_with_level "SUCCESS" "Verified $operation: $file_path exists"
                fi
                return 0
            else
                log_with_level "ERROR" "Verification failed for $operation: $file_path does not exist"
                return 1
            fi
            ;;
        "removed")
            if [[ ! -e "$file_path" ]]; then
                log_with_level "SUCCESS" "Verified $operation: $file_path removed"
                return 0
            else
                log_with_level "ERROR" "Verification failed for $operation: $file_path still exists"
                return 1
            fi
            ;;
        *)
            log_with_level "ERROR" "Invalid expected state: $expected_state"
            return 1
            ;;
    esac
}

# Network connectivity check for API operations
check_network_connectivity() {
    local test_hosts=("8.8.8.8" "1.1.1.1" "google.com")
    local timeout=5
    
    log_with_level "INFO" "Checking network connectivity..."
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W $timeout "$host" >/dev/null 2>&1; then
            log_with_level "SUCCESS" "Network connectivity verified (reached $host)"
            return 0
        fi
    done
    
    log_with_level "WARNING" "Network connectivity check failed"
    return 1
}

# Backup creation with verification
create_backup() {
    local source_path="$1"
    local backup_name="${2:-backup_$(date +%Y%m%d_%H%M%S)}"
    local compression="${3:-true}"
    
    if [[ ! -e "$source_path" ]]; then
        log_with_level "ERROR" "Source path does not exist: $source_path"
        return 1
    fi
    
    local backup_dir="${BACKUP_DIR:-$HOME/.cursor_management/backups}"
    ensure_directory "$backup_dir"
    
    local backup_path="$backup_dir/$backup_name"
    
    log_with_level "INFO" "Creating backup of $source_path to $backup_path"
    
    if [[ "$compression" == "true" ]]; then
        backup_path="${backup_path}.tar.gz"
        if tar -czf "$backup_path" -C "$(dirname "$source_path")" "$(basename "$source_path")" 2>/dev/null; then
            log_with_level "SUCCESS" "Compressed backup created: $backup_path"
        else
            log_with_level "ERROR" "Failed to create compressed backup"
            return 1
        fi
    else
        if cp -R "$source_path" "$backup_path" 2>/dev/null; then
            log_with_level "SUCCESS" "Backup created: $backup_path"
        else
            log_with_level "ERROR" "Failed to create backup"
            return 1
        fi
    fi
    
    # Verify backup
    if [[ -e "$backup_path" ]]; then
        local backup_size
        backup_size=$(du -sh "$backup_path" 2>/dev/null | cut -f1 || echo "unknown")
        log_with_level "INFO" "Backup size: $backup_size"
        return 0
    else
        log_with_level "ERROR" "Backup verification failed"
        return 1
    fi
}

# Helper functions loaded confirmation
export HELPERS_LOADED=true
log_with_level "DEBUG" "Enhanced helper functions loaded successfully" 