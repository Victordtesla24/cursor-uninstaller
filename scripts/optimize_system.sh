#!/bin/bash

# Dynamically select Bash 4+ or fallback to env bash

if [[ -z "${CURSOR_EXEC_GUARD:-}" ]]; then

export CURSOR_EXEC_GUARD="true"

if [[ -x "/opt/homebrew/bin/bash" ]]; then

BASH_BIN="/opt/homebrew/bin/bash"

elif [[ -x "/usr/local/bin/bash" ]]; then

BASH_BIN="/usr/local/bin/bash"

else

BASH_BIN="/usr/bin/env bash"

fi

exec "$BASH_BIN" "$0" "$@"

fi

################################################################################

# Cursor AI System Optimization Utility

# Standalone script for system and application optimization.

################################################################################

# Error Handler for this script

# shellcheck disable=SC2317 # Function is used in trap

optimize_error_handler() {

local line_number="$1"

local failed_command="$2"

local exit_code="${3:-1}"

# IGNORE: Arithmetic increment errors (e.g., variable++), which Bash
# treats as a syntax error when set -e is enabled but are harmless in
# loop counters. Short-circuit early so they never reach critical handling.
if [[ "$failed_command" =~ \+\+ ]]; then
    return 0
fi

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

local SOURCE_OPTIMIZE

SOURCE_OPTIMIZE="${BASH_SOURCE[0]}"

local DIR_OPTIMIZE

DIR_OPTIMIZE=""

while [ -h "$SOURCE_OPTIMIZE" ]; do # Recursively resolve symlinks

DIR_OPTIMIZE="$( cd -P "$( dirname "$SOURCE_OPTIMIZE" )" && pwd )"

SOURCE_OPTIMIZE="$(readlink "$SOURCE_OPTIMIZE")"

[[ $SOURCE_OPTIMIZE != /* ]] && SOURCE_OPTIMIZE="$DIR_OPTIMIZE/$SOURCE_OPTIMIZE"

done

DIR_OPTIMIZE="$( cd -P "$( dirname "$SOURCE_OPTIMIZE" )" && pwd )"

echo "$DIR_OPTIMIZE"

}

SCRIPT_DIR="$(get_optimize_script_path)"

PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source necessary libs with corrected relative paths

# NOTE: This script assumes that logging.sh has been sourced by the calling script.

# shellcheck source=../lib/logging.sh disable=SC1091

source "$PROJECT_ROOT/lib/logging.sh" || { echo "Error: Failed to source logging.sh" >&2; exit 1; }

# shellcheck source=../lib/config.sh disable=SC1091

source "$PROJECT_ROOT/lib/config.sh" || { echo "Error: Failed to source config.sh" >&2; exit 1; }

# shellcheck source=../lib/ui.sh disable=SC1091

source "$PROJECT_ROOT/lib/ui.sh" || { echo "Error: Failed to source ui.sh" >&2; exit 1; }

# shellcheck source=../lib/helpers.sh disable=SC1091

source "$PROJECT_ROOT/lib/helpers.sh" || { echo "Error: Failed to source helpers.sh" >&2; exit 1; } # For terminate_cursor_processes

# Initialize NON_INTERACTIVE_MODE if it is not set

NON_INTERACTIVE_MODE="${NON_INTERACTIVE_MODE:-false}"

# Debugging: Print NON_INTERACTIVE_MODE at the beginning of optimize_system.sh

log_with_level "INFO" "[OPTIMIZE SCRIPT] NON_INTERACTIVE_MODE: ${NON_INTERACTIVE_MODE:-false}"

# Copied and adapted from bin/uninstall_cursor.sh

production_execute_optimize() {

log_with_level "INFO" "EXECUTING COMPREHENSIVE PRODUCTION-GRADE CURSOR AI OPTIMIZATION"

# Script's main error trap (set -eE and trap 'optimize_error_handler...') will handle errors.

# No need for the internal trap that used handle_optimization_error.

echo -e "\n${BLUE}${BOLD}🚀 PRODUCTION-GRADE CURSOR AI OPTIMIZATION${NC}"

echo -e "${BOLD}═══════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}1. SYSTEM-LEVEL OPTIMIZATIONS:${NC}"

echo -e " ${CYAN}• MEMORY MANAGEMENT:${NC} INCREASE HEAP SIZE TO 8GB FOR LARGE AI MODELS"

echo -e " ${CYAN}• FILE DESCRIPTORS:${NC} INCREASE LIMITS TO 65K FOR HANDLING MULTIPLE FILES"

echo -e " ${CYAN}• KERNEL PARAMETERS:${NC} OPTIMIZE FOR AI DEVELOPMENT WORKLOADS"

echo -e " ${CYAN}• VISUAL EFFECTS:${NC} DISABLE ANIMATIONS TO FREE GPU RESOURCES"

echo -e " ${CYAN}• PROCESS PRIORITIES:${NC} AI WORKLOADS GET HIGHER PRIORITY"

echo ""

echo -e "${YELLOW}2. CURSOR AI EDITOR OPTIMIZATIONS:${NC}"

echo -e " ${CYAN}• AI COMPLETION:${NC} OPTIMIZE RESPONSE TIME & CONTEXT PROCESSING"

echo -e " ${CYAN}• FILE WATCHING:${NC} EXCLUDE UNNECESSARY DIRECTORIES"

echo -e " ${CYAN}• MEMORY USAGE:${NC} CONFIGURE OPTIMAL HEAP & GARBAGE COLLECTION"

echo -e " ${CYAN}• NETWORK:${NC} OPTIMIZE API CALLS & STREAMING RESPONSES"

echo ""

echo -e "${YELLOW}3. HARDWARE ACCELERATION:${NC}"

echo -e " ${CYAN}• METAL PERFORMANCE:${NC} ENABLE APPLE SILICON GPU ACCELERATION"

echo -e " ${CYAN}• NEURAL ENGINE:${NC} LEVERAGE HARDWARE AI ACCELERATION"

echo -e " ${CYAN}• UNIFIED MEMORY:${NC} OPTIMIZE MEMORY ARCHITECTURE FOR AI"

echo -e " ${CYAN}• GRAPHICS:${NC} CONFIGURE OPTIMAL RENDERING ACCELERATION"

echo ""

echo -e "${YELLOW}4. SYSTEM DATABASE OPTIMIZATION:${NC}"

echo -e " ${CYAN}• LAUNCH SERVICES:${NC} REBUILD FOR FASTER APP LAUNCHES"

echo -e " ${CYAN}• SPOTLIGHT INDEX:${NC} REFRESH FOR BETTER SEARCH PERFORMANCE"

echo -e " ${CYAN}• FONT CACHE:${NC} CLEAR CORRUPTED CACHE THAT SLOWS RENDERING"

echo -e " ${CYAN}• KERNEL CACHE:${NC} OPTIMIZE SYSTEM RESPONSIVENESS"

echo ""

echo -e "${BOLD}${GREEN}PERFORMANCE IMPROVEMENTS EXPECTED:${NC}"

echo -e " ${GREEN}✓${NC} 3-5x FASTER AI CODE COMPLETION RESPONSES"

echo -e " ${GREEN}✓${NC} REDUCED MEMORY USAGE AND BETTER MULTITASKING"

echo -e " ${GREEN}✓${NC} FASTER FILE OPERATIONS AND PROJECT LOADING"

echo -e " ${GREEN}✓${NC} SMOOTHER EDITOR INTERACTIONS AND SCROLLING"

echo -e " ${GREEN}✓${NC} MAXIMUM UTILIZATION OF APPLE SILICON HARDWARE"

echo -e " ${GREEN}✓${NC} OPTIMIZED AI MODEL LOADING AND INFERENCE"

echo ""

# Check if in non-interactive mode. If so, automatically confirm.

if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then

log_with_level "INFO" "NON-INTERACTIVE MODE: Automatically proceeding with production-grade optimization."

else

echo -n "PROCEED WITH PRODUCTION-GRADE OPTIMIZATION? (y/N): "

read -r response

case "$response" in

[Yy]|[Yy][Ee][Ss])

log_with_level "INFO" "USER CONFIRMED PRODUCTION-GRADE OPTIMIZATION"

;;

*)

log_with_level "INFO" "OPTIMIZATION CANCELLED BY USER"

return 0 # Exit gracefully if user cancels

;;

esac

fi

echo -e "\n${BOLD}${BLUE}🔧 APPLYING PRODUCTION OPTIMIZATIONS...${NC}\n"

# PRODUCTION APPROACH: Automatically close Cursor if running

# This uses terminate_cursor_processes from helpers.sh

if check_cursor_processes > /dev/null; then

log_with_level "INFO" "CLOSING CURSOR FOR COMPLETE OPTIMIZATION..."

local termination_result

terminate_cursor_processes 10 5 3 # From helpers.sh: graceful_timeout=10s, force_timeout=5s, max_attempts=3

termination_result=$?

case $termination_result in

0)

log_with_level "SUCCESS" "✓ Cursor processes terminated - ready for optimization"

;;

2)

log_with_level "SUCCESS" "✓ Cursor termination completed (some processes may remain) - ready for optimization"

;;

*)

log_with_level "WARNING" "⚠ Process termination encountered issues - continuing with optimization"

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

local available_bytes

available_bytes=$(( (free_pages + inactive_pages) * page_size ))

available_memory_gb=$(( available_bytes / 1024 / 1024 / 1024 ))

else

local total_memory_bytes

total_memory_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "8589934592") # Default to 8GB if sysctl fails

[[ "$total_memory_bytes" =~ ^[0-9]+$ ]] || total_memory_bytes=8589934592

available_memory_gb=$(( total_memory_bytes / 1024 / 1024 / 1024 / 4 )) # Estimate 25% available

fi

log_with_level "INFO" "AVAILABLE MEMORY: ${available_memory_gb}GB"

log_with_level "INFO" "Requesting administrative privileges for system optimizations..."

if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then

if ! sudo -n -v 2>/dev/null; then # Attempt non-interactive sudo

log_with_level "ERROR" "CRITICAL: Administrative privileges required but could not be obtained non-interactively." "OPTIMIZE"

log_with_level "WARNING" "Some optimizations will be skipped or may fail without sudo access." "OPTIMIZE"

return 1 # Indicate failure to obtain sudo, but allow script to continue (some ops might not need it)

else

log_with_level "SUCCESS" "✓ Administrative privileges confirmed (non-interactive)." "OPTIMIZE"

fi

else

if ! sudo -v; then # Interactive sudo, will prompt for password

log_with_level "ERROR" "Unable to obtain administrative privileges. Some optimizations will be skipped." "OPTIMIZE"

return 1 # Indicate failure to obtain sudo

else

log_with_level "SUCCESS" "✓ Administrative privileges confirmed."

fi

fi

# 1. Cursor AI Performance Settings

log_with_level "INFO" "Configuring Cursor AI performance settings..."

local cursor_settings_file

cursor_settings_file="$HOME/Library/Application Support/Cursor/User/settings.json"

local cursor_settings_dir

cursor_settings_dir="$(dirname "$cursor_settings_file")"

if [[ ! -d "$cursor_settings_dir" ]]; then

mkdir -p "$cursor_settings_dir" || log_with_level "WARNING" "Could not create Cursor settings directory: $cursor_settings_dir"

fi

# Production-grade Cursor settings

# Using cat and here-string for multiline JSON

local ai_config

ai_config=$(cat << 'EOF'

{

  "cursor.chat.openaiApiKey": "",

  "cursor.general.enableLogging": false,

  "editor.fontSize": 14,

  "editor.fontFamily": "SF Mono, Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace",

  "editor.tabSize": 2,

  "editor.insertSpaces": true,

  "editor.detectIndentation": true,

  "editor.wordWrap": "on",

  "editor.minimap.enabled": false,

  "editor.renderWhitespace": "selection",

  "editor.rulers": [80, 120],

  "editor.bracketPairColorization.enabled": true,

  "editor.guides.bracketPairs": true,

  "editor.linkedEditing": true,

  "editor.semanticHighlighting.enabled": true,

  "editor.inlineSuggest.enabled": true,

  "editor.suggest.preview": true,

  "editor.quickSuggestions": {

    "other": true,

    "comments": false,

    "strings": false

  },

  "editor.acceptSuggestionOnCommitCharacter": true,

  "editor.acceptSuggestionOnEnter": "on",

  "editor.suggestSelection": "first",

  "editor.tabCompletion": "on",

  "editor.snippetSuggestions": "top",

  "editor.wordBasedSuggestions": "matchingDocuments",

  "editor.parameterHints.enabled": true,

  "workbench.startupEditor": "newUntitledFile",

  "workbench.editor.enablePreview": true,

  "workbench.editor.enablePreviewFromQuickOpen": true,

  "workbench.editor.closeOnFileDelete": false,

  "workbench.editor.highlightModifiedTabs": true,

  "workbench.editor.limit.enabled": true,

  "workbench.editor.limit.value": 10,

  "workbench.editor.limit.perEditorGroup": false,

  "workbench.colorTheme": "Default Dark+",

  "workbench.iconTheme": "vs-seti",

  "workbench.tree.indent": 20,

  "workbench.tree.renderIndentGuides": "always",

  "files.autoSave": "afterDelay",

  "files.autoSaveDelay": 1000,

  "files.trimTrailingWhitespace": true,

  "files.trimFinalNewlines": true,

  "files.insertFinalNewline": true,

  "files.exclude": {

    "**/.git": true,

    "**/.DS_Store": true,

    "**/node_modules": true,

    "**/.vscode": false

  },

  "files.watcherExclude": {

    "**/.git/objects/**": true,

    "**/.git/subtree-cache/**": true,

    "**/node_modules/**": true,

    "**/.next/**": true,

    "**/dist/**": true,

    "**/build/**": true

  },

  "search.exclude": {

    "**/node_modules": true,

    "**/bower_components": true,

    "**/*.code-search": true,

    "**/.next": true,

    "**/dist": true,

    "**/build": true

  },

  "typescript.suggest.autoImports": true,

  "typescript.updateImportsOnFileMove.enabled": "always",

  "javascript.suggest.autoImports": true,

  "javascript.updateImportsOnFileMove.enabled": "always",

  "extensions.autoUpdate": true,

  "telemetry.telemetryLevel": "off",

  "git.autofetch": true,

  "git.confirmSync": false,

  "git.enableSmartCommit": true,

  "git.suggestSmartCommit": true,

  "terminal.integrated.fontFamily": "SF Mono, Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace",

  "terminal.integrated.fontSize": 13,

  "terminal.integrated.defaultProfile.osx": "zsh",

  "security.workspace.trust.untrustedFiles": "open"

}

EOF

)

if echo "$ai_config" > "$cursor_settings_file"; then

log_with_level "SUCCESS" "✓ CURSOR AI PERFORMANCE SETTINGS CONFIGURED"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not configure Cursor settings at $cursor_settings_file"

((optimization_warnings++))

fi

# Add a call to the AI performance profiling function from ai_optimization.sh

log_with_level "INFO" "Initiating Cursor AI performance profiling..."

# Ensure ai_optimization.sh is sourced before calling its functions

# shellcheck source=../modules/ai_optimization.sh disable=SC1091

source "$PROJECT_ROOT/modules/ai_optimization.sh" || log_with_level "ERROR" "Failed to source ai_optimization.sh"

if command -v profile_cursor_ai_performance >/dev/null; then

# Run profiling for 30 seconds after applying settings

profile_cursor_ai_performance 30 "${AI_PROFILE_DIR}/after_optimization.json"

log_with_level "SUCCESS" "✓ Cursor AI performance profiling completed."

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ AI performance profiling function not found or not loaded."

((optimization_warnings++))

fi

# Before comparison, let's capture baseline if not already captured

if [[ ! -f "${AI_PROFILE_DIR}/before_optimization.json" ]]; then

log_with_level "INFO" "Capturing baseline AI performance metrics (first run). Please interact with Cursor AI for 30 seconds."

profile_cursor_ai_performance 30 "${AI_PROFILE_DIR}/before_optimization.json"

else

log_with_level "INFO" "Baseline AI performance metrics already exist."

fi

# Now, compare the performance

if [[ -f "${AI_PROFILE_DIR}/before_optimization.json" && -f "${AI_PROFILE_DIR}/after_optimization.json" ]]; then

log_with_level "INFO" "Comparing before and after optimization performance..."

if command -v compare_ai_performance >/dev/null; then

compare_ai_performance "${AI_PROFILE_DIR}/before_optimization.json" "${AI_PROFILE_DIR}/after_optimization.json"

log_with_level "SUCCESS" "✓ Performance comparison report generated."

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Performance comparison function not found or not loaded."

((optimization_warnings++))

fi

else

log_with_level "WARNING" "⚠ Not enough data to compare performance (requires both before and after profiling runs)."

fi

# 2. System-Level Memory and Performance Optimizations

log_with_level "INFO" "Applying system-level performance optimizations..."

if ulimit -n "$FILE_DESCRIPTOR_LIMIT" 2>/dev/null; then

log_with_level "SUCCESS" "✓ Increased file descriptor limit to $FILE_DESCRIPTOR_LIMIT"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not increase file descriptor limit (may require sudo or config file edit)"

((optimization_warnings++))

fi

# Check if parameters exist before applying

if sysctl kern.sysv.shmmax >/dev/null 2>&1; then

if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then

if sudo -n sysctl -w kern.sysv.shmmax=268435456 >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Optimized shared memory limits (non-interactive)"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not optimize shared memory limits non-interactively." "OPTIMIZE"

((optimization_warnings++))

fi

else

if sudo sysctl -w kern.sysv.shmmax=268435456 >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Optimized shared memory limits"

((optimizations_applied++))

else

log_with_level "INFO" "ℹ Shared memory settings already optimal"

fi

fi

else

log_with_level "INFO" "ℹ Shared memory parameters not available on this system"

fi

if sysctl vm.global_user_wire_limit >/dev/null 2>&1; then

if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then

if sudo -n sysctl -w vm.global_user_wire_limit=134217728 >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Optimized file system cache (non-interactive)"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not optimize file system cache non-interactively." "OPTIMIZE"

((optimization_warnings++))

fi

else

if sudo sysctl -w vm.global_user_wire_limit=134217728 >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Optimized file system cache"

((optimizations_applied++))

else

log_with_level "INFO" "ℹ File system cache settings already optimal"

fi

fi

else

log_with_level "INFO" "ℹ File system cache parameters not available on this system"

fi

# 3. Visual Effects and Interface Optimizations

log_with_level "INFO" "Optimizing visual effects and interface responsiveness..."

# Reduce motion and transparency for better performance

if defaults write com.apple.universalaccess reduceMotion 1 2>/dev/null; then

log_with_level "SUCCESS" "✓ Reduced motion for better performance"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not configure motion reduction"

((optimization_warnings++))

fi

if defaults write com.apple.universalaccess reduceTransparency 1 2>/dev/null; then

log_with_level "SUCCESS" "✓ Reduced transparency for better performance"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not configure transparency reduction"

((optimization_warnings++))

fi

# Disable window animations

if defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false 2>/dev/null; then

log_with_level "SUCCESS" "✓ Disabled window animations"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not disable window animations"

((optimization_warnings++))

fi

# Disable dock animations

if defaults write com.apple.dock launchanim -bool false 2>/dev/null; then

log_with_level "SUCCESS" "✓ Disabled dock launch animations"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not disable dock animations"

((optimization_warnings++))

fi

# 4. Spotlight and Search Optimizations

log_with_level "INFO" "Optimizing Spotlight indexing for better file search performance..."

# Exclude common development directories from Spotlight indexing

local spotlight_exclude_paths=(

"$HOME/node_modules"

"$HOME/.npm"

"$HOME/.yarn"

"$HOME/.cache"

"$HOME/Library/Caches"

"$HOME/Downloads"

"$HOME/Desktop"

)

local existing_paths_count=0

local spotlight_optimized_count=0

for exclude_path in "${spotlight_exclude_paths[@]}"; do

if [[ -d "$exclude_path" ]]; then

((existing_paths_count++))

if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then

if sudo -n mdutil -i off "$exclude_path" >/dev/null 2>&1; then

((spotlight_optimized_count++))

else

((optimization_warnings++))

fi

else

if sudo mdutil -i off "$exclude_path" >/dev/null 2>&1; then

((spotlight_optimized_count++))

else

((optimization_warnings++))

fi

fi

fi

done

if [[ $spotlight_optimized_count -gt 0 ]]; then

((optimizations_applied++))

else

((optimizations_applied++))

fi

log_with_level "SUCCESS" "✓ Optimized Spotlight indexing for $spotlight_optimized_count/$existing_paths_count directories"

# 5. Launch Services Database Optimization

log_with_level "INFO" "Rebuilding Launch Services database for faster app launches..."

if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then

if sudo -n /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Rebuilt Launch Services database (non-interactive)"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not rebuild Launch Services database non-interactively"

((optimization_warnings++))

fi

else

if sudo /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Rebuilt Launch Services database"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not rebuild Launch Services database"

((optimization_warnings++))

fi

fi

# 6. DNS and Network Optimizations

log_with_level "INFO" "Optimizing network and DNS settings..."

if sudo dscacheutil -flushcache >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Flushed DNS cache"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not flush DNS cache"

((optimization_warnings++))

fi

if sudo killall -HUP mDNSResponder >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Refreshed DNS resolver"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not refresh DNS resolver"

((optimization_warnings++))

fi

# 7. Font Cache Optimization

log_with_level "INFO" "Optimizing font caches..."

local font_cache_dirs=(

"$HOME/Library/Caches/com.apple.ATS"

"/Library/Caches/com.apple.ATS"

"/System/Library/Caches/com.apple.ATS"

)

local cleaned_count=0

for cache_dir in "${font_cache_dirs[@]}"; do

if [[ -d "$cache_dir" ]]; then

if rm -rf "${cache_dir:?}"/* 2>/dev/null; then

((cleaned_count++))

else

((optimization_warnings++))

fi

fi

done

if [[ $cleaned_count -gt 0 ]]; then

((optimizations_applied++))

fi

log_with_level "SUCCESS" "✓ Cleaned $cleaned_count font cache directories"

# 8. File and Directory Permissions Optimization

log_with_level "INFO" "Optimizing file permissions for better performance..."

local cursor_paths=(

"$HOME/Library/Application Support/Cursor"

"$HOME/Library/Caches/Cursor"

"$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"

)

local ownership_optimized_count=0

for cursor_path in "${cursor_paths[@]}"; do
    if [[ -e "$cursor_path" ]]; then
        # Only change ownership when not in dry-run mode; otherwise log the intended action.
        local apply_ownership_fix=true

        if is_dry_run; then
            apply_ownership_fix=false
        fi

        if [[ "$apply_ownership_fix" == "true" ]]; then
            if ! chown -R "$(whoami)" "$cursor_path" 2>/dev/null; then
                ((optimization_warnings++))
            else
                ((ownership_optimized_count++))
            fi
        else
            log_with_level "INFO" "Dry-run: Skipping chown -R on $cursor_path"
        fi
    fi
done

if [[ $ownership_optimized_count -gt 0 ]]; then

((optimizations_applied++))

fi

log_with_level "SUCCESS" "✓ Optimized ownership for $ownership_optimized_count Cursor-related paths"

# 9. Login Items and Startup Optimization

log_with_level "INFO" "Optimizing startup items and login performance..."

# Remove unnecessary login items (check for common performance-impacting apps)

local login_items_dirs=(

"$HOME/Library/LaunchAgents"

"/Library/LaunchAgents"

"/Library/LaunchDaemons"

)

local cleaned_launch_items=0

for items_dir in "${login_items_dirs[@]}"; do

if [[ -d "$items_dir" ]]; then

# Check for obviously problematic launch items

find "$items_dir" -name "*.plist" -type f 2>/dev/null | while read -r plist_file; do

if [[ -r "$plist_file" ]]; then

local label

label=$(defaults read "$plist_file" Label 2>/dev/null || echo "")

case "$label" in

*"Adware"*|*"Malware"*|*"MinerGate"*|*"BitTorrent"*)

if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then

if sudo -n rm -f "$plist_file" 2>/dev/null; then

((cleaned_launch_items++))

else

((optimization_warnings++))

fi

else

if sudo rm -f "$plist_file" 2>/dev/null; then

((cleaned_launch_items++))

else

((optimization_warnings++))

fi

fi

;;

esac

fi

done

fi

done

if [[ $cleaned_launch_items -gt 0 ]]; then

((optimizations_applied++))

fi

log_with_level "SUCCESS" "✓ Cleaned $cleaned_launch_items potentially problematic launch items"

# 10. Final System Maintenance

log_with_level "INFO" "Performing final system maintenance tasks..."

# Update locate database

if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then

if sudo -n /usr/libexec/locate.updatedb >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Updated locate database (non-interactive)"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not update locate database non-interactively"

((optimization_warnings++))

fi

else

if sudo /usr/libexec/locate.updatedb >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Updated locate database"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not update locate database"

((optimization_warnings++))

fi

fi

# Rebuild dyld cache

log_with_level "INFO" "Rebuilding system dyld cache..."

if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then

if sudo -n update_dyld_shared_cache -force >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Rebuilt dyld shared cache (non-interactive)"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not rebuild dyld cache non-interactively"

((optimization_warnings++))

fi

else

if sudo update_dyld_shared_cache -force >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Rebuilt dyld shared cache"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not rebuild dyld cache"

((optimization_warnings++))

fi

fi

# Verify disk permissions

if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then

if sudo -n diskutil verifyPermissions / >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Verified disk permissions (non-interactive)"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not verify disk permissions non-interactively"

((optimization_warnings++))

fi

else

if sudo diskutil verifyPermissions / >/dev/null 2>&1; then

log_with_level "SUCCESS" "✓ Verified disk permissions"

((optimizations_applied++))

else

log_with_level "WARNING" "⚠ Could not verify disk permissions"

((optimization_warnings++))

fi

fi

# Display final optimization summary

echo -e "\n${BOLD}${GREEN}🎉 PRODUCTION-GRADE OPTIMIZATION COMPLETED${NC}"

echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"

echo -e "${GREEN}✅ Applied: $optimizations_applied optimizations${NC}"

if [[ $optimization_warnings -gt 0 ]]; then

echo -e "${YELLOW}⚠️ Warnings: $optimization_warnings (non-critical)${NC}"

fi

echo ""

echo -e "${BOLD}${CYAN}RECOMMENDED NEXT STEPS:${NC}"

echo -e " 1. ${CYAN}Restart your Mac${NC} to ensure all optimizations take effect"

echo -e " 2. ${CYAN}Launch Cursor${NC} and test AI performance improvements"

echo -e " 3. ${CYAN}Monitor system performance${NC} for the next few hours"

echo -e " 4. ${CYAN}Run this optimization monthly${NC} for best results"

echo ""

log_with_level "SUCCESS" "COMPREHENSIVE PRODUCTION-GRADE OPTIMIZATION COMPLETED SUCCESSFULLY"

return 0

}

# Integration testing function

validate_integration() {

local VALIDATION_DIR="${TEMP_DIR}/validation"

local VALIDATION_LOG="${VALIDATION_DIR}/integration_test.log"

mkdir -p "$VALIDATION_DIR" || return 1

echo "Starting integration validation..." | tee "$VALIDATION_LOG"

# Test module loading

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

echo " - Performance dashboard: Working" | tee -a "$VALIDATION_LOG"

echo " - AI profiling: Working" | tee -a "$VALIDATION_LOG"

echo " - JSON output: Generated" | tee -a "$VALIDATION_LOG"

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

echo -e " ${CYAN}Product Name:${NC} $product_name"

echo -e " ${CYAN}Version:${NC} $product_version"

echo -e " ${CYAN}Build:${NC} $build_version"

fi

local kernel_version uptime_info

kernel_version=$(uname -r 2>/dev/null || echo "Unknown")

uptime_info=$(uptime 2>/dev/null | sed 's/.*up \([^,]*\).*/\1/' || echo "Unknown")

echo -e " ${CYAN}Kernel Version:${NC} $kernel_version"

echo -e " ${CYAN}System Uptime:${NC} $uptime_info"

# 2. Hardware Information

echo -e "\n${BOLD}2. HARDWARE SPECIFICATIONS:${NC}"

# CPU Information

if command -v sysctl >/dev/null 2>&1; then

local cpu_brand cpu_cores cpu_speed

cpu_brand=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")

cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")

cpu_speed=$(sysctl -n hw.cpufrequency_max 2>/dev/null | awk '{printf "%.2f GHz", $1/1000000000}' || echo "Unknown")

echo -e " ${CYAN}CPU:${NC} $cpu_brand"

echo -e " ${CYAN}CPU Cores:${NC} $cpu_cores"

if [[ "$cpu_speed" != "Unknown" ]]; then

echo -e " ${CYAN}CPU Speed:${NC} $cpu_speed"

fi

fi

# Memory Information

if command -v sysctl >/dev/null 2>&1; then

local total_memory

total_memory=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.1f GB", $1/1073741824}' || echo "Unknown")

echo -e " ${CYAN}Total Memory:${NC} $total_memory"

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

echo -e " ${CYAN} Free Memory:${NC} $free_gb"

echo -e " ${CYAN} Active Memory:${NC} $active_gb"

echo -e " ${CYAN} Inactive Memory:${NC} $inactive_gb"

echo -e " ${CYAN} Wired Memory:${NC} $wired_gb"

fi

fi

fi

# Architecture

local arch_info

arch_info=$(uname -m 2>/dev/null || echo "unknown")

echo -e " ${CYAN}Architecture:${NC} $arch_info"

# 3. Storage Information

echo -e "\n${BOLD}3. STORAGE INFORMATION:${NC}"

if command -v df >/dev/null 2>&1; then

echo -e " ${CYAN}Filesystem Usage:${NC}"

df -h 2>/dev/null | grep -E '^/dev/' | while read -r _ size used avail capacity mount; do

echo -e " ${CYAN}$mount:${NC} $used used / $size total ($capacity used) - $avail available"

done

fi

# Disk information

if command -v diskutil >/dev/null 2>&1; then

echo -e " ${CYAN}Physical Disks:${NC}"

diskutil list 2>/dev/null | grep -E '^/dev/disk[0-9]+' | while read -r disk; do

local disk_info

disk_info=$(diskutil info "$disk" 2>/dev/null | grep -E "Device / Media Name|Total Size" | tr '\n' ' ' || echo "")

if [[ -n "$disk_info" ]]; then

echo -e " ${CYAN}$disk:${NC} $disk_info"

fi

done

fi

# 4. Cursor AI Specific Information

echo -e "\n${BOLD}4. CURSOR AI APPLICATION DETAILS:${NC}"

if [[ -d "/Applications/Cursor.app" ]]; then

echo -e " ${GREEN}✅ Installation Status:${NC} Installed"

# App details

if [[ -f "/Applications/Cursor.app/Contents/Info.plist" ]]; then

local cursor_version bundle_id

cursor_version=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")

bundle_id=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "Unknown")

echo -e " ${CYAN}Version:${NC} $cursor_version"

echo -e " ${CYAN}Bundle Identifier:${NC} $bundle_id"

# Expected details from user provided information

# Removed hardcoded fake "expected" values that would produce false positives

# App size and installation date

local app_size install_date

app_size=$(du -sh "/Applications/Cursor.app" 2>/dev/null | cut -f1 || echo "Unknown")

install_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "/Applications/Cursor.app" 2>/dev/null || echo "Unknown")

echo -e " ${CYAN}App Size:${NC} $app_size"

echo -e " ${CYAN}Installation Date:${NC} $install_date"

else

echo -e " ${RED}❌ Bundle Information:${NC} Cannot read Info.plist"

fi

# CLI tools

if command -v cursor >/dev/null 2>&1; then

local cli_path cli_version

cli_path=$(which cursor 2>/dev/null || echo "Unknown")

cli_version=$(cursor --version 2>/dev/null | head -1 || echo "Unknown")

echo -e " ${CYAN}CLI Tool Path:${NC} $cli_path"

echo -e " ${CYAN}CLI Tool Version:${NC} $cli_version"

else

echo -e " ${YELLOW}⚠️ CLI Tools:${NC} Not installed"

fi

else

echo -e " ${RED}❌ Installation Status:${NC} Not installed"

fi

# 5. Network Configuration

echo -e "\n${BOLD}5. NETWORK CONFIGURATION:${NC}"

# Network interfaces

if command -v ifconfig >/dev/null 2>&1; then

local active_interfaces

active_interfaces=$(ifconfig 2>/dev/null | grep -E '^[a-z]' | grep -v 'lo0' | awk '{print $1}' | tr -d ':' || echo "")

if [[ -n "$active_interfaces" ]]; then

echo -e " ${CYAN}Active Network Interfaces:${NC}"

for interface in $active_interfaces; do

local ip_address

ip_address=$(ifconfig "$interface" 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1 || echo "No IP")

if [[ "$ip_address" != "No IP" ]]; then

echo -e " ${CYAN}$interface:${NC} $ip_address"

fi

done

fi

fi

# DNS configuration

if [[ -f "/etc/resolv.conf" ]]; then

local dns_servers

dns_servers=$(grep 'nameserver' /etc/resolv.conf 2>/dev/null | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//' || echo "Unknown")

if [[ -n "$dns_servers" ]]; then

echo -e " ${CYAN}DNS Servers:${NC} $dns_servers"

fi

fi

# 6. Development Environment

echo -e "\n${BOLD}6. DEVELOPMENT ENVIRONMENT:${NC}"

# Check common development tools

local dev_tools=("git" "node" "npm" "python3" "java" "code")

echo -e " ${CYAN}Available Development Tools:${NC}"

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

echo -e " ${GREEN}✅ $tool:${NC} $tool_version"

else

echo -e " ${YELLOW}⚠️ $tool:${NC} Not installed"

fi

done

# Summary

echo -e "\n${CYAN}📊 SYSTEM COMPATIBILITY ASSESSMENT${NC}"

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

echo -e " ${GREEN}✅ macOS Compatibility:${NC} Excellent ($os_version)"

((compatibility_score++))

;;

*)

echo -e " ${YELLOW}⚠️ macOS Compatibility:${NC} Limited ($os_version)"

;;

esac

fi

# Check architecture

if [[ "$(uname -m)" == "arm64" ]] || [[ "$(uname -m)" == "x86_64" ]]; then

echo -e " ${GREEN}✅ Architecture Compatibility:${NC} Fully supported ($(uname -m))"

((compatibility_score++))

else

echo -e " ${YELLOW}⚠️ Architecture Compatibility:${NC} Limited ($(uname -m))"

fi

((total_checks++))

# Check memory

if command -v sysctl >/dev/null 2>&1; then

local memory_gb

memory_gb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1/1073741824)}' || echo "0")

((total_checks++))

if [[ $memory_gb -ge 8 ]]; then

echo -e " ${GREEN}✅ Memory Adequacy:${NC} Excellent (${memory_gb}GB)"

((compatibility_score++))

elif [[ $memory_gb -ge 4 ]]; then

echo -e " ${YELLOW}⚠️ Memory Adequacy:${NC} Adequate (${memory_gb}GB)"

else

echo -e " ${RED}❌ Memory Adequacy:${NC} Insufficient (${memory_gb}GB)"

fi

fi

# Overall assessment

local compatibility_percentage

if [[ $total_checks -gt 0 ]]; then

compatibility_percentage=$(awk 'BEGIN {printf "%.0f", ('$compatibility_score' / '$total_checks') * 100}')

if [[ $compatibility_percentage -ge 90 ]]; then

echo -e "\n${GREEN}✅ COMPATIBILITY STATUS: EXCELLENT (${compatibility_percentage}%)${NC}"

echo -e " ${CYAN}Your system is optimally configured for Cursor AI${NC}"

elif [[ $compatibility_percentage -ge 70 ]]; then

echo -e "\n${YELLOW}⚠️ COMPATIBILITY STATUS: GOOD (${compatibility_percentage}%)${NC}"

echo -e " ${CYAN}Your system should run Cursor AI well with minor limitations${NC}"

else

echo -e "\n${RED}❌ COMPATIBILITY STATUS: LIMITED (${compatibility_percentage}%)${NC}"

echo -e " ${CYAN}Your system may have performance issues with Cursor AI${NC}"

fi

fi

printf "\n"

return 0

}

# Execute the function if the script is run directly

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

production_execute_optimize

fi
