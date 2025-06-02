#!/bin/bash

################################################################################
# Optimization Module for Cursor AI Editor Management Utility
# PRODUCTION-GRADE OPTIMIZATION FUNCTIONS
################################################################################

# Note: The main optimization logic is implemented in production_execute_optimize() 
# in the main script to avoid duplication and maintain consolidation

# Perform system health check before optimization
perform_health_check() {
    local health_issues=0
    
    echo -e "\n${BOLD}${BLUE}🏥 SYSTEM HEALTH CHECK${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Check system resources
    local memory_gb
    memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "0")
    
    if [[ $memory_gb -lt 8 ]]; then
        echo -e "${RED}❌ Low Memory: ${memory_gb}GB (8GB+ recommended)${NC}"
        ((health_issues++))
    else
        echo -e "${GREEN}✅ Memory: ${memory_gb}GB${NC}"
    fi
    
    # Check disk space
    local disk_gb
    disk_gb=$(df -g / 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
    
    if [[ $disk_gb -lt 10 ]]; then
        echo -e "${RED}❌ Low Disk Space: ${disk_gb}GB (10GB+ recommended)${NC}"
        ((health_issues++))
    else
        echo -e "${GREEN}✅ Disk Space: ${disk_gb}GB available${NC}"
    fi
    
    # Check system load
    local load_avg
    load_avg=$(uptime | awk -F'load averages:' '{print $2}' | awk '{print $1}' | sed 's/,//' || echo "0.0")
    
    local load_int
    load_int=$(echo "$load_avg" | cut -d. -f1)
    
    if [[ $load_int -ge 5 ]]; then
        echo -e "${YELLOW}⚠️ High System Load: $load_avg${NC}"
        ((health_issues++))
    else
        echo -e "${GREEN}✅ System Load: $load_avg${NC}"
    fi
    
    # Check Cursor processes
    if pgrep -f -i cursor >/dev/null 2>&1; then
        echo -e "${CYAN}ℹ️ Cursor is currently running${NC}"
    else
        echo -e "${GREEN}✅ No Cursor processes running${NC}"
    fi
    
    echo ""
    if [[ $health_issues -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✅ SYSTEM HEALTH: EXCELLENT${NC}"
    elif [[ $health_issues -le 2 ]]; then
        echo -e "${YELLOW}${BOLD}⚠️ SYSTEM HEALTH: GOOD WITH WARNINGS${NC}"
    else
        echo -e "${RED}${BOLD}❌ SYSTEM HEALTH: NEEDS ATTENTION${NC}"
    fi
    
    return $health_issues
}

# Display system specifications
display_system_specifications() {
    echo -e "\n${BOLD}${BLUE}🖥️ SYSTEM SPECIFICATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # CPU information
    local cpu_info
    cpu_info=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown CPU")
    echo -e "${BOLD}CPU:${NC} $cpu_info"
    
    # Memory information
    local memory_gb
    memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "Unknown")
    echo -e "${BOLD}Memory:${NC} ${memory_gb}GB"
    
    # Architecture
    local arch
    arch=$(uname -m)
    echo -e "${BOLD}Architecture:${NC} $arch"
    
    # macOS version
    if command -v sw_vers >/dev/null 2>&1; then
        local macos_version
        macos_version=$(sw_vers -productVersion)
        echo -e "${BOLD}macOS:${NC} $macos_version"
    fi
    
    # Available disk space
    local disk_space
    disk_space=$(df -h / 2>/dev/null | tail -1 | awk '{print $4}' || echo "Unknown")
    echo -e "${BOLD}Available Space:${NC} $disk_space"
    
    echo ""
}

# Optimization module loaded
export OPTIMIZATION_LOADED=true 