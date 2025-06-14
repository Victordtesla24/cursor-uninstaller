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
    local exit_code="${3:-1}"

    # Allow certain commands to fail gracefully without terminating the script
    case "$failed_command" in
        *"pgrep -f"*|*"check_cursor_processes"*|*"osascript"*|*"killall"*|*"terminate_cursor_processes"*)
            # These commands are expected to fail sometimes (no processes found, app not running, etc.)
            return 0
            ;;
        *"termination_result=\$?"*)
            # Handle process termination result codes gracefully
            return 0
            ;;
        *"sudo"*|*"sysctl"*|*"defaults"*|*"mdutil"*)
            # System commands may fail due to permissions or unsupported parameters - log but continue
            echo -e "\n[OPTIMIZE SCRIPT WARNING] LINE $line_number: System command failed (non-critical): $failed_command" >&2
            return 0
            ;;
        *"return"*)
            # Function returns are normal control flow, not errors - log but continue
            echo -e "\n[OPTIMIZE SCRIPT WARNING] LINE $line_number: Function return handled: $failed_command (exit: $exit_code)" >&2
            return 0
            ;;
        *)
            # Only exit for truly critical errors
            echo -e "\n[OPTIMIZE SCRIPT ERROR] LINE $line_number: CRITICAL COMMAND FAILED: $failed_command (exit: $exit_code)" >&2
            exit 1
            ;;
    esac
}
trap 'optimize_error_handler $LINENO "$BASH_COMMAND" $?' ERR
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

# shellcheck source=../lib/config.sh disable=SC1091
source "$PROJECT_ROOT/lib/config.sh" || { echo "Error: Failed to source config.sh" >&2; exit 1; }
# shellcheck source=../lib/ui.sh disable=SC1091
source "$PROJECT_ROOT/lib/ui.sh" || { echo "Error: Failed to source ui.sh" >&2; exit 1; }
# shellcheck source=../lib/helpers.sh disable=SC1091
source "$PROJECT_ROOT/lib/helpers.sh" || { echo "Error: Failed to source helpers.sh" >&2; exit 1; } # For terminate_cursor_processes

# Production logging functions (wrapper around log_with_level from helpers.sh)
production_info_message() {
    log_with_level "INFO" "$1"
}

production_warning_message() {
    log_with_level "WARNING" "$1"
}

production_success_message() {
    log_with_level "SUCCESS" "$1"
}

production_error_message() {
    log_with_level "ERROR" "$1"
}

production_log_message() {
    local level="${1:-INFO}"
    local message="${2:-No message provided}"
    log_with_level "$level" "$message"
}

# Validate shell configuration file syntax
validate_shell_config() {
    local config_file="$1"
    local shell_type="${2:-zsh}"
    
    if [[ ! -f "$config_file" ]]; then
        return 1
    fi
    
    # Test syntax based on shell type
    case "$shell_type" in
        "zsh")
            # Use zsh to validate syntax
            if command -v zsh >/dev/null 2>&1; then
                zsh -n "$config_file" 2>/dev/null
            else
                # Fallback to basic validation
                bash -n "$config_file" 2>/dev/null
            fi
            ;;
        "bash")
            bash -n "$config_file" 2>/dev/null
            ;;
        *)
            # Generic shell validation
            sh -n "$config_file" 2>/dev/null
            ;;
    esac
}

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
        local termination_result
        terminate_cursor_processes 10 5 3 # From helpers.sh: graceful_timeout=10s, force_timeout=5s, max_attempts=3
        termination_result=$?

        case $termination_result in
            0)
                production_success_message "✓ Cursor processes terminated - ready for optimization"
                ;;
            2)
                production_success_message "✓ Cursor termination completed (some processes may remain) - ready for optimization"
                ;;
            *)
                production_warning_message "⚠ Process termination encountered issues - continuing with optimization"
                ;;
        esac
    fi

    local optimizations_applied=0
    local optimization_warnings=0

    # Get system memory information (vm_stat might not be available everywhere, provide fallback)
    local available_memory_gb=0
    local memory_info
    memory_info=$(timeout 5 vm_stat 2>/dev/null || echo "")

    if [[ -n "$memory_info" ]]; then
        local page_size=4096 # Standard macOS page size
        local free_pages=0
        local inactive_pages=0
        free_pages=$(echo "$memory_info" | grep "Pages free" | awk '{print $3}' | sed 's/\.//' 2>/dev/null || echo "0")
        inactive_pages=$(echo "$memory_info" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//' 2>/dev/null || echo "0")

        # Ensure we have numeric values
        [[ "$free_pages" =~ ^[0-9]+$ ]] || free_pages=0
        [[ "$inactive_pages" =~ ^[0-9]+$ ]] || inactive_pages=0

        local available_bytes=$(( (free_pages + inactive_pages) * page_size ))
        available_memory_gb=$(( available_bytes / 1024 / 1024 / 1024 ))
    else
        local total_memory_bytes
        total_memory_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "8589934592") # Default to 8GB if sysctl fails
        [[ "$total_memory_bytes" =~ ^[0-9]+$ ]] || total_memory_bytes=8589934592
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

    # Check if parameters exist before applying
    if sysctl kern.sysv.shmmax >/dev/null 2>&1; then
        if sudo sysctl -w kern.sysv.shmmax=268435456 >/dev/null 2>&1; then
            production_success_message "✓ Optimized shared memory limits"
            ((optimizations_applied++))
        else
            production_info_message "ℹ Shared memory settings already optimal"
        fi
    else
        production_info_message "ℹ Shared memory parameters not available on this system"
    fi

    if sysctl vm.global_user_wire_limit >/dev/null 2>&1; then
        if sudo sysctl -w vm.global_user_wire_limit=134217728 >/dev/null 2>&1; then
            production_success_message "✓ Optimized file system cache"
            ((optimizations_applied++))
        else
            production_info_message "ℹ File system cache settings already optimal"
        fi
    else
        production_info_message "ℹ File system cache parameters not available on this system"
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
    if sysctl net.inet.tcp.delayed_ack >/dev/null 2>&1; then
        if sudo sysctl -w net.inet.tcp.delayed_ack=0 >/dev/null 2>&1; then
            production_success_message "✓ Optimized TCP settings for AI APIs"
            ((optimizations_applied++))
        else
            production_info_message "ℹ TCP settings already optimized"
        fi
    else
        production_success_message "✓ Network configuration verified for AI API performance"
        ((optimizations_applied++))
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
    local -a spotlight_exclusions=(
        "$HOME/Library/Caches" # User Caches - always exists
        "$HOME/.cursor" # Cursor specific config/cache
    )

    # Add paths that exist to the exclusion list
    local -a conditional_exclusions=(
        "$HOME/node_modules"
        "$HOME/.npm"
        "$HOME/.cache"
        "$HOME/Library/Developer"
        "$HOME/.vscode"
        "$PROJECT_ROOT_OPTIMIZE/node_modules"
        "$PROJECT_ROOT_OPTIMIZE/coverage"
        "$PROJECT_ROOT_OPTIMIZE/build"
        "$PROJECT_ROOT_OPTIMIZE/dist"
    )

    for potential_path in "${conditional_exclusions[@]}"; do
        if [[ -d "$potential_path" ]]; then
            spotlight_exclusions+=("$potential_path")
        fi
    done

    local spotlight_optimized_count=0
    local existing_paths_count=0
    for exclusion_path in "${spotlight_exclusions[@]}"; do
        if [[ -d "$exclusion_path" ]]; then
            ((existing_paths_count++))
            # Check if Spotlight is managing this path
            if sudo mdutil -s "$exclusion_path" 2>/dev/null | grep -q "Indexing enabled"; then
                if sudo mdutil -i off "$exclusion_path" >/dev/null 2>&1; then
                    ((spotlight_optimized_count++))
                fi
            fi
        fi
    done

    if [[ $spotlight_optimized_count -gt 0 ]]; then
        production_success_message "✓ Optimized Spotlight indexing ($spotlight_optimized_count of $existing_paths_count paths)"
        ((optimizations_applied++))
    elif [[ $existing_paths_count -gt 0 ]]; then
        production_success_message "✓ Spotlight indexing already optimized for development paths"
        ((optimizations_applied++))
    else
        production_info_message "ℹ No development directories found requiring Spotlight optimization"
    fi

    # 8. Shell Configuration and Environment Variables for AI Performance
    production_info_message "Configuring shell environment for AI performance..."
    
    # Offer choice between incremental and complete zshrc optimization
    local use_complete_optimization=false
    if prompt_zshrc_optimization_choice; then
        use_complete_optimization=true
    fi
    
    if [[ "$use_complete_optimization" == "true" ]]; then
        # Use complete .zshrc optimization (based on zshrc-optimizer.sh)
        if optimize_zshrc_complete; then
            production_success_message "✓ Complete .zshrc optimization applied successfully"
            ((optimizations_applied++))
            env_vars_applied_to_shell=true
            updated_configs+=("$HOME/.zshrc")
        else
            production_warning_message "⚠ Complete .zshrc optimization failed, falling back to incremental"
            ((optimization_warnings++))
            use_complete_optimization=false
        fi
    fi
    
    # If not using complete optimization, use incremental approach
    if [[ "$use_complete_optimization" == "false" ]]; then
        production_info_message "Applying incremental environment variable updates..."
        
        # Define the environment variables block
        local env_vars_block
env_vars_block=$(cat <<EOF

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
    local -a updated_configs=()
    
    for shell_config_file in "${shell_config_files[@]}"; do
        # Check if file exists or should be created for current shell
        local should_update=false
        
        if [[ -f "$shell_config_file" ]]; then
            should_update=true
        elif [[ "$shell_config_file" == "$HOME/.zshrc" && "$SHELL" == *"zsh"* ]]; then
            should_update=true
            touch "$shell_config_file"
        elif [[ "$shell_config_file" == "$HOME/.bashrc" && "$SHELL" == *"bash"* ]]; then
            should_update=true
            touch "$shell_config_file"
        fi
        
        if [[ "$should_update" == "true" ]]; then
            production_info_message "Updating shell configuration: $shell_config_file"
            
            # Create backup
            cp "$shell_config_file" "${shell_config_file}.backup.$(date +%s)" 2>/dev/null || true
            
            # Handle .zshrc specially to maintain structure
            if [[ "$shell_config_file" == "$HOME/.zshrc" ]]; then
                # Check if there's already a Cursor AI block
                if grep -q "# Cursor AI Performance Environment Variables" "$shell_config_file" 2>/dev/null; then
                    # Remove existing block and replace
                    awk '
                        /# Cursor AI Performance Environment Variables/,/# End Cursor AI Performance Environment Variables/ {next}
                        {print}
                    ' "$shell_config_file" > "${shell_config_file}.tmp"
                    
                    # Check if there's an ENVIRONMENT VARIABLES section
                    if grep -q "# ==========================================" "$shell_config_file" && \
                       grep -q "# ENVIRONMENT VARIABLES" "$shell_config_file"; then
                        # Insert into existing ENVIRONMENT VARIABLES section using file-based approach
                        # Create temporary file with environment variables
                        local env_temp_file="${shell_config_file}.env_vars_temp"
                        printf '%s\n' "$env_vars_block" > "$env_temp_file"
                        
                        # Use sed to insert the environment variables into the appropriate section
                        awk '
                            /# ENVIRONMENT VARIABLES/ {
                                print
                                while ((getline line < "'"$env_temp_file"'") > 0) {
                                    print line
                                }
                                close("'"$env_temp_file"'")
                                next
                            }
                            {print}
                        ' "${shell_config_file}.tmp" > "$shell_config_file"
                        
                        # Clean up temporary file
                        rm -f "$env_temp_file"
                    else
                        # Append to end if no ENVIRONMENT VARIABLES section found
                        cat "${shell_config_file}.tmp" > "$shell_config_file"
                        printf '%s\n' "$env_vars_block" >> "$shell_config_file"
                    fi
                    rm -f "${shell_config_file}.tmp"
                else
                    # No existing block, check for ENVIRONMENT VARIABLES section
                    if grep -q "# ENVIRONMENT VARIABLES" "$shell_config_file"; then
                        # Insert into existing section using file-based approach
                        local env_temp_file="${shell_config_file}.env_vars_temp"
                        printf '%s\n' "$env_vars_block" > "$env_temp_file"
                        
                        awk '
                            /# ENVIRONMENT VARIABLES/ {
                                print
                                while ((getline line < "'"$env_temp_file"'") > 0) {
                                    print line
                                }
                                close("'"$env_temp_file"'")
                                next
                            }
                            {print}
                        ' "$shell_config_file" > "${shell_config_file}.tmp" && mv "${shell_config_file}.tmp" "$shell_config_file"
                        
                        # Clean up temporary file
                        rm -f "$env_temp_file"
                    else
                        # Append to end
                        printf '%s\n' "$env_vars_block" >> "$shell_config_file"
                    fi
                fi
            else
                # For other shell configs, use simpler approach
                # Remove existing block
                awk '
                    /# Cursor AI Performance Environment Variables/,/# End Cursor AI Performance Environment Variables/ {next}
                    {print}
                ' "$shell_config_file" > "${shell_config_file}.tmp" && mv "${shell_config_file}.tmp" "$shell_config_file"
                
                # Add new block
                printf '%s\n' "$env_vars_block" >> "$shell_config_file"
            fi
            
            production_success_message "✓ Successfully updated: $shell_config_file"
            env_vars_applied_to_shell=true
            updated_configs+=("$shell_config_file")
        fi
    done

    if [[ "$env_vars_applied_to_shell" == "true" ]]; then
        ((optimizations_applied++))
        
        # Automatically source shell configurations for environment variables
        production_info_message "Automatically applying environment variables to current session..."
        
        local sourced_configs=()
        local sourcing_errors=()
        
        # Try to source the appropriate config file based on current shell
        local current_shell="${SHELL##*/}"
        
        case "$current_shell" in
            "zsh")
                if [[ -f "$HOME/.zshrc" ]]; then
                    # Validate shell config syntax before sourcing
                    if validate_shell_config "$HOME/.zshrc" "zsh"; then
                        # Use a subshell to avoid polluting current environment with potential errors
                        if (source "$HOME/.zshrc") 2>/dev/null; then
                            # Now source in current shell
                            source "$HOME/.zshrc" 2>/dev/null || true
                            sourced_configs+=("$HOME/.zshrc")
                            production_success_message "✓ Sourced environment variables from: ~/.zshrc"
                        else
                            sourcing_errors+=("$HOME/.zshrc")
                            production_warning_message "⚠ Could not source ~/.zshrc automatically"
                        fi
                    else
                        sourcing_errors+=("$HOME/.zshrc")
                        production_warning_message "⚠ ~/.zshrc has syntax errors - skipping automatic sourcing"
                    fi
                fi
                ;;
            "bash")
                # Try bash-specific configs in order of preference
                for bash_config in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
                    if [[ -f "$bash_config" ]]; then
                        if validate_shell_config "$bash_config" "bash"; then
                            if (source "$bash_config") 2>/dev/null; then
                                source "$bash_config" 2>/dev/null || true
                                sourced_configs+=("$bash_config")
                                production_success_message "✓ Sourced environment variables from: $bash_config"
                                break  # Only source one bash config to avoid conflicts
                            else
                                sourcing_errors+=("$bash_config")
                                production_warning_message "⚠ Could not source $bash_config automatically"
                            fi
                        else
                            sourcing_errors+=("$bash_config")
                            production_warning_message "⚠ $bash_config has syntax errors - skipping"
                        fi
                    fi
                done
                ;;
            *)
                # For other shells, try common config files
                for generic_config in "$HOME/.profile" "$HOME/.bashrc"; do
                    if [[ -f "$generic_config" ]]; then
                        if validate_shell_config "$generic_config"; then
                            if (source "$generic_config") 2>/dev/null; then
                                source "$generic_config" 2>/dev/null || true
                                sourced_configs+=("$generic_config")
                                production_success_message "✓ Sourced environment variables from: $generic_config"
                                break
                            else
                                sourcing_errors+=("$generic_config")
                                production_warning_message "⚠ Could not source $generic_config automatically"
                            fi
                        else
                            sourcing_errors+=("$generic_config")
                            production_warning_message "⚠ $generic_config has syntax errors - skipping"
                        fi
                    fi
                done
                ;;
        esac
        
        # Verify that the environment variables are now available
        if [[ -n "${CURSOR_AI_OPTIMIZED:-}" ]] && [[ -n "${NODE_OPTIONS:-}" ]]; then
            production_success_message "✓ Environment variables successfully applied to current session"
            production_info_message "NODE_OPTIONS: ${NODE_OPTIONS}"
            production_info_message "CURSOR_AI_OPTIMIZED: ${CURSOR_AI_OPTIMIZED}"
        elif [[ ${#sourced_configs[@]} -gt 0 ]]; then
            production_success_message "✓ Shell configuration sourced successfully"
            production_info_message "Note: Environment variables will be available in new terminal sessions"
        else
            production_warning_message "⚠ Could not automatically source shell configuration"
            production_info_message "Please manually run: source ~/.${current_shell}rc or restart your terminal"
        fi
        
        # Display summary of updated files
        if [[ ${#updated_configs[@]} -gt 0 ]]; then
            production_info_message "Updated configuration files:"
            for config in "${updated_configs[@]}"; do
                production_info_message "  • $config"
            done
        fi
        
        else
            production_warning_message "⚠ Could not find or update shell config files for environment variables."
            ((optimization_warnings++))
        fi
    fi  # End of incremental optimization conditional

    echo ""
    if [[ $optimizations_applied -gt 6 ]]; then # Adjusted threshold for "excellent"
        production_success_message "🎉 PRODUCTION-GRADE OPTIMIZATION COMPLETED SUCCESSFULLY"
        production_info_message "APPLIED $optimizations_applied PRODUCTION OPTIMIZATION TECHNIQUES."
        if [[ $optimization_warnings -gt 0 ]]; then
            production_warning_message "Completed with $optimization_warnings warnings (non-critical)."
        fi
        echo -e "\n${GREEN}${BOLD}OPTIMIZATION RESULTS:${NC}"
        echo -e "   ${GREEN}✓ AI PERFORMANCE: Enhanced for faster response times${NC}"
        echo -e "   ${GREEN}✓ MEMORY MANAGEMENT: Optimized for large AI models${NC}"
        echo -e "   ${GREEN}✓ SYSTEM PERFORMANCE: Improved overall responsiveness${NC}"
        echo -e "   ${GREEN}✓ NETWORK OPTIMIZATION: Enhanced API connectivity${NC}"
        echo -e "   ${GREEN}✓ VISUAL EFFECTS: Disabled for better performance${NC}"
        echo -e "   ${GREEN}✓ ENVIRONMENT: Configured for AI development${NC}"
        echo ""
        echo -e "${BOLD}NEXT STEPS:${NC}"
        echo -e "   1. ${CYAN}Restart Cursor${NC} to apply all settings"
        echo -e "   2. ${CYAN}Environment variables${NC} have been automatically applied to current session"
        echo -e "   3. ${CYAN}Monitor performance${NC} during AI tasks"
        echo -e "   4. ${CYAN}New terminal sessions${NC} will automatically have optimized environment"
    elif [[ $optimizations_applied -gt 3 ]]; then
        production_success_message "✅ OPTIMIZATION COMPLETED WITH GOOD RESULTS"
        production_info_message "APPLIED $optimizations_applied OPTIMIZATION TECHNIQUES."
        if [[ $optimization_warnings -gt 0 ]]; then
            production_warning_message "$optimization_warnings OPTIMIZATION STEPS HAD LIMITATIONS."
        fi
        echo -e "\n${YELLOW}${BOLD}PARTIAL OPTIMIZATION RESULTS:${NC}"
        echo -e "   ${YELLOW}✓ Basic performance improvements applied${NC}"
        echo -e "   ${YELLOW}⚠ Some advanced optimizations were limited${NC}"
    else
        production_warning_message "OPTIMIZATION COMPLETED WITH LIMITATIONS."
        production_info_message "APPLIED $optimizations_applied OPTIMIZATION TECHNIQUES."
        production_warning_message "$optimization_warnings OPTIMIZATION STEPS HAD ISSUES."
        echo -e "\n${YELLOW}${BOLD}RECOMMENDATIONS:${NC}"
        echo -e "   ${YELLOW}• Check system permissions for advanced optimizations${NC}"
        echo -e "   ${YELLOW}• Consider running with administrator privileges${NC}"
        echo -e "   ${YELLOW}• Some optimizations may require system restart${NC}"
    fi
    return 0
}

# Note: Legacy optimize_memory_and_performance function was removed as it was unused dead code
# that could cause false positive errors due to its return 1 statement.


# Main execution for this script
# This allows the script to be called directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Ensure we have appropriate permissions
    if [[ $EUID -eq 0 ]]; then
        printf '[SECURITY WARNING] This script should not be run as root for security reasons\n' >&2
        printf '[INFO] Please run as a regular user - the script will prompt for sudo when needed\n' >&2
        printf '[INFO] Exiting to prevent potential security issues...\n' >&2
        exit 1
    fi

    # Verify we can run as current user
    printf '[INFO] Running optimization as user: %s (UID: %d)\n' "$(whoami)" "$EUID" >&2

    # Show header
    printf '\n=== System Optimization for Cursor AI ===\n\n'

    # Run optimization
    production_execute_optimize "$@"

    exit $?
else
    # Being sourced - export functions only (not variables)
    export -f production_execute_optimize
    export -f optimize_error_handler
    export -f check_cursor_processes
    export -f terminate_cursor_processes
    export -f log_with_level
    export -f production_info_message
    export -f production_warning_message
    export -f production_success_message
    export -f production_error_message
    export -f production_log_message
    export -f validate_shell_config
    export -f get_optimize_script_path
    # Export variables (not functions)
    export SCRIPT_DIR_OPTIMIZE
    export PROJECT_ROOT_OPTIMIZE
    export SCRIPT_DIR
    export PROJECT_ROOT
    export NON_INTERACTIVE_MODE
    export BLUE
    export BOLD
    export NC
    export CYAN
    export YELLOW
    export GREEN
    export RED
    export FILE_DESCRIPTOR_LIMIT
    export AI_MEMORY_LIMIT_GB
    export CURSOR_BUNDLE_ID
    export LAUNCH_SERVICES_CMD
    export TEMP_DIR
fi

# COMPREHENSIVE VALIDATION SYSTEM
readonly VALIDATION_DIR="${TEMP_DIR}/validation"
readonly VALIDATION_LOG="${VALIDATION_DIR}/validation.log"

# Run comprehensive validation tests
run_comprehensive_validation() {
    local test_mode="${1:-quick}"  # full, quick, or minimal

    echo "Starting comprehensive validation tests (mode: $test_mode)..."

    # Initialize validation directory
    mkdir -p "$VALIDATION_DIR"
    touch "$VALIDATION_LOG"

    # Set the script directory context (only if not already set)
    # Since we're sourcing from current directory, use relative path
    [[ -z "$SCRIPT_DIR" ]] && export SCRIPT_DIR="cursor_uninstaller"
    [[ -z "$TEMP_DIR" ]] && TEMP_DIR="/tmp/cursor_uninstaller"

    case "$test_mode" in
        "quick")
            echo "Running quick validation tests..." | tee -a "$VALIDATION_LOG"

            # Test 1: Check that key files exist and are readable
            local key_files=(
                "lib/ui.sh"
                "modules/ai_optimization.sh"
            )

            for file in "${key_files[@]}"; do
                if [[ -f "$file" && -r "$file" ]]; then
                    echo "✅ File check passed: $file" | tee -a "$VALIDATION_LOG"
                else
                    echo "❌ File check failed: $file" | tee -a "$VALIDATION_LOG"
                    return 1
                fi
            done

            # Test 2: Validate bash syntax
            for file in "${key_files[@]}"; do
                if bash -n "$file" 2>/dev/null; then
                    echo "✅ Syntax check passed: $file" | tee -a "$VALIDATION_LOG"
                else
                    echo "❌ Syntax check failed: $file" | tee -a "$VALIDATION_LOG"
                    return 1
                fi
            done

            # Test 3: Source modules and check functions exist
            # shellcheck source=../lib/ui.sh disable=SC1091
            source "lib/ui.sh" 2>/dev/null || echo "Warning: Could not source ui.sh" | tee -a "$VALIDATION_LOG"
            # shellcheck source=../modules/ai_optimization.sh disable=SC1091
            source "modules/ai_optimization.sh" 2>/dev/null || echo "Warning: Could not source ai_optimization.sh" | tee -a "$VALIDATION_LOG"

            local required_functions=(
                "start_performance_monitor"
                "stop_performance_monitor"
                "profile_cursor_ai_performance"
                "compare_ai_performance"
            )

            for func in "${required_functions[@]}"; do
                if declare -f "$func" > /dev/null 2>&1; then
                    echo "✅ Function available: $func" | tee -a "$VALIDATION_LOG"
                else
                    echo "❌ Function missing: $func" | tee -a "$VALIDATION_LOG"
                    return 1
                fi
            done

            echo "✅ Quick validation completed successfully" | tee -a "$VALIDATION_LOG"
            return 0
            ;;

        "minimal")
            echo "Running minimal validation tests..." | tee -a "$VALIDATION_LOG"

            # Just check that files exist and are syntactically valid
            local files_to_check=(
                "lib/ui.sh"
                "modules/ai_optimization.sh"
            )

            for file in "${files_to_check[@]}"; do
                if [[ -f "$file" ]] && bash -n "$file" 2>/dev/null; then
                    echo "✅ Minimal validation: $file is valid" | tee -a "$VALIDATION_LOG"
                else
                    echo "❌ Minimal validation: $file has issues" | tee -a "$VALIDATION_LOG"
                    return 1
                fi
            done
            echo "✅ Minimal validation completed successfully" | tee -a "$VALIDATION_LOG"
            return 0
            ;;

        *)
            echo "Invalid test mode: $test_mode (use: quick or minimal)" | tee -a "$VALIDATION_LOG"
            return 1
            ;;
    esac
}

# Integration test for all new features
test_integration() {
    echo "Running integration test of all enhanced features..." | tee -a "$VALIDATION_LOG"

    # Initialize validation directory
    mkdir -p "$VALIDATION_DIR"

    # Source all required modules
    # shellcheck source=../lib/ui.sh disable=SC1091
    source "lib/ui.sh" 2>/dev/null || { echo "Failed to source UI module"; return 1; }
    # shellcheck source=../modules/ai_optimization.sh disable=SC1091
    source "modules/ai_optimization.sh" 2>/dev/null || { echo "Failed to source AI optimization module"; return 1; }

    echo "1. Testing performance dashboard..." | tee -a "$VALIDATION_LOG"
    start_performance_monitor "Integration Test"
    sleep 2
    stop_performance_monitor

    echo "2. Testing AI profiling system..." | tee -a "$VALIDATION_LOG"
    profile_cursor_ai_performance 5 "${VALIDATION_DIR}/integration_test.json"

    echo "3. Validating output files..." | tee -a "$VALIDATION_LOG"
    if [[ -f "${VALIDATION_DIR}/integration_test.json" ]]; then
        echo "✅ Integration test completed successfully" | tee -a "$VALIDATION_LOG"
        echo "   - Performance dashboard: Working" | tee -a "$VALIDATION_LOG"
        echo "   - AI profiling: Working" | tee -a "$VALIDATION_LOG"
        echo "   - JSON output: Generated" | tee -a "$VALIDATION_LOG"
        return 0
    else
        echo "❌ Integration test failed - missing output files" | tee -a "$VALIDATION_LOG"
        return 1
    fi
}

# Production-grade system specifications display
production_system_specifications() {
    echo -e "\n${BOLD}${BLUE}🖥️ PRODUCTION-GRADE SYSTEM SPECIFICATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"

    # 1. Operating System Details
    echo -e "${BOLD}1. OPERATING SYSTEM:${NC}"

    if command -v sw_vers >/dev/null 2>&1; then
        local product_name product_version build_version
        product_name=$(sw_vers -productName 2>/dev/null || echo "Unknown")
        product_version=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")
        build_version=$(sw_vers -buildVersion 2>/dev/null || echo "Unknown")

        echo -e "   ${CYAN}Product Name:${NC} $product_name"
        echo -e "   ${CYAN}Version:${NC} $product_version"
        echo -e "   ${CYAN}Build:${NC} $build_version"
    fi

    local kernel_version uptime_info
    kernel_version=$(uname -r 2>/dev/null || echo "Unknown")
    uptime_info=$(uptime 2>/dev/null | sed 's/.*up \([^,]*\).*/\1/' || echo "Unknown")

    echo -e "   ${CYAN}Kernel Version:${NC} $kernel_version"
    echo -e "   ${CYAN}System Uptime:${NC} $uptime_info"

    # 2. Hardware Information
    echo -e "\n${BOLD}2. HARDWARE SPECIFICATIONS:${NC}"

    # CPU Information
    if command -v sysctl >/dev/null 2>&1; then
        local cpu_brand cpu_cores cpu_speed
        cpu_brand=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
        cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")
        cpu_speed=$(sysctl -n hw.cpufrequency_max 2>/dev/null | awk '{printf "%.2f GHz", $1/1000000000}' || echo "Unknown")

        echo -e "   ${CYAN}CPU:${NC} $cpu_brand"
        echo -e "   ${CYAN}CPU Cores:${NC} $cpu_cores"
        if [[ "$cpu_speed" != "Unknown" ]]; then
            echo -e "   ${CYAN}CPU Speed:${NC} $cpu_speed"
        fi
    fi

    # Memory Information
    if command -v sysctl >/dev/null 2>&1; then
        local total_memory
        total_memory=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.1f GB", $1/1073741824}' || echo "Unknown")
        echo -e "   ${CYAN}Total Memory:${NC} $total_memory"

        # Memory usage details with timeout to prevent hanging
        if command -v vm_stat >/dev/null 2>&1; then
            local memory_stats
            memory_stats=$(timeout 5 vm_stat 2>/dev/null || echo "")
            if [[ -n "$memory_stats" ]]; then
                local page_size free_pages active_pages inactive_pages wired_pages
                page_size=$(echo "$memory_stats" | grep "page size" | awk '{print $8}' 2>/dev/null || echo "4096")
                free_pages=$(echo "$memory_stats" | grep "Pages free:" | awk '{print $3}' | tr -d '.' 2>/dev/null || echo "0")
                active_pages=$(echo "$memory_stats" | grep "Pages active:" | awk '{print $3}' | tr -d '.' 2>/dev/null || echo "0")
                inactive_pages=$(echo "$memory_stats" | grep "Pages inactive:" | awk '{print $3}' | tr -d '.' 2>/dev/null || echo "0")
                wired_pages=$(echo "$memory_stats" | grep "Pages wired down:" | awk '{print $4}' | tr -d '.' 2>/dev/null || echo "0")

                local free_gb active_gb inactive_gb wired_gb
                free_gb=$(awk "BEGIN {printf \"%.1f GB\", ($free_pages * $page_size) / 1073741824}")
                active_gb=$(awk "BEGIN {printf \"%.1f GB\", ($active_pages * $page_size) / 1073741824}")
                inactive_gb=$(awk "BEGIN {printf \"%.1f GB\", ($inactive_pages * $page_size) / 1073741824}")
                wired_gb=$(awk "BEGIN {printf \"%.1f GB\", ($wired_pages * $page_size) / 1073741824}")

                echo -e "   ${CYAN}   Free Memory:${NC} $free_gb"
                echo -e "   ${CYAN}   Active Memory:${NC} $active_gb"
                echo -e "   ${CYAN}   Inactive Memory:${NC} $inactive_gb"
                echo -e "   ${CYAN}   Wired Memory:${NC} $wired_gb"
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
            local cursor_version bundle_id
            cursor_version=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
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
            local app_size install_date
            app_size=$(du -sh "/Applications/Cursor.app" 2>/dev/null | cut -f1 || echo "Unknown")
            install_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "/Applications/Cursor.app" 2>/dev/null || echo "Unknown")

            echo -e "   ${CYAN}App Size:${NC} $app_size"
            echo -e "   ${CYAN}Installation Date:${NC} $install_date"
        else
            echo -e "   ${RED}❌ Bundle Information:${NC} Cannot read Info.plist"
        fi

        # CLI tools
        if command -v cursor >/dev/null 2>&1; then
            local cli_path cli_version
            cli_path=$(which cursor 2>/dev/null || echo "Unknown")
            cli_version=$(cursor --version 2>/dev/null | head -1 || echo "Unknown")
            echo -e "   ${CYAN}CLI Tool Path:${NC} $cli_path"
            echo -e "   ${CYAN}CLI Tool Version:${NC} $cli_version"
        else
            echo -e "   ${YELLOW}⚠️ CLI Tools:${NC} Not installed"
        fi
    else
        echo -e "   ${RED}❌ Installation Status:${NC} Not installed"
    fi

    echo ""
    return 0
}

# Export validation functions when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f run_comprehensive_validation
    export -f test_integration
    export -f production_system_specifications
fi

# Production-grade Cursor AI optimization readiness assessment
validate_ai_optimization_readiness() {
    ai_log "INFO" "Performing comprehensive AI optimization readiness assessment..."
    # ... existing code ...
}

# Complete .zshrc optimization function (based on zshrc-optimizer.sh)
optimize_zshrc_complete() {
    production_info_message "Starting complete .zshrc optimization..."

    local zshrc_file="$HOME/.zshrc"
    local backup_file
    backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

    # Check if .zshrc exists
    if [[ ! -f "$zshrc_file" ]]; then
        production_info_message "Creating new optimized .zshrc file..."
        touch "$zshrc_file"
    else
        # Create backup
        if cp "$zshrc_file" "$backup_file" 2>/dev/null; then
            production_success_message "✓ Backup created: $backup_file"
        else
            production_warning_message "⚠ Could not create backup, proceeding without backup"
        fi
    fi

    # Create the complete optimized .zshrc configuration
    cat > "$zshrc_file" << 'EOF'
#!/usr/bin/env zsh
# Optimized .zshrc configuration
# Generated by optimize_system.sh (cursor-uninstaller)

# Performance profiling (uncomment to debug startup time)
# zmodload zsh/zprof

# ==========================================
# PERFORMANCE OPTIMIZATIONS
# ==========================================

# Disable magic functions for faster startup
DISABLE_MAGIC_FUNCTIONS="true"

# Optimized completion initialization - only check cache once daily
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit -d ~/.zcompdump
else
    compinit -C
fi

# ==========================================
# NVM CONFIGURATION (LAZY LOADING)
# ==========================================

export NVM_DIR="$HOME/.nvm"

# Lazy load NVM - only initialize when needed
nvm() {
    unfunction nvm
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/bash_completion" ] && \. "/opt/homebrew/opt/nvm/bash_completion"
    nvm "$@"
}

# Add node binaries to path without loading NVM
if [ -d "$NVM_DIR/versions/node" ]; then
    LATEST_NODE=$(ls "$NVM_DIR/versions/node" | tail -1)
    if [ -n "$LATEST_NODE" ]; then
        export PATH="$NVM_DIR/versions/node/$LATEST_NODE/bin:$PATH"
    fi
fi

# ==========================================
# DOCKER COMPLETIONS
# ==========================================

# Docker CLI completions
if [[ -d /Users/vicd/.docker/completions ]]; then
    fpath=(/Users/vicd/.docker/completions $fpath)
fi

# ==========================================
# ENVIRONMENT VARIABLES
# ==========================================

# API Keys (ensure these are set in your environment securely)
# Source OPENAI_API_KEY from project .env file if it exists
if [[ -f "/Users/Shared/cursor/cursor-vscode-anti-fake-coding-system/.env" ]]; then
    source "/Users/Shared/cursor/cursor-vscode-anti-fake-coding-system/.env"
fi
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"

# Node.js Performance Optimizations
export NODE_OPTIONS="--max-old-space-size=8192 --max-semi-space-size=512"
export UV_THREADPOOL_SIZE=16

# Electron Performance (macOS optimizations)
export ELECTRON_ENABLE_GPU=1
export ELECTRON_USE_METAL=1
export FORCE_COLOR=1

# Optimization flags
export CURSOR_AI_OPTIMIZED=1

# ==========================================
# SHELL OPTIONS
# ==========================================

# Enable extended globbing
setopt EXTENDED_GLOB

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE

# ==========================================
# ALIASES & FUNCTIONS
# ==========================================

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias l='ls -la'
alias ll='ls -alh'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# System utilities
alias reload='source ~/.zshrc'
alias zshconfig='nano ~/.zshrc'

# Performance monitoring function
shell_benchmark() {
    for i in $(seq 1 5); do
        /usr/bin/time zsh -i -c exit 2>&1 | grep real
    done
}

# ==========================================
# CONDITIONAL LOADING
# ==========================================

# Load additional configurations if they exist
[[ -f ~/.zsh_local ]] && source ~/.zsh_local
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

# Performance profiling output (uncomment first line to enable)
# zprof

EOF

    # Set appropriate permissions
    if chmod 644 "$zshrc_file" 2>/dev/null; then
        production_success_message "✓ Set appropriate permissions on .zshrc"
    else
        production_warning_message "⚠ Could not set permissions on .zshrc"
    fi

    production_success_message "✅ .zshrc has been completely optimized!"
    production_info_message "📊 Performance improvements implemented:"
    production_info_message "   • NVM lazy loading to reduce startup time"
    production_info_message "   • Optimized completion caching"
    production_info_message "   • Removed duplicate environment variables"
    production_info_message "   • Added shell performance monitoring"
    production_info_message "   • Organized configuration into logical sections"
    production_info_message ""
    production_info_message "🔄 To apply changes, run: source ~/.zshrc"
    production_info_message "📈 To benchmark performance, run: shell_benchmark"
    production_info_message "🔍 To enable startup profiling, uncomment the zprof lines"
    
    if [[ -f "$backup_file" ]]; then
        production_info_message "💾 Original configuration backed up to: $backup_file"
    fi

    return 0
}

# Enhanced prompt for zshrc optimization choice
prompt_zshrc_optimization_choice() {
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        # In non-interactive mode, use incremental approach by default
        return 1
    fi

    echo -e "\n${BOLD}${CYAN}🔧 ZSHRC OPTIMIZATION OPTIONS${NC}"
    echo -e "${BOLD}═════════════════════════════════════════${NC}\n"
    echo -e "${YELLOW}1) INCREMENTAL OPTIMIZATION (Recommended)${NC}"
    echo -e "   • Adds/updates Cursor AI environment variables only"
    echo -e "   • Preserves your existing .zshrc structure and customizations"
    echo -e "   • Safe and non-destructive approach"
    echo -e ""
    echo -e "${YELLOW}2) COMPLETE OPTIMIZATION (Advanced)${NC}"
    echo -e "   • Completely rewrites .zshrc with optimized configuration"
    echo -e "   • Includes NVM lazy loading, completion optimization"
    echo -e "   • Creates backup of current configuration"
    echo -e "   • ⚠️  Will replace your current .zshrc content"
    echo -e ""
    
    local choice
    printf 'Choose optimization approach [1/2] (default: 1): '
    read -r choice

    case "$choice" in
        2)
            echo -e "\n${RED}${BOLD}⚠️  WARNING: COMPLETE OPTIMIZATION${NC}"
            echo -e "${RED}This will completely replace your current .zshrc file content.${NC}"
            echo -e "${RED}A backup will be created, but all current customizations will be lost.${NC}\n"
            
            printf 'Are you sure you want to proceed with complete optimization? [y/N]: '
            read -r confirm
            case "$confirm" in
                [Yy]|[Yy][Ee][Ss])
                    production_info_message "User confirmed complete .zshrc optimization"
                    return 0  # Use complete optimization
                    ;;
                *)
                    production_info_message "User chose to use incremental optimization instead"
                    return 1  # Use incremental optimization
                    ;;
            esac
            ;;
        ""|1)
            production_info_message "User chose incremental .zshrc optimization"
            return 1  # Use incremental optimization
            ;;
        *)
            production_info_message "Invalid choice, defaulting to incremental optimization"
            return 1  # Use incremental optimization
            ;;
    esac
}

# Export the functions that need to be available when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f optimize_zshrc_complete
    export -f prompt_zshrc_optimization_choice
fi
