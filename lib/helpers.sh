#!/bin/bash

################################################################################
# Production Helper Functions for Cursor AI Editor Management Utility
# REFACTORED: Enhanced security, reliability, and performance
################################################################################

# Secure error handling
set -euo pipefail
# Note: IFS is already set as readonly in main script

# Helper module configuration
readonly HELPERS_MODULE_VERSION="3.0.0"

# Function to check if dry run mode is active
is_dry_run() {
    [[ "${DRY_RUN_MODE:-false}" == "true" ]]
}
# Export is_dry_run so it can be used by modules
export -f is_dry_run

# Enhanced logging with structured output and security considerations
log_with_level() {
    local level="$1"
    local message="$2"

    # Input validation
    if [[ ! "$level" =~ ^(ERROR|WARNING|SUCCESS|INFO|DEBUG)$ ]]; then
        level="INFO"
    fi

    # Sanitize message to prevent log injection
    message=$(printf '%s' "$message" | tr -cd '[:print:]\n\t' | head -c 1000)

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date)

    # Color coding with security-aware output
    local color=""
    case "$level" in
        "ERROR") color="${RED:-}" ;;
        "WARNING") color="${YELLOW:-}" ;;
        "SUCCESS") color="${GREEN:-}" ;;
        "INFO") color="${CYAN:-}" ;;
        "DEBUG") color="${BLUE:-}" ;;
    esac

    local formatted_message
    formatted_message=$(printf '[%s] [%s] %s' "$timestamp" "$level" "$message")

    # Route output appropriately
    if [[ "$level" == "ERROR" || "$level" == "WARNING" ]]; then
        printf '%s%s%s\n' "$color" "$formatted_message" "${NC:-}" >&2
    else
        printf '%s%s%s\n' "$color" "$formatted_message" "${NC:-}"
    fi

    # Log to file if available (with rotation)
    if [[ -n "${LOG_DIR:-}" && -d "$LOG_DIR" ]]; then
        local log_file="$LOG_DIR/cursor_uninstaller.log"

        # Implement simple log rotation
        if [[ -f "$log_file" ]] && (( $(stat -f%z "$log_file" 2>/dev/null || echo 0) > 10485760 )); then
            mv "$log_file" "${log_file}.old" 2>/dev/null || true
        fi

        printf '[%s] [%s] %s\n' "$timestamp" "$level" "$message" >> "$log_file" 2>/dev/null || true
    fi
}

# Enhanced system validation with comprehensive security checks
validate_system_requirements() {
    local -i validation_errors=0 validation_warnings=0

    log_with_level "INFO" "Performing comprehensive system validation..."

    # Security: Check for dangerous PATH elements
    if [[ "$PATH" =~ (^|:)\.(:|$) ]]; then
        log_with_level "ERROR" "Security violation: PATH contains current directory"
        ((validation_errors++))
    fi

    # macOS version validation with secure parsing
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_with_level "ERROR" "This utility requires macOS - Current OS: $OSTYPE"
        ((validation_errors++))
    else
        if command -v sw_vers >/dev/null 2>&1; then
            local macos_version major_version minor_version
            macos_version=$(sw_vers -productVersion 2>/dev/null || echo "0.0")

            # Secure version parsing
            if [[ "$macos_version" =~ ^([0-9]+)\.([0-9]+) ]]; then
                major_version="${BASH_REMATCH[1]}"
                minor_version="${BASH_REMATCH[2]}"

                local min_major=10 min_minor=15
                if (( major_version < min_major )) || (( major_version == min_major && minor_version < min_minor )); then
                    log_with_level "ERROR" "macOS version $macos_version is below minimum ${min_major}.${min_minor}"
                    ((validation_errors++))
                elif (( major_version == min_major && minor_version < 16 )); then
                    log_with_level "WARNING" "macOS $macos_version may have limited functionality"
                    ((validation_warnings++))
                else
                    log_with_level "SUCCESS" "macOS version $macos_version is supported"
                fi
            else
                log_with_level "WARNING" "Cannot parse macOS version: $macos_version"
                ((validation_warnings++))
            fi
        fi
    fi

    # Enhanced memory check with error handling
    local -i total_memory_gb
    if total_memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}'); then
        local -i min_memory_gb=${MIN_MEMORY_GB:-8}
        if (( total_memory_gb < min_memory_gb )); then
            log_with_level "WARNING" "Insufficient memory: ${total_memory_gb}GB (recommended: ${min_memory_gb}GB+)"
            ((validation_warnings++))
        else
            log_with_level "SUCCESS" "Memory: ${total_memory_gb}GB available"
        fi
    else
        log_with_level "WARNING" "Cannot determine system memory"
        ((validation_warnings++))
    fi

    # Enhanced disk space validation
    local -i root_space_gb temp_space_gb
    local -i min_disk_gb=${MIN_DISK_SPACE_GB:-10}

    if root_space_gb=$(df -g / 2>/dev/null | awk 'NR==2 {print int($4)}'); then
        if (( root_space_gb < min_disk_gb )); then
            log_with_level "WARNING" "Low disk space on /: ${root_space_gb}GB (recommended: ${min_disk_gb}GB+)"
            ((validation_warnings++))
        else
            log_with_level "SUCCESS" "Disk space: ${root_space_gb}GB available on root"
        fi
    else
        log_with_level "WARNING" "Cannot determine root disk space"
        ((validation_warnings++))
    fi

    # Check temp directory space
    if temp_space_gb=$(df -g "${TMPDIR:-/tmp}" 2>/dev/null | awk 'NR==2 {print int($4)}'); then
        if (( temp_space_gb < 2 )); then
            log_with_level "WARNING" "Low temp space: ${temp_space_gb}GB"
            ((validation_warnings++))
        fi
    else
        log_with_level "WARNING" "Cannot determine temp space"
        ((validation_warnings++))
    fi

    # Validate required commands with detailed checking
    local -a missing_commands=()
    local -a required_commands=(defaults osascript sudo pgrep pkill find xargs)

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done

    if (( ${#missing_commands[@]} > 0 )); then
        log_with_level "ERROR" "Missing required commands: ${missing_commands[*]}"
        log_with_level "INFO" "Install missing commands and try again"
        ((validation_errors++))
    else
        log_with_level "SUCCESS" "All required commands available"
    fi

    # System Integrity Protection check (informational)
    if command -v csrutil >/dev/null 2>&1; then
        local sip_status
        sip_status=$(csrutil status 2>/dev/null | grep -o "enabled\|disabled" || echo "unknown")
        log_with_level "INFO" "System Integrity Protection: $sip_status"
    fi

    # Report validation summary
    if (( validation_errors == 0 && validation_warnings == 0 )); then
        log_with_level "SUCCESS" "System validation passed with no issues"
    elif (( validation_errors == 0 )); then
        log_with_level "WARNING" "System validation passed with $validation_warnings warnings"
    else
        log_with_level "ERROR" "System validation failed: $validation_errors errors, $validation_warnings warnings"
    fi

    return $validation_errors
}

# Enhanced file operations with atomic operations and comprehensive security
safe_remove_file() {
    local file_path="$1"
    local force_remove="${2:-false}"
    local verify_removal="${3:-true}"

    # Input validation and security checks
    if [[ -z "$file_path" ]]; then
        log_with_level "ERROR" "No file path provided for removal"
        return 1
    fi

    # SECURITY FIX: Comprehensive path traversal prevention with realpath validation
    local normalized_path resolved_path

    # First, resolve the real path to prevent symlink attacks
    if command -v realpath >/dev/null 2>&1; then
        # Use realpath with fallback for non-existent paths
        if [[ -e "$file_path" ]]; then
            resolved_path=$(realpath "$file_path" 2>/dev/null) || resolved_path="$file_path"
        else
            resolved_path=$(realpath -m "$file_path" 2>/dev/null) || resolved_path="$file_path"
        fi
        normalized_path="$resolved_path"
    else
        # Fallback normalization if realpath not available
        normalized_path=$(printf '%s' "$file_path" | \
            # Remove all .. sequences completely
            sed 's|\.\./\+||g; s|/\.\./\+|/|g; s|\.\.$||; s|^\.\./\+||' | \
            # Remove ./ sequences
            sed 's|\./||g; s|/\./|/|g' | \
            # Remove multiple consecutive slashes
            sed 's|//\+|/|g' | \
            # Remove trailing slashes (except for root)
            sed 's|/\+$||; s|^$|/|')
    fi

    # SECURITY: Validate that path doesn't contain any remaining traversal attempts
    if [[ "$normalized_path" =~ \.\./|\.\. ]]; then
        log_with_level "ERROR" "SECURITY: Path contains traversal sequences after normalization: $file_path"
        return 1
    fi

    # SECURITY: Block dangerous path patterns
    case "$normalized_path" in
        # System critical directories - absolute protection
        /|/etc|/etc/*|/usr|/usr/*|/bin|/bin/*|/sbin|/sbin/*|/System|/System/*)
            log_with_level "ERROR" "SECURITY: Refusing to remove system critical path: $normalized_path"
            return 1
            ;;
        # Root level directories - protection
        /Applications|/Library|/Users)
            log_with_level "ERROR" "SECURITY: Refusing to remove root-level directory: $normalized_path"
            return 1
            ;;
        # Prevent accidental /tmp cleaning
        /tmp|/var/tmp|/private/tmp)
            log_with_level "ERROR" "SECURITY: Refusing to remove system temp directory: $normalized_path"
            return 1
            ;;
        # Relative paths that could be dangerous
        ..|../*|*/..|*/../*)
            log_with_level "ERROR" "SECURITY: Path contains traversal elements: $file_path"
            return 1
            ;;
    esac

    # SECURITY: Validate path contains only safe characters (allow spaces in macOS paths)
    if [[ "$normalized_path" =~ [[:cntrl:]] ]] || [[ "$normalized_path" =~ [\$\`\"\\] ]]; then
        log_with_level "ERROR" "SECURITY: Path contains dangerous control characters: $file_path"
        return 1
    fi

    # SECURITY: Ensure path is absolute or within allowed directories
    case "$normalized_path" in
        /*)
            # Absolute path - validate against allowed prefixes
            local allowed=false
            local -a allowed_prefixes=(
                "/Users/$USER"
                "/Applications/Cursor"
                "${HOME:-/dev/null}"
                "${TMPDIR:-/tmp}/cursor"
                "${CONFIG_DIR:-/dev/null}"
                "${BACKUP_DIR:-/dev/null}"
                "${LOG_DIR:-/dev/null}"
            )

            for prefix in "${allowed_prefixes[@]}"; do
                if [[ -n "$prefix" && "$prefix" != "/dev/null" && "$normalized_path" == "$prefix"* ]]; then
                    allowed=true
                    break
                fi
            done

            if [[ "$allowed" != "true" ]]; then
                log_with_level "ERROR" "SECURITY: Path outside allowed directories: $normalized_path"
                return 1
            fi
            ;;
        *)
            # Relative path - resolve and revalidate
            if command -v realpath >/dev/null 2>&1; then
                local resolved_path
                if resolved_path=$(realpath "$normalized_path" 2>/dev/null); then
                    # Recursively validate the resolved absolute path
                    safe_remove_file "$resolved_path" "$force_remove" "$verify_removal"
                    return $?
                else
                    log_with_level "DEBUG" "Cannot resolve relative path, skipping: $normalized_path"
                    return 0
                fi
            else
                log_with_level "WARNING" "Cannot validate relative path without realpath: $normalized_path"
                return 1
            fi
            ;;
    esac

    # Use the validated normalized path
    file_path="$normalized_path"

    # Check if file/directory exists
    if [[ ! -e "$file_path" ]]; then
        log_with_level "DEBUG" "File does not exist: $file_path"
        return 0
    fi

    # SECURITY: Verify ownership before removal (safety check)
    local file_owner
    if file_owner=$(stat -f%u "$file_path" 2>/dev/null); then
        local current_uid
        current_uid=$(id -u)

        # Only proceed if we own the file OR it's in our allowed directories
        if [[ "$file_owner" != "$current_uid" ]]; then
            # Check if it's in a directory we can manage
            case "$file_path" in
                "$HOME"/*|"${CONFIG_DIR:-/dev/null}"/*|"${BACKUP_DIR:-/dev/null}"/*|"${LOG_DIR:-/dev/null}"/*)
                    log_with_level "INFO" "File owned by different user but in managed directory: $file_path"
                    ;;
                *)
                    log_with_level "WARNING" "File owned by different user (UID: $file_owner): $file_path"
                    if [[ "$force_remove" != "true" ]]; then
                        log_with_level "ERROR" "Refusing to remove file owned by different user without force"
                        return 1
                    fi
                    ;;
            esac
        fi
    fi

    # Get file info for logging (with comprehensive error handling)
    local file_size file_type file_permissions
    file_size=$(du -sh "$file_path" 2>/dev/null | cut -f1 || echo "unknown")
    file_permissions=$(stat -f%p "$file_path" 2>/dev/null | tail -c 4 || echo "unknown")

    if [[ -d "$file_path" ]]; then
        file_type="directory"
        # Count items in directory
        local item_count
        item_count=$(find "$file_path" -type f 2>/dev/null | wc -l | tr -d ' ' || echo "unknown")
        file_size="$file_size ($item_count files)"
    elif [[ -L "$file_path" ]]; then
        file_type="symlink"
        local link_target
        link_target=$(readlink "$file_path" 2>/dev/null || echo "unknown")
        file_size="-> $link_target"
    else
        file_type="file"
    fi

    # Dry-run mode handling
    if [[ "$force_remove" != "true" ]]; then
        log_with_level "INFO" "Would remove $file_type: $file_path ($file_size, mode: $file_permissions)"
        return 0
    fi

    log_with_level "INFO" "Removing $file_type: $file_path ($file_size, mode: $file_permissions)"

    # ENHANCED: Atomic removal with comprehensive strategies
    local removal_success=false
    local -i attempt=1
    local -i max_attempts=4
    local error_message=""

    # Create backup if this is an important file and backup is enabled
    local backup_created=false
    if [[ "${ENABLE_BACKUPS:-true}" == "true" && -f "$file_path" && "$file_path" =~ \.(plist|config|json)$ ]]; then
        local backup_path
        backup_path="${BACKUP_DIR:-/tmp}/$(basename "$file_path").backup.$(date +%s)"
        if [[ -d "$(dirname "$backup_path")" ]] && cp "$file_path" "$backup_path" 2>/dev/null; then
            log_with_level "INFO" "Created backup: $backup_path"
            backup_created=true
        fi
    fi

    while (( attempt <= max_attempts )) && [[ "$removal_success" != "true" ]]; do
        case $attempt in
            1)
                # Strategy 1: Standard removal with error capture
                if error_message=$(rm -rf "$file_path" 2>&1); then
                    removal_success=true
                fi
                ;;
            2)
                # Strategy 2: Change permissions first (safely)
                if [[ -e "$file_path" ]]; then
                    error_message=""
                    # Only change permissions if we own the file or it's in our directory
                    if [[ "$file_owner" == "$(id -u)" ]] || [[ "$file_path" == "$HOME"/* ]]; then
                        if chmod -R u+w "$file_path" 2>/dev/null; then
                            if error_message=$(rm -rf "$file_path" 2>&1); then
                                removal_success=true
                            fi
                        else
                            error_message="Cannot change permissions"
                        fi
                    else
                        error_message="Insufficient permissions (not owner)"
                    fi
                fi
                ;;
            3)
                # Strategy 3: Process-by-process approach for busy files
                if [[ -e "$file_path" ]]; then
                    error_message=""

                    # Check if file is in use
                    local using_processes
                    if using_processes=$(lsof "$file_path" 2>/dev/null | awk 'NR>1 {print $2}' | sort -u); then
                        if [[ -n "$using_processes" ]]; then
                            log_with_level "INFO" "File in use by processes: $using_processes"

                            # Try to terminate processes gracefully
                            echo "$using_processes" | while read -r pid; do
                                if [[ "$pid" =~ ^[0-9]+$ ]]; then
                                    log_with_level "INFO" "Requesting process $pid to close file"
                                    kill -TERM "$pid" 2>/dev/null || true
                                fi
                            done

                            sleep 2
                        fi
                    fi

                    # Retry removal
                    if error_message=$(rm -rf "$file_path" 2>&1); then
                        removal_success=true
                    fi
                fi
                ;;
            4)
                # Strategy 4: Use sudo with confirmation (last resort)
                if [[ -e "$file_path" ]] && command -v sudo >/dev/null 2>&1; then
                    log_with_level "WARNING" "Using elevated privileges for removal (last resort)"

                    # Final confirmation for sudo operations
                    if [[ "${SUDO_REMOVAL_CONFIRMED:-false}" != "true" ]]; then
                        log_with_level "ERROR" "Sudo removal requires explicit confirmation via SUDO_REMOVAL_CONFIRMED=true"
                        error_message="Sudo removal not confirmed"
                    else
                        # Use sudo with timeout
                        if timeout 30 sudo rm -rf "$file_path" 2>/dev/null; then
                            removal_success=true
                        else
                            error_message="Sudo removal failed or timed out"
                        fi
                    fi
                fi
                ;;
        esac

        # Log attempt results
        if [[ "$removal_success" != "true" ]]; then
            log_with_level "WARNING" "Removal attempt $attempt failed: ${error_message:-unknown error}"
        fi

        ((attempt++))

        # Add exponential backoff between attempts
        if [[ "$removal_success" != "true" ]] && (( attempt <= max_attempts )); then
            sleep $((attempt - 1))
        fi
    done

    # Final verification and result reporting
    if [[ "$removal_success" == "true" ]]; then
        # Verify removal if requested
        if [[ "$verify_removal" == "true" ]]; then
            if [[ -e "$file_path" ]]; then
                log_with_level "ERROR" "CRITICAL: File still exists after successful removal: $file_path"
                return 1
            fi

            # Additional verification: check parent directory doesn't contain traces
            local parent_dir
            parent_dir=$(dirname "$file_path")
            if [[ -d "$parent_dir" ]]; then
                local basename_file
                basename_file=$(basename "$file_path")
                # Check if any files matching the pattern exist in parent directory
                if compgen -G "$parent_dir/$basename_file*" >/dev/null 2>&1; then
                    log_with_level "WARNING" "Possible traces remain in parent directory: $parent_dir"
                fi
            fi
        fi

        log_with_level "SUCCESS" "Successfully removed $file_type: $file_path"
        return 0
    else
        log_with_level "ERROR" "Failed to remove $file_type after $max_attempts attempts: $file_path"
        log_with_level "ERROR" "Final error: ${error_message:-unknown error}"

        # Restore backup if removal failed and backup exists
        if [[ "$backup_created" == "true" && -f "$backup_path" ]]; then
            if cp "$backup_path" "$file_path" 2>/dev/null; then
                log_with_level "INFO" "Restored backup after failed removal"
            fi
        fi

        return 1
    fi
}

# Enhanced process management with robust detection and graceful termination
check_cursor_processes() {
    local -a process_patterns=("Cursor" "cursor" "com.todesktop.230313mzl4w4u92" "todesktop")
    local -a found_processes=()
    local current_pid=$$

    for pattern in "${process_patterns[@]}"; do
        local pids
        # Use pgrep for safer process detection - disable error exit temporarily
        set +e
        pids=$(pgrep -f "$pattern" 2>/dev/null)
        local pgrep_exit=$?
        set -e

        # Only process results if pgrep found matches (exit code 0)
        if [[ $pgrep_exit -eq 0 && -n "$pids" ]]; then
            # Process PIDs without modifying IFS (Bash 3.2 compatibility)
            while read -r pid; do
                # Skip our own process and invalid PIDs
                if [[ "$pid" =~ ^[0-9]+$ ]] && (( pid != current_pid )) && kill -0 "$pid" 2>/dev/null; then
                    local process_info
                    process_info=$(ps -p "$pid" -o comm= 2>/dev/null | tr -cd '[:print:]' || echo "unknown")
                    found_processes+=("$pid:$process_info")
                fi
            done <<< "$pids"
        fi
    done

    if (( ${#found_processes[@]} > 0 )); then
        printf '%s\n' "${found_processes[@]}"
        return 0
    else
        return 1
    fi
}

# Enhanced process termination with comprehensive error handling
terminate_cursor_processes() {
    local -i graceful_timeout="${1:-10}"
    local -i force_timeout="${2:-5}"
    local -i max_attempts="${3:-3}"

    log_with_level "INFO" "Initiating cursor process termination..."

    # Validate input parameters
    if (( graceful_timeout < 1 || graceful_timeout > 300 )); then
        log_with_level "WARNING" "Invalid graceful timeout, using default"
        graceful_timeout=10
    fi

    local -i attempt=1
    while (( attempt <= max_attempts )); do
        log_with_level "INFO" "Termination attempt $attempt of $max_attempts"

        # Get current processes
        local cursor_processes
        if ! cursor_processes=$(check_cursor_processes); then
            log_with_level "SUCCESS" "No cursor processes found"
            return 0
        fi

        log_with_level "INFO" "Found cursor processes:"
        # Process cursor processes using while read to avoid word splitting
        while read -r process_line; do
            local pid="${process_line%%:*}"
            local name="${process_line##*:}"
            log_with_level "INFO" "  PID $pid: $name"
        done <<< "$cursor_processes"

        # Step 1: Graceful application quit
        log_with_level "INFO" "Attempting graceful shutdown..."
        local -i quit_attempts=0
        while (( quit_attempts < 3 )); do
            if osascript -e 'tell application "Cursor" to quit' 2>/dev/null; then
                log_with_level "INFO" "Sent quit signal to Cursor application (attempt $((quit_attempts + 1)))"
                break
            fi
            ((quit_attempts++))
            sleep 1
        done

        # Wait for graceful shutdown with timeout
        local -i waited=0
        while (( waited < graceful_timeout )); do
            if ! check_cursor_processes >/dev/null; then
                log_with_level "SUCCESS" "Graceful shutdown completed"
                return 0
            fi
            sleep 1
            ((waited++))
        done

        # Step 2: Send TERM signal to remaining processes with PID verification
        log_with_level "INFO" "Sending TERM signal to remaining processes..."
        local -a pids_to_terminate=()
        # Process cursor processes using while read to avoid word splitting
        while read -r process_line; do
            local pid="${process_line%%:*}"
            if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
                pids_to_terminate+=("$pid")
            fi
        done <<< "$cursor_processes"

        # Send TERM signals to validated PIDs
        for pid in "${pids_to_terminate[@]}"; do
            # Re-verify PID exists before sending signal
            if kill -0 "$pid" 2>/dev/null; then
                kill -TERM "$pid" 2>/dev/null || true
            fi
        done

        # Wait for TERM to take effect with periodic verification
        local -i term_wait=0
        while (( term_wait < force_timeout )); do
            local still_running=false
            for pid in "${pids_to_terminate[@]}"; do
                if kill -0 "$pid" 2>/dev/null; then
                    still_running=true
                    break
                fi
            done
            if [[ "$still_running" == "false" ]]; then
                break
            fi
            sleep 1
            ((term_wait++))
        done

        # Step 3: Force kill if necessary
        if check_cursor_processes >/dev/null; then
            log_with_level "WARNING" "Some processes require force termination"
            local remaining_processes
            remaining_processes=$(check_cursor_processes)

            # Process remaining processes using while read
            while read -r process_line; do
                local pid="${process_line%%:*}"
                if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
                    log_with_level "INFO" "Force killing PID $pid"
                    kill -KILL "$pid" 2>/dev/null || true
                fi
            done <<< "$remaining_processes"

            sleep 2
        fi

        ((attempt++))
    done

    # Final verification with graceful handling
    if check_cursor_processes >/dev/null; then
        log_with_level "WARNING" "Some cursor processes may still be running after $max_attempts attempts"
        log_with_level "INFO" "This is typically harmless and optimization can continue"
        return 2  # Use exit code 2 to indicate partial success
    else
        log_with_level "SUCCESS" "All cursor processes terminated successfully"
        return 0
    fi
}

# Enhanced system specifications with comprehensive hardware analysis
get_system_specs() {
    local -A system_info=()

    # CPU information with detailed analysis
    if command -v sysctl >/dev/null 2>&1; then
        system_info[cpu_brand]=$(sysctl -n machdep.cpu.brand_string 2>/dev/null | tr -cd '[:print:]' || echo "Unknown CPU")
        system_info[cpu_cores]=$(sysctl -n hw.ncpu 2>/dev/null || echo "unknown")
        system_info[cpu_freq]=$(sysctl -n hw.cpufrequency_max 2>/dev/null | awk '{print int($1/1000000)}' || echo "unknown")
        system_info[cpu_arch]=$(uname -m 2>/dev/null || echo "unknown")
    fi

    # Memory analysis with detailed breakdown
    if command -v vm_stat >/dev/null 2>&1; then
        system_info[total_memory_gb]=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "unknown")

        local vm_info
        vm_info=$(vm_stat 2>/dev/null)
        if [[ -n "$vm_info" ]]; then
            local -i page_size=4096
            local -i free_pages active_pages inactive_pages

            free_pages=$(echo "$vm_info" | awk '/Pages free:/ {print int($3)}' || echo "0")
            active_pages=$(echo "$vm_info" | awk '/Pages active:/ {print int($3)}' || echo "0")
            inactive_pages=$(echo "$vm_info" | awk '/Pages inactive:/ {print int($3)}' || echo "0")

            system_info[free_memory_gb]=$(( (free_pages * page_size) / 1024 / 1024 / 1024 ))
            system_info[used_memory_gb]=$(( ((active_pages + inactive_pages) * page_size) / 1024 / 1024 / 1024 ))
        fi
    fi

    # Operating system information
    if command -v sw_vers >/dev/null 2>&1; then
        system_info[macos_version]=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
        system_info[macos_build]=$(sw_vers -buildVersion 2>/dev/null || echo "unknown")
    fi

    # Storage analysis
    if command -v df >/dev/null 2>&1; then
        local disk_info
        disk_info=$(df -h / 2>/dev/null | awk 'NR==2 {printf "%s,%s,%s,%s", $2, $3, $4, $5}' || echo "unknown,unknown,unknown,unknown")

        # Parse disk info without modifying IFS (Bash 3.2 compatibility)
        total_space=$(echo "$disk_info" | cut -d',' -f1)
        used_space=$(echo "$disk_info" | cut -d',' -f2)
        available_space=$(echo "$disk_info" | cut -d',' -f3)
        usage_percent=$(echo "$disk_info" | cut -d',' -f4)
        system_info[disk_total]="$total_space"
        system_info[disk_used]="$used_space"
        system_info[disk_available]="$available_space"
        system_info[disk_usage_percent]="$usage_percent"
    fi

    # System performance metrics
    system_info[uptime]=$(uptime | awk -F'up ' '{print $2}' | awk -F', load' '{print $1}' 2>/dev/null | tr -cd '[:print:]' || echo "unknown")
    system_info[load_average]=$(uptime | awk -F'load averages: ' '{print $2}' 2>/dev/null | tr -cd '[:print:]' || echo "unknown")

    # Output formatted system information
    local output=""

    # CPU Information
    output+="CPU: ${system_info[cpu_brand]}\n"
    output+="CPU Cores: ${system_info[cpu_cores]}\n"
    output+="Architecture: ${system_info[cpu_arch]}\n"
    if [[ "${system_info[cpu_freq]}" != "unknown" ]]; then
        output+="CPU Frequency: ${system_info[cpu_freq]}MHz\n"
    fi

    # Memory Information
    output+="Total Memory: ${system_info[total_memory_gb]}GB\n"
    if [[ -n "${system_info[free_memory_gb]:-}" ]]; then
        output+="Free Memory: ${system_info[free_memory_gb]}GB\n"
        output+="Used Memory: ${system_info[used_memory_gb]}GB\n"
    fi

    # System Information
    output+="macOS: ${system_info[macos_version]} (Build: ${system_info[macos_build]})\n"

    # Storage Information
    if [[ "${system_info[disk_total]}" != "unknown" ]]; then
        output+="Disk Total: ${system_info[disk_total]}\n"
        output+="Disk Used: ${system_info[disk_used]} (${system_info[disk_usage_percent]})\n"
        output+="Disk Available: ${system_info[disk_available]}\n"
    fi

    # Performance Information
    if [[ "${system_info[uptime]}" != "unknown" ]]; then
        output+="Uptime: ${system_info[uptime]}\n"
    fi
    if [[ "${system_info[load_average]}" != "unknown" ]]; then
        output+="Load Average: ${system_info[load_average]}\n"
    fi

    printf '%s' "$output"
}

# Enhanced directory creation with comprehensive security and error handling
ensure_directory() {
    local dir_path="$1"
    local permissions="${2:-700}"  # Default to secure permissions
    local create_parents="${3:-true}"

    # Input validation
    if [[ -z "$dir_path" ]]; then
        log_with_level "ERROR" "No directory path provided"
        return 1
    fi

    # Security: Validate directory path
    if [[ ! "$dir_path" =~ ^/[^[:space:]]*$ ]]; then
        log_with_level "ERROR" "Invalid directory path: $dir_path"
        return 1
    fi

    # Normalize path
    dir_path=$(printf '%s' "$dir_path" | sed 's|/\./|/|g; s|//|/|g')

    if [[ -d "$dir_path" ]]; then
        log_with_level "DEBUG" "Directory already exists: $dir_path"

        # Check and fix permissions if needed
        local current_perms
        current_perms=$(stat -f%A "$dir_path" 2>/dev/null || echo "unknown")
        if [[ "$current_perms" != "$permissions" ]]; then
            if chmod "$permissions" "$dir_path" 2>/dev/null; then
                log_with_level "INFO" "Updated permissions on existing directory: $dir_path"
            else
                log_with_level "WARNING" "Could not update permissions on existing directory: $dir_path"
            fi
        fi
        return 0
    fi

    # Create directory
    local mkdir_flags=()
    if [[ "$create_parents" == "true" ]]; then
        mkdir_flags+=("-p")
    fi

    if mkdir "${mkdir_flags[@]}" "$dir_path" 2>/dev/null; then
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

# Enhanced file operation verification with integrity checking
verify_file_operation() {
    local operation="$1"
    local file_path="$2"
    local expected_state="$3"
    local verify_checksum="${4:-false}"
    local original_checksum="${5:-}"

    # Input validation
    if [[ -z "$operation" || -z "$file_path" || -z "$expected_state" ]]; then
        log_with_level "ERROR" "Missing required parameters for file operation verification"
        return 1
    fi

    case "$expected_state" in
        "exists")
            if [[ -e "$file_path" ]]; then
                if [[ "$verify_checksum" == "true" && -n "$original_checksum" ]]; then
                    local current_checksum
                    if current_checksum=$(shasum -a 256 "$file_path" 2>/dev/null | cut -d' ' -f1); then
                        if [[ "$current_checksum" == "$original_checksum" ]]; then
                            log_with_level "SUCCESS" "Verified $operation: $file_path (checksum match)"
                        else
                            log_with_level "WARNING" "File exists but checksum differs: $file_path"
                            return 2
                        fi
                    else
                        log_with_level "WARNING" "Could not calculate checksum for: $file_path"
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

# Enhanced network connectivity check with multiple validation methods and proper timeouts
check_network_connectivity() {
    local -a test_hosts=("8.8.8.8" "1.1.1.1" "apple.com")
    local -i timeout="${NETWORK_TIMEOUT:-10}"
    local -i successful_tests=0
    # Note: max_concurrent_tests could be used for parallel connectivity checks in the future

    log_with_level "INFO" "Checking network connectivity with ${timeout}s timeout..."

    # Use timeout command to ensure we don't hang
    for host in "${test_hosts[@]}"; do
        # Use multiple methods for robustness with proper timeout enforcement
        if timeout "$timeout" ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
            log_with_level "SUCCESS" "Network connectivity verified (reached $host)"
            ((successful_tests++))
            break
        elif command -v nc >/dev/null 2>&1 && [[ "$host" =~ ^[0-9.]+$ ]]; then
            # Try with netcat for IP addresses with timeout
            if timeout "$timeout" nc -z -w2 "$host" 53 2>/dev/null; then
                log_with_level "SUCCESS" "Network connectivity verified via nc (reached $host)"
                ((successful_tests++))
                break
            fi
        elif command -v curl >/dev/null 2>&1 && [[ "$host" =~ ^[a-zA-Z] ]]; then
            # Try HTTP check for domain names with timeout
            if timeout "$timeout" curl -s --connect-timeout 2 --max-time "$timeout" "https://$host" >/dev/null 2>&1; then
                log_with_level "SUCCESS" "Network connectivity verified via curl (reached $host)"
                ((successful_tests++))
                break
            fi
        fi

        # Add small delay between tests to avoid overwhelming network
        sleep 0.5
    done

    if (( successful_tests > 0 )); then
        return 0
    else
        log_with_level "WARNING" "Network connectivity check failed for all test hosts"
        return 1
    fi
}

# Enhanced backup creation with verification and compression options
create_backup() {
    local source_path="$1"
    local backup_name="${2:-backup_$(date +%Y%m%d_%H%M%S)}"
    local compression="${3:-true}"

    # Input validation
    if [[ -z "$source_path" ]]; then
        log_with_level "ERROR" "No source path provided for backup"
        return 1
    fi

    if [[ ! -e "$source_path" ]]; then
        log_with_level "ERROR" "Source path does not exist: $source_path"
        return 1
    fi

    # Sanitize backup name
    backup_name=$(printf '%s' "$backup_name" | tr -cd '[:alnum:]_.-')
    if [[ -z "$backup_name" ]]; then
        backup_name="backup_$(date +%Y%m%d_%H%M%S)"
    fi

    local backup_dir="${BACKUP_DIR:-$HOME/.cursor_management/backups}"
    ensure_directory "$backup_dir"

    local backup_path="$backup_dir/$backup_name"

    log_with_level "INFO" "Creating backup of $source_path to $backup_path"

    # Create backup with appropriate method
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

        # Additional verification for compressed backups
        if [[ "$compression" == "true" && "$backup_path" == *.tar.gz ]]; then
            if tar -tzf "$backup_path" >/dev/null 2>&1; then
                log_with_level "SUCCESS" "Backup integrity verified"
            else
                log_with_level "WARNING" "Backup created but integrity check failed"
                return 2
            fi
        fi

        return 0
    else
        log_with_level "ERROR" "Backup verification failed"
        return 1
    fi
}

# Module initialization and export
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced - export functions
    readonly HELPERS_LOADED=true
    export HELPERS_LOADED
    log_with_level "DEBUG" "Enhanced helper functions v$HELPERS_MODULE_VERSION loaded successfully"
else
    # Being executed directly
    printf 'Enhanced Helper Functions v%s\n' "$HELPERS_MODULE_VERSION"
    printf 'This module must be sourced, not executed directly\n'
    exit 1
fi
