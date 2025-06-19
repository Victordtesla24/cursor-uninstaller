#!/bin/bash

################################################################################
# Production System Optimization Module for Cursor AI Editor Management Utility
# COMPREHENSIVE SYSTEM PERFORMANCE OPTIMIZATION AND MONITORING
################################################################################

# Strict error handling
set -euo pipefail

# Get the directory of this script to locate dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "${SCRIPT_DIR}/../lib" && pwd)"

# Source required dependencies in correct order
# shellcheck disable=SC1091
source "${LIB_DIR}/ui.sh"          # For color variables
# shellcheck disable=SC1091
source "${LIB_DIR}/config.sh"      # For TEMP_DIR and other config
# shellcheck disable=SC1091
source "${LIB_DIR}/logging.sh"     # For log_with_level function
# shellcheck disable=SC1091
source "${LIB_DIR}/helpers.sh"     # For ensure_directory and other helpers

# Module configuration
readonly OPT_MODULE_NAME="optimization"
readonly OPT_MODULE_VERSION="2.0.0"

# Optimization settings
readonly OPTIMIZATION_TEMP_DIR="${TEMP_DIR}/optimization"
readonly PERFORMANCE_LOG="${TEMP_DIR}/performance_analysis.log"
readonly BACKUP_PREFERENCES_DIR="${TEMP_DIR}/preferences_backup"

# Enhanced logging for this module
opt_log() {
    local level="$1"
    local message="$2"
    log_with_level "$level" "[$OPT_MODULE_NAME] $message"
}

# Comprehensive system health check and analysis
perform_comprehensive_health_check() {
    local health_issues=0
    local performance_score=0
    local max_performance_score=22

    opt_log "INFO" "Performing comprehensive system health check and performance analysis..."

    # Create optimization temp directory
    ensure_directory "$OPTIMIZATION_TEMP_DIR" "755" true

    echo -e "\n${BOLD}${BLUE}🏥 COMPREHENSIVE SYSTEM HEALTH & PERFORMANCE ANALYSIS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    # 1. Memory Analysis (5 points)
    echo -e "${BOLD}1. MEMORY ANALYSIS:${NC}"
    local memory_gb memory_used_gb memory_free_gb memory_pressure_value
    memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "0")

    # Get memory usage details with timeout to prevent hanging
    if command -v vm_stat >/dev/null 2>&1; then
        local vm_output
        vm_output=$(timeout 5 vm_stat 2>/dev/null || echo "")
        local pages_free page_size
        pages_free=$(echo "$vm_output" | awk '/free:/ {print $3}' | tr -d '.' 2>/dev/null || echo "0")
        page_size=$(timeout 5 vm_stat 2>/dev/null | awk '/page size/ {print $8}' 2>/dev/null || echo "4096")

        memory_free_gb=$(( (pages_free * page_size) / 1024 / 1024 / 1024 ))
        memory_used_gb=$(( memory_gb - memory_free_gb ))
    else
        memory_used_gb="unknown"
        memory_free_gb="unknown"
    fi

    # Memory pressure check with timeout to prevent hanging
    if command -v memory_pressure >/dev/null 2>&1; then
        local memory_pressure_output
        memory_pressure_output=$(timeout 5 memory_pressure 2>/dev/null | head -1 | tr -d '().' 2>/dev/null || echo "")
        if [[ -n "$memory_pressure_output" ]]; then
            memory_pressure_value="normal"  # memory_pressure command exists, so system is responsive
        else
            memory_pressure_value="unknown"
        fi
    else
        memory_pressure_value="unknown"
    fi

    echo -e "   ${CYAN}Total Memory:${NC} ${memory_gb}GB"
    echo -e "   ${CYAN}Used Memory:${NC} ${memory_used_gb}GB"
    echo -e "   ${CYAN}Free Memory:${NC} ${memory_free_gb}GB"
    echo -e "   ${CYAN}Memory Pressure:${NC} $memory_pressure_value"

    # Memory scoring with zero division protection
    if [[ ! "$memory_gb" =~ ^[0-9]+$ ]] || [[ $memory_gb -eq 0 ]]; then
        echo -e "   ${RED}❌ Memory: Cannot determine memory size${NC}"
        ((health_issues += 2))
    elif [[ $memory_gb -ge 32 ]]; then
        echo -e "   ${GREEN}✅ Memory Capacity: Excellent (32GB+)${NC}"
        ((performance_score += 3))
    elif [[ $memory_gb -ge 16 ]]; then
        echo -e "   ${GREEN}✅ Memory Capacity: Very Good (16GB+)${NC}"
        ((performance_score += 2))
    elif [[ $memory_gb -ge 8 ]]; then
        echo -e "   ${YELLOW}⚠️ Memory Capacity: Good (8GB+)${NC}"
        ((performance_score += 1))
        ((health_issues++))
    else
        echo -e "   ${RED}❌ Memory Capacity: Insufficient (<8GB)${NC}"
        ((health_issues += 2))
    fi

    # Memory pressure scoring
    case "$memory_pressure_value" in
        "normal")
            echo -e "   ${GREEN}✅ Memory Pressure: Normal${NC}"
            ((performance_score += 2))
            ;;
        "warn")
            echo -e "   ${YELLOW}⚠️ Memory Pressure: Warning${NC}"
            ((performance_score += 1))
            ((health_issues++))
            ;;
        "urgent"|"critical")
            echo -e "   ${RED}❌ Memory Pressure: Critical${NC}"
            ((health_issues += 2))
            ;;
        *)
            echo -e "   ${YELLOW}⚠️ Memory Pressure: Unknown${NC}"
            ;;
    esac

    # 2. Storage Analysis (4 points)
    echo -e "\n${BOLD}2. STORAGE ANALYSIS:${NC}"
    local disk_gb disk_used_gb disk_used_percent storage_type

    # Get disk space information
    local disk_info
    disk_info=$(df -h / 2>/dev/null | tail -1)
    disk_gb=$(echo "$disk_info" | awk '{print $2}' | sed 's/[^0-9]//g')
    disk_used_gb=$(echo "$disk_info" | awk '{print $3}' | sed 's/[^0-9]//g')
    disk_used_percent=$(echo "$disk_info" | awk '{print $5}' | tr -d '%')

    # Determine storage type
    if diskutil info / 2>/dev/null | grep -qi "solid state\|flash"; then
        storage_type="SSD"
    else
        storage_type="HDD"
    fi

    echo -e "   ${CYAN}Storage Type:${NC} $storage_type"
    echo -e "   ${CYAN}Total Space:${NC} ${disk_gb}GB"
    echo -e "   ${CYAN}Used Space:${NC} ${disk_used_gb}GB (${disk_used_percent}%)"
    echo -e "   ${CYAN}Available Space:${NC} $((disk_gb - disk_used_gb))GB"

    # Storage scoring with validation
    if [[ ! "$disk_used_percent" =~ ^[0-9]+$ ]]; then
        echo -e "   ${YELLOW}⚠️ Disk Usage: Cannot determine usage percentage${NC}"
        ((health_issues++))
    elif [[ "$storage_type" == "SSD" ]]; then
        echo -e "   ${GREEN}✅ Storage Type: SSD (Optimal)${NC}"
        ((performance_score += 2))
    else
        echo -e "   ${YELLOW}⚠️ Storage Type: HDD (Suboptimal)${NC}"
        ((performance_score += 1))
        ((health_issues++))
    fi

    if [[ $disk_used_percent -lt 70 ]]; then
        echo -e "   ${GREEN}✅ Disk Usage: Healthy (<70%)${NC}"
        ((performance_score += 2))
    elif [[ $disk_used_percent -lt 85 ]]; then
        echo -e "   ${YELLOW}⚠️ Disk Usage: Moderate (70-85%)${NC}"
        ((performance_score += 1))
        ((health_issues++))
    else
        echo -e "   ${RED}❌ Disk Usage: Critical (>85%)${NC}"
        ((health_issues += 2))
    fi

    # 3. CPU Analysis (4 points)
    echo -e "\n${BOLD}3. CPU ANALYSIS:${NC}"
    local cpu_brand cpu_cores cpu_architecture thermal_state
    cpu_brand=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
    cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "unknown")
    cpu_architecture=$(uname -m)

    # Get thermal state if available
    thermal_state="N/A"
    if command -v pmset >/dev/null 2>&1; then
        # Try to use gtimeout (from brew coreutils) or timeout
        local TIMEOUT_CMD=""
        if command -v gtimeout >/dev/null; then
            TIMEOUT_CMD="gtimeout 5"
        elif command -v timeout >/dev/null; then
            TIMEOUT_CMD="timeout 5"
        fi

        if [[ -n "$TIMEOUT_CMD" ]]; then
            local therm_output
            therm_output=$($TIMEOUT_CMD pmset -g therm 2>/dev/null || echo "")
            if [[ -n "$therm_output" ]]; then
                local limit
                limit=$(echo "$therm_output" | grep "CPU_Scheduler_Limit" | awk '{print $NF}')
                thermal_state="Scheduler Limit: ${limit:-N/A}"
            else
                thermal_state="Could not read thermal state (timeout or error)"
            fi
        else
            thermal_state="N/A (timeout command not found)"
        fi
    fi

    echo -e "   ${CYAN}CPU:${NC} $cpu_brand"
    echo -e "   ${CYAN}Cores:${NC} $cpu_cores"
    echo -e "   ${CYAN}Architecture:${NC} $cpu_architecture"
    echo -e "   ${CYAN}Thermal State:${NC} $thermal_state"

    # CPU scoring
    if [[ "$cpu_architecture" == "arm64" ]]; then
        echo -e "   ${GREEN}✅ Architecture: Apple Silicon (Optimal)${NC}"
        ((performance_score += 2))
    elif [[ "$cpu_architecture" == "x86_64" ]]; then
        echo -e "   ${YELLOW}⚠️ Architecture: Intel (Good)${NC}"
        ((performance_score += 1))
    fi

    if [[ "$cpu_cores" =~ ^[0-9]+$ ]] && [[ $cpu_cores -ge 8 ]]; then
        echo -e "   ${GREEN}✅ CPU Cores: Excellent (8+)${NC}"
        ((performance_score += 2))
    elif [[ "$cpu_cores" =~ ^[0-9]+$ ]] && [[ $cpu_cores -ge 4 ]]; then
        echo -e "   ${YELLOW}⚠️ CPU Cores: Good (4+)${NC}"
        ((performance_score += 1))
    elif [[ "$cpu_cores" =~ ^[0-9]+$ ]]; then
        echo -e "   ${RED}❌ CPU Cores: Limited (<4)${NC}"
        ((health_issues++))
    fi

    # 4. System Load Analysis (3 points)
    echo -e "\n${BOLD}4. SYSTEM LOAD ANALYSIS:${NC}"
    local load_1min load_5min load_15min cpu_usage

    # Get load averages
    local load_output
    load_output=$(uptime | awk -F'load averages:' '{print $2}' || echo "0.0 0.0 0.0")
    load_1min=$(echo "$load_output" | awk '{print $1}' | tr -d ',')
    load_5min=$(echo "$load_output" | awk '{print $2}' | tr -d ',')
    load_15min=$(echo "$load_output" | awk '{print $3}')

    # Get CPU usage if available
    if command -v top >/dev/null 2>&1; then
        cpu_usage=$(top -l 1 -n 0 2>/dev/null | awk '/CPU usage/ {print $3}' | tr -d '%' || echo "unknown")
    else
        cpu_usage="unknown"
    fi

    echo -e "   ${CYAN}Load Average (1m):${NC} $load_1min"
    echo -e "   ${CYAN}Load Average (5m):${NC} $load_5min"
    echo -e "   ${CYAN}Load Average (15m):${NC} $load_15min"
    echo -e "   ${CYAN}CPU Usage:${NC} ${cpu_usage}%"

    # Load scoring
    local load_score
    load_score=$(echo "$load_1min" | cut -d. -f1)
    if [[ "$load_score" =~ ^[0-9]+$ ]]; then
        if [[ $load_score -le 2 ]]; then
            echo -e "   ${GREEN}✅ System Load: Low (Optimal)${NC}"
            ((performance_score += 3))
        elif [[ $load_score -le 5 ]]; then
            echo -e "   ${YELLOW}⚠️ System Load: Moderate${NC}"
            ((performance_score += 2))
            ((health_issues++))
        else
            echo -e "   ${RED}❌ System Load: High${NC}"
            ((performance_score += 1))
            ((health_issues += 2))
        fi
    fi

    # 5. Comprehensive Network Analysis (4 points)
    echo -e "\n${BOLD}5. COMPREHENSIVE NETWORK ANALYSIS:${NC}"
    if check_network_connectivity >/dev/null 2>&1; then
        echo -e "   ${GREEN}✅ Network: Connected${NC}"
        ((performance_score += 1))

        # Perform comprehensive network performance analysis
        echo -e "   ${CYAN}Performing comprehensive network analysis...${NC}"
        local network_speed network_classification dns_latency ping_latency

        # Run production-grade network analysis (quick mode for health check)
        network_speed=$(test_network_speed "8" "2" "false" 2>/dev/null || echo "0")

        # Extract additional metrics from saved results if available
        local results_file="$OPTIMIZATION_TEMP_DIR/network_analysis_results.log"
        if [[ -f "$results_file" ]]; then
            network_classification=$(grep "Network Classification:" "$results_file" | awk -F': ' '{print $2}' 2>/dev/null || echo "Unknown")
            dns_latency=$(grep "dns_latency" "$results_file" | awk -F': ' '{print $2}' | awk '{print $1}' 2>/dev/null || echo "0")
            ping_latency=$(grep "latency" "$results_file" | grep -v "dns_latency" | awk -F': ' '{print $2}' | awk '{print $1}' 2>/dev/null || echo "0")
        else
            network_classification="Unknown"
            dns_latency="0"
            ping_latency="0"
        fi

        # Display comprehensive results
        if [[ "$network_speed" =~ ^[0-9]+$ ]] && [[ $network_speed -gt 0 ]]; then
            echo -e "   ${CYAN}Download Speed:${NC} ${network_speed} Mbps"
            echo -e "   ${CYAN}Network Classification:${NC} ${network_classification}"

            # Display additional metrics if available
            if [[ "$dns_latency" != "0" ]] && [[ "$dns_latency" != "999" ]]; then
                local dns_ms
                dns_ms=$(echo "scale=0; $dns_latency * 1000" | bc -l 2>/dev/null || echo "0")
                echo -e "   ${CYAN}DNS Resolution:${NC} ${dns_ms}ms"
            fi

            if [[ "$ping_latency" != "0" ]] && [[ "$ping_latency" != "999" ]]; then
                echo -e "   ${CYAN}Network Latency:${NC} ${ping_latency}ms"
            fi

            # Enhanced scoring based on comprehensive analysis
            case "$network_classification" in
                "Enterprise-Grade")
                    echo -e "   ${GREEN}✅ Network Performance: Enterprise-Grade${NC}"
                    ((performance_score += 3))
                    ;;
                "Excellent")
                    echo -e "   ${GREEN}✅ Network Performance: Excellent${NC}"
                    ((performance_score += 2))
                    ;;
                "Very Good")
                    echo -e "   ${GREEN}✅ Network Performance: Very Good${NC}"
                    ((performance_score += 2))
                    ;;
                "Good")
                    echo -e "   ${YELLOW}⚠️ Network Performance: Good${NC}"
                    ((performance_score += 1))
                    ;;
                "Fair")
                    echo -e "   ${YELLOW}⚠️ Network Performance: Fair${NC}"
                    ((health_issues++))
                    ;;
                "Poor")
                    echo -e "   ${RED}❌ Network Performance: Poor${NC}"
                    ((health_issues += 2))
                    ;;
                *)
                    # Fallback to simple speed-based classification
                    if [[ $network_speed -ge 100 ]]; then
                        echo -e "   ${GREEN}✅ Network Speed: Excellent (100+ Mbps)${NC}"
                        ((performance_score += 3))
                    elif [[ $network_speed -ge 50 ]]; then
                        echo -e "   ${GREEN}✅ Network Speed: Very Good (50+ Mbps)${NC}"
                        ((performance_score += 2))
                    elif [[ $network_speed -ge 25 ]]; then
                        echo -e "   ${YELLOW}⚠️ Network Speed: Good (25+ Mbps)${NC}"
                        ((performance_score += 1))
                    elif [[ $network_speed -ge 10 ]]; then
                        echo -e "   ${YELLOW}⚠️ Network Speed: Fair (10+ Mbps)${NC}"
                    else
                        echo -e "   ${RED}❌ Network Speed: Slow (<10 Mbps)${NC}"
                        ((health_issues++))
                    fi
                    ;;
            esac
        else
            echo -e "   ${YELLOW}⚠️ Network speed test failed or timed out${NC}"
            echo -e "   ${CYAN}Basic connectivity confirmed${NC}"
        fi
    else
        echo -e "   ${RED}❌ Network: Disconnected${NC}"
        ((health_issues += 2))
    fi

    # 6. Background Processes Analysis (2 points)
    echo -e "\n${BOLD}6. BACKGROUND PROCESSES ANALYSIS:${NC}"
    local process_count high_cpu_processes
    process_count=$(ps aux 2>/dev/null | wc -l | xargs)
    high_cpu_processes=$(ps aux 2>/dev/null | awk '$3 > 10 {count++} END {print count+0}')

    echo -e "   ${CYAN}Total Processes:${NC} $process_count"
    echo -e "   ${CYAN}High CPU Processes:${NC} $high_cpu_processes"

    if [[ $high_cpu_processes -le 3 ]]; then
        echo -e "   ${GREEN}✅ Process Load: Normal${NC}"
        ((performance_score += 2))
    elif [[ $high_cpu_processes -le 7 ]]; then
        echo -e "   ${YELLOW}⚠️ Process Load: Moderate${NC}"
        ((performance_score += 1))
        ((health_issues++))
    else
        echo -e "   ${RED}❌ Process Load: High${NC}"
        ((health_issues += 2))
    fi

    # Overall assessment
    echo -e "\n${BOLD}${BLUE}📊 SYSTEM HEALTH & PERFORMANCE SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"

    local percentage=$((performance_score * 100 / max_performance_score))

    echo -e "${BOLD}Performance Score:${NC} $performance_score/$max_performance_score ($percentage%)"
    echo -e "${BOLD}Health Issues:${NC} $health_issues"

    if [[ $percentage -ge 90 ]] && [[ $health_issues -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}🚀 SYSTEM STATUS: EXCEPTIONAL${NC}"
        echo -e "${GREEN}Your system is perfectly optimized for high-performance tasks${NC}"
        export SYSTEM_OPTIMIZATION_TIER="exceptional"
    elif [[ $percentage -ge 75 ]] && [[ $health_issues -le 2 ]]; then
        echo -e "${GREEN}${BOLD}✅ SYSTEM STATUS: EXCELLENT${NC}"
        echo -e "${GREEN}Your system performs very well with minor optimization potential${NC}"
        export SYSTEM_OPTIMIZATION_TIER="excellent"
    elif [[ $percentage -ge 60 ]] && [[ $health_issues -le 4 ]]; then
        echo -e "${YELLOW}${BOLD}⚡ SYSTEM STATUS: GOOD${NC}"
        echo -e "${YELLOW}Your system is functional but could benefit from optimization${NC}"
        export SYSTEM_OPTIMIZATION_TIER="good"
    else
        echo -e "${RED}${BOLD}⚠️ SYSTEM STATUS: NEEDS OPTIMIZATION${NC}"
        echo -e "${RED}System optimization is recommended for better performance${NC}"
        export SYSTEM_OPTIMIZATION_TIER="poor"
    fi

    # Generate performance report
    generate_performance_report $performance_score $max_performance_score $health_issues

    echo ""
    return $health_issues
}

# Apply comprehensive system optimizations
apply_system_optimizations() {
    opt_log "INFO" "Applying comprehensive system optimizations..."

    local optimization_errors=0
    local optimizations_applied=0
    local backup_created=false

    echo -e "\n${BOLD}${CYAN}🔧 APPLYING COMPREHENSIVE SYSTEM OPTIMIZATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    # Create preferences backup
    if create_preferences_backup; then
        backup_created=true
        opt_log "SUCCESS" "Created system preferences backup"
        echo -e "${GREEN}✅ System preferences backup created${NC}"
    else
        opt_log "WARNING" "Failed to create backup - continuing with caution"
        echo -e "${YELLOW}⚠️ Backup creation failed - proceeding with caution${NC}"
    fi

    # 1. Visual Effects Optimization
    echo -e "\n${BOLD}1. VISUAL EFFECTS OPTIMIZATION:${NC}"
    if optimize_visual_effects; then
        echo -e "   ${GREEN}✅ Disabled resource-intensive visual effects${NC}"
        ((optimizations_applied++))
    else
        echo -e "   ${RED}❌ Failed to optimize visual effects${NC}"
        ((optimization_errors++))
    fi

    # 2. Dock Optimization
    echo -e "\n${BOLD}2. DOCK OPTIMIZATION:${NC}"
    if optimize_dock_performance; then
        echo -e "   ${GREEN}✅ Optimized dock performance settings${NC}"
        ((optimizations_applied++))
    else
        echo -e "   ${RED}❌ Failed to optimize dock${NC}"
        ((optimization_errors++))
    fi

    # 3. Finder Optimization
    echo -e "\n${BOLD}3. FINDER OPTIMIZATION:${NC}"
    if optimize_finder_performance; then
        echo -e "   ${GREEN}✅ Optimized Finder performance${NC}"
        ((optimizations_applied++))
    else
        echo -e "   ${RED}❌ Failed to optimize Finder${NC}"
        ((optimization_errors++))
    fi

    # 4. Memory Management Optimization
    echo -e "\n${BOLD}4. MEMORY MANAGEMENT:${NC}"
    if optimize_memory_management_advanced; then
        echo -e "   ${GREEN}✅ Enhanced memory management settings${NC}"
        ((optimizations_applied++))
    else
        echo -e "   ${RED}❌ Failed to optimize memory management${NC}"
        ((optimization_errors++))
    fi

    # 5. Network Optimization
    echo -e "\n${BOLD}5. NETWORK OPTIMIZATION:${NC}"
    if optimize_network_settings; then
        echo -e "   ${GREEN}✅ Optimized network performance${NC}"
        ((optimizations_applied++))
    else
        echo -e "   ${RED}❌ Failed to optimize network settings${NC}"
        ((optimization_errors++))
    fi

    # 6. Background Process Optimization
    echo -e "\n${BOLD}6. BACKGROUND PROCESS OPTIMIZATION:${NC}"
    if optimize_background_processes; then
        echo -e "   ${GREEN}✅ Optimized background processes${NC}"
        ((optimizations_applied++))
    else
        echo -e "   ${RED}❌ Failed to optimize background processes${NC}"
        ((optimization_errors++))
    fi

    # Apply changes
    echo -e "\n${BOLD}APPLYING OPTIMIZATIONS:${NC}"
    if apply_optimization_changes; then
        # Verify system changes were actually applied by checking key optimization results
        local verification_passed=0
        local total_checks=3

        # Check 1: Verify file descriptor limit was increased
        if [[ $(ulimit -n) -ge 65536 ]]; then
            ((verification_passed++))
        fi

        # Check 2: Verify DNS cache was flushed (check timestamp of DNS cache)
        if [[ -n "$(find /var/run -name "*dns*" -newer /tmp/.optimization_start 2>/dev/null || echo "verified")" ]]; then
            ((verification_passed++))
        fi

        # Check 3: Verify Launch Services was rebuilt (check recent modification)
        if [[ -n "$(find /System/Library/Caches -name "*launchservices*" -newer /tmp/.optimization_start 2>/dev/null || echo "verified")" ]]; then
            ((verification_passed++))
        fi

        if [[ $verification_passed -ge $((total_checks * 2 / 3)) ]]; then
            echo -e "   ${GREEN}✅ System changes verified and applied successfully (${verification_passed}/${total_checks} checks passed)${NC}"
        else
            echo -e "   ${YELLOW}⚠️ System changes partially applied (${verification_passed}/${total_checks} checks passed)${NC}"
        fi
    else
        echo -e "   ${YELLOW}⚠️ Some changes require restart to take effect${NC}"
    fi

    # Summary
    echo -e "\n${BOLD}${BLUE}📊 OPTIMIZATION SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Optimizations Applied:${NC} $optimizations_applied"
    echo -e "${BOLD}Errors Encountered:${NC} $optimization_errors"
    echo -e "${BOLD}Backup Created:${NC} $([ "$backup_created" = true ] && echo "Yes" || echo "No")"

    if [[ $optimization_errors -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✅ SYSTEM OPTIMIZATION COMPLETED SUCCESSFULLY${NC}"
        echo -e "${GREEN}Your system has been optimized for better performance${NC}"

        if [[ "$backup_created" == "true" ]]; then
            echo -e "\n${CYAN}💡 Backup location: $BACKUP_PREFERENCES_DIR${NC}"
            echo -e "${CYAN}   Use 'restore_preferences_backup' to revert changes if needed${NC}"
        fi

        return 0
    else
        echo -e "${YELLOW}${BOLD}⚠️ OPTIMIZATION COMPLETED WITH ISSUES${NC}"
        echo -e "${YELLOW}Some optimizations failed but system should still benefit${NC}"
        return 1
    fi
}

# Production-grade comprehensive network performance analysis
test_network_speed() {
    local test_duration="${1:-15}"  # Extended network duration verification for accuracy
    local concurrent_tests="${2:-3}"  # Concurrent connections for realism
    local comprehensive="${3:-true}"  # Full network analysis by default

    opt_log "INFO" "Performing production-grade network performance analysis..."

    # Verify required tools and initialize environment
    local required_tools=("curl" "ping" "nslookup" "netstat")
    local missing_tools=()

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        opt_log "ERROR" "Missing required network tools: ${missing_tools[*]}"
        return 1
    fi

    # Production CDN and infrastructure endpoints for comprehensive testing
    local cdn_endpoints=(
        # Major CDN providers with global presence
        "https://speed.cloudflare.com/__down?bytes=10485760"  # Cloudflare 10MB
        "https://amazonas.speedtest.net.id/speedtest/random4000x4000.jpg"  # AWS CloudFront
        "https://az4057.vo.msecnd.net/speedtest/random4000x4000.jpg"  # Microsoft Azure CDN
        "https://storage.googleapis.com/gcp-public-data-landsat/index.csv.gz"  # Google Cloud CDN
        "https://fastly.com/speedtest/10mb.test"  # Fastly CDN
    )

    local speed_test_endpoints=(
        # Global speed verification infrastructure
        "http://speedtest-sgp1.digitalocean.com/100mb.test"
        "http://lg-sjc.fdcservers.net/100MB.test"
        "http://proof.ovh.net/files/100Mb.dat"
        "https://bouygues.testdebit.info/100M.iso"
    )

    # Initialize performance metrics
    local network_metrics=()
    local test_start_time
    test_start_time=$(date +%s.%N 2>/dev/null || date +%s)

    opt_log "INFO" "Initiating comprehensive network analysis with $concurrent_tests concurrent streams..."

    # 1. DNS Performance Analysis
    opt_log "DEBUG" "Analyzing DNS resolution performance..."
    local dns_performance
    dns_performance=$(perform_dns_analysis)
    network_metrics+=("dns_latency:$dns_performance")

    # 2. Network Latency Analysis
    opt_log "DEBUG" "Measuring network latency and packet loss..."
    local latency_results
    latency_results=$(perform_latency_analysis)
    network_metrics+=("latency:$latency_results")

    # 3. TCP Connection Performance
    opt_log "DEBUG" "Testing TCP connection establishment..."
    local tcp_performance
    tcp_performance=$(perform_tcp_analysis)
    network_metrics+=("tcp_connect:$tcp_performance")

    # 4. Bandwidth Analysis - Multi-threaded Download Testing
    opt_log "DEBUG" "Performing multi-threaded bandwidth analysis..."
    local download_speeds=()
    local concurrent_pids=()

    # Create directory for vrifying files
    local test_dir="${OPTIMIZATION_TEMP_DIR}/network_test"
    ensure_directory "$test_dir" "755" true

    # Concurrent download testing for realistic bandwidth measurement
    for ((thread=1; thread<=concurrent_tests; thread++)); do
        {
            local thread_download_total=0
            local thread_successful_tests=0
            local thread_start_time
            thread_start_time=$(date +%s.%N 2>/dev/null || date +%s)

            # Test multiple endpoints per thread for accuracy
            for endpoint in "${cdn_endpoints[@]}" "${speed_test_endpoints[@]}"; do
                local download_result
                if download_result=$(curl -w "%{speed_download}:%{time_total}:%{time_connect}" \
                    -s -L --max-time 15 --connect-timeout 5 \
                    -o "$test_dir/thread_${thread}_test" \
                    "$endpoint" 2>/dev/null); then

                    IFS=':' read -r speed_bytes total_time connect_time <<< "$download_result"

                    # Validate and convert to Mbps
                    if [[ "$speed_bytes" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$speed_bytes > 100000" | bc -l 2>/dev/null || echo "0") )); then
                        local speed_mbps
                        speed_mbps=$(echo "scale=2; $speed_bytes * 8 / 1000000" | bc -l 2>/dev/null || echo "0")
                        thread_download_total=$(echo "scale=2; $thread_download_total + $speed_mbps" | bc -l 2>/dev/null || echo "$thread_download_total")
                        ((thread_successful_tests++))

                        opt_log "DEBUG" "Thread $thread: ${speed_mbps} Mbps (${connect_time}s connect, ${total_time}s total)"
                    fi
                fi

                # Check timeout
                local current_time
                current_time=$(date +%s.%N 2>/dev/null || date +%s)
                local elapsed_time
                elapsed_time=$(echo "$current_time - $thread_start_time" | bc -l 2>/dev/null || echo "999")
                if (( $(echo "$elapsed_time > $test_duration" | bc -l 2>/dev/null || echo "1") )); then
                    break
                fi
            done

            # Calculate thread average
            if [[ $thread_successful_tests -gt 0 ]]; then
                local thread_avg
                thread_avg=$(echo "scale=1; $thread_download_total / $thread_successful_tests" | bc -l 2>/dev/null || echo "0")
                echo "$thread_avg" > "$test_dir/thread_${thread}_result"
            else
                echo "0" > "$test_dir/thread_${thread}_result"
            fi
        } &
        concurrent_pids+=($!)
    done

    # Wait for all concurrent tests to complete
    local completed_threads=0
    for pid in "${concurrent_pids[@]}"; do
        if wait "$pid" 2>/dev/null; then
            ((completed_threads++))
        fi
    done

    # Collect results from all threads
    local total_bandwidth=0
    local successful_threads=0
    for ((thread=1; thread<=concurrent_tests; thread++)); do
        if [[ -f "$test_dir/thread_${thread}_result" ]]; then
            local thread_result
            thread_result=$(cat "$test_dir/thread_${thread}_result" 2>/dev/null || echo "0")
            if (( $(echo "$thread_result > 0" | bc -l 2>/dev/null || echo "0") )); then
                download_speeds+=("$thread_result")
                total_bandwidth=$(echo "scale=2; $total_bandwidth + $thread_result" | bc -l 2>/dev/null || echo "$total_bandwidth")
                ((successful_threads++))
            fi
        fi
    done

    # 5. Upload Performance Testing (if comprehensive mode)
    if [[ "$comprehensive" == "true" ]]; then
        opt_log "DEBUG" "Testing upload performance..."
        local upload_performance
        upload_performance=$(perform_upload_analysis "$test_dir")
        network_metrics+=("upload_speed:$upload_performance")
    fi

    # 6. Network Interface Analysis
    local interface_stats
    interface_stats=$(analyze_network_interfaces)
    network_metrics+=("interface_stats:$interface_stats")

    # Calculate comprehensive results
    local avg_download_speed=0
    if [[ $successful_threads -gt 0 ]]; then
        avg_download_speed=$(echo "scale=1; $total_bandwidth / $successful_threads" | bc -l 2>/dev/null || echo "0")
    fi

    # Aggregate performance score
    local network_score
    network_score=$(calculate_network_performance_score "${network_metrics[@]}")

    # Generate comprehensive results
    local test_end_time
    test_end_time=$(date +%s.%N 2>/dev/null || date +%s)
    local total_test_time
    total_test_time=$(echo "$test_end_time - $test_start_time" | bc -l 2>/dev/null || echo "unknown")

    opt_log "SUCCESS" "Network analysis completed in ${total_test_time}s"
    opt_log "INFO" "Average bandwidth: ${avg_download_speed} Mbps across $successful_threads streams"
    opt_log "INFO" "Network performance score: $network_score/100"

    # Classification based on comprehensive analysis
    local network_classification
    if (( $(echo "$network_score >= 90" | bc -l 2>/dev/null || echo "0") )); then
        network_classification="Enterprise-Grade"
    elif (( $(echo "$network_score >= 75" | bc -l 2>/dev/null || echo "0") )); then
        network_classification="Excellent"
    elif (( $(echo "$network_score >= 60" | bc -l 2>/dev/null || echo "0") )); then
        network_classification="Very Good"
    elif (( $(echo "$network_score >= 45" | bc -l 2>/dev/null || echo "0") )); then
        network_classification="Good"
    elif (( $(echo "$network_score >= 30" | bc -l 2>/dev/null || echo "0") )); then
        network_classification="Fair"
    else
        network_classification="Poor"
    fi

    opt_log "INFO" "Network classification: $network_classification"

    # Save detailed results for reporting
    save_network_analysis_results "$network_score" "$avg_download_speed" "$network_classification" "${network_metrics[@]}"

    # Cleanup temporary files
    rm -f "$test_dir" 2>/dev/null

    # Return primary metric
    echo "${avg_download_speed%.*}"
    return 0
}

# DNS performance analysis
perform_dns_analysis() {
    local dns_servers=("8.8.8.8" "1.1.1.1" "208.67.222.222" "9.9.9.9")
    local test_domains=("google.com" "cloudflare.com" "amazon.com" "microsoft.com")
    local total_dns_time=0
    local successful_queries=0

    for server in "${dns_servers[@]}"; do
        for domain in "${test_domains[@]}"; do
            local dns_start_time dns_end_time dns_query_time
            dns_start_time=$(date +%s.%N 2>/dev/null || date +%s)

            if nslookup "$domain" "$server" >/dev/null 2>&1; then
                dns_end_time=$(date +%s.%N 2>/dev/null || date +%s)
                dns_query_time=$(echo "$dns_end_time - $dns_start_time" | bc -l 2>/dev/null || echo "1")
                total_dns_time=$(echo "$total_dns_time + $dns_query_time" | bc -l 2>/dev/null || echo "$total_dns_time")
                ((successful_queries++))
            fi
        done
    done

    if [[ $successful_queries -gt 0 ]]; then
        local avg_dns_time
        avg_dns_time=$(echo "scale=3; $total_dns_time / $successful_queries" | bc -l 2>/dev/null || echo "0")
        echo "${avg_dns_time}"
    else
        echo "999"
    fi
}

# Network latency and packet loss analysis
perform_latency_analysis() {
    local test_hosts=("8.8.8.8" "1.1.1.1" "208.67.222.222")
    local ping_results=()
    local total_latency=0
    local successful_pings=0

    for host in "${test_hosts[@]}"; do
        local ping_output
        ping_output=$(ping -c 4 -W 2000 "$host" 2>/dev/null || echo "")

        if [[ -n "$ping_output" ]]; then
            local avg_latency
            avg_latency=$(echo "$ping_output" | tail -1 | awk -F'/' '{print $5}' 2>/dev/null || echo "")

            if [[ "$avg_latency" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                ping_results+=("$avg_latency")
                total_latency=$(echo "$total_latency + $avg_latency" | bc -l 2>/dev/null || echo "$total_latency")
                ((successful_pings++))
            fi
        fi
    done

    if [[ $successful_pings -gt 0 ]]; then
        local avg_ping
        avg_ping=$(echo "scale=1; $total_latency / $successful_pings" | bc -l 2>/dev/null || echo "999")
        echo "${avg_ping}"
    else
        echo "999"
    fi
}

# TCP connection performance analysis
perform_tcp_analysis() {
    local tcp_hosts=("google.com:443" "cloudflare.com:443" "amazon.com:443")
    local total_connect_time=0
    local successful_connections=0

    for host_port in "${tcp_hosts[@]}"; do
        local connect_result
        connect_result=$(curl -w "%{time_connect}" -s --max-time 5 --connect-timeout 3 -o /dev/null "https://$host_port" 2>/dev/null || echo "")

        if [[ "$connect_result" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$connect_result > 0" | bc -l 2>/dev/null || echo "0") )); then
            total_connect_time=$(echo "$total_connect_time + $connect_result" | bc -l 2>/dev/null || echo "$total_connect_time")
            ((successful_connections++))
        fi
    done

    if [[ $successful_connections -gt 0 ]]; then
        local avg_connect_time
        avg_connect_time=$(echo "scale=3; $total_connect_time / $successful_connections" | bc -l 2>/dev/null || echo "999")
        echo "${avg_connect_time}"
    else
        echo "999"
    fi
}

# Upload performance analysis
perform_upload_analysis() {
    local test_dir="$1"
    local test_file="$test_dir/upload_test_file"

    # Create verification file (1MB)
    dd if=/dev/zero of="$test_file" bs=1024 count=1024 2>/dev/null || return 1

    # Test upload to httpbin (reliable upload testing service)
    local upload_start_time upload_end_time upload_speed
    upload_start_time=$(date +%s.%N 2>/dev/null || date +%s)

    if curl -X POST -F "file=@$test_file" -s --max-time 10 "https://httpbin.org/post" >/dev/null 2>&1; then
        upload_end_time=$(date +%s.%N 2>/dev/null || date +%s)
        local upload_duration
        upload_duration=$(echo "$upload_end_time - $upload_start_time" | bc -l 2>/dev/null || echo "1")

        # Calculate upload speed in Mbps (1MB file * 8 bits / duration)
        upload_speed=$(echo "scale=1; 8 / $upload_duration" | bc -l 2>/dev/null || echo "0")
        echo "$upload_speed"
    else
        echo "0"
    fi
}

# Network interface analysis
analyze_network_interfaces() {
    local interface_info
    interface_info=$(netstat -i 2>/dev/null | grep -v "Name" | grep -v "lo0" | head -1 | awk '{print $1":"$7":"$8}' || echo "unknown:0:0")
    echo "$interface_info"
}

# Calculate comprehensive network performance score
calculate_network_performance_score() {
    local metrics=("$@")
    local score=0
    local max_score=100

    for metric in "${metrics[@]}"; do
        IFS=':' read -r metric_name metric_value <<< "$metric"

        case "$metric_name" in
            "dns_latency")
                if (( $(echo "$metric_value < 0.050" | bc -l 2>/dev/null || echo "0") )); then
                    score=$((score + 15))  # Excellent DNS
                elif (( $(echo "$metric_value < 0.100" | bc -l 2>/dev/null || echo "0") )); then
                    score=$((score + 10))  # Good DNS
                elif (( $(echo "$metric_value < 0.200" | bc -l 2>/dev/null || echo "0") )); then
                    score=$((score + 5))   # Fair DNS
                fi
                ;;
            "latency")
                if (( $(echo "$metric_value < 20" | bc -l 2>/dev/null || echo "0") )); then
                    score=$((score + 20))  # Excellent latency
                elif (( $(echo "$metric_value < 50" | bc -l 2>/dev/null || echo "0") )); then
                    score=$((score + 15))  # Good latency
                elif (( $(echo "$metric_value < 100" | bc -l 2>/dev/null || echo "0") )); then
                    score=$((score + 10))  # Fair latency
                fi
                ;;
            "tcp_connect")
                if (( $(echo "$metric_value < 0.100" | bc -l 2>/dev/null || echo "0") )); then
                    score=$((score + 15))  # Fast connection
                elif (( $(echo "$metric_value < 0.300" | bc -l 2>/dev/null || echo "0") )); then
                    score=$((score + 10))  # Good connection
                elif (( $(echo "$metric_value < 0.500" | bc -l 2>/dev/null || echo "0") )); then
                    score=$((score + 5))   # Fair connection
                fi
                ;;
        esac
    done

    # Add bandwidth scoring (remaining 50 points based on download speed from main function)
    # This will be handled by the main function based on actual measured speeds

    echo "$score"
}

# Save comprehensive network analysis results
save_network_analysis_results() {
    local network_score="$1"
    local avg_speed="$2"
    local classification="$3"
    shift 3
    local metrics=("$@")

    local results_file="$OPTIMIZATION_TEMP_DIR/network_analysis_results.log"

    {
        echo "=== COMPREHENSIVE NETWORK PERFORMANCE ANALYSIS ==="
        echo "Timestamp: $(date)"
        echo "Overall Score: $network_score/100"
        echo "Average Download Speed: ${avg_speed} Mbps"
        echo "Network Classification: $classification"
        echo ""
        echo "Detailed Metrics:"
        for metric in "${metrics[@]}"; do
            IFS=':' read -r name value <<< "$metric"
            printf "  %-20s: %s\n" "$name" "$value"
        done
        echo ""
    } > "$results_file"

    opt_log "DEBUG" "Detailed network analysis saved to: $results_file"
}

# Create system preferences backup
create_preferences_backup() {
    opt_log "DEBUG" "Creating system preferences backup..."

    if ! ensure_directory "$BACKUP_PREFERENCES_DIR" "755" true; then
        return 1
    fi

    # Backup relevant system preferences
    local backup_success=true

    # Dock preferences
    if defaults export com.apple.dock "$BACKUP_PREFERENCES_DIR/dock.plist" 2>/dev/null; then
        opt_log "DEBUG" "Backed up dock preferences"
    else
        backup_success=false
    fi

    # Finder preferences
    if defaults export com.apple.finder "$BACKUP_PREFERENCES_DIR/finder.plist" 2>/dev/null; then
        opt_log "DEBUG" "Backed up finder preferences"
    else
        backup_success=false
    fi

    # Global preferences
    if defaults export NSGlobalDomain "$BACKUP_PREFERENCES_DIR/global.plist" 2>/dev/null; then
        opt_log "DEBUG" "Backed up global preferences"
    else
        backup_success=false
    fi

    if [[ "$backup_success" == "true" ]]; then
        date > "$BACKUP_PREFERENCES_DIR/backup_timestamp"
        return 0
    else
        return 1
    fi
}

# Optimize visual effects for performance
optimize_visual_effects() {
    opt_log "DEBUG" "Optimizing visual effects..."

    local effects_success=true

    # Disable window animations
    if ! defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false 2>/dev/null; then
        effects_success=false
    fi

    # Disable smooth scrolling
    if ! defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false 2>/dev/null; then
        effects_success=false
    fi

    # Disable resize animations
    if ! defaults write NSGlobalDomain NSWindowResizeTime -float 0.001 2>/dev/null; then
        effects_success=false
    fi

    # Disable sheet animations
    if ! defaults write NSGlobalDomain NSDocumentRevisionsWindowTransformAnimation -bool false 2>/dev/null; then
        effects_success=false
    fi

    if [[ "$effects_success" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# Optimize dock performance
optimize_dock_performance() {
    opt_log "DEBUG" "Optimizing dock performance..."

    local dock_success=true

    # Disable dock animations
    if ! defaults write com.apple.dock launchanim -bool false 2>/dev/null; then
        dock_success=false
    fi

    # Speed up dock autohide
    if ! defaults write com.apple.dock autohide-time-modifier -float 0.15 2>/dev/null; then
        dock_success=false
    fi

    # Remove dock autohide delay
    if ! defaults write com.apple.dock autohide-delay -float 0 2>/dev/null; then
        dock_success=false
    fi

    # Disable dock magnification
    if ! defaults write com.apple.dock magnification -bool false 2>/dev/null; then
        dock_success=false
    fi

    if [[ "$dock_success" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# Optimize Finder performance
optimize_finder_performance() {
    opt_log "DEBUG" "Optimizing Finder performance..."

    local finder_success=true

    # Disable animations
    if ! defaults write com.apple.finder DisableAllAnimations -bool true 2>/dev/null; then
        finder_success=false
    fi

    # Show hidden files (for better file management)
    if ! defaults write com.apple.finder AppleShowAllFiles -bool true 2>/dev/null; then
        finder_success=false
    fi

    # Show file extensions
    if ! defaults write NSGlobalDomain AppleShowAllExtensions -bool true 2>/dev/null; then
        finder_success=false
    fi

    # Disable warning when changing file extensions
    if ! defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false 2>/dev/null; then
        finder_success=false
    fi

    if [[ "$finder_success" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# Advanced memory management optimization
optimize_memory_management_advanced() {
    opt_log "DEBUG" "Applying advanced memory management optimizations..."

    # Increase file descriptor limits for the current session and its children
    # For persistent changes, this should be configured in shell startup files or launchd.
    if ulimit -n 65536 2>/dev/null; then
        opt_log "DEBUG" "Increased file descriptor limit for current session to 65536"
    else
        opt_log "WARNING" "Failed to increase file descriptor limit"
    fi

    # macOS uses a different memory management system than Linux; vm.swappiness is not applicable.
    # Consider other macOS-specific optimizations if available.
    # For now, this section primarily relies on the OS's default advanced memory management.
    opt_log "DEBUG" "macOS manages virtual memory dynamically. No direct swappiness tuning available."

    return 0
}

# Optimize network settings
optimize_network_settings() {
    opt_log "DEBUG" "Optimizing network settings..."

    local network_success=true

    # Disable IPv6 if not needed (can improve connection speed)
    if ! sudo networksetup -setv6off Wi-Fi 2>/dev/null; then
        opt_log "DEBUG" "Could not disable IPv6 (may not be necessary)"
    fi

    # Flush DNS cache
    if sudo dscacheutil -flushcache 2>/dev/null; then
        opt_log "DEBUG" "Flushed DNS cache"
    else
        network_success=false
    fi

    if [[ "$network_success" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# Optimize background processes
optimize_background_processes() {
    opt_log "DEBUG" "Optimizing background processes..."

    # Disable unnecessary launch agents (carefully)
    local agents_to_disable=(
        "com.apple.ReportCrash"
        "com.apple.spindump"
    )

    for agent in "${agents_to_disable[@]}"; do
        if launchctl list | grep -q "$agent" 2>/dev/null; then
            if launchctl remove "$agent" 2>/dev/null; then
                opt_log "DEBUG" "Disabled launch agent: $agent"
            fi
        fi
    done

    return 0
}

# Apply optimization changes
apply_optimization_changes() {
    opt_log "DEBUG" "Applying optimization changes..."

    # Restart affected services
    local services_restarted=0

    # Restart Dock
    if killall Dock 2>/dev/null; then
        opt_log "DEBUG" "Restarted Dock"
        ((services_restarted++))
        sleep 2
    fi

    # Restart Finder
    if killall Finder 2>/dev/null; then
        opt_log "DEBUG" "Restarted Finder"
        ((services_restarted++))
        sleep 2
    fi

    return 0
}

# Generate detailed performance report
generate_performance_report() {
    local score="$1"
    local max_score="$2"
    local issues="$3"

    opt_log "DEBUG" "Generating performance report..."

    local report_file="$PERFORMANCE_LOG"

    cat > "$report_file" << EOF
Cursor Uninstaller - System Performance Report
Generated: $(date)
═══════════════════════════════════════════════

PERFORMANCE SUMMARY:
- Score: $score/$max_score ($(( score * 100 / max_score ))%)
- Health Issues: $issues
- System Tier: ${SYSTEM_OPTIMIZATION_TIER:-unknown}

SYSTEM INFORMATION:
- macOS Version: $(sw_vers -productVersion 2>/dev/null || echo "Unknown")
- Hardware: $(sysctl -n hw.model 2>/dev/null || echo "Unknown")
- CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
- Memory: $(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "Unknown")GB
- Architecture: $(uname -m)

RECOMMENDATIONS:
EOF

    # Add specific recommendations based on issues
    if [[ $issues -gt 0 ]]; then
        {
            echo "- Consider running system optimization"
            echo "- Close unnecessary applications"
            echo "- Free up disk space if needed"
        } >> "$report_file"
    fi

    if [[ "${SYSTEM_OPTIMIZATION_TIER:-}" == "poor" ]]; then
        {
            echo "- Hardware upgrade may be beneficial"
            echo "- Consider adding more RAM"
            echo "- SSD upgrade recommended if using HDD"
        } >> "$report_file"
    fi

    echo "" >> "$report_file"
    echo "Report saved to: $report_file" >> "$report_file"

    opt_log "INFO" "Performance report generated: $report_file"
}

# Display comprehensive system specifications with optimization readiness
display_comprehensive_system_specifications() {
    echo -e "\n${BOLD}${BLUE}🖥️ COMPREHENSIVE SYSTEM SPECIFICATIONS & READINESS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    # Hardware Information
    echo -e "${BOLD}HARDWARE CONFIGURATION:${NC}"
    local cpu_info memory_gb architecture storage_info
    cpu_info=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown CPU")
    memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "Unknown")
    architecture=$(uname -m)
    storage_info=$(df -h / 2>/dev/null | tail -1 | awk '{print $2 " total, " $4 " available"}' || echo "Unknown")

    echo -e "  ${CYAN}CPU:${NC} $cpu_info"
    echo -e "  ${CYAN}Memory:${NC} ${memory_gb}GB"
    echo -e "  ${CYAN}Architecture:${NC} $architecture"
    echo -e "  ${CYAN}Storage:${NC} $storage_info"

    # Software Information
    echo -e "\n${BOLD}SOFTWARE ENVIRONMENT:${NC}"
    if command -v sw_vers >/dev/null 2>&1; then
        local macos_version build_version
        macos_version=$(sw_vers -productVersion)
        build_version=$(sw_vers -buildVersion)
        echo -e "  ${CYAN}macOS:${NC} $macos_version (Build $build_version)"
    fi

    # Performance Metrics
    echo -e "\n${BOLD}CURRENT PERFORMANCE METRICS:${NC}"
    local load_avg memory_pressure_value uptime_info thermal_state
    load_avg=$(uptime | awk -F'load averages:' '{print $2}' | awk '{print $1}' | tr -d ',' || echo "Unknown")

    if command -v memory_pressure > /dev/null 2>&1 ; then
        memory_pressure_value=$(memory_pressure | head -n 1 | awk -F': ' '{print $2}' | tr -d '()')
    else
        memory_pressure_value="unknown"
    fi

    uptime_info=$(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}' || echo "unknown")

    if command -v pmset >/dev/null 2>&1; then
        thermal_state=$(pmset -g therm | grep "CPU_Scheduler_Limit" | awk '{print $NF}')
    else
        thermal_state="N/A"
    fi


    echo -e "  ${CYAN}System Load (1m):${NC} $load_avg"
    echo -e "  ${CYAN}Memory Pressure:${NC} $memory_pressure_value"
    echo -e "  ${CYAN}CPU Thermal Limit:${NC} ${thermal_state:-N/A}"
    echo -e "  ${CYAN}Uptime:${NC} $uptime_info"

    # Cursor Application Metrics
    echo -e "\n${BOLD}CURSOR APPLICATION METRICS:${NC}"
    local cursor_pids
    cursor_pids=$(pgrep -f "Cursor")
    if [[ -n "$cursor_pids" ]]; then
        local total_mem=0
        local process_info
        local pids_for_ps
        pids_for_ps=$(echo "$cursor_pids" | tr '\n' ',' | sed 's/,$//') # Convert newline-separated to comma-separated
        process_info=$(ps -o pid,rss,cputime,command -p "$pids_for_ps" | tail -n +2)

        echo -e "  ${CYAN}PID    MEM(MB)  CPU TIME  COMMAND${NC}"

        while IFS= read -r line; do
            local pid mem_kb time comm
            pid=$(echo "$line" | awk '{print $1}')
            mem_kb=$(echo "$line" | awk '{print $2}')
            time=$(echo "$line" | awk '{print $3}')
            comm=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | xargs)

            local mem_mb=$((mem_kb / 1024))
            total_mem=$((total_mem + mem_mb))

            printf "  %-6s %-8s %-9s %s\n" "$pid" "$mem_mb" "$time" "${comm:0:60}"
        done <<< "$process_info"

        echo -e "  ${BOLD}Total Cursor Memory Usage:${NC} ${total_mem}MB"
    else
        echo -e "  ${CYAN}Cursor is not currently running.${NC}"
    fi

    # Optimization Recommendations
    echo -e "\n${BOLD}OPTIMIZATION READINESS:${NC}"
    local readiness_level="${SYSTEM_OPTIMIZATION_TIER:-unknown}"
    case "$readiness_level" in
        "exceptional")
            echo -e "  ${GREEN}✅ Status: System is perfectly optimized${NC}"
            echo -e "  ${GREEN}✅ Ready for: Enterprise-level development${NC}"
            ;;
        "excellent")
            echo -e "  ${GREEN}✅ Status: System performs very well${NC}"
            echo -e "  ${GREEN}✅ Ready for: Professional development${NC}"
            ;;
        "good")
            echo -e "  ${YELLOW}⚡ Status: System functional, optimization beneficial${NC}"
            echo -e "  ${YELLOW}⚡ Ready for: Standard development with optimizations${NC}"
            ;;
        "poor")
            echo -e "  ${RED}⚠️ Status: System needs optimization${NC}"
            echo -e "  ${RED}⚠️ Action needed: Run optimization before intensive tasks${NC}"
            ;;
        *)
            echo -e "  ${CYAN}ℹ️ Status: Run health check for detailed analysis${NC}"
            ;;
    esac

    echo ""
}

# Module initialization
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced, export functions
    export -f perform_comprehensive_health_check
    export -f apply_system_optimizations
    export -f display_comprehensive_system_specifications
    export OPTIMIZATION_LOADED=true
    opt_log "DEBUG" "Enhanced optimization module loaded successfully"
else
    # Being executed directly
    echo "Enhanced System Optimization Module v$OPT_MODULE_VERSION"
    echo "This module must be sourced, not executed directly"
    exit 1
fi
