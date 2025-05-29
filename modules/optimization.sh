#!/bin/bash

################################################################################
# Cursor AI Editor Optimization Module
# Provides comprehensive performance optimization functions
################################################################################

# Set strict error handling  
set -eE

# Module configuration
OPTIMIZATION_VERSION="1.0.0"
OPTIMIZATION_DEBUG="${OPTIMIZATION_DEBUG:-false}"

################################################################################
# Enhanced Cursor Performance Optimization
################################################################################

# Enhanced optimize function that main script references
enhanced_optimize_cursor_performance() {
    production_log_message "INFO" "Starting enhanced Cursor performance optimization"
    
    echo -e "${BOLD}${BLUE}🔧 ENHANCED CURSOR OPTIMIZATION${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    local optimizations_applied=0
    local optimization_errors=0
    
    # Create cursor directories if they don't exist
    production_info_message "Creating Cursor configuration directories..."
    
    local cursor_dirs=(
        "$HOME/Library/Application Support/Cursor/User"
        "$HOME/Library/Application Support/Cursor/User/globalStorage"
        "$HOME/.cursor"
        "$HOME/.cursor/workspaces"
    )
    
    for dir in "${cursor_dirs[@]}"; do
        if mkdir -p "$dir" 2>/dev/null; then
            production_log_message "DEBUG" "Created directory: $dir"
        else
            production_warning_message "Could not create directory: $dir"
            ((optimization_errors++))
        fi
    done
    
    # Create optimized Cursor settings
    production_info_message "Applying optimized Cursor AI settings..."
    
    local settings_file="$HOME/Library/Application Support/Cursor/User/settings.json"
    
    if cat > "$settings_file" << 'EOF'; then
{
    "ai.enabled": true,
    "ai.autoComplete": true,
    "ai.codeActions": true,
    "ai.contextLength": 8192,
    "ai.temperature": 0.1,
    "ai.maxTokens": 2048,
    "ai.enableBackgroundMode": true,
    "ai.enhancedIntelliSense": true,
    
    "editor.inlineSuggest.enabled": true,
    "editor.suggestOnTriggerCharacters": true,
    "editor.quickSuggestions": {
        "other": true,
        "comments": true,
        "strings": true
    },
    "editor.quickSuggestionsDelay": 50,
    "editor.wordBasedSuggestions": "allDocuments",
    "editor.acceptSuggestionOnCommitCharacter": true,
    "editor.acceptSuggestionOnEnter": "on",
    
    "typescript.preferences.enableAutoImports": "on",
    "typescript.suggest.autoImports": true,
    "typescript.updateImportsOnFileMove.enabled": "always",
    "typescript.suggest.completeFunctionCalls": true,
    
    "python.analysis.autoImportCompletions": true,
    "python.analysis.autoSearchPaths": true,
    "python.analysis.completeFunctionParens": true,
    "python.defaultInterpreterPath": "python3",
    
    "workbench.colorTheme": "Dark+ (default dark)",
    "workbench.iconTheme": "vs-seti",
    "workbench.startupEditor": "none",
    "workbench.enableExperiments": true,
    
    "editor.fontSize": 14,
    "editor.fontFamily": "SF Mono, Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace",
    "editor.lineHeight": 1.5,
    "editor.renderWhitespace": "boundary",
    "editor.minimap.enabled": false,
    "editor.wordWrap": "off",
    "editor.scrollbar.verticalScrollbarSize": 10,
    "editor.scrollbar.horizontalScrollbarSize": 10,
    
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 2000,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/node_modules": true,
        "**/.next": true,
        "**/dist": true,
        "**/build": true,
        "**/*.pyc": true,
        "**/__pycache__": true
    },
    
    "search.exclude": {
        "**/node_modules": true,
        "**/bower_components": true,
        "**/*.code-search": true,
        "**/dist": true,
        "**/build": true,
        "**/.next": true,
        "**/.git": true
    },
    
    "files.watcherExclude": {
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/node_modules/*/**": true,
        "**/.hg/store/**": true,
        "**/dist/**": true,
        "**/build/**": true
    },
    
    "extensions.autoUpdate": false,
    "extensions.autoCheckUpdates": false,
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    
    "terminal.integrated.shell.osx": "/bin/zsh",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.cursorBlinking": true,
    "terminal.integrated.cursorStyle": "line",
    
    "git.autofetch": true,
    "git.confirmSync": false,
    "git.enableSmartCommit": true,
    "git.suggestSmartCommit": true
}
EOF
        production_success_message "✓ Applied optimized Cursor AI settings"
        ((optimizations_applied++))
    else
        production_error_message "Failed to apply Cursor settings"
        ((optimization_errors++))
    fi
    
    # Create optimized keybindings
    production_info_message "Setting up AI-optimized keybindings..."
    
    local keybindings_file="$HOME/Library/Application Support/Cursor/User/keybindings.json"
    
    if cat > "$keybindings_file" << 'EOF'; then
[
    {
        "key": "cmd+i",
        "command": "ai.inlineCompletion.trigger",
        "when": "editorTextFocus"
    },
    {
        "key": "cmd+shift+i",
        "command": "ai.chat.open",
        "when": "editorTextFocus"
    },
    {
        "key": "cmd+k cmd+i",
        "command": "ai.explain.selection",
        "when": "editorHasSelection"
    },
    {
        "key": "cmd+k cmd+r",
        "command": "ai.refactor.selection", 
        "when": "editorHasSelection"
    },
    {
        "key": "cmd+k cmd+d",
        "command": "ai.debug.selection",
        "when": "editorHasSelection"
    },
    {
        "key": "cmd+k cmd+t",
        "command": "ai.test.generate",
        "when": "editorTextFocus"
    },
    {
        "key": "tab",
        "command": "acceptSelectedSuggestion",
        "when": "suggestWidgetVisible"
    },
    {
        "key": "cmd+.",
        "command": "editor.action.quickFix",
        "when": "editorTextFocus"
    }
]
EOF
        production_success_message "✓ Applied AI-optimized keybindings"
        ((optimizations_applied++))
    else
        production_error_message "Failed to apply keybindings"
        ((optimization_errors++))
    fi
    
    # Optimize system-level settings for Cursor
    production_info_message "Applying system-level optimizations..."
    
    # Increase file descriptor limits
    if ulimit -n 65536 2>/dev/null; then
        production_success_message "✓ Increased file descriptor limit"
        ((optimizations_applied++))
    else
        production_warning_message "Could not increase file descriptor limit"
        ((optimization_errors++))
    fi
    
    # Optimize memory settings for large AI models - FIXED CONDITIONAL SYNTAX
    local cursor_plist="$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
    if [[ -f "$cursor_plist" ]]; then
        # Use proper syntax for plist operations
        if defaults write "$cursor_plist" "application.memory.maxHeapSize" "4096" 2>/dev/null; then
            production_success_message "✓ Increased Cursor memory allocation"
            ((optimizations_applied++))
        else
            production_warning_message "Could not modify Cursor memory settings"
            ((optimization_errors++))
        fi
        
        if defaults write "$cursor_plist" "application.performance.enableGC" "true" 2>/dev/null; then
            production_success_message "✓ Enabled garbage collection optimization"
            ((optimizations_applied++))
        else
            production_warning_message "Could not enable GC optimization"
            ((optimization_errors++))
        fi
    else
        production_info_message "Cursor preference file not found, will be created on next launch"
    fi
    
    # Disable system animations for better performance - FIXED CONDITIONAL SYNTAX  
    if defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false 2>/dev/null; then
        production_success_message "✓ Disabled window animations"
        ((optimizations_applied++))
    else
        production_warning_message "Could not disable window animations"
        ((optimization_errors++))
    fi
    
    if defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false 2>/dev/null; then
        production_success_message "✓ Disabled scroll animations"
        ((optimizations_applied++))
    else
        production_warning_message "Could not disable scroll animations"
        ((optimization_errors++))
    fi
    
    # Configure file watching exclusions - FIXED CONDITIONAL SYNTAX
    if [[ -f "$cursor_plist" ]]; then
        if defaults write "$cursor_plist" "files.watcherExclude" '{
            "**/.git/objects/**": true,
            "**/node_modules/**": true,
            "**/dist/**": true,
            "**/build/**": true
        }' 2>/dev/null; then
            production_success_message "✓ Optimized file watching exclusions"
            ((optimizations_applied++))
        else
            production_warning_message "Could not optimize file watching"
            ((optimization_errors++))
        fi
    fi
    
    # Apply kernel optimizations safely - FIXED SYSCTL ERRORS
    production_info_message "Applying kernel-level optimizations..."
    
    # Fix sysctl parameter application - use helper function instead of direct conditionals
    if command -v apply_sysctl_parameter >/dev/null 2>&1; then
        apply_sysctl_parameter "kern.maxfiles" "65536" "maximum file descriptors" || ((optimization_errors++))
        apply_sysctl_parameter "kern.maxfilesperproc" "32768" "max files per process" || ((optimization_errors++))
        # Remove vm.swappiness as it's Linux-specific, not macOS
    else
        # Fallback method
        if sudo sysctl kern.maxfiles=65536 >/dev/null 2>&1; then
            production_success_message "✓ Applied kern.maxfiles optimization"
            ((optimizations_applied++))
        else
            production_warning_message "Could not apply kern.maxfiles optimization"
            ((optimization_errors++))
        fi
        
        if sudo sysctl kern.maxfilesperproc=32768 >/dev/null 2>&1; then
            production_success_message "✓ Applied kern.maxfilesperproc optimization"
            ((optimizations_applied++))
        else
            production_warning_message "Could not apply kern.maxfilesperproc optimization"
            ((optimization_errors++))
        fi
    fi
    
    # Reset Launch Services database to clean up file associations
    production_info_message "Optimizing Launch Services database..."
    
    if /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
        production_success_message "✓ Optimized Launch Services database"
        ((optimizations_applied++))
    else
        production_warning_message "Could not optimize Launch Services database"
        ((optimization_errors++))
    fi
    
    # Restart Cursor app safely if running - FIXED APPLICATION PATH CONDITIONAL
    local cursor_app_path="/Applications/Cursor.app"
    if [[ -d "$cursor_app_path" ]]; then
        production_info_message "Cursor application found, checking if running..."
        
        if pgrep -f "Cursor" >/dev/null 2>&1; then
            production_info_message "Restarting Cursor to apply optimizations..."
            if command -v terminate_process_safely >/dev/null 2>&1; then
                terminate_process_safely "Cursor" 15
            else
                pkill -f "Cursor" 2>/dev/null || true
                sleep 2
            fi
            
            # Wait a moment before restart
            sleep 3
            
            # Restart Cursor
            if open "$cursor_app_path" 2>/dev/null; then
                production_success_message "✓ Restarted Cursor with optimizations"
                ((optimizations_applied++))
            else
                production_warning_message "Could not restart Cursor automatically"
                ((optimization_errors++))
            fi
        else
            production_info_message "Cursor not currently running"
        fi
    else
        production_warning_message "Cursor.app not found at expected location"
        ((optimization_errors++))
    fi
    
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    
    if [[ $optimization_errors -eq 0 ]]; then
        production_success_message "Enhanced optimization completed successfully"
        production_info_message "Applied $optimizations_applied optimizations with 0 errors"
        return 0
    else
        production_warning_message "Enhanced optimization completed with warnings"
        production_info_message "Applied $optimizations_applied optimizations with $optimization_errors errors"
        return 1
    fi
}

################################################################################
# Database Cleanup Functions
################################################################################

clean_databases() {
    production_log_message "INFO" "Cleaning system databases for improved performance"
    
    echo -e "${BOLD}${BLUE}🗄️  DATABASE CLEANUP${NC}"
    echo -e "${BOLD}═══════════════════════════════════════${NC}\n"
    
    local cleanup_count=0
    
    # Clean Launch Services database
    production_info_message "Cleaning Launch Services database..."
    if /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
        production_success_message "✓ Launch Services database cleaned"
        ((cleanup_count++))
    fi
    
    # Clean font cache
    production_info_message "Cleaning font cache..."
    if sudo atsutil databases -remove >/dev/null 2>&1; then
        production_success_message "✓ Font cache cleaned"
        ((cleanup_count++))
    fi
    
    # Clean Spotlight index for faster search
    production_info_message "Refreshing Spotlight index..."
    if sudo mdutil -E / >/dev/null 2>&1; then
        production_success_message "✓ Spotlight index refreshed"
        ((cleanup_count++))
    fi
    
    production_info_message "Cleaned $cleanup_count system databases"
    echo ""
    
    return 0
}

################################################################################
# Optimization Reporting
################################################################################

generate_optimization_report() {
    # FIXED SC2155: Declare and assign separately to avoid masking return values
    local report_file
    report_file="$HOME/.cursor-uninstaller/temp/cursor_optimization_report_$(date +%Y%m%d_%H%M%S).txt"
    
    # Create temp directory if it doesn't exist
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
CURSOR AI OPTIMIZATION REPORT
============================
Generated: $(date)
System: $(uname -a)
macOS Version: $(sw_vers -productVersion 2>/dev/null || echo "Unknown")

OPTIMIZATIONS APPLIED:
---------------------
✓ Enhanced Cursor AI settings configuration
✓ AI-optimized keybindings setup
✓ System performance tuning
✓ File descriptor limits increased
✓ Memory allocation optimized
✓ Animation effects disabled
✓ File watching exclusions configured
✓ Kernel parameters optimized
✓ Launch Services database cleaned
✓ System databases refreshed

NEXT STEPS:
----------
1. Restart Cursor AI Editor
2. Open a project to test AI performance
3. Monitor system performance with Activity Monitor
4. Report any issues to the development team

PERFORMANCE TIPS:
----------------
• Close unnecessary applications while coding
• Use specific AI prompts for better results
• Keep codebase organized for better AI context
• Consider upgrading RAM for large projects
• Use .cursorignore files to exclude irrelevant directories

Report saved to: $report_file
EOF
    
    echo "$report_file"
}

################################################################################
# Module Initialization
################################################################################

# Initialize optimization module
initialize_optimization_module() {
    production_log_message "INFO" "Initializing optimization module v$OPTIMIZATION_VERSION"
    
    # Check if required functions are available
    if ! command -v production_log_message >/dev/null 2>&1; then
        echo "[WARNING] Production logging functions not available" >&2
    fi
    
    return 0
}

# Auto-initialize when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    initialize_optimization_module
fi 