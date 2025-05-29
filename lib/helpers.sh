#!/bin/bash

################################################################################
# Helper Functions Module - Option 1: Functional Domain Separation
# Contains utility functions, path resolution, and common operations
################################################################################

# Prevent multiple loading
if [[ "${HELPERS_LOADED:-}" == "true" ]]; then
    return 0
fi

################################################################################
# Logging and Output Functions
################################################################################

# Enhanced logging system with levels and rotation
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"

    # Write to log file
    echo "$log_entry" >> "$LOG_FILE" 2>/dev/null || true

    # Also write errors to error log
    if [[ "$level" == "ERROR" ]]; then
        echo "$log_entry" >> "$ERROR_LOG" 2>/dev/null || true
    fi

    # Display to console based on verbosity
    if [[ "$QUIET" != "true" ]]; then
        case "$level" in
            "ERROR")
                echo -e "${RED}[ERROR]${NC} $message" >&2
                ;;
            "WARN"|"WARNING")
                echo -e "${YELLOW}[WARNING]${NC} $message"
                ;;
            "SUCCESS")
                echo -e "${GREEN}[SUCCESS]${NC} $message"
                ;;
            "INFO")
                if [[ "$VERBOSE" == "true" ]]; then
                    echo -e "${BLUE}[INFO]${NC} $message"
                fi
                ;;
            "DEBUG")
                if [[ "$VERBOSE" == "true" ]]; then
                    echo -e "${MAGENTA}[DEBUG]${NC} $message"
                fi
                ;;
            *)
                echo "$message"
                ;;
        esac
    fi
}

# Initialize logging system
initialize_logging() {
    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR" 2>/dev/null || true

    # Rotate logs if they're too large
    rotate_logs

    # Log startup information
    log_message "INFO" "=== Starting $SCRIPT_NAME v$SCRIPT_VERSION ==="
    log_message "INFO" "System: macOS $MACOS_VERSION ($HARDWARE_ARCH)"
    log_message "INFO" "Configuration loaded from: $CONFIG_FILE"
}

# Log rotation function
rotate_logs() {
    local max_size_bytes=$((MAX_LOG_SIZE_MB * 1024 * 1024))

    for log_file in "$LOG_FILE" "$ERROR_LOG" "$PERFORMANCE_LOG"; do
        if [[ -f "$log_file" ]]; then
            local file_size=$(stat -f%z "$log_file" 2>/dev/null || echo 0)
            if [[ "$file_size" -gt "$max_size_bytes" ]]; then
                mv "$log_file" "${log_file}.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
                touch "$log_file" 2>/dev/null || true
            fi
        fi
    done

    # Clean old log files
    find "$LOG_DIR" -name "*.log.*" -mtime +"$LOG_RETENTION_DAYS" -delete 2>/dev/null || true
}

################################################################################
# Error Handling and Safety Functions
################################################################################

# Enhanced error handling wrapper with retry logic
execute_safely() {
    local cmd="$1"
    local description="$2"
    local retry_count="${3:-0}"
    local max_retries="${4:-3}"

    log_message "DEBUG" "Executing: $description"

    # Execute the command
    if eval "$cmd" > /dev/null 2>&1; then
        log_message "DEBUG" "Successfully executed: $description"
        return 0
    else
        local exit_code=$?
        log_message "WARN" "Non-critical error in: $description (exit code: $exit_code)"

        # Retry logic for transient failures
        if [[ "$retry_count" -lt "$max_retries" ]]; then
            retry_count=$((retry_count + 1))
            log_message "INFO" "Retrying ($retry_count of $max_retries): $description"
            sleep 1
            execute_safely "$cmd" "$description" "$retry_count" "$max_retries"
            return $?
        fi

        log_message "ERROR" "Failed after $max_retries attempts: $description"
        return 0  # Return success to prevent script termination
    fi
}

# Safe file removal that never fails
safe_remove() {
    local path="$1"
    local description="${2:-removing $path}"

    if [[ ! -e "$path" ]] && [[ ! -L "$path" ]]; then
        log_message "DEBUG" "Path does not exist: $path"
        return 0
    fi

    log_message "INFO" "Removing: $path"

    # Make writable before removal
    execute_safely "sudo chmod -R 755 \"$path\" 2>/dev/null || true" "chmod $path"

    # Remove the path
    if execute_safely "sudo rm -rf \"$path\"" "$description"; then
        log_message "SUCCESS" "Removed: $path"
    else
        log_message "WARN" "Could not remove: $path"
    fi

    return 0  # Always return success
}

# Enhanced safe remove with better error handling
enhanced_safe_remove() {
    local path="$1"

    if [[ -e "$path" ]] || [[ -L "$path" ]]; then
        execute_safely "sudo chmod -R 755 \"$path\" 2>/dev/null || true" "chmod $path"
        execute_safely "sudo rm -rf \"$path\"" "remove $path"
    fi

    return 0  # Always return success
}

# Safe symlink removal
safe_remove_symlink() {
    local symlink_path="$1"

    if [[ -L "$symlink_path" ]]; then
        log_message "INFO" "Removing symlink: $symlink_path"
        rm -f "$symlink_path" 2>/dev/null || true
    fi
}

################################################################################
# System Utilities and Validation
################################################################################

# Check if running with appropriate permissions
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo -e "${YELLOW}${BOLD}🔐 Administrator Access Required${NC}"
        echo -e "This script requires administrator privileges to:"
        echo -e "  • Remove system-level application files"
        echo -e "  • Clear system caches and preferences"
        echo -e "  • Modify system settings"
        echo ""
        echo -e "Please enter your password when prompted."

        if ! sudo -v; then
            log_message "ERROR" "Unable to obtain administrator privileges"
            return "$ERR_PERMISSION_DENIED"
        fi
    fi

    log_message "INFO" "Administrator privileges confirmed"
    return 0
}

# Start background process to keep sudo alive
start_sudo_refresh() {
    if [[ -n "$SUDO_REFRESH_PID" ]]; then
        return 0  # Already running
    fi

    (
        while true; do
            sudo -v 2>/dev/null || break
            sleep 60
        done
    ) &
    SUDO_REFRESH_PID=$!

    # Ensure it's killed when the script exits
    trap 'stop_sudo_refresh' EXIT

    log_message "DEBUG" "Started sudo refresh process (PID: $SUDO_REFRESH_PID)"
}

# Stop sudo refresh process
stop_sudo_refresh() {
    if [[ -n "$SUDO_REFRESH_PID" ]]; then
        kill "$SUDO_REFRESH_PID" 2>/dev/null || true
        unset SUDO_REFRESH_PID
        log_message "DEBUG" "Stopped sudo refresh process"
    fi
}

# Validate system requirements
validate_system_requirements() {
    log_message "INFO" "Validating system requirements"

    # Check macOS version
    if [[ "$MACOS_VERSION" == "unknown" ]]; then
        log_message "ERROR" "Unable to determine macOS version"
        return "$ERR_VALIDATION_FAILED"
    fi

    # Check available disk space
    local available_space
    available_space=$(df -g / | tail -1 | awk '{print $4}')
    if [[ "$available_space" -lt 1 ]]; then
        log_message "WARN" "Low disk space available: ${available_space}GB"
    fi

    # Check memory
    local memory_gb
    memory_gb=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
    if [[ "$memory_gb" -lt "$MIN_MEMORY_GB" ]]; then
        log_message "WARN" "System has ${memory_gb}GB RAM, minimum recommended is ${MIN_MEMORY_GB}GB"
    fi

    log_message "SUCCESS" "System requirements validated"
    return 0
}

# Check for required dependencies
check_dependencies() {
    log_message "INFO" "Checking dependencies"

    local missing_deps=()
    local optional_deps=()

    # Check for essential commands
    local required_commands=("sudo" "find" "rm" "cp" "mv" "mkdir" "chmod" "chown")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done

    # Check for optional but useful commands
    local optional_commands=("jq" "curl" "wget" "git")
    for cmd in "${optional_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            optional_deps+=("$cmd")
        fi
    done

    # Report results
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_message "ERROR" "Missing required dependencies: ${missing_deps[*]}"
        return "$ERR_VALIDATION_FAILED"
    fi

    if [[ ${#optional_deps[@]} -gt 0 ]]; then
        log_message "WARN" "Missing optional dependencies: ${optional_deps[*]}"
        log_message "INFO" "Some features may be limited without these dependencies"
    fi

    log_message "SUCCESS" "Dependencies checked"
    return 0
}

################################################################################
# Path and File Utilities
################################################################################

# Detect and validate Cursor installation paths
detect_cursor_paths() {
    log_message "INFO" "Detecting Cursor installation paths"

    local found_paths=()
    local cursor_paths=(
        "$CURSOR_APP"
        "$CURSOR_SUPPORT"
        "$CURSOR_CACHE"
        "$CURSOR_PREFERENCES"
        "$CURSOR_SAVED_STATE"
        "$CURSOR_LOGS"
        "$CURSOR_WEBSTORAGE"
    )

    for path in "${cursor_paths[@]}"; do
        if [[ -e "$path" ]]; then
            found_paths+=("$path")
            log_message "DEBUG" "Found: $path"
        fi
    done

    if [[ ${#found_paths[@]} -eq 0 ]]; then
        log_message "INFO" "No Cursor installation found"
        return 1
    else
        log_message "INFO" "Found ${#found_paths[@]} Cursor-related paths"
        return 0
    fi
}

# Get file size in human readable format
get_file_size() {
    local path="$1"

    if [[ -e "$path" ]]; then
        du -sh "$path" 2>/dev/null | cut -f1
    else
        echo "0B"
    fi
}

# Create temporary file with cleanup tracking
create_temp_file() {
    local prefix="${1:-cursor_temp}"
    local temp_file

    temp_file=$(mktemp "${TEMP_DIR}/${prefix}.XXXXXX")
    TEMP_FILES+=("$temp_file")

    echo "$temp_file"
}

################################################################################
# Database and Cache Cleanup
################################################################################

# Clean various system databases and caches
clean_databases() {
    log_message "INFO" "Cleaning system databases and caches"

    # LaunchServices database
    execute_safely "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user" "rebuild LaunchServices database"

    # Spotlight index
    execute_safely "sudo mdutil -i off / && sudo mdutil -i on /" "rebuild Spotlight index"

    # DNS cache
    execute_safely "sudo dscacheutil -flushcache" "flush DNS cache"

    # Font cache
    execute_safely "sudo atsutil databases -remove" "clear font cache"

    log_message "SUCCESS" "Database cleanup completed"
}

################################################################################
# Confirmation and User Interaction
################################################################################

# Get user confirmation with timeout
get_confirmation() {
    local message="$1"
    local timeout="${2:-30}"
    local default="${3:-n}"

    if [[ "$SKIP_CONFIRMATION" == "true" ]] || [[ "$FORCE" == "true" ]]; then
        log_message "INFO" "Confirmation skipped (force mode)"
        return 0
    fi

    echo -e "${YELLOW}$message${NC}"
    echo -e "Continue? (y/N): "

    local response
    if command -v timeout >/dev/null 2>&1; then
        if ! response=$(timeout "$timeout" read -r); then
            response="$default"
            echo -e "\nTimeout reached, using default: $default"
        fi
    else
        read -r response
    fi

    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            log_message "INFO" "User confirmed action"
            return 0
            ;;
        *)
            log_message "INFO" "User cancelled action"
            return 1
            ;;
    esac
}

################################################################################
# Performance and Monitoring
################################################################################

# Monitor command execution time
time_command() {
    local description="$1"
    shift
    local cmd="$*"

    local start_time=$(date +%s.%N)

    log_message "DEBUG" "Starting: $description"
    eval "$cmd"
    local exit_code=$?

    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")

    log_message "DEBUG" "Completed: $description (${duration}s)"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$description] ${duration}s" >> "$PERFORMANCE_LOG" 2>/dev/null || true

    return $exit_code
}

# Get system performance metrics
get_system_metrics() {
    local metrics_file
    metrics_file=$(create_temp_file "metrics")

    {
        echo "timestamp: $(date -Iseconds)"
        echo "cpu_usage: $(top -l 1 -s 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')"
        echo "memory_pressure: $(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//')"
        echo "disk_usage: $(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')"
        echo "load_average: $(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')"
    } > "$metrics_file" 2>/dev/null || true

    echo "$metrics_file"
}

################################################################################
# Health Check Functions
################################################################################

# Comprehensive health check function
perform_health_check() {
    log_message "INFO" "Starting comprehensive system health check"
    
    local health_issues=0
    local warnings=0
    
    echo -e "\n${BOLD}${BLUE}🔍 COMPREHENSIVE SYSTEM HEALTH CHECK${NC}"
    echo -e "${BOLD}════════════════════════════════════════════════════════${NC}\n"
    
    # System Requirements Check
    echo -e "${BOLD}${CYAN}1. SYSTEM REQUIREMENTS${NC}"
    echo -e "   ${CYAN}•${NC} Operating System: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo -e "   ${CYAN}•${NC} Architecture: $(uname -m)"
    echo -e "   ${CYAN}•${NC} Kernel Version: $(uname -r)"
    
    # Check macOS version compatibility
    local macos_version
    macos_version=$(sw_vers -productVersion | cut -d. -f1-2)
    local macos_major=$(echo "$macos_version" | cut -d. -f1)
    local macos_minor=$(echo "$macos_version" | cut -d. -f2)
    
    if [[ "$macos_major" -lt 11 ]] || [[ "$macos_major" -eq 11 && "$macos_minor" -lt 0 ]]; then
        echo -e "   ${RED}✗${NC} macOS version may be too old for optimal Cursor performance"
        ((health_issues++))
    else
        echo -e "   ${GREEN}✓${NC} macOS version compatible"
    fi
    
    # Memory Check
    echo -e "\n${BOLD}${CYAN}2. MEMORY AND STORAGE${NC}"
    local total_mem=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
    echo -e "   ${CYAN}•${NC} Total RAM: ${total_mem}GB"
    
    if [[ "$total_mem" -lt 8 ]]; then
        echo -e "   ${YELLOW}⚠${NC} Low RAM detected - AI features may be slower"
        ((warnings++))
    elif [[ "$total_mem" -ge 16 ]]; then
        echo -e "   ${GREEN}✓${NC} Excellent RAM for AI development"
    else
        echo -e "   ${GREEN}✓${NC} Sufficient RAM for basic AI development"
    fi
    
    # Disk Space Check
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    local disk_avail=$(df -h / | tail -1 | awk '{print $4}')
    echo -e "   ${CYAN}•${NC} Disk Usage: ${disk_usage}% used, ${disk_avail} available"
    
    if [[ "$disk_usage" -gt 90 ]]; then
        echo -e "   ${RED}✗${NC} Critical: Very low disk space available"
        ((health_issues++))
    elif [[ "$disk_usage" -gt 80 ]]; then
        echo -e "   ${YELLOW}⚠${NC} Warning: Low disk space - consider cleanup"
        ((warnings++))
    else
        echo -e "   ${GREEN}✓${NC} Sufficient disk space available"
    fi
    
    # CPU and Performance Check
    echo -e "\n${BOLD}${CYAN}3. PROCESSOR AND PERFORMANCE${NC}"
    local cpu_model=$(sysctl -n machdep.cpu.brand_string)
    echo -e "   ${CYAN}•${NC} CPU: $cpu_model"
    
    # Check if Apple Silicon
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo -e "   ${GREEN}✓${NC} Apple Silicon detected - excellent AI performance expected"
    else
        echo -e "   ${YELLOW}⚠${NC} Intel processor - AI performance may be limited"
        ((warnings++))
    fi
    
    # Load Average Check
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local load_num=$(echo "$load_avg" | bc -l 2>/dev/null || echo "$load_avg")
    echo -e "   ${CYAN}•${NC} Current Load Average: $load_avg"
    
    if (( $(echo "$load_num > 5.0" | bc -l 2>/dev/null || echo 0) )); then
        echo -e "   ${YELLOW}⚠${NC} High system load detected"
        ((warnings++))
    else
        echo -e "   ${GREEN}✓${NC} System load is normal"
    fi
    
    # Cursor Installation Check
    echo -e "\n${BOLD}${CYAN}4. CURSOR INSTALLATION STATUS${NC}"
    if [[ -d "/Applications/Cursor.app" ]]; then
        echo -e "   ${GREEN}✓${NC} Cursor.app found at /Applications/Cursor.app"
        
        # Check Cursor version
        if [[ -f "/Applications/Cursor.app/Contents/Info.plist" ]]; then
            local cursor_version=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
            echo -e "   ${CYAN}•${NC} Version: $cursor_version"
        fi
        
        # Check app size
        local app_size=$(get_file_size "/Applications/Cursor.app")
        echo -e "   ${CYAN}•${NC} Application Size: $app_size"
        
    else
        echo -e "   ${YELLOW}ℹ${NC} Cursor.app not found - not currently installed"
    fi
    
    # Check CLI tools
    if command -v cursor >/dev/null 2>&1; then
        local cursor_cli_path=$(which cursor)
        echo -e "   ${GREEN}✓${NC} Cursor CLI available at: $cursor_cli_path"
    else
        echo -e "   ${YELLOW}ℹ${NC} Cursor CLI not found in PATH"
    fi
    
    # Network Connectivity Check
    echo -e "\n${BOLD}${CYAN}5. NETWORK CONNECTIVITY${NC}"
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} Internet connectivity available"
        
        # Check Cursor API connectivity (if applicable)
        if curl -s --max-time 5 https://api.cursor.sh/health >/dev/null 2>&1; then
            echo -e "   ${GREEN}✓${NC} Cursor API reachable"
        else
            echo -e "   ${YELLOW}⚠${NC} Cursor API may be unreachable"
            ((warnings++))
        fi
    else
        echo -e "   ${RED}✗${NC} No internet connectivity detected"
        ((health_issues++))
    fi
    
    # Development Environment Check
    echo -e "\n${BOLD}${CYAN}6. DEVELOPMENT ENVIRONMENT${NC}"
    
    # Check for Git
    if command -v git >/dev/null 2>&1; then
        local git_version=$(git --version | awk '{print $3}')
        echo -e "   ${GREEN}✓${NC} Git available (version $git_version)"
    else
        echo -e "   ${YELLOW}⚠${NC} Git not found - version control may be limited"
        ((warnings++))
    fi
    
    # Check for Node.js
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version)
        echo -e "   ${GREEN}✓${NC} Node.js available ($node_version)"
    else
        echo -e "   ${YELLOW}ℹ${NC} Node.js not found - JavaScript development may be limited"
    fi
    
    # Check for Python
    if command -v python3 >/dev/null 2>&1; then
        local python_version=$(python3 --version | awk '{print $2}')
        echo -e "   ${GREEN}✓${NC} Python 3 available (version $python_version)"
    else
        echo -e "   ${YELLOW}ℹ${NC} Python 3 not found - Python development may be limited"
    fi
    
    # Security and Permissions Check
    echo -e "\n${BOLD}${CYAN}7. SECURITY AND PERMISSIONS${NC}"
    
    # Check SIP status
    if csrutil status | grep -q "disabled"; then
        echo -e "   ${YELLOW}⚠${NC} System Integrity Protection is disabled"
        ((warnings++))
    else
        echo -e "   ${GREEN}✓${NC} System Integrity Protection is enabled"
    fi
    
    # Check sudo access
    if sudo -n true 2>/dev/null; then
        echo -e "   ${GREEN}✓${NC} Sudo access available without password"
    elif sudo -v >/dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} Sudo access available with password"
    else
        echo -e "   ${RED}✗${NC} No sudo access - administrative operations will fail"
        ((health_issues++))
    fi
    
    # Final Health Summary
    echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}HEALTH CHECK SUMMARY${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [[ "$health_issues" -eq 0 && "$warnings" -eq 0 ]]; then
        echo -e "${BOLD}${GREEN}🎉 EXCELLENT HEALTH${NC}"
        echo -e "   ${GREEN}•${NC} System is optimally configured for Cursor AI development"
        log_message "SUCCESS" "Health check passed with no issues"
    elif [[ "$health_issues" -eq 0 ]]; then
        echo -e "${BOLD}${YELLOW}⚠️  GOOD HEALTH WITH WARNINGS${NC}"
        echo -e "   ${YELLOW}•${NC} $warnings warning(s) detected - minor optimization possible"
        echo -e "   ${GREEN}•${NC} No critical issues found"
        log_message "SUCCESS" "Health check passed with $warnings warnings"
    else
        echo -e "${BOLD}${RED}🚨 HEALTH ISSUES DETECTED${NC}"
        echo -e "   ${RED}•${NC} $health_issues critical issue(s) require attention"
        echo -e "   ${YELLOW}•${NC} $warnings warning(s) detected"
        echo -e "   ${RED}•${NC} System may not function optimally until issues are resolved"
        log_message "WARNING" "Health check completed with $health_issues issues and $warnings warnings"
    fi
    
    echo -e "\n${BOLD}${CYAN}RECOMMENDATIONS:${NC}"
    if [[ "$total_mem" -lt 16 ]]; then
        echo -e "   ${CYAN}•${NC} Consider upgrading to 16GB+ RAM for better AI performance"
    fi
    if [[ "$disk_usage" -gt 70 ]]; then
        echo -e "   ${CYAN}•${NC} Clean up disk space for optimal performance"
    fi
    if [[ "$(uname -m)" != "arm64" ]]; then
        echo -e "   ${CYAN}•${NC} Consider upgrading to Apple Silicon Mac for best AI performance"
    fi
    echo -e "   ${CYAN}•${NC} Keep Cursor updated for latest AI improvements"
    echo -e "   ${CYAN}•${NC} Regularly restart Cursor to free up memory"
    
    return 0
}

################################################################################
# Module Initialization
################################################################################

# Mark helpers as loaded
HELPERS_LOADED="true"

# Export important functions and variables
export HELPERS_LOADED
