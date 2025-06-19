#!/bin/bash

################################################################################
# Real-Time System Monitor for Cursor AI Editor Management Utility
################################################################################

# Secure error handling
set -euo pipefail

# Module configuration
SYSTEM_MONITOR_MODULE_VERSION="1.0.0"

# Draws the static frame of the dashboard
draw_dashboard_frame() {
    clear
    local width
    width=$(tput cols)

    # Draw header
    tput cup 0 0
    print_separator "=" "$width"
    tput cup 1 0
    printf "%*s" "$width" " " # Clear line
    tput cup 1 2
    printf "%s" "📊 REAL-TIME SYSTEM MONITOR"
    tput cup 1 $((width - 15))
    printf "%s" "Press 'q' to quit"
    tput cup 2 0
    print_separator "=" "$width"

    # Draw sections
    tput cup 4 2
    printf "%s" "CPU USAGE"
    tput cup 4 $((width / 2))
    printf "%s" "MEMORY USAGE"

    tput cup 10 2
    printf "%s" "DISK I/O"
    tput cup 10 $((width / 2))
    printf "%s" "NETWORK I/O"

    tput cup 16 2
    printf "%s" "CURSOR PROCESSES"
}

# Updates the dynamic data on the dashboard
update_dashboard_data() {
    local width
    width=$(tput cols)

    # --- CPU USAGE ---
    local cpu_info
    cpu_info=$(top -l 1 -n 0 | grep "CPU usage")
    local user_cpu
    user_cpu=$(echo "$cpu_info" | awk '{print $3}')
    local sys_cpu
    sys_cpu=$(echo "$cpu_info" | awk '{print $5}')
    local idle_cpu
    idle_cpu=$(echo "$cpu_info" | awk '{print $7}')

    tput cup 6 2
    printf "User: %-10s System: %-10s Idle: %-10s" "$user_cpu" "$sys_cpu" "$idle_cpu"

    # --- MEMORY USAGE ---
    local total_mem_gb
    total_mem_gb=$(sysctl -n hw.memsize | awk '{printf "%.1f", $1/1073741824}')
    local vm_stats
    vm_stats=$(vm_stat)
    local page_size
    page_size=$(echo "$vm_stats" | grep "page size" | awk '{print $8}')
    local pages_active
    pages_active=$(echo "$vm_stats" | grep "Pages active" | awk '{print $3}' | tr -d '.')
    local pages_inactive
    pages_inactive=$(echo "$vm_stats" | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
    local pages_wired
    pages_wired=$(echo "$vm_stats" | grep "Pages wired" | awk '{print $4}' | tr -d '.')

    local used_mem_bytes
    used_mem_bytes=$(( (pages_active + pages_inactive + pages_wired) * page_size ))
    local used_mem_gb
    used_mem_gb=$(awk "BEGIN {printf \"%.1f\", $used_mem_bytes / 1073741824}")

    local mem_percentage
    mem_percentage=$(awk "BEGIN {printf \"%d\", ($used_mem_gb / $total_mem_gb) * 100}")

    local bar_width=$(( (width / 2) - 10 ))
    local filled_blocks
    filled_blocks=$(( (mem_percentage * bar_width) / 100 ))
    local empty_blocks
    empty_blocks=$(( bar_width - filled_blocks ))

    local mem_bar
    mem_bar=$(printf "%${filled_blocks}s" | tr ' ' '■')
    mem_bar+=$(printf "%${empty_blocks}s" | tr ' ' '□')

    tput cup 6 $((width / 2))
    printf "Used: %sGB / %sGB" "$used_mem_gb" "$total_mem_gb"
    tput cup 7 $((width / 2))
    printf "[%s] %d%%" "$mem_bar" "$mem_percentage"

    # --- DISK I/O ---
    local disk_io
    disk_io=$(iostat -d 1 1 | tail -1)
    local kbs
    kbs=$(echo "$disk_io" | awk '{print $1}')
    local tps
    tps=$(echo "$disk_io" | awk '{print $2}')
    local mbs
    mbs=$(echo "$disk_io" | awk '{print $3}')

    tput cup 12 2
    printf "KB/t: %-10s Tps: %-10s MB/s: %-10s" "$kbs" "$tps" "$mbs"

    # --- NETWORK I/O ---
    local net_io
    net_io=$(netstat -i -b | grep "<Link#". | awk '{sum_ipackets+=$5; sum_opackets+=$7} END {print sum_ipackets, sum_opackets}')
    local ipackets
    ipackets=$(echo "$net_io" | awk '{print $1}')
    local opackets
    opackets=$(echo "$net_io" | awk '{print $2}')

    tput cup 12 $((width / 2))
    printf "Packets In: %-12s Packets Out: %-12s" "$ipackets" "$opackets"

    # --- CURSOR PROCESSES ---
    tput cup 18 2
    printf "%-10s %-10s %s" "PID" "%CPU" "COMMAND"
    local pids
    pids=$(pgrep -f "Cursor" | head -n 5)
    if [ -n "$pids" ]; then
        # Convert newline-separated PIDs to comma-separated format
        local pid_list
        pid_list=$(echo "$pids" | tr '\n' ',' | sed 's/,$//')
        local process_list
        # Add error handling in case processes have terminated
        if process_list=$(ps -p "$pid_list" -o pid,pcpu,comm 2>/dev/null); then
            local line_num=19
            while read -r line; do
                tput cup $line_num 2
                printf "%s" "$line"
                line_num=$((line_num + 1))
            done <<< "$process_list"
        else
            tput cup 19 2
            printf "No active Cursor processes found"
        fi
    else
        tput cup 19 2
        printf "No Cursor processes running"
    fi
}

# Function to start the real-time system monitor
start_system_monitor() {
    trap 'tput cnorm; clear; exit 0' INT TERM QUIT
    tput civis # Hide cursor

    draw_dashboard_frame

    while true; do
        update_dashboard_data
        read -r -s -n 1 -t 1 key
        if [[ "$key" == "q" ]]; then
            break
        fi
    done

    tput cnorm # Restore cursor
    clear
}

# Export functions for use by other modules
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f start_system_monitor
    SYSTEM_MONITOR_MODULE_LOADED=true
    export SYSTEM_MONITOR_MODULE_LOADED
else
    # Being executed directly
    printf 'System Monitor Module v%s\n' "$SYSTEM_MONITOR_MODULE_VERSION"
    printf 'This module must be sourced, not executed directly\n'
    exit 1
fi
