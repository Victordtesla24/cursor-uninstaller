#!/bin/bash

################################################################################
# Cursor AI System Information & Health Check Module
# Version 1.0.0 - Production Ready
################################################################################

# Secure error handling
set -euo pipefail

# Basic fallback functions
basic_health_check() {
    echo -e "\n${BOLD}${BLUE}🔍 PRODUCTION-GRADE CURSOR AI HEALTH ASSESSMENT${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    local health_issues=0
    local critical_issues=0
    local performance_score=0
    local -i total_checks=5 # Number of major sections/checks
    local -i current_check=0
    local -i start_time
    start_time=$(date +%s)

    # 1. System Compatibility Analysis
    show_progress_with_dashboard $((++current_check)) $total_checks "System Compatibility Analysis" "$start_time"
    echo -e "${BOLD}1. SYSTEM COMPATIBILITY ANALYSIS:${NC}"

    # OS and architecture with enhanced checking
    local os_version
    local arch_info
    local kernel_version
    if command -v sw_vers >/dev/null 2>&1; then
        os_version=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")
        local build_version
        build_version=$(sw_vers -buildVersion 2>/dev/null || echo "Unknown")
        echo -e "   ${GREEN}✅ macOS Version:${NC} $os_version (Build: $build_version)"

        # Enhanced version compatibility checking
        case "$os_version" in
            10.1[5-9]*|1[1-9].*|[2-9]*.*)
                echo -e "   ${GREEN}✅ Version Compatibility:${NC} Fully supported for Cursor AI"
                ((performance_score += 2))
                ;;
            10.1[3-4]*)
                echo -e "   ${YELLOW}⚠️ Version Compatibility:${NC} Limited support - consider upgrading"
                ((health_issues++))
                ;;
            *)
                echo -e "   ${RED}❌ Version Compatibility:${NC} Unsupported - upgrade required"
                ((critical_issues++))
                ;;
        esac
    else
        echo -e "   ${RED}❌ macOS Detection:${NC} System information unavailable"
        ((critical_issues++))
    fi

    arch_info=$(uname -m 2>/dev/null || echo "unknown")
    if [[ "$arch_info" == "arm64" ]]; then
        echo -e "   ${GREEN}✅ Architecture:${NC} Apple Silicon ($arch_info) - Optimal for AI"
        ((performance_score += 2))
    elif [[ "$arch_info" == "x86_64" ]]; then
        echo -e "   ${YELLOW}⚠️ Architecture:${NC} Intel ($arch_info) - Good performance"
        ((performance_score += 1))
    else
        echo -e "   ${RED}❌ Architecture:${NC} $arch_info - Compatibility issues expected"
        ((critical_issues++))
    fi

    kernel_version=$(uname -r 2>/dev/null || echo "unknown")
    echo -e "   ${CYAN}Kernel Version:${NC} $kernel_version"

    # 2. Cursor AI Application Health Analysis
    show_progress_with_dashboard $((++current_check)) $total_checks "Cursor AI Application Health Analysis" "$start_time"
    echo -e "\n${BOLD}2. CURSOR AI APPLICATION HEALTH ANALYSIS:${NC}"

    # Enhanced app bundle verification
    if [[ -d "/Applications/Cursor.app" ]]; then
        echo -e "   ${GREEN}✅ Application Bundle:${NC} Found at /Applications/Cursor.app"

        # Comprehensive bundle integrity check
        if [[ -f "/Applications/Cursor.app/Contents/Info.plist" ]]; then
            local cursor_version
            cursor_version=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
            local bundle_id
            bundle_id=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "Unknown")
            local build_version
            build_version=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleVersion 2>/dev/null || echo "Unknown")
            local app_size
            app_size=$(du -sh "/Applications/Cursor.app" 2>/dev/null | cut -f1 || echo "unknown")
            local install_date
            install_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "/Applications/Cursor.app" 2>/dev/null || echo "Unknown")

            echo -e "   ${CYAN}   Version:${NC} $cursor_version (Build: $build_version)"
            echo -e "   ${CYAN}   Bundle ID:${NC} $bundle_id"
            echo -e "   ${CYAN}   Size:${NC} $app_size"
            echo -e "   ${CYAN}   Installed:${NC} $install_date"

            # Version validation with current stable version
            if [[ "$cursor_version" == "1.1.2" ]]; then
                echo -e "   ${GREEN}✅ Version Status:${NC} Latest stable version (1.1.2)"
                ((performance_score += 2))
            elif [[ "$cursor_version" > "1.1.2" ]]; then
                echo -e "   ${GREEN}✅ Version Status:${NC} Newer version ($cursor_version)"
                ((performance_score += 2))
            else
                echo -e "   ${YELLOW}⚠️ Version Status:${NC} Outdated ($cursor_version) - consider updating"
                ((health_issues++))
            fi

            # Bundle ID validation
            if [[ "$bundle_id" == *"cursor"* ]] || [[ "$bundle_id" == *"todesktop"* ]]; then
                echo -e "   ${GREEN}✅ Bundle Verification:${NC} Authentic Cursor application"
                ((performance_score += 1))
            else
                echo -e "   ${YELLOW}⚠️ Bundle Verification:${NC} Unexpected bundle ID"
                ((health_issues++))
            fi

            # Executable verification
            if [[ -x "/Applications/Cursor.app/Contents/MacOS/Cursor" ]]; then
                echo -e "   ${GREEN}✅ Main Executable:${NC} Present and executable"
                ((performance_score += 1))
            else
                echo -e "   ${RED}❌ Main Executable:${NC} Missing or not executable"
                ((critical_issues++))
            fi

            # Critical resources check
            local required_resources=(
                "/Applications/Cursor.app/Contents/Resources"
                "/Applications/Cursor.app/Contents/Frameworks"
            )
            local missing_resources=0
            for resource in "${required_resources[@]}"; do
                if [[ ! -d "$resource" ]]; then
                    ((missing_resources++))
                fi
            done

            if [[ $missing_resources -eq 0 ]]; then
                echo -e "   ${GREEN}✅ Application Resources:${NC} Complete"
                ((performance_score += 1))
            else
                echo -e "   ${RED}❌ Application Resources:${NC} $missing_resources critical components missing"
                ((critical_issues++))
            fi
        else
            echo -e "   ${RED}❌ Bundle Integrity:${NC} Info.plist missing or corrupted"
            ((critical_issues++))
        fi
    else
        echo -e "   ${RED}❌ Application Bundle:${NC} Not found at /Applications/Cursor.app"
        echo -e "   ${CYAN}   Recommendation:${NC} Install Cursor from official website"
        ((critical_issues++))
    fi

    # Enhanced CLI tools analysis
    if command -v cursor >/dev/null 2>&1; then
        local cursor_cli_version
        local cursor_path
        cursor_cli_version=$(cursor --version 2>/dev/null | head -1 || echo "Unknown")
        cursor_path=$(which cursor 2>/dev/null || echo "Unknown")
        echo -e "   ${GREEN}✅ CLI Tools:${NC} Available at $cursor_path"
        echo -e "   ${CYAN}   CLI Version:${NC} $cursor_cli_version"
        ((performance_score += 1))
    else
        echo -e "   ${YELLOW}⚠️ CLI Tools:${NC} Not installed - optional but recommended"
        echo -e "   ${CYAN}   Install via:${NC} Cursor → Settings → Command Palette → 'Install cursor command'"
        ((health_issues++))
    fi

    # 3. System Resources
    show_progress_with_dashboard $((++current_check)) $total_checks "System Resources Check" "$start_time"
    echo -e "\n${BOLD}3. SYSTEM RESOURCES:${NC}"

    # Memory check with timeout to prevent hanging
    if command -v vm_stat >/dev/null 2>&1; then
        local memory_info
        memory_info=$(timeout 5 vm_stat 2>/dev/null | head -5 | tail -4 || echo "")
        local free_pages
        free_pages=$(echo "$memory_info" | grep "Pages free:" | awk '{print $3}' | tr -d '.' 2>/dev/null || echo "0")
        if [[ -n "$free_pages" && "$free_pages" -gt 100000 ]]; then
            echo -e "   ${GREEN}✅ Memory:${NC} Sufficient free memory available"
        else
            echo -e "   ${YELLOW}⚠️ Memory:${NC} Low free memory - may affect performance"
            ((health_issues++))
        fi
    fi

    # Disk space check
    if command -v df >/dev/null 2>&1; then
        local disk_space_pct
        local available_space
        disk_space_pct=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%' || echo "100")
        available_space=$(df -h / 2>/dev/null | awk 'NR==2 {print $4}' || echo "unknown")

        if [[ "$disk_space_pct" -lt 90 ]]; then
            echo -e "   ${GREEN}✅ Disk Space:${NC} $available_space available (${disk_space_pct}% used)"
        elif [[ "$disk_space_pct" -lt 95 ]]; then
            echo -e "   ${YELLOW}⚠️ Disk Space:${NC} $available_space available (${disk_space_pct}% used) - Monitor usage"
            ((health_issues++))
        else
            echo -e "   ${RED}❌ Disk Space:${NC} $available_space available (${disk_space_pct}% used) - Critical"
            ((critical_issues++))
        fi
    fi

    # 4. Network connectivity for AI features
    show_progress_with_dashboard $((++current_check)) $total_checks "Network Connectivity Check" "$start_time"
    echo -e "\n${BOLD}4. NETWORK CONNECTIVITY (for AI features):${NC}"

    # Test basic connectivity with timeout to prevent hanging
    if timeout 8 ping -c 1 -W 5000 8.8.8.8 >/dev/null 2>&1; then
        echo -e "   ${GREEN}✅ Internet Connection:${NC} Available"

        # Test HTTPS connectivity (important for AI model downloads)
        if timeout 12 curl -s --max-time 10 "https://www.google.com" >/dev/null 2>&1; then
            echo -e "   ${GREEN}✅ HTTPS Connectivity:${NC} Working"
        else
            echo -e "   ${YELLOW}⚠️ HTTPS Connectivity:${NC} Issues detected"
            ((health_issues++))
        fi
    else
        echo -e "   ${RED}❌ Internet Connection:${NC} Not available or limited"
        echo -e "   ${CYAN}   Impact:${NC} AI features will not work without internet"
        ((critical_issues++))
    fi

    # 5. Security and permissions
    show_progress_with_dashboard $((++current_check)) $total_checks "Security & Permissions Check" "$start_time"
    echo -e "\n${BOLD}5. SECURITY & PERMISSIONS:${NC}"

    # Check if SIP is enabled
    if command -v csrutil >/dev/null 2>&1; then
        local sip_status
        sip_status=$(csrutil status 2>/dev/null | grep -o "enabled\|disabled" || echo "unknown")
        if [[ "$sip_status" == "enabled" ]]; then
            echo -e "   ${GREEN}✅ System Integrity Protection:${NC} Enabled (recommended)"
        else
            echo -e "   ${YELLOW}⚠️ System Integrity Protection:${NC} $sip_status"
            ((health_issues++))
        fi
    fi

    # Check quarantine status of Cursor app
    if [[ -d "/Applications/Cursor.app" ]] && command -v xattr >/dev/null 2>&1; then
        if xattr -l "/Applications/Cursor.app" 2>/dev/null | grep -q "com.apple.quarantine"; then
            echo -e "   ${YELLOW}⚠️ App Quarantine:${NC} Cursor is quarantined - may need manual approval"
            ((health_issues++))
        else
            echo -e "   ${GREEN}✅ App Quarantine:${NC} Cursor is not quarantined"
        fi
    fi

    # Health Summary
    echo ""  # Clear progress line
    local end_time
    end_time=$(date +%s)
    local duration
    duration=$((end_time - start_time))
    display_operation_summary "System Health Check" $((total_checks - critical_issues - health_issues)) $health_issues $critical_issues $total_checks $duration

    echo -e "\n${BOLD}${BLUE}📊 HEALTH ASSESSMENT SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"

    local total_issues=$((health_issues + critical_issues))

    if [[ $critical_issues -eq 0 && $health_issues -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}🎉 SYSTEM STATUS: EXCELLENT${NC}"
        echo -e "${GREEN}Your system is optimally configured for Cursor AI${NC}"
    elif [[ $critical_issues -eq 0 && $health_issues -le 2 ]]; then
        echo -e "${YELLOW}${BOLD}⚠️ SYSTEM STATUS: GOOD WITH MINOR ISSUES${NC}"
        echo -e "${YELLOW}Found $health_issues minor issues that should be addressed${NC}"
    elif [[ $critical_issues -eq 0 ]]; then
        echo -e "${YELLOW}${BOLD}⚠️ SYSTEM STATUS: FUNCTIONAL WITH ISSUES${NC}"
        echo -e "${YELLOW}Found $health_issues issues that may affect performance${NC}"
    else
        echo -e "${RED}${BOLD}❌ SYSTEM STATUS: CRITICAL ISSUES DETECTED${NC}"
        echo -e "${RED}Found $critical_issues critical issues and $health_issues other issues${NC}"
        echo -e "\n${BOLD}Immediate Actions Required:${NC}"
        if [[ $critical_issues -gt 0 ]]; then
            echo -e "  • Resolve critical issues before using Cursor"
            echo -e "  • Consider reinstalling Cursor if app bundle is corrupted"
        fi
    fi

    echo ""
    return $total_issues
}

display_cursor_performance_metrics() {
    echo -e "\n${BOLD}7. CURSOR AI PERFORMANCE METRICS:${NC}"

    if pgrep -f "Cursor" >/dev/null; then
        echo -e "   ${GREEN}✅ Cursor is currently running.${NC}"
        local total_mem=0
        local process_count=0
        
        local cursor_pids
        cursor_pids=$(pgrep -f "Cursor")

        for pid in $cursor_pids; do
            if ! kill -0 "$pid" 2>/dev/null; then
                continue # Skip to the next PID if this one is no longer valid
            fi
            local mem_usage
            mem_usage=$(ps -p "$pid" -o rss= | xargs) # in KB
            if [[ "$mem_usage" =~ ^[0-9]+$ ]]; then
                total_mem=$((total_mem + mem_usage))
            fi
            ((process_count++))
        done

        local total_mem_mb
        total_mem_mb=$((total_mem / 1024))
        echo -e "   ${CYAN}Process Count:${NC} $process_count processes"
        echo -e "   ${CYAN}Total Memory Usage:${NC} ${total_mem_mb}MB"
        
        echo -e "   ${CYAN}CPU Usage (current snapshot):${NC}"
        local pids
        pids=$(pgrep -if "Cursor" | tr '\n' ',')
        if [[ -n "$pids" ]]; then
            ps -p "${pids%,}" -o %cpu,comm | sort -rn | head -n 5 | awk '{printf "     • %s: %s%% CPU\n", $2, $1}'
        else
            echo "     • No Cursor processes found for CPU usage."
        fi

        echo -e "\n   ${YELLOW}AI & Optimization Metrics (Conceptual):${NC}"
        echo -e "   ${CYAN}   AI Model Status:${NC} Not available via external script"
        echo -e "   ${CYAN}   Token Usage:${NC} Not available via external script"
        echo -e "   ${CYAN}   Active Optimizations:${NC} See 'Optimize System' menu"

    else
        echo -e "   ${YELLOW}⚠️ Cursor is not running. Performance metrics unavailable.${NC}"
    fi
}

# Production-grade system specifications display
production_system_specifications() {
    echo -e "\n${BOLD}${BLUE}🖥️ PRODUCTION-GRADE SYSTEM SPECIFICATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    # 1. Operating System Details
    echo -e "${BOLD}1. OPERATING SYSTEM:${NC}"

    if command -v sw_vers >/dev/null 2>&1; then
        local product_name
        product_name=$(sw_vers -productName 2>/dev/null || echo "Unknown")
        local product_version
        product_version=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")
        local build_version
        build_version=$(sw_vers -buildVersion 2>/dev/null || echo "Unknown")

        echo -e "   ${CYAN}Product Name:${NC} $product_name"
        echo -e "   ${CYAN}Version:${NC} $product_version"
        echo -e "   ${CYAN}Build:${NC} $build_version"
    fi

    local kernel_version
    kernel_version=$(uname -r 2>/dev/null || echo "Unknown")
    local uptime_info
    uptime_info=$(uptime 2>/dev/null | sed 's/.*up \\([^,]*\\).*/\1/' || echo "Unknown")
    local architecture
    architecture=$(uname -m 2>/dev/null || echo "Unknown")

    echo -e "   ${CYAN}Kernel Version:${NC} $kernel_version"
    echo -e "   ${CYAN}Architecture:${NC} $architecture"
    echo -e "   ${CYAN}System Uptime:${NC} $uptime_info"

    # 2. Hardware Information
    echo -e "\n${BOLD}2. HARDWARE SPECIFICATIONS:${NC}"

    # CPU Information
    if command -v sysctl >/dev/null 2>&1; then
        local cpu_brand
        cpu_brand=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
        local cpu_cores
        cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")
        local cpu_speed
        cpu_speed=$(sysctl -n hw.cpufrequency_max 2>/dev/null | awk '{printf "%.2f GHz", $1/1000000000}' 2>/dev/null || echo "Unknown")

        echo -e "   ${CYAN}CPU:${NC} $cpu_brand"
        echo -e "   ${CYAN}CPU Cores:${NC} $cpu_cores"
        if [[ "$cpu_speed" != "Unknown" ]]; then
            echo -e "   ${CYAN}CPU Speed:${NC} $cpu_speed"
        fi
    fi

    # Memory Information
    if command -v sysctl >/dev/null 2>&1; then
        local total_memory_bytes
        total_memory_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
        local total_memory_gb
        if [[ "$total_memory_bytes" != "0" ]] && [[ "$total_memory_bytes" =~ ^[0-9]+$ ]]; then
            total_memory_gb=$(awk "BEGIN {printf \"%.1f GB\", $total_memory_bytes/1073741824}")
        else
            total_memory_gb="Unknown"
        fi
        echo -e "   ${CYAN}Total Memory:${NC} $total_memory_gb"

        # Memory usage details with improved error handling
        if command -v vm_stat >/dev/null 2>&1; then
            local memory_stats
            memory_stats=$(timeout 5 vm_stat 2>/dev/null || echo "")
            if [[ -n "$memory_stats" ]]; then
                local page_size
                page_size=$(echo "$memory_stats" | grep "page size" | awk '{print $8}' 2>/dev/null || echo "4096")
                local free_pages
                free_pages=$(echo "$memory_stats" | grep "Pages free:" | awk '{print $3}' | tr -d '.' 2>/dev/null || echo "0")
                local active_pages
                active_pages=$(echo "$memory_stats" | grep "Pages active:" | awk '{print $3}' | tr -d '.' 2>/dev/null || echo "0")
                local inactive_pages
                inactive_pages=$(echo "$memory_stats" | grep "Pages inactive:" | awk '{print $3}' | tr -d '.' 2>/dev/null || echo "0")
                local wired_pages
                wired_pages=$(echo "$memory_stats" | grep "Pages wired down:" | awk '{print $4}' | tr -d '.' 2>/dev/null || echo "0")

                # Only calculate if we have valid numbers
                if [[ "$page_size" =~ ^[0-9]+$ ]] && [[ "$free_pages" =~ ^[0-9]+$ ]]; then
                    local free_gb
                    free_gb=$(awk "BEGIN {printf \"%.1f GB\", ($free_pages * $page_size) / 1073741824}" 2>/dev/null || echo "Unknown")
                    local active_gb
                    active_gb=$(awk "BEGIN {printf \"%.1f GB\", ($active_pages * $page_size) / 1073741824}" 2>/dev/null || echo "Unknown")
                    local inactive_gb
                    inactive_gb=$(awk "BEGIN {printf \"%.1f GB\", ($inactive_pages * $page_size) / 1073741824}" 2>/dev/null || echo "Unknown")
                    local wired_gb
                    wired_gb=$(awk "BEGIN {printf \"%.1f GB\", ($wired_pages * $page_size) / 1073741824}" 2>/dev/null || echo "Unknown")

                    echo -e "   ${CYAN}   Free Memory:${NC} $free_gb"
                    echo -e "   ${CYAN}   Active Memory:${NC} $active_gb"
                    echo -e "   ${CYAN}   Inactive Memory:${NC} $inactive_gb"
                    echo -e "   ${CYAN}   Wired Memory:${NC} $wired_gb"
                fi
            fi
        fi
    fi

    # Architecture
    local arch_info
    arch_info=$(uname -m 2>/dev/null || echo "unknown")
    echo -e "   ${CYAN}Architecture:${NC} $arch_info"

    # 3. Storage Information
    echo -e "\n${BOLD}3. STORAGE INFORMATION:${NC}"

    if command -v df >/dev/null 2>&1; then
        echo -e "   ${CYAN}Filesystem Usage:${NC}"
        df -h 2>/dev/null | grep -E '^/dev/' | while read -r _ size used avail capacity mount; do
            echo -e "     ${CYAN}$mount:${NC} $used used / $size total ($capacity used) - $avail available"
        done
    fi

    # Disk information
    if command -v diskutil >/dev/null 2>&1; then
        echo -e "   ${CYAN}Physical Disks:${NC}"
        diskutil list 2>/dev/null | grep -E '^/dev/disk[0-9]+' | while read -r disk; do
            local disk_info
            disk_info=$(diskutil info "$disk" 2>/dev/null | grep -E "Device / Media Name|Total Size" | tr '\n' ' ' || echo "")
            if [[ -n "$disk_info" ]]; then
                echo -e "     ${CYAN}$disk:${NC} $disk_info"
            fi
        done
    fi

    # 4. Cursor AI Specific Information
    echo -e "\n${BOLD}4. CURSOR AI APPLICATION DETAILS:${NC}"

    if [[ -d "/Applications/Cursor.app" ]]; then
        echo -e "   ${GREEN}✅ Installation Status:${NC} Installed"

        # App details
        if [[ -f "/Applications/Cursor.app/Contents/Info.plist" ]]; then
            local cursor_version
            cursor_version=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
            local bundle_id
            bundle_id=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "Unknown")

            echo -e "   ${CYAN}Version:${NC} $cursor_version"
            echo -e "   ${CYAN}Bundle Identifier:${NC} $bundle_id"

            # Expected details from user provided information
            echo -e "   ${CYAN}Expected Version:${NC} 1.1.2 (Universal)"
            echo -e "   ${CYAN}Expected VSCode Version:${NC} 1.96.2"
            echo -e "   ${CYAN}Expected Commit:${NC} 87ea1604be1f602f173c5fb67582e647fcef6c40"
            echo -e "   ${CYAN}Expected Date:${NC} 2025-06-13T00:26:52.696Z"
            echo -e "   ${CYAN}Expected Electron:${NC} 34.5.1"
            echo -e "   ${CYAN}Expected Chromium:${NC} 132.0.6834.210"
            echo -e "   ${CYAN}Expected Node.js:${NC} 20.19.0"
            echo -e "   ${CYAN}Expected V8:${NC} 13.2.152.41-electron.0"

            # App size and installation date
            local app_size
            app_size=$(du -sh "/Applications/Cursor.app" 2>/dev/null | cut -f1 || echo "Unknown")
            local install_date
            install_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "/Applications/Cursor.app" 2>/dev/null || echo "Unknown")

            echo -e "   ${CYAN}App Size:${NC} $app_size"
            echo -e "   ${CYAN}Installation Date:${NC} $install_date"
        else
            echo -e "   ${RED}❌ Bundle Information:${NC} Cannot read Info.plist"
        fi

        # CLI tools
        if command -v cursor >/dev/null 2>&1; then
            local cli_path
            cli_path=$(which cursor 2>/dev/null || echo "Unknown")
            local cli_version
            cli_version=$(cursor --version 2>/dev/null | head -1 || echo "Unknown")
            echo -e "   ${CYAN}CLI Tool Path:${NC} $cli_path"
            echo -e "   ${CYAN}CLI Tool Version:${NC} $cli_version"
        else
            echo -e "   ${YELLOW}⚠️ CLI Tools:${NC} Not installed"
        fi
    else
        echo -e "   ${RED}❌ Installation Status:${NC} Not installed"
    fi

    # 5. Network Configuration
    echo -e "\n${BOLD}5. NETWORK CONFIGURATION:${NC}"

    # Network interfaces
    if command -v ifconfig >/dev/null 2>&1; then
        local active_interfaces
        active_interfaces=$(ifconfig 2>/dev/null | grep -E '^[a-z]' | grep -v 'lo0' | awk '{print $1}' | tr -d ':' || echo "")
        if [[ -n "$active_interfaces" ]]; then
            echo -e "   ${CYAN}Active Network Interfaces:${NC}"
            for interface in $active_interfaces; do
                local ip_address
                ip_address=$(ifconfig "$interface" 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1 || echo "No IP")
                if [[ "$ip_address" != "No IP" ]]; then
                    echo -e "     ${CYAN}$interface:${NC} $ip_address"
                fi
            done
        fi
    fi

    # DNS configuration
    if [[ -f "/etc/resolv.conf" ]]; then
        local dns_servers
        dns_servers=$(grep 'nameserver' /etc/resolv.conf 2>/dev/null | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//' || echo "Unknown")
        if [[ -n "$dns_servers" ]]; then
            echo -e "   ${CYAN}DNS Servers:${NC} $dns_servers"
        fi
    fi

    # 6. Development Environment
    echo -e "\n${BOLD}6. DEVELOPMENT ENVIRONMENT:${NC}"

    local dev_tools=("git" "node" "npm" "python3" "java" "code")

    echo -e "   ${CYAN}Available Development Tools:${NC}"
    for tool in "${dev_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            local tool_version
            case "$tool" in
                "git") tool_version=$(git --version 2>/dev/null | awk '{print $3}' || echo "Unknown") ;;
                "node") tool_version=$(node --version 2>/dev/null || echo "Unknown") ;;
                "npm") tool_version=$(npm --version 2>/dev/null || echo "Unknown") ;;
                "python3") tool_version=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "Unknown") ;;
                "java") tool_version=$(java -version 2>&1 | head -1 | awk -F'"' '{print $2}' || echo "Unknown") ;;
                "code") tool_version=$(code --version 2>/dev/null | head -1 || echo "Unknown") ;;
                *) tool_version="Available" ;;
            esac
            echo -e "     ${GREEN}✅ $tool:${NC} $tool_version"
        else
            echo -e "     ${YELLOW}⚠️ $tool:${NC} Not installed"
        fi
    done

    # Summary
    echo -e "\n${BOLD}${BLUE}📊 SYSTEM COMPATIBILITY ASSESSMENT${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"

    local compatibility_score=0
    local total_checks=0

    # Check macOS version compatibility
    if command -v sw_vers >/dev/null 2>&1; then
        local os_version
        os_version=$(sw_vers -productVersion 2>/dev/null || echo "0.0.0")
        ((total_checks++))
        case "$os_version" in
            10.1[5-9]*|1[1-9].*|[2-9]*.*)
                echo -e "${GREEN}✅ macOS Compatibility:${NC} Excellent ($os_version)"
                ((compatibility_score++))
                ;;
            *)
                echo -e "${YELLOW}⚠️ macOS Compatibility:${NC} Limited ($os_version)"
                ;;
        esac
    fi

    # Check architecture
    if [[ "$(uname -m)" == "arm64" ]] || [[ "$(uname -m)" == "x86_64" ]]; then
        echo -e "${GREEN}✅ Architecture Compatibility:${NC} Fully supported ($(uname -m))"
        ((compatibility_score++))
    else
        echo -e "${YELLOW}⚠️ Architecture Compatibility:${NC} Limited ($(uname -m))"
    fi
    ((total_checks++))

    # Check memory
    if command -v sysctl >/dev/null 2>&1; then
        local memory_gb
        memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1073741824)}' || echo "0")
        ((total_checks++))
        if [[ $memory_gb -ge 8 ]]; then
            echo -e "${GREEN}✅ Memory Adequacy:${NC} Excellent (${memory_gb}GB)"
            ((compatibility_score++))
        elif [[ $memory_gb -ge 4 ]]; then
            echo -e "${YELLOW}⚠️ Memory Adequacy:${NC} Adequate (${memory_gb}GB)"
        else
            echo -e "${RED}❌ Memory Adequacy:${NC} Insufficient (${memory_gb}GB)"
        fi
    fi

    # Overall assessment
    local compatibility_percentage
    if [[ $total_checks -gt 0 ]]; then
        compatibility_percentage=$(awk "BEGIN {printf \"%.0f\", ($compatibility_score / $total_checks) * 100}")

        if [[ $compatibility_percentage -ge 90 ]]; then
            echo -e "\n${GREEN}${BOLD}🎉 COMPATIBILITY STATUS: EXCELLENT (${compatibility_percentage}%)${NC}"
            echo -e "${GREEN}Your system is optimally configured for Cursor AI${NC}"
        elif [[ $compatibility_percentage -ge 70 ]]; then
            echo -e "\n${YELLOW}${BOLD}✅ COMPATIBILITY STATUS: GOOD (${compatibility_percentage}%)${NC}"
            echo -e "${YELLOW}Your system should run Cursor AI well with minor limitations${NC}"
        else
            echo -e "\n${RED}${BOLD}⚠️ COMPATIBILITY STATUS: LIMITED (${compatibility_percentage}%)${NC}"
            echo -e "${RED}Your system may have performance issues with Cursor AI${NC}"
        fi
    fi

    display_cursor_performance_metrics
    echo ""
    return 0
}

# Export functions for main script
export -f basic_health_check
export -f display_cursor_performance_metrics
export -f production_system_specifications 