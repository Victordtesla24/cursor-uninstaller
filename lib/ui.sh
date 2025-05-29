#!/bin/bash

################################################################################
# User Interface Module - PRODUCTION GRADE UI Functions
# Provides user interface functions and comprehensive health check capabilities
################################################################################

# Prevent multiple loading
if [[ "${UI_LOADED:-}" == "true" ]]; then
    return 0
fi

################################################################################
# Color and Style Configuration
################################################################################

# Enhanced color scheme for better readability
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    BOLD='\033[1m'
    DIM='\033[2m'
    UNDERLINE='\033[4m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    WHITE=''
    BOLD=''
    DIM=''
    UNDERLINE=''
    NC=''
fi

# Export color variables
export RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BOLD DIM UNDERLINE NC

################################################################################
# Progress and Status Display Functions
################################################################################

# Enhanced progress display with animations
show_progress() {
    local current=${1:-0}
    local total=${2:-100}
    local message=${3:-"PROCESSING"}
    local width=${4:-40}
    
    if [[ "$total" -eq 0 ]]; then
        echo -e "${CYAN}${message}...${NC}"
        return 0
    fi
    
    local percentage=$(( (current * 100) / total ))
    local filled=$(( (percentage * width) / 100 ))
    local empty=$((width - filled))
    
    local progress_bar=""
    for ((i=0; i<filled; i++)); do
        progress_bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        progress_bar+="░"
    done
    
    printf "\r${BOLD}[${BLUE}%s${NC}${BOLD}] %3d%% ${CYAN}%s${NC}" "$progress_bar" "$percentage" "$message"
    
    if [[ "$current" -ge "$total" ]]; then
        echo ""  # New line when complete
    fi
}

# Spinner animation for long-running tasks
show_spinner() {
    local message="${1:-Processing}"
    local delay=0.1
    local spinstr="|/-\\"
    
    while true; do
        local temp=${spinstr#?}
        printf "\r${CYAN}[%c] %s...${NC}" "$spinstr" "$message"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
}

# Stop spinner function
stop_spinner() {
    kill $! 2>/dev/null
    printf "\r${GREEN}✓${NC} %s\n" "${1:-Complete}"
}

################################################################################
# System Information Display Functions
################################################################################

# Display system banner with comprehensive information
display_system_banner() {
    local banner_width=60
    local title="CURSOR MANAGEMENT UTILITY"
    
    echo -e "${BOLD}${BLUE}"
    printf "%*s\n" $(((${#title} + banner_width) / 2)) "$title"
    echo -e "${NC}${BOLD}"
    printf "═%.0s" $(seq 1 $banner_width)
    echo -e "${NC}\n"
    
    # System Information
    echo -e "${BOLD}${GREEN}SYSTEM INFORMATION:${NC}"
    echo -e "  ${CYAN}Hostname:${NC} $(hostname)"
    echo -e "  ${CYAN}User:${NC} $(whoami)"
    echo -e "  ${CYAN}macOS:${NC} $(sw_vers -productVersion 2>/dev/null || echo 'Unknown')"
    echo -e "  ${CYAN}Architecture:${NC} $(uname -m)"
    echo -e "  ${CYAN}Uptime:${NC} $(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}' | xargs)"
    
    # Hardware Information  
    if command -v system_profiler >/dev/null 2>&1; then
        local hardware_model
        hardware_model=$(system_profiler SPHardwareDataType | grep "Model Name" | awk -F': ' '{print $2}' | xargs 2>/dev/null || echo "Unknown")
        echo -e "  ${CYAN}Hardware:${NC} $hardware_model"
        
        local memory_gb
        memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "Unknown")
        echo -e "  ${CYAN}Memory:${NC} ${memory_gb} GB"
    fi
    
    echo ""
}

################################################################################
# Comprehensive Health Check Functions
################################################################################

# Perform comprehensive system health check
perform_health_check() {
    production_log_message "INFO" "Starting comprehensive system health check"
    
    echo -e "\n${BOLD}${BLUE}🏥 COMPREHENSIVE SYSTEM HEALTH CHECK${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}\n"
    
    local health_issues=0
    local total_checks=12
    local current_check=0
    
    # Initialize health report
    local health_report=()
    
    # 1. System Requirements Check
    ((current_check++))
    show_progress $current_check $total_checks "Checking system requirements"
    sleep 0.5
    
    if check_system_requirements_detailed; then
        health_report+=("✓ System requirements: PASSED")
    else
        health_report+=("✗ System requirements: FAILED")
        ((health_issues++))
    fi
    
    # 2. Disk Space Analysis  
    ((current_check++))
    show_progress $current_check $total_checks "Analyzing disk space"
    sleep 0.5
    
    if check_disk_space_health; then
        health_report+=("✓ Disk space: HEALTHY")
    else
        health_report+=("⚠ Disk space: CONCERNS DETECTED")
        ((health_issues++))
    fi
    
    # 3. Memory Usage Analysis
    ((current_check++))
    show_progress $current_check $total_checks "Analyzing memory usage"
    sleep 0.5
    
    if check_memory_health; then
        health_report+=("✓ Memory usage: OPTIMAL")
    else
        health_report+=("⚠ Memory usage: HIGH USAGE DETECTED")
        ((health_issues++))
    fi
    
    # 4. CPU Performance Check
    ((current_check++))
    show_progress $current_check $total_checks "Checking CPU performance"
    sleep 0.5
    
    if check_cpu_health; then
        health_report+=("✓ CPU performance: GOOD")
    else
        health_report+=("⚠ CPU performance: HIGH LOAD DETECTED")
        ((health_issues++))
    fi
    
    # 5. System Processes Analysis
    ((current_check++))
    show_progress $current_check $total_checks "Analyzing system processes"
    sleep 0.5
    
    if check_process_health; then
        health_report+=("✓ System processes: NORMAL")
    else
        health_report+=("⚠ System processes: ANOMALIES DETECTED")
        ((health_issues++))
    fi
    
    # 6. Network Connectivity Check
    ((current_check++))
    show_progress $current_check $total_checks "Testing network connectivity"
    sleep 0.5
    
    if check_network_health; then
        health_report+=("✓ Network connectivity: ACTIVE")
    else
        health_report+=("⚠ Network connectivity: ISSUES DETECTED")
        ((health_issues++))
    fi
    
    # 7. File System Integrity
    ((current_check++))
    show_progress $current_check $total_checks "Checking file system integrity"
    sleep 0.5
    
    if check_filesystem_health; then
        health_report+=("✓ File system: HEALTHY")
    else
        health_report+=("⚠ File system: INTEGRITY ISSUES")
        ((health_issues++))
    fi
    
    # 8. System Updates Check
    ((current_check++))
    show_progress $current_check $total_checks "Checking system updates"
    sleep 0.5
    
    if check_system_updates; then
        health_report+=("✓ System updates: CURRENT")
    else
        health_report+=("⚠ System updates: UPDATES AVAILABLE")
        ((health_issues++))
    fi
    
    # 9. Security Status Check
    ((current_check++))
    show_progress $current_check $total_checks "Checking security status"
    sleep 0.5
    
    if check_security_health; then
        health_report+=("✓ Security status: SECURE")
    else
        health_report+=("⚠ Security status: VULNERABILITIES DETECTED")
        ((health_issues++))
    fi
    
    # 10. Development Environment Check
    ((current_check++))
    show_progress $current_check $total_checks "Checking development environment"
    sleep 0.5
    
    if check_development_environment; then
        health_report+=("✓ Development environment: CONFIGURED")
    else
        health_report+=("⚠ Development environment: SETUP NEEDED")
        ((health_issues++))
    fi
    
    # 11. Cursor Installation Health
    ((current_check++))
    show_progress $current_check $total_checks "Checking Cursor installation"
    sleep 0.5
    
    if check_cursor_health; then
        health_report+=("✓ Cursor installation: HEALTHY")
    else
        health_report+=("⚠ Cursor installation: ISSUES DETECTED")
        ((health_issues++))
    fi
    
    # 12. Performance Optimization Status
    ((current_check++))
    show_progress $current_check $total_checks "Checking optimization status"
    sleep 0.5
    
    if check_optimization_status; then
        health_report+=("✓ Performance optimization: APPLIED")
    else
        health_report+=("○ Performance optimization: RECOMMENDED")
    fi
    
    # Display Results
    echo -e "\n${BOLD}${GREEN}📊 HEALTH CHECK RESULTS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}\n"
    
    for report_line in "${health_report[@]}"; do
        echo -e "  $report_line"
    done
    
    echo ""
    
    # Summary
    local passed_checks=$((total_checks - health_issues))
    echo -e "${BOLD}${BLUE}📈 HEALTH SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Total Checks:${NC} $total_checks"
    echo -e "${BOLD}Passed:${NC} ${GREEN}$passed_checks${NC}"
    echo -e "${BOLD}Issues:${NC} ${RED}$health_issues${NC}"
    
    local health_percentage=$(( (passed_checks * 100) / total_checks ))
    
    if [[ $health_percentage -ge 90 ]]; then
        echo -e "${BOLD}Overall Health:${NC} ${GREEN}EXCELLENT${NC} ($health_percentage%)"
    elif [[ $health_percentage -ge 70 ]]; then
        echo -e "${BOLD}Overall Health:${NC} ${YELLOW}GOOD${NC} ($health_percentage%)"
    elif [[ $health_percentage -ge 50 ]]; then
        echo -e "${BOLD}Overall Health:${NC} ${YELLOW}FAIR${NC} ($health_percentage%)"
    else
        echo -e "${BOLD}Overall Health:${NC} ${RED}POOR${NC} ($health_percentage%)"
    fi
    
    # Recommendations
    if [[ $health_issues -gt 0 ]]; then
        echo -e "\n${BOLD}${YELLOW}💡 RECOMMENDATIONS${NC}"
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
        provide_health_recommendations $health_issues
    fi
    
    # Generate detailed report
    generate_health_report $health_issues $total_checks
    
    # Ensure return value is within valid exit code range (0-255)
    if [[ $health_issues -gt 255 ]]; then
        return 255
    else
        return $health_issues
    fi
}

################################################################################
# Individual Health Check Functions
################################################################################

# Check system requirements in detail
check_system_requirements_detailed() {
    local requirements_met=true
    
    # Check macOS version
    if [[ "$OSTYPE" != "darwin"* ]]; then
        production_error_message "Not running on macOS"
        requirements_met=false
    fi
    
    # Check essential commands
    local required_commands=("defaults" "sudo" "sysctl" "sw_vers" "system_profiler")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            production_error_message "Required command not found: $cmd"
            requirements_met=false
        fi
    done
    
    [[ "$requirements_met" == "true" ]]
}

# Check disk space health
check_disk_space_health() {
    local disk_usage
    disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    local available_gb
    available_gb=$(df -h / | tail -1 | awk '{print $4}' | sed 's/Gi//')
    
    # Check if available space is less than 10GB or usage over 90%
    if [[ $disk_usage -gt 90 ]] || [[ ${available_gb%.*} -lt 10 ]]; then
        return 1
    fi
    return 0
}

# Check memory health
check_memory_health() {
    local memory_info
    memory_info=$(vm_stat)
    
    local free_pages
    free_pages=$(echo "$memory_info" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    local active_pages
    active_pages=$(echo "$memory_info" | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    local inactive_pages
    inactive_pages=$(echo "$memory_info" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
    local wired_pages
    wired_pages=$(echo "$memory_info" | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
    
    # Ensure we have valid numbers
    [[ -z "$free_pages" ]] && free_pages=0
    [[ -z "$active_pages" ]] && active_pages=0
    [[ -z "$inactive_pages" ]] && inactive_pages=0
    [[ -z "$wired_pages" ]] && wired_pages=0
    
    local total_pages=$((free_pages + active_pages + inactive_pages + wired_pages))
    local used_pages=$((active_pages + inactive_pages + wired_pages))
    
    if [[ $total_pages -gt 0 ]]; then
        local memory_usage_percent=$((used_pages * 100 / total_pages))
        # Return failure if memory usage over 85%
        [[ $memory_usage_percent -le 85 ]]
    else
        return 0  # Can't determine, assume OK
    fi
}

# Check CPU health
check_cpu_health() {
    local cpu_usage
    cpu_usage=$(top -l 1 -s 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    
    if [[ -n "$cpu_usage" ]]; then
        local cpu_usage_int
        cpu_usage_int=$(printf "%.0f" "$cpu_usage" 2>/dev/null || echo "0")
        # Return failure if CPU usage over 80%
        [[ $cpu_usage_int -le 80 ]]
    else
        return 0  # Can't determine, assume OK
    fi
}

# Check process health
check_process_health() {
    # Check for zombie processes
    local zombie_count
    zombie_count=$(ps aux | awk '$8 ~ /Z/ { count++ } END { print count+0 }')
    
    # Check for excessive process count
    local total_processes
    total_processes=$(ps aux | wc -l)
    
    # Return failure if more than 5 zombies or over 500 total processes
    [[ $zombie_count -le 5 ]] && [[ $total_processes -le 500 ]]
}

# Check network health
check_network_health() {
    # Test connectivity to common servers
    local test_hosts=("8.8.8.8" "1.1.1.1")
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 3000 "$host" >/dev/null 2>&1; then
            return 0  # At least one host is reachable
        fi
    done
    
    return 1  # No hosts reachable
}

# Check filesystem health
check_filesystem_health() {
    # Check for filesystem errors (basic)
    if command -v fsck >/dev/null 2>&1; then
        # Run basic filesystem check (read-only)
        if fsck -n / >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
    
    # If fsck not available, check disk utility status
    return 0  # Assume OK if we can't check
}

# Check system updates
check_system_updates() {
    if command -v softwareupdate >/dev/null 2>&1; then
        local updates
        local software_output
        software_output=$(softwareupdate -l 2>/dev/null)
        
        # Count recommended updates safely
        if [[ -n "$software_output" ]]; then
            updates=$(echo "$software_output" | grep -c "recommended" 2>/dev/null || echo "0")
            # Sanitize the value - remove any whitespace/newlines and ensure it's a number
            updates=$(echo "$updates" | tr -d '\n\r\t ' | grep -E '^[0-9]+$' || echo "0")
        else
            updates=0
        fi
        
        # Return success if no updates or can't check
        [[ $updates -eq 0 ]]
    else
        return 0  # Can't check, assume OK
    fi
}

# Check security health
check_security_health() {
    local security_issues=0
    
    # Check if System Integrity Protection is enabled
    if command -v csrutil >/dev/null 2>&1; then
        if ! csrutil status | grep -q "enabled"; then
            ((security_issues++))
        fi
    fi
    
    # Check if FileVault is enabled
    if command -v fdesetup >/dev/null 2>&1; then
        if ! fdesetup status | grep -q "On"; then
            ((security_issues++))
        fi
    fi
    
    # Check if Firewall is enabled
    if command -v defaults >/dev/null 2>&1; then
        local firewall_state
        firewall_state=$(defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null || echo "0")
        if [[ "$firewall_state" != "1" ]] && [[ "$firewall_state" != "2" ]]; then
            ((security_issues++))
        fi
    fi
    
    # Return success if 1 or fewer security issues
    [[ $security_issues -le 1 ]]
}

# Check development environment
check_development_environment() {
    local dev_tools_present=0
    
    # Check for common development tools
    local dev_commands=("git" "node" "python3" "brew")
    for cmd in "${dev_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            ((dev_tools_present++))
        fi
    done
    
    # Return success if at least 2 dev tools are present
    [[ $dev_tools_present -ge 2 ]]
}

# Check Cursor health
check_cursor_health() {
    local cursor_issues=0
    
    # Check if Cursor.app exists and is accessible
    if [[ ! -d "/Applications/Cursor.app" ]]; then
        ((cursor_issues++))
    elif [[ ! -r "/Applications/Cursor.app/Contents/Info.plist" ]]; then
        ((cursor_issues++))
    fi
    
    # Check CLI availability
    if ! command -v cursor >/dev/null 2>&1; then
        ((cursor_issues++))
    fi
    
    # Return success if 1 or fewer issues
    [[ $cursor_issues -le 1 ]]
}

# Check optimization status
check_optimization_status() {
    # Check if basic optimizations are applied
    local optimizations_applied=0
    
    # Check if dock autohide is enabled
    if defaults read com.apple.dock autohide 2>/dev/null | grep -q "1"; then
        ((optimizations_applied++))
    fi
    
    # Check if reduced motion is enabled
    if defaults read com.apple.universalaccess reduceMotion 2>/dev/null | grep -q "1"; then
        ((optimizations_applied++))
    fi
    
    # Check if Cursor settings exist
    if [[ -f "$HOME/Library/Application Support/Cursor/User/settings.json" ]]; then
        ((optimizations_applied++))
    fi
    
    # Return success if at least 1 optimization is applied
    [[ $optimizations_applied -ge 1 ]]
}

################################################################################
# Health Recommendations and Reporting
################################################################################

# Provide health recommendations
provide_health_recommendations() {
    local issue_count="$1"
    
    echo -e "  ${YELLOW}•${NC} Run system optimization to improve performance"
    echo -e "  ${YELLOW}•${NC} Check Activity Monitor for resource-heavy processes"
    echo -e "  ${YELLOW}•${NC} Consider restarting if system has been running for many days"
    echo -e "  ${YELLOW}•${NC} Free up disk space by removing unnecessary files"
    echo -e "  ${YELLOW}•${NC} Update macOS and applications to latest versions"
    
    if [[ $issue_count -gt 3 ]]; then
        echo -e "  ${RED}•${NC} Multiple issues detected - consider professional system maintenance"
    fi
}

# Generate detailed health report
generate_health_report() {
    local issues=$1
    local total=$2
    
    local report_file
    report_file="${TEMP_DIR:-/tmp}/system_health_report_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
# System Health Report
# Generated: $(date)
# System: $(uname -s) $(uname -r)
# User: $(whoami)
# Hostname: $(hostname)

## Health Check Results:
EOF
    
    # Write the health report array that was created in perform_health_check
    for line in "${health_report[@]}"; do
        echo "$line" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## Summary:
Total Checks: $total
Issues Found: $issues
Health Score: $(( ((total - issues) * 100) / total ))%

## System Information:
macOS Version: $(sw_vers -productVersion 2>/dev/null || echo 'Unknown')
Hardware: $(system_profiler SPHardwareDataType | grep "Model Name" | awk -F': ' '{print $2}' | xargs 2>/dev/null || echo 'Unknown')
Memory: $(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo 'Unknown') GB
Architecture: $(uname -m)

## Disk Usage:
$(df -h /)

## Memory Usage:
$(vm_stat | head -10)

## Top Processes by CPU:
$(ps aux | sort -nr -k 3 | head -10)

## Top Processes by Memory:
$(ps aux | sort -nr -k 4 | head -10)
EOF
    
    production_success_message "Detailed health report saved: $report_file"
    echo -e "\n${BOLD}📄 Report Location:${NC} $report_file"
}

################################################################################
# Module Initialization
################################################################################

# Mark module as loaded
UI_LOADED="true"

# Export functions for use in other modules
export -f show_progress show_spinner stop_spinner display_system_banner
export -f perform_health_check check_system_requirements_detailed
export -f provide_health_recommendations generate_health_report
