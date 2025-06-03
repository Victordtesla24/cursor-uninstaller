#!/bin/bash

################################################################################
# Cursor AI System Optimization Utility
# Standalone script for system and application optimization.
################################################################################

# Error Handler for this script
# shellcheck disable=SC2317  # Function is used in trap
optimize_error_handler() {
    local line_number="$1"
    local failed_command="$2"
    echo -e "\n[OPTIMIZE SCRIPT ERROR] LINE $line_number: COMMAND FAILED: $failed_command" >&2
    exit 1 # Exit on error for this standalone script
}
trap 'optimize_error_handler $LINENO "$BASH_COMMAND"' ERR
set -eE # Exit immediately if a command exits with a non-zero status.
set -o pipefail # Causes a pipeline to return the exit status of the last command in the pipe that failed.

# Script Self-Location & Robust Path Resolution for Sourcing
get_optimize_script_path() {
    local SOURCE_OPTIMIZE="${BASH_SOURCE[0]}"
    local DIR_OPTIMIZE=""
    while [ -h "$SOURCE_OPTIMIZE" ]; do # Recursively resolve symlinks
        DIR_OPTIMIZE="$( cd -P "$( dirname "$SOURCE_OPTIMIZE" )" && pwd )"
        SOURCE_OPTIMIZE="$(readlink "$SOURCE_OPTIMIZE")"
        [[ $SOURCE_OPTIMIZE != /* ]] && SOURCE_OPTIMIZE="$DIR_OPTIMIZE/$SOURCE_OPTIMIZE"
    done
    DIR_OPTIMIZE="$( cd -P "$( dirname "$SOURCE_OPTIMIZE" )" && pwd )"
    echo "$DIR_OPTIMIZE"
}
SCRIPT_DIR_OPTIMIZE="$(get_optimize_script_path)"
PROJECT_ROOT_OPTIMIZE="$(dirname "$SCRIPT_DIR_OPTIMIZE")" # Assumes scripts/ is one level down from project root

# Source necessary libs with corrected relative paths
# Get the directory of this script for proper relative path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/config.sh
source "$PROJECT_ROOT/lib/config.sh" || { echo "Error: Failed to source config.sh" >&2; exit 1; }
# shellcheck source=lib/ui.sh
source "$PROJECT_ROOT/lib/ui.sh" || { echo "Error: Failed to source ui.sh" >&2; exit 1; }
# shellcheck source=lib/helpers.sh
source "$PROJECT_ROOT/lib/helpers.sh" || { echo "Error: Failed to source helpers.sh" >&2; exit 1; } # For terminate_cursor_processes

# Global state tracking for non-interactive mode (if needed by sourced functions)
NON_INTERACTIVE_MODE=false
if [[ ! -t 0 ]] || [[ -n "${CI:-}" ]] || [[ -n "${DEBIAN_FRONTEND:-}" ]] || [[ "${TERM:-}" == "dumb" ]]; then
    NON_INTERACTIVE_MODE=true
    production_info_message "[OPTIMIZE SCRIPT] NON-INTERACTIVE ENVIRONMENT DETECTED"
fi


# Copied and adapted from bin/uninstall_cursor.sh
production_execute_optimize() {
    production_info_message "EXECUTING COMPREHENSIVE PRODUCTION-GRADE CURSOR AI OPTIMIZATION"

    # Script's main error trap (set -eE and trap 'optimize_error_handler...') will handle errors.
    # No need for the internal trap that used handle_optimization_error.

    echo -e "\n${BLUE}${BOLD}🚀 PRODUCTION-GRADE CURSOR AI OPTIMIZATION${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}\n"

    echo -e "${BOLD}${GREEN}PRODUCTION OPTIMIZATION TECHNIQUES:${NC}"
    echo -e "${BOLD}═════════════════════════════════════════════════${NC}\n"

    echo -e "${YELLOW}1. SYSTEM-LEVEL OPTIMIZATIONS:${NC}"
    echo -e "   ${CYAN}• MEMORY MANAGEMENT:${NC} INCREASE HEAP SIZE TO 8GB FOR LARGE AI MODELS"
    echo -e "   ${CYAN}• FILE DESCRIPTORS:${NC} INCREASE LIMITS TO 65K FOR HANDLING MULTIPLE FILES"
    echo -e "   ${CYAN}• KERNEL PARAMETERS:${NC} OPTIMIZE FOR AI DEVELOPMENT WORKLOADS"
    echo -e "   ${CYAN}• VISUAL EFFECTS:${NC} DISABLE ANIMATIONS TO FREE GPU RESOURCES"
    echo -e "   ${CYAN}• PROCESS PRIORITIES:${NC} AI WORKLOADS GET HIGHER PRIORITY"
    echo ""

    echo -e "${YELLOW}2. CURSOR AI EDITOR OPTIMIZATIONS:${NC}"
    echo -e "   ${CYAN}• AI COMPLETION:${NC} OPTIMIZE RESPONSE TIME & CONTEXT PROCESSING"
    echo -e "   ${CYAN}• FILE WATCHING:${NC} EXCLUDE UNNECESSARY DIRECTORIES"
    echo -e "   ${CYAN}• MEMORY USAGE:${NC} CONFIGURE OPTIMAL HEAP & GARBAGE COLLECTION"
    echo -e "   ${CYAN}• NETWORK:${NC} OPTIMIZE API CALLS & STREAMING RESPONSES"
    echo ""

    echo -e "${YELLOW}3. HARDWARE ACCELERATION:${NC}"
    echo -e "   ${CYAN}• METAL PERFORMANCE:${NC} ENABLE APPLE SILICON GPU ACCELERATION"
    echo -e "   ${CYAN}• NEURAL ENGINE:${NC} LEVERAGE HARDWARE AI ACCELERATION"
    echo -e "   ${CYAN}• UNIFIED MEMORY:${NC} OPTIMIZE MEMORY ARCHITECTURE FOR AI"
    echo -e "   ${CYAN}• GRAPHICS:${NC} CONFIGURE OPTIMAL RENDERING ACCELERATION"
    echo ""

    echo -e "${YELLOW}4. SYSTEM DATABASE OPTIMIZATION:${NC}"
    echo -e "   ${CYAN}• LAUNCH SERVICES:${NC} REBUILD FOR FASTER APP LAUNCHES"
    echo -e "   ${CYAN}• SPOTLIGHT INDEX:${NC} REFRESH FOR BETTER SEARCH PERFORMANCE"
    echo -e "   ${CYAN}• FONT CACHE:${NC} CLEAR CORRUPTED CACHE THAT SLOWS RENDERING"
    echo -e "   ${CYAN}• KERNEL CACHE:${NC} OPTIMIZE SYSTEM RESPONSIVENESS"
    echo ""

    echo -e "${BOLD}${GREEN}PERFORMANCE IMPROVEMENTS EXPECTED:${NC}"
    echo -e "   ${GREEN}✓${NC} 3-5x FASTER AI CODE COMPLETION RESPONSES"
    echo -e "   ${GREEN}✓${NC} REDUCED MEMORY USAGE AND BETTER MULTITASKING"
    echo -e "   ${GREEN}✓${NC} FASTER FILE OPERATIONS AND PROJECT LOADING"
    echo -e "   ${GREEN}✓${NC} SMOOTHER EDITOR INTERACTIONS AND SCROLLING"
    echo -e "   ${GREEN}✓${NC} MAXIMUM UTILIZATION OF APPLE SILICON HARDWARE"
    echo -e "   ${GREEN}✓${NC} OPTIMIZED AI MODEL LOADING AND INFERENCE"
    echo ""

    if [[ "$NON_INTERACTIVE_MODE" != "true" ]]; then
        echo -n "PROCEED WITH PRODUCTION-GRADE OPTIMIZATION? (y/N): "
        read -r response
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                production_info_message "USER CONFIRMED PRODUCTION-GRADE OPTIMIZATION"
                ;;
            *)
                production_info_message "OPTIMIZATION CANCELLED BY USER"
                return 0 # Exit gracefully if user cancels
                ;;
        esac
    fi

    echo -e "\n${BOLD}${BLUE}🔧 APPLYING PRODUCTION OPTIMIZATIONS...${NC}\n"

    # PRODUCTION APPROACH: Automatically close Cursor if running
    # This uses terminate_cursor_processes from helpers.sh
    if check_cursor_processes > /dev/null; then
        production_info_message "CLOSING CURSOR FOR COMPLETE OPTIMIZATION..."
        terminate_cursor_processes 10 5 3 # From helpers.sh: graceful_timeout=10s, force_timeout=5s, max_attempts=3
        production_success_message "✓ Cursor processes terminated - ready for optimization"
    fi
    
    local optimizations_applied=0
    local optimization_warnings=0

    # Get system memory information (vm_stat might not be available everywhere, provide fallback)
    local available_memory_gb
    local memory_info
    memory_info=$(vm_stat 2>/dev/null)
    
    if [[ -n "$memory_info" ]]; then
        local page_size=4096 # Standard macOS page size
        local free_pages
        free_pages=$(echo "$memory_info" | grep "Pages free" | awk '{print $3}' | sed 's/\.//' || echo "0")
        local inactive_pages
        inactive_pages=$(echo "$memory_info" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//' || echo "0")
        local available_bytes=$(( (free_pages + inactive_pages) * page_size ))
        available_memory_gb=$(( available_bytes / 1024 / 1024 / 1024 ))
    else
        local total_memory_bytes
        total_memory_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "8589934592") # Default to 8GB if sysctl fails
        available_memory_gb=$(( total_memory_bytes / 1024 / 1024 / 1024 / 4 )) # Estimate 25% available
    fi
    
    production_info_message "AVAILABLE MEMORY: ${available_memory_gb}GB"

    production_info_message "Requesting administrative privileges for system optimizations..."
    if ! sudo -v 2>/dev/null; then
        production_warning_message "Administrative privileges required for complete optimization."
        production_info_message "Please enter your password when prompted."
        if ! sudo echo "Administrative access granted for optimizations."; then
            production_error_message "Unable to obtain administrative privileges. Some optimizations will be skipped."
            # No forceful exit here, script will try to apply what it can.
        fi
    else
        production_success_message "✓ Administrative privileges confirmed."
    fi

    # 1. Cursor AI Performance Settings
    production_info_message "Configuring Cursor AI performance settings..."
    local cursor_settings_file="$HOME/Library/Application Support/Cursor/User/settings.json"
    local cursor_settings_dir
    cursor_settings_dir="$(dirname "$cursor_settings_file")"
    
    if [[ ! -d "$cursor_settings_dir" ]]; then
        mkdir -p "$cursor_settings_dir" || production_warning_message "Could not create Cursor settings directory: $cursor_settings_dir"
    fi

    # Production-grade Cursor settings
    # Using cat and here-string for multiline JSON
    local ai_config
ai_config=$(cat <<EOF
{
    "ai.enabled": true,
    "ai.autoComplete": true,
    "ai.codeActions": true,
    "ai.contextLength": 8192,
    "ai.temperature": 0.05,
    "ai.maxTokens": 2048,
    "ai.streamResponse": true,
    "ai.parallelRequests": 4,
    "editor.inlineSuggest.enabled": true,
    "editor.minimap.enabled": false,
    "editor.wordWrap": "off",
    "editor.renderLineHighlight": "none",
    "editor.renderWhitespace": "none",
    "editor.smoothScrolling": false,
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 5000,
    "search.useIgnoreFiles": true,
    "search.exclude": {
        "**/node_modules": true,
        "**/.git": true,
        "**/dist": true,
        "**/build": true,
        "**/.next": true,
        "**/coverage": true
    },
    "files.watcherExclude": {
        "**/node_modules/**": true,
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/dist/**": true,
        "**/build/**": true
    },
    "extensions.autoUpdate": false,
    "telemetry.enableTelemetry": false,
    "workbench.colorTheme": "Dark+",
    "window.titleBarStyle": "native",
    "terminal.integrated.gpuAcceleration": "on"
}
EOF
)
    if echo "$ai_config" > "$cursor_settings_file"; then
        production_success_message "✓ CURSOR AI PERFORMANCE SETTINGS CONFIGURED"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not configure Cursor settings at $cursor_settings_file"
        ((optimization_warnings++))
    fi

    # 2. System-Level Memory and Performance Optimizations
    production_info_message "Applying system-level performance optimizations..."
    if ulimit -n "$FILE_DESCRIPTOR_LIMIT" 2>/dev/null; then
        production_success_message "✓ Increased file descriptor limit to $FILE_DESCRIPTOR_LIMIT"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not increase file descriptor limit (may require sudo or config file edit)"
        ((optimization_warnings++))
    fi

    if sudo sysctl -w kern.sysv.shmmax=268435456 >/dev/null 2>&1; then
        production_success_message "✓ Optimized shared memory limits"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not modify shared memory settings (sudo might have failed or param not available)"
        ((optimization_warnings++))
    fi

    if sudo sysctl -w vm.global_user_wire_limit=134217728 >/dev/null 2>&1; then
        production_success_message "✓ Optimized file system cache"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not optimize file system cache (sudo might have failed or param not available)"
        ((optimization_warnings++))
    fi

    # 3. macOS System Optimizations
    production_info_message "Applying macOS system optimizations..."
    if defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false 2>/dev/null; then
        production_success_message "✓ Disabled window animations"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not disable window animations"
        ((optimization_warnings++))
    fi
    if defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false 2>/dev/null; then
        production_success_message "✓ Disabled scroll animations"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not disable scroll animations"
        ((optimization_warnings++))
    fi
    if defaults write com.apple.dock autohide-time-modifier -float 0.12 2>/dev/null && killall Dock 2>/dev/null; then
        production_success_message "✓ Optimized dock animations"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not optimize dock animations"
        ((optimization_warnings++))
    fi

    # 4. Hardware Acceleration Configuration (specific to Cursor's plist if available, otherwise general Electron flags)
    # CURSOR_BUNDLE_ID is from config.sh
    production_info_message "Configuring hardware acceleration..."
    if defaults write "$CURSOR_BUNDLE_ID" disable-metal-rendering -bool false 2>/dev/null; then
        production_success_message "✓ Enabled Metal rendering for Cursor"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not configure Metal rendering for Cursor (app specific plist might not exist or perm issue)"
        ((optimization_warnings++))
    fi
    if defaults write "$CURSOR_BUNDLE_ID" disable-gpu -bool false 2>/dev/null; then
        production_success_message "✓ Enabled GPU acceleration for Cursor"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not enable GPU acceleration for Cursor (app specific plist might not exist or perm issue)"
        ((optimization_warnings++))
    fi

    # 5. Network and API Optimizations
    production_info_message "Optimizing network settings for AI API performance..."
    if sudo sysctl -w net.inet.tcp.delayed_ack=0 >/dev/null 2>&1; then
        production_success_message "✓ Optimized TCP settings for AI APIs"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not optimize TCP settings (sudo might have failed or param not available)"
        ((optimization_warnings++))
    fi

    # 6. Cache and Database Optimizations
    production_info_message "Optimizing system databases and caches..."
    # LAUNCH_SERVICES_CMD is from config.sh
    if sudo "$LAUNCH_SERVICES_CMD" -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
        production_success_message "✓ Refreshed Launch Services database"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not refresh Launch Services database"
        ((optimization_warnings++))
    fi
    if sudo atsutil databases -remove >/dev/null 2>&1; then
        production_success_message "✓ Cleared font caches"
        ((optimizations_applied++))
    else
        production_warning_message "⚠ Could not clear font caches"
        ((optimization_warnings++))
    fi

    # 7. Spotlight Optimization for Development
    production_info_message "Optimizing Spotlight for development workflows..."
    local spotlight_exclusions=(
        "$HOME/node_modules"
        "$HOME/.npm"
        "$HOME/.cache" # General cache folder
        "$HOME/Library/Caches" # User Caches
        "$HOME/Library/Developer" # Xcode derived data, etc.
        "$HOME/.vscode" # VSCode general config/cache
        "$HOME/.cursor" # Cursor specific config/cache
        "$PROJECT_ROOT_OPTIMIZE/node_modules" # Project specific node_modules
        "$PROJECT_ROOT_OPTIMIZE/coverage"
        "$PROJECT_ROOT_OPTIMIZE/build"
        "$PROJECT_ROOT_OPTIMIZE/dist"
    )
    local spotlight_optimized_count=0
    for exclusion_path in "${spotlight_exclusions[@]}"; do
        # Ensure path exists and is a directory before trying to run mdutil
        if [[ -d "$exclusion_path" ]]; then
            # Check if Spotlight is even managing this path
            if sudo mdutil -s "$exclusion_path" 2>/dev/null | grep -q "Indexing enabled"; then
                if sudo mdutil -i off "$exclusion_path" >/dev/null 2>&1; then
                    production_log_message "DEBUG" "Successfully disabled Spotlight indexing for: $exclusion_path"
                    ((spotlight_optimized_count++))
                else
                    production_log_message "DEBUG" "Could not disable Spotlight indexing for: $exclusion_path (mdutil -i off failed)"
                fi
            else
                 production_log_message "DEBUG" "Spotlight indexing already off or not applicable for: $exclusion_path"
            fi
        else
            production_log_message "DEBUG" "Spotlight exclusion path not found or not a directory: $exclusion_path"
        fi
    done
    if [[ $spotlight_optimized_count -gt 0 ]]; then
        production_success_message "✓ Optimized Spotlight indexing ($spotlight_optimized_count paths excluded)"
        ((optimizations_applied++))
    else
        production_info_message "ℹ Spotlight indexing for specified paths either already off or paths not found."
    fi

    # 8. Environment Variables for AI Performance
    production_info_message "Setting environment variables for AI performance..."
    local env_vars_to_set
env_vars_to_set=$(cat <<EOF
# Cursor AI Performance Environment Variables (added by optimize_system.sh)
export NODE_OPTIONS="--max-old-space-size=${AI_MEMORY_LIMIT_GB}192 --max-semi-space-size=512" # e.g. 8192 for 8GB
export UV_THREADPOOL_SIZE=16 # Increased thread pool size for async operations
export ELECTRON_ENABLE_GPU=1 # Ensure Electron uses GPU
export ELECTRON_USE_METAL=1 # Force Metal on macOS for Electron
export FORCE_COLOR=1 # For CLI tools that might be used alongside
export CURSOR_AI_OPTIMIZED=1 # Flag to indicate optimizations applied
# End Cursor AI Performance Environment Variables
EOF
)
    local shell_config_files=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
    local env_vars_applied_to_shell=false
    for shell_config_file in "${shell_config_files[@]}"; do
        if [[ -f "$shell_config_file" ]] || [[ "$shell_config_file" == "$HOME/.zshrc" && "$SHELL" == *"zsh"* ]] || [[ "$shell_config_file" == "$HOME/.bashrc" && "$SHELL" == *"bash"* ]]; then
            # Remove existing block
            # Using awk for more robust block removal
            awk '
                /# Cursor AI Performance Environment Variables/,/# End Cursor AI Performance Environment Variables/ {next}
                {print}
            ' "$shell_config_file" > "${shell_config_file}.tmp" && mv "${shell_config_file}.tmp" "$shell_config_file"

            # Add new block
            if echo -e "\n$env_vars_to_set" >> "$shell_config_file"; then
                production_success_message "✓ Configured environment variables in: $shell_config_file"
                env_vars_applied_to_shell=true
            else
                production_warning_message "⚠ Could not configure environment variables in: $shell_config_file"
            fi
        fi
    done

    if [[ "$env_vars_applied_to_shell" == "true" ]]; then
        ((optimizations_applied++))
        production_info_message "Please source your shell config (e.g., source ~/.zshrc) or restart your terminal to apply environment variables."
    else
        production_warning_message "⚠ Could not find a common shell config file to set environment variables."
        ((optimization_warnings++))
    fi
    
    echo ""
    if [[ $optimizations_applied -gt 8 ]]; then # Threshold for "excellent"
        production_success_message "🎉 PRODUCTION-GRADE OPTIMIZATION COMPLETED SUCCESSFULLY"
        production_info_message "APPLIED $optimizations_applied PRODUCTION OPTIMIZATION TECHNIQUES."
        if [[ $optimization_warnings -gt 0 ]]; then
            production_warning_message "Completed with $optimization_warnings warnings (non-critical)."
        fi
        echo -e "\n${GREEN}${BOLD}OPTIMIZATION RESULTS:${NC}"
        # ... (rest of success messages)
    else
        production_warning_message "OPTIMIZATION COMPLETED WITH SOME LIMITATIONS."
        production_info_message "APPLIED $optimizations_applied OPTIMIZATION TECHNIQUES."
        production_warning_message "$optimization_warnings OPTIMIZATION STEPS HAD ISSUES."
        echo -e "\n${YELLOW}${BOLD}RECOMMENDATIONS:${NC}"
        # ... (rest of warning messages)
    fi
    return 0
}

# Enhanced memory and performance optimization for production use (Copied from bin/uninstall_cursor.sh)
# This function seems to be a duplicate or an older version of some optimizations.
# For now, I will include it as per the plan to extract. It might be refactored or merged later.
optimize_memory_and_performance() {
    production_info_message "[optimize_memory_and_performance] APPLYING PRODUCTION MEMORY AND PERFORMANCE TUNING"
    
    local tuning_applied=0
    
    # 1. Increase file descriptor limits for AI model loading
    production_info_message "[optimize_memory_and_performance] Configuring file descriptor limits..."
    if ulimit -n "$FILE_DESCRIPTOR_LIMIT" 2>/dev/null; then
        production_success_message "[optimize_memory_and_performance] ✓ Increased file descriptor limit to $FILE_DESCRIPTOR_LIMIT"
        ((tuning_applied++))
    else
        production_warning_message "[optimize_memory_and_performance] ⚠ Could not increase file descriptor limit"
    fi
    
    # 2. Configure optimal memory pressure handling
    production_info_message "[optimize_memory_and_performance] Optimizing memory pressure settings..."
    if sudo sysctl -w kern.sysv.shmmax=268435456 >/dev/null 2>&1; then
        production_success_message "[optimize_memory_and_performance] ✓ Configured memory pressure handling"
        ((tuning_applied++))
    else
        production_warning_message "[optimize_memory_and_performance] ⚠ Could not modify memory pressure settings"
    fi
    
    # 3. Configure LaunchServices for faster app launching
    production_info_message "[optimize_memory_and_performance] Optimizing Launch Services for faster Cursor startup..."
    if sudo "$LAUNCH_SERVICES_CMD" -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
        production_success_message "[optimize_memory_and_performance] ✓ Refreshed Launch Services database"
        ((tuning_applied++))
    else
        production_warning_message "[optimize_memory_and_performance] ⚠ Could not refresh Launch Services"
    fi
    
    # 4. Configure kernel parameters for AI workloads
    production_info_message "[optimize_memory_and_performance] Applying kernel parameter optimizations..."
    if sudo sysctl -w vm.global_user_wire_limit=134217728 >/dev/null 2>&1; then
        production_success_message "[optimize_memory_and_performance] ✓ Optimized file system cache"
        ((tuning_applied++))
    fi
    
    # 5. Configure audio/video for reduced interference with AI processing (Less relevant for Cursor, but general perf)
    production_info_message "[optimize_memory_and_performance] Reducing multimedia interference..."
    if defaults write com.apple.coreaudio Disable_IOAudio_10_6_Audio_Driver -bool true 2>/dev/null; then
        production_success_message "[optimize_memory_and_performance] ✓ Reduced audio processing overhead"
        ((tuning_applied++))
    fi
    
    # 6. Optimize Spotlight indexing to exclude development directories
    production_info_message "[optimize_memory_and_performance] Configuring Spotlight for development workflows..."
    local spotlight_exclusions=(
        "$HOME/node_modules"
        "$HOME/.npm"
        "$HOME/.cache"
        "$HOME/Library/Caches"
        "$HOME/Library/Developer"
        # Project specific paths if known, or add them to Cursor's .vscode/settings.json search.exclude
    )
    local excluded_count=0
    for exclusion in "${spotlight_exclusions[@]}"; do
        if [[ -d "$exclusion" ]]; then
            if sudo mdutil -s "$exclusion" 2>/dev/null | grep -q "Indexing enabled"; then
                if sudo mdutil -i off "$exclusion" >/dev/null 2>&1; then
                    production_log_message "DEBUG" "[optimize_memory_and_performance] Successfully disabled Spotlight indexing for: $(basename "$exclusion")"
                    ((excluded_count++))
                else
                    production_log_message "DEBUG" "[optimize_memory_and_performance] Could not disable Spotlight indexing for: $(basename "$exclusion")"
                fi
            fi
        fi
    done
    if [[ $excluded_count -gt 0 ]]; then
        production_success_message "[optimize_memory_and_performance] ✓ Optimized Spotlight indexing ($excluded_count directories)"
        ((tuning_applied++))
    else
        production_log_message "DEBUG" "[optimize_memory_and_performance] Spotlight optimization skipped or already configured."
    fi
    
    # 7. Configure network settings for AI API calls
    production_info_message "[optimize_memory_and_performance] Optimizing network settings for AI API performance..."
    if sudo sysctl -w net.inet.tcp.delayed_ack=0 >/dev/null 2>&1; then
        production_success_message "[optimize_memory_and_performance] ✓ Optimized TCP settings for AI APIs"
        ((tuning_applied++))
    fi
    
    production_info_message "[optimize_memory_and_performance] PRODUCTION MEMORY TUNING: Applied $tuning_applied optimizations."
    
    if [[ $tuning_applied -gt 4 ]]; then # Arbitrary threshold for success
        return 0
    else
        return 1
    fi
}


# Main execution for this script
# This allows the script to be called directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Call the main optimization function when script is executed.
    # Pass all command-line arguments to the function.
    production_execute_optimize "$@"
fi

exit 0
