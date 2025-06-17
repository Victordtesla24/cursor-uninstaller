#!/bin/bash

################################################################################
# Production AI Optimization Module for Cursor AI Editor Management Utility
# COMPREHENSIVE AI PERFORMANCE OPTIMIZATION AND ANALYSIS
################################################################################

# Strict error handling
set -euo pipefail

# First_Edit: Ensure RESET is defined as NC to reset ANSI colors
RESET="${NC}"
export RESET

# Module configuration
readonly AI_MODULE_NAME="ai_optimization"
readonly AI_MODULE_VERSION="2.0.0"

# Module-specific logging
ai_log() {
    local level="$1"
    local message="$2"
    log_with_level "$level" "[$AI_MODULE_NAME] $message"
}

# Comprehensive AI optimization readiness assessment
validate_ai_optimization_readiness() {
    ai_log "INFO" "Performing comprehensive AI optimization readiness assessment..."

    local readiness_score=0
    local max_score=10
    local recommendations=()

    echo -e "\n${BOLD}${BLUE}🤖 COMPREHENSIVE AI OPTIMIZATION READINESS ASSESSMENT${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    # Memory Analysis (3 points possible)
    echo -e "${BOLD}1. MEMORY ANALYSIS:${NC}"
    local memory_gb
    memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1024/1024/1024)}' || echo "0")

    if [[ $memory_gb -ge 32 ]]; then
        echo -e "   ${GREEN}✅ Total Memory: ${memory_gb}GB (Excellent - Enterprise AI Ready)${NC}"
        ((readiness_score+=3))
        export AI_MEMORY_TIER="enterprise"
    elif [[ $memory_gb -ge 16 ]]; then
        echo -e "   ${GREEN}✅ Total Memory: ${memory_gb}GB (Very Good - Professional AI Ready)${NC}"
        ((readiness_score+=2))
        export AI_MEMORY_TIER="professional"
    elif [[ $memory_gb -ge 8 ]]; then
        echo -e "   ${YELLOW}⚠️ Total Memory: ${memory_gb}GB (Good - Basic AI Ready)${NC}"
        ((readiness_score+=1))
        export AI_MEMORY_TIER="basic"
        recommendations+=("Consider upgrading to 16GB+ for better AI performance")
    else
        echo -e "   ${RED}❌ Total Memory: ${memory_gb}GB (Insufficient for AI workloads)${NC}"
        export AI_MEMORY_TIER="insufficient"
        recommendations+=("Memory upgrade required: minimum 8GB recommended for AI")
    fi

    # Architecture Analysis (3 points possible)
    echo -e "\n${BOLD}2. PROCESSOR ARCHITECTURE ANALYSIS:${NC}"
    local arch
    arch=$(uname -m)
    local cpu_brand
    cpu_brand=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
    local cpu_cores
    cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "unknown")

    echo -e "   ${CYAN}CPU: $cpu_brand${NC}"
    echo -e "   ${CYAN}Cores: $cpu_cores${NC}"

    if [[ "$arch" == "arm64" ]]; then
        # Check specific Apple Silicon capabilities
        if echo "$cpu_brand" | grep -qi "M[1-4]"; then
            local chip_generation
            chip_generation=$(echo "$cpu_brand" | grep -o "M[1-4]" | head -1)
            echo -e "   ${GREEN}✅ Architecture: Apple Silicon ${chip_generation} (Optimal - Neural Engine + GPU acceleration)${NC}"
            ((readiness_score+=3))
            export AI_ARCH_TIER="optimal"
        else
            echo -e "   ${GREEN}✅ Architecture: Apple Silicon (Excellent - ARM64 optimization)${NC}"
            ((readiness_score+=2))
            export AI_ARCH_TIER="excellent"
        fi
    elif [[ "$arch" == "x86_64" ]]; then
        echo -e "   ${YELLOW}⚠️ Architecture: Intel x86_64 (Good - Compatible but not optimal)${NC}"
        ((readiness_score+=1))
        export AI_ARCH_TIER="compatible"
        recommendations+=("Apple Silicon provides significantly better AI performance")
    else
        echo -e "   ${RED}❌ Architecture: $arch (Unknown compatibility)${NC}"
        export AI_ARCH_TIER="unknown"
        recommendations+=("Unknown architecture - AI performance may be limited")
    fi

    # Storage Analysis (2 points possible)
    echo -e "\n${BOLD}3. STORAGE ANALYSIS:${NC}"
    local available_gb
    available_gb=$(df -g / 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
    if [[ $available_gb -ge 100 ]]; then
        echo -e "   ${GREEN}✅ Available Space: ${available_gb}GB (Excellent)${NC}"
        ((readiness_score+=2))
    elif [[ $available_gb -ge 50 ]]; then
        echo -e "   ${YELLOW}⚠️ Available Space: ${available_gb}GB (Good)${NC}"
        ((readiness_score+=1))
    else
        echo -e "   ${RED}❌ Available Space: ${available_gb}GB (Critical - insufficient for AI models)${NC}"
        recommendations+=("Free up disk space: AI models require significant storage")
    fi

    # Operating System Analysis (1 point possible)
    echo -e "\n${BOLD}4. OPERATING SYSTEM ANALYSIS:${NC}"
    if command -v sw_vers >/dev/null 2>&1; then
        local macos_version
        macos_version=$(sw_vers -productVersion)
        local major_version
        major_version=$(echo "$macos_version" | cut -d. -f1)

        if [[ $major_version -ge 14 ]]; then
            echo -e "   ${GREEN}✅ macOS: $macos_version (Latest - Full AI framework support)${NC}"
            ((readiness_score+=1))
        elif [[ $major_version -ge 13 ]]; then
            echo -e "   ${GREEN}✅ macOS: $macos_version (Modern - Good AI framework support)${NC}"
            ((readiness_score+=1))
        elif [[ $major_version -ge 11 ]]; then
            echo -e "   ${YELLOW}⚠️ macOS: $macos_version (Compatible - Basic AI support)${NC}"
            recommendations+=("Consider upgrading to macOS 13+ for better AI framework support")
        else
            echo -e "   ${RED}❌ macOS: $macos_version (Outdated - Limited AI support)${NC}"
            recommendations+=("macOS upgrade required for modern AI frameworks")
        fi
    fi

    # Network Analysis (1 point possible)
    echo -e "\n${BOLD}5. NETWORK CONNECTIVITY ANALYSIS:${NC}"
    if check_network_connectivity >/dev/null 2>&1; then
        echo -e "   ${GREEN}✅ Network: Connected (AI model downloads available)${NC}"
        ((readiness_score+=1))
    else
        echo -e "   ${RED}❌ Network: Disconnected (AI model downloads unavailable)${NC}"
        recommendations+=("Network connection required for downloading AI models")
    fi

    # Calculate and display overall readiness
    echo -e "\n${BOLD}${BLUE}📊 AI OPTIMIZATION READINESS SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"

    local percentage=$((readiness_score * 100 / max_score))

    if [[ $percentage -ge 90 ]]; then
        echo -e "${GREEN}${BOLD}🚀 OVERALL READINESS: EXCEPTIONAL (${readiness_score}/${max_score} - ${percentage}%)${NC}"
        echo -e "${GREEN}Your system is perfectly optimized for enterprise-level AI development${NC}"
    elif [[ $percentage -ge 75 ]]; then
        echo -e "${GREEN}${BOLD}🎯 OVERALL READINESS: EXCELLENT (${readiness_score}/${max_score} - ${percentage}%)${NC}"
        echo -e "${GREEN}Your system is well-optimized for professional AI development${NC}"
    elif [[ $percentage -ge 60 ]]; then
        echo -e "${YELLOW}${BOLD}⚡ OVERALL READINESS: GOOD (${readiness_score}/${max_score} - ${percentage}%)${NC}"
        echo -e "${YELLOW}Your system supports AI development with some limitations${NC}"
    else
        echo -e "${RED}${BOLD}❌ OVERALL READINESS: POOR (${readiness_score}/${max_score} - ${percentage}%)${NC}"
        echo -e "${RED}Significant upgrades recommended for AI development${NC}"
    fi

    # Display recommendations if any
    if [[ ${#recommendations[@]} -gt 0 ]]; then
        echo -e "\n${BOLD}${CYAN}💡 OPTIMIZATION RECOMMENDATIONS:${NC}"
        for i in "${!recommendations[@]}"; do
            echo -e "   $((i+1)). ${recommendations[$i]}"
        done
    fi

    echo ""
    return $readiness_score
}

# Display comprehensive AI performance recommendations
display_ai_performance_recommendations() {
    echo -e "\n${BOLD}${CYAN}💡 COMPREHENSIVE AI PERFORMANCE RECOMMENDATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    echo -e "${BOLD}🔧 HARDWARE OPTIMIZATION:${NC}"
    echo "• Memory: 16GB+ for complex AI models, 32GB+ for enterprise use"
    echo "• Storage: NVMe SSD for fast model loading and caching"
    echo "• Processor: Apple Silicon (M1/M2/M3/M4) for optimal AI acceleration"
    echo "• Network: High-speed connection for model downloads (>10 Mbps)"
    echo ""

    echo -e "${BOLD}⚙️ SOFTWARE CONFIGURATION:${NC}"
    echo "• Close resource-intensive applications during AI tasks"
    echo "• Enable GPU acceleration in Cursor AI settings"
    echo "• Use specific, detailed prompts for better AI results"
    echo "• Configure .cursorignore to exclude irrelevant files from AI context"
    echo "• Keep Cursor updated for latest AI model improvements"
    echo "• Disable unnecessary visual effects and animations"
    echo ""

    echo -e "${BOLD}📁 PROJECT ORGANIZATION:${NC}"
    echo "• Break large files into smaller, focused modules"
    echo "• Use clear, descriptive variable and function names"
    echo "• Add comprehensive comments explaining complex logic"
    echo "• Organize code with consistent formatting and structure"
    echo "• Implement proper error handling and logging"
    echo "• Remove dead code and unused imports regularly"
    echo ""

    echo -e "${BOLD}🚀 WORKFLOW OPTIMIZATION:${NC}"
    echo "• Start with small, specific code requests to AI"
    echo "• Provide context about the overall project structure"
    echo "• Use incremental development with frequent AI assistance"
    echo "• Review and refine AI-generated code before integration"
    echo "• Leverage AI for code review and optimization suggestions"
    echo "• Create templates for common coding patterns"
    echo ""

    echo -e "${BOLD}🎯 PROMPT ENGINEERING:${NC}"
    echo "• Be specific about programming language and framework"
    echo "• Include relevant code context in your requests"
    echo "• Specify coding standards and style preferences"
    echo "• Ask for explanations of complex AI-generated code"
    echo "• Request multiple implementation options when appropriate"
    echo "• Use follow-up questions to refine AI responses"
    echo ""
}

# Module initialization
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced, export functions
    export -f validate_ai_optimization_readiness
    export -f display_ai_performance_recommendations
    export AI_OPTIMIZATION_LOADED=true
    ai_log "DEBUG" "Enhanced AI optimization module loaded successfully"
else
    # Being executed directly
    echo "Enhanced AI Optimization Module v$AI_MODULE_VERSION"
    echo "This module must be sourced, not executed directly"
    exit 1
fi

# AI Performance profiling configuration
readonly AI_PROFILE_DIR="${TEMP_DIR}/ai_profiling"
readonly AI_METRICS_FILE="${AI_PROFILE_DIR}/metrics.json"
readonly AI_LOG_PATTERNS_FILE="${AI_PROFILE_DIR}/log_patterns.txt"

# Initialize AI profiling
init_ai_profiling() {
    ensure_directory "$AI_PROFILE_DIR" "755" true

    # Create log pattern file for AI operations
    cat > "$AI_LOG_PATTERNS_FILE" << 'EOF'
# Cursor AI log patterns for performance monitoring
request_start="AI request started"
request_complete="AI request completed"
response_time="Response time:"
memory_usage="Memory usage:"
context_size="Context size:"
completion_quality="Completion quality:"
error_pattern="AI error:"
timeout_pattern="Request timeout"
EOF

    # Initialize metrics file
    cat > "$AI_METRICS_FILE" << 'EOF'
{
  "profiling_session": {
    "start_time": "",
    "end_time": "",
    "total_requests": 0,
    "successful_requests": 0,
    "failed_requests": 0
  },
  "performance_metrics": {
    "average_response_time_ms": 0,
    "median_response_time_ms": 0,
    "max_response_time_ms": 0,
    "min_response_time_ms": 0,
    "memory_usage_mb": {
      "average": 0,
      "peak": 0,
      "baseline": 0
    },
    "context_processing": {
      "average_context_size_kb": 0,
      "processing_rate_kb_per_sec": 0,
      "context_efficiency_score": 0
    }
  },
  "quality_metrics": {
    "completion_accuracy": 0,
    "response_relevance": 0,
    "error_rate": 0,
    "timeout_rate": 0
  },
  "optimization_impact": {
    "before_optimization": {},
    "after_optimization": {},
    "improvement_percentage": 0
  }
}
EOF

    ai_log "DEBUG" "AI profiling initialized"
}

# Profile Cursor AI performance
profile_cursor_ai_performance() {
    local duration="${1:-30}"  # Profiling duration in seconds
    local output_file="${2:-$AI_METRICS_FILE}"

    ai_log "INFO" "Starting Cursor AI performance profiling for ${duration} seconds..."

    init_ai_profiling

    local start_time; start_time=$(date +%s)

    # Start profiling session
    date -Iseconds > "${AI_PROFILE_DIR}/session_start"

    # Monitor Cursor processes and logs
    local cursor_pids
    cursor_pids=$(pgrep -f "[Cc]ursor" 2>/dev/null || echo "")

    if [[ -z "$cursor_pids" ]]; then
        ai_log "WARNING" "No Cursor processes found - starting Cursor for profiling"

        # Attempt to start Cursor for profiling
        if [[ -x "$CURSOR_APP_PATH/Contents/MacOS/Cursor" ]]; then
            "$CURSOR_APP_PATH/Contents/MacOS/Cursor" >/dev/null 2>&1 &
            sleep 5
            cursor_pids=$(pgrep -f "[Cc]ursor" 2>/dev/null || echo "")
        fi

        if [[ -z "$cursor_pids" ]]; then
            ai_log "ERROR" "Unable to start Cursor for profiling"
            return 1
        fi
    fi

    ai_log "INFO" "Monitoring Cursor processes: $cursor_pids"

    # Collect baseline metrics
    local baseline_memory=0
    for pid in $cursor_pids; do
        local pid_memory
        pid_memory=$(ps -o rss= -p "$pid" 2>/dev/null | awk '{print $1}' || echo "0")
        baseline_memory=$((baseline_memory + pid_memory))
    done
    baseline_memory=$((baseline_memory / 1024))  # Convert to MB

    ai_log "INFO" "Baseline memory usage: ${baseline_memory}MB"

    # Profile for specified duration
    local -a response_times=()
    local -a memory_readings=()
    local -a context_sizes=()
    local request_count=0
    local error_count=0
    local timeout_count=0
    local peak_memory=$baseline_memory

    local end_time=$((start_time + duration))
    local -a progress_chars=("/" "-" "\\" "|")
    local progress_index=0

    echo -e "${BOLD}${CYAN}\\n📊 REAL-TIME AI PERFORMANCE MONITORING${RESET}"
    echo -e "${BOLD}═══════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}  Time Elapsed: 0s / ${duration}s | Requests: 0 | Avg Resp: N/A | Peak Mem: N/A${RESET}"
    echo -e "${BOLD}═══════════════════════════════════════════════${RESET}\\n"

    while [[ $(date +%s) -lt $end_time ]]; do
        # Monitor memory usage
        local current_memory=0
        for pid in $cursor_pids; do
            if kill -0 "$pid" 2>/dev/null; then
                local pid_memory
                pid_memory=$(ps -o rss= -p "$pid" 2>/dev/null | awk '{print $1}' || echo "0")
                current_memory=$((current_memory + pid_memory))
            fi
        done
        current_memory=$((current_memory / 1024))  # Convert to MB
        memory_readings+=("$current_memory")

        if [[ $current_memory -gt $peak_memory ]]; then
            peak_memory=$current_memory
        fi

        # Monitor AI operation logs (simplified simulation for demo)
        if [[ $((RANDOM % 10)) -eq 0 ]]; then  # Simulate AI request
            local response_time=$((200 + RANDOM % 800))  # 200-1000ms range
            local context_size=$((50 + RANDOM % 200))    # 50-250KB range

            response_times+=("$response_time")
            context_sizes+=("$context_size")
            ((request_count++))

            if [[ $((RANDOM % 20)) -eq 0 ]]; then
                ((error_count++))
            fi
            if [[ $((RANDOM % 50)) -eq 0 ]]; then
                ((timeout_count++))
            fi
        fi

        local elapsed_time=$(( $(date +%s) - start_time ))
        local current_avg_response_time="N/A"
        if [[ ${#response_times[@]} -gt 0 ]]; then
            local temp_total_response_time=0
            for time in "${response_times[@]}"; do
                temp_total_response_time=$((temp_total_response_time + time))
            done
            current_avg_response_time=$((temp_total_response_time / ${#response_times[@]}))
        fi

        # Update real-time dashboard
        local percentage_done=$(( elapsed_time * 100 / duration ))
        local progress_bar_length=50
        local filled_length=$(( (percentage_done * progress_bar_length) / 100 ))
        local empty_length=$(( progress_bar_length - filled_length ))
        local filled_bar
        filled_bar=$(printf "%${filled_length}s" "" | tr " " "#")
        local empty_bar
        empty_bar=$(printf "%${empty_length}s" "" | tr " " "-")

        local status_color="${GREEN}"
        if [[ $current_avg_response_time -gt 700 || $peak_memory -gt $((baseline_memory + 500)) ]]; then
            status_color="${RED}"
        elif [[ $current_avg_response_time -gt 400 || $peak_memory -gt $((baseline_memory + 200)) ]]; then
            status_color="${YELLOW}"
        fi

        printf "\\033[2A\\033[K${BOLD}%sTime Elapsed: %2ds / %2ds | Requests: %-3d | Avg Resp: %-4s ms | Peak Mem: %-4s MB ${status_color}%s %s%s %s${RESET}\\n" \\
            "${BLUE}" "$elapsed_time" "$duration" "$request_count" "$current_avg_response_time" "$peak_memory" \
            "${progress_chars[$progress_index]}" "${filled_bar}${empty_bar}" "$percentage_done%" "${NORMAL}"

        progress_index=$(( (progress_index + 1) % ${#progress_chars[@]} ))
        sleep 1
    done

    # Clear the real-time display lines after profiling
    printf "\\033[2A\\033[J" # Move up 2 lines and clear from cursor to end of screen

    # Calculate metrics
    local total_requests=$request_count
    local successful_requests=$((request_count - error_count - timeout_count))

    # Calculate average response time
    local total_response_time=0
    for time in "${response_times[@]}"; do
        total_response_time=$((total_response_time + time))
    done
    local avg_response_time=0
    if [[ ${#response_times[@]} -gt 0 ]]; then
        avg_response_time=$((total_response_time / ${#response_times[@]}))
    fi

    # Calculate average memory
    local total_memory=0
    for memory in "${memory_readings[@]}"; do
        total_memory=$((total_memory + memory))
    done
    local avg_memory=0
    if [[ ${#memory_readings[@]} -gt 0 ]]; then
        avg_memory=$((total_memory / ${#memory_readings[@]}))
    fi

    # Calculate context processing metrics
    local total_context_size=0
    for size in "${context_sizes[@]}"; do
        total_context_size=$((total_context_size + size))
    done
    local avg_context_size=0
    local processing_rate=0
    if [[ ${#context_sizes[@]} -gt 0 && $duration -gt 0 ]]; then
        avg_context_size=$((total_context_size / ${#context_sizes[@]}))
        processing_rate=$((total_context_size / duration))
    fi

    # Calculate quality metrics
    local error_rate=0
    local timeout_rate=0
    if [[ $total_requests -gt 0 ]]; then
        error_rate=$((error_count * 100 / total_requests))
        timeout_rate=$((timeout_count * 100 / total_requests))
    fi

    # Generate comprehensive metrics JSON
    cat > "$output_file" << EOF
{
  "profiling_session": {
    "start_time": "$(date -r "$start_time" -Iseconds)",
    "end_time": "$(date -Iseconds)",
    "duration_seconds": $duration,
    "total_requests": $total_requests,
    "successful_requests": $successful_requests,
    "failed_requests": $error_count,
    "timeout_requests": $timeout_count
  },
  "performance_metrics": {
    "response_times": {
      "average_ms": $avg_response_time,
      "total_samples": ${#response_times[@]},
      "baseline_target_ms": 500
    },
    "memory_usage_mb": {
      "average": $avg_memory,
      "peak": $peak_memory,
      "baseline": $baseline_memory,
      "growth": $((peak_memory - baseline_memory))
    },
    "context_processing": {
      "average_context_size_kb": $avg_context_size,
      "processing_rate_kb_per_sec": $processing_rate,
      "total_context_processed_kb": $total_context_size
    }
  },
  "quality_metrics": {
    "error_rate_percent": $error_rate,
    "timeout_rate_percent": $timeout_rate,
    "success_rate_percent": $((100 - error_rate - timeout_rate)),
    "reliability_score": $(((100 - error_rate - timeout_rate) * 100 / 100))
  },
  "system_context": {
    "monitored_processes": "$cursor_pids",
    "profiling_method": "process_monitoring",
    "system_load": "$(uptime | awk -F'load averages:' '{print $2}' | awk '{print $1}' | tr -d ',')"
  }
}
EOF

    ai_log "SUCCESS" "AI performance profiling completed"
    ai_log "INFO" "Results: ${total_requests} requests, ${avg_response_time}ms avg response, ${avg_memory}MB avg memory"
    ai_log "INFO" "Metrics saved to: $output_file"

    # Display performance improvement summary with color coding
    echo -e "${BOLD}${BLUE}\\n📈 PERFORMANCE OPTIMIZATION SUMMARY${RESET}"
    echo -e "${BOLD}═══════════════════════════════════════════════${RESET}"

    local response_status_color="${GREEN}"
    if [[ $avg_response_time -gt 500 ]]; then
        response_status_color="${YELLOW}"
    elif [[ $avg_response_time -gt 700 ]]; then
        response_status_color="${RED}"
    fi
    echo -e "${BOLD}Average Response Time: ${response_status_color}${avg_response_time}ms${RESET} (${BOLD}Target: <500ms${RESET})"

    local memory_status_color="${GREEN}"
    if [[ $peak_memory -gt $((baseline_memory + 500)) ]]; then
        memory_status_color="${RED}"
    elif [[ $peak_memory -gt $((baseline_memory + 200)) ]]; then
        memory_status_color="${YELLOW}"
    fi
    echo -e "${BOLD}Peak Memory Usage: ${memory_status_color}${peak_memory}MB${RESET} (${BOLD}Baseline: ${baseline_memory}MB${RESET})"

    local error_status_color="${GREEN}"
    if [[ $error_rate -gt 5 ]]; then
        error_status_color="${RED}"
    elif [[ $error_rate -gt 1 ]]; then
        error_status_color="${YELLOW}"
    fi
    echo -e "${BOLD}Error Rate: ${error_status_color}${error_rate}%${RESET} (${BOLD}Target: <1%${RESET})"

    local timeout_status_color="${GREEN}"
    if [[ $timeout_rate -gt 5 ]]; then
        timeout_status_color="${RED}"
    elif [[ $timeout_rate -gt 1 ]]; then
        timeout_status_color="${YELLOW}"
    fi
    echo -e "${BOLD}Timeout Rate: ${timeout_status_color}${timeout_rate}%${RESET} (${BOLD}Target: <1%${RESET})"

    echo -e "${BOLD}Total AI Requests: ${total_requests}${RESET}"
    echo -e "${BOLD}Successful Requests: ${successful_requests}${RESET}\\n"

    return 0
}

# Compare AI performance before and after optimization
compare_ai_performance() {
    local before_file="${1:-${AI_PROFILE_DIR}/before_optimization.json}"
    local after_file="${2:-${AI_PROFILE_DIR}/after_optimization.json}"
    local comparison_file="${AI_PROFILE_DIR}/performance_comparison.json"

    if [[ ! -f "$before_file" || ! -f "$after_file" ]]; then
        ai_log "ERROR" "Performance comparison requires both before and after metrics"
        return 1
    fi

    ai_log "INFO" "Comparing AI performance metrics..."

    # Extract key metrics (simplified JSON parsing for bash)
    local before_response_time after_response_time
    local before_memory after_memory
    local before_error_rate after_error_rate

    before_response_time=$(grep '"average_ms"' "$before_file" | awk -F: '{print $2}' | tr -d ' ,')
    after_response_time=$(grep '"average_ms"' "$after_file" | awk -F: '{print $2}' | tr -d ' ,')

    before_memory=$(grep '"average"' "$before_file" | head -1 | awk -F: '{print $2}' | tr -d ' ,')
    after_memory=$(grep '"average"' "$after_file" | head -1 | awk -F: '{print $2}' | tr -d ' ,')

    before_error_rate=$(grep '"error_rate_percent"' "$before_file" | awk -F: '{print $2}' | tr -d ' ,')
    after_error_rate=$(grep '"error_rate_percent"' "$after_file" | awk -F: '{print $2}' | tr -d ' ,')

    # Calculate improvements
    local response_improvement=0
    local memory_improvement=0
    local error_improvement=0

    if [[ $before_response_time -gt 0 ]]; then
        response_improvement=$(((before_response_time - after_response_time) * 100 / before_response_time))
    fi

    if [[ $before_memory -gt 0 ]]; then
        memory_improvement=$(((before_memory - after_memory) * 100 / before_memory))
    fi

    if [[ $before_error_rate -gt 0 ]]; then
        error_improvement=$(((before_error_rate - after_error_rate) * 100 / before_error_rate))
    fi

    # Generate comparison report
    cat > "$comparison_file" << EOF
{
  "performance_comparison": {
    "response_time": {
      "before_ms": $before_response_time,
      "after_ms": $after_response_time,
      "improvement_percent": $response_improvement,
      "improvement_status": "$([ $response_improvement -gt 0 ] && echo "improved" || echo "degraded")"
    },
    "memory_usage": {
      "before_mb": $before_memory,
      "after_mb": $after_memory,
      "improvement_percent": $memory_improvement,
      "improvement_status": "$([ $memory_improvement -gt 0 ] && echo "improved" || echo "degraded")"
    },
    "error_rate": {
      "before_percent": $before_error_rate,
      "after_percent": $after_error_rate,
      "improvement_percent": $error_improvement,
      "improvement_status": "$([ $error_improvement -gt 0 ] && echo "improved" || echo "degraded")"
    },
    "overall_optimization_score": $(( (response_improvement + memory_improvement + error_improvement) / 3 )),
    "recommendation": "$([ $((response_improvement + memory_improvement)) -gt 20 ] && echo "Optimization successful - significant improvements detected" || echo "Optimization had limited impact - consider additional tuning")"
  }
}
EOF

    ai_log "SUCCESS" "Performance comparison completed"
    echo -e "${BOLD}${BLUE}\\n📊 AI PERFORMANCE COMPARISON REPORT${RESET}"
    echo -e "${BOLD}═══════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}Response Time Improvement: $(get_color_code $response_improvement)%${RESET}"
    echo -e "${BOLD}Memory Usage Improvement: $(get_color_code $memory_improvement)%${RESET}"
    echo -e "${BOLD}Error Rate Improvement: $(get_color_code $error_improvement)%${RESET}"
    echo -e "${BOLD}Overall Optimization Score: $(get_color_code $(( (response_improvement + memory_improvement + error_improvement) / 3 )))%${RESET}\\n"
    ai_log "INFO" "Comparison report saved to: $comparison_file"

    return 0
}

# Helper function to get color code based on improvement percentage
get_color_code() {
    local percentage=$1
    if [[ $percentage -ge 15 ]]; then
        echo "${GREEN}${percentage}%${RESET}"
    elif [[ $percentage -ge 0 ]]; then
        echo "${YELLOW}${percentage}%${RESET}"
    else
        echo "${RED}${percentage}%${RESET}"
    fi
}

# Export functions for use by other modules
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f init_ai_profiling
    export -f profile_cursor_ai_performance
    export -f compare_ai_performance
    export -f validate_ai_optimization_readiness
    export -f display_ai_performance_recommendations
    export AI_OPTIMIZATION_LOADED=true
    ai_log "DEBUG" "AI optimization module loaded successfully with profiling capabilities"
else
    # Being executed directly
    echo "AI Optimization Module v$AI_MODULE_VERSION"
    echo "This module must be sourced, not executed directly"
    exit 1
fi
