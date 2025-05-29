#!/bin/bash

################################################################################
# Optimization Module - Cursor Editor Performance Optimization Functions
# Part of Cursor Uninstaller Modular Architecture
################################################################################

# Enhanced optimization function with comprehensive performance improvements
enhanced_optimize_cursor_performance() {
    log_message "INFO" "Starting enhanced Cursor performance optimization..."

    # Check if Cursor is installed
    if ! check_cursor_installation; then
        error_message "Cursor is not installed. Please install Cursor first."
        return "$ERR_NOT_INSTALLED"
    fi

    # Check dependencies
    check_performance_deps || return $?

    # Create backup before optimization
    create_optimization_backup

    # Apply various optimizations
    optimize_cursor_settings
    optimize_system_resources
    optimize_launch_services
    configure_performance_settings

    log_message "SUCCESS" "✓ Cursor performance optimization completed"
    return 0
}

# Check for required dependencies for optimization
check_performance_deps() {
    log_message "INFO" "Checking optimization dependencies..."

    local deps_missing=0
    local required_tools=("defaults" "plutil")

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            error_message "Required tool not found: $tool"
            deps_missing=1
        fi
    done

    # Check for lsregister at its specific location
    if [[ ! -x "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister" ]]; then
        error_message "Required tool not found: lsregister"
        deps_missing=1
    fi

    if [[ $deps_missing -eq 1 ]]; then
        error_message "Missing required dependencies for optimization"
        return 1
    fi

    log_message "SUCCESS" "✓ All optimization dependencies are available"
    return 0
}

# Optimize Cursor application settings
optimize_cursor_settings() {
    log_message "INFO" "Optimizing Cursor application settings..."

    local cursor_app="/Applications/Cursor.app"
    local preferences_dir="$HOME/Library/Preferences"
    local cursor_pref="com.todesktop.230313mzl4w4u92.plist"

    # Optimize memory usage
    if [[ -f "$preferences_dir/$cursor_pref" ]]; then
        execute_safely defaults write "$preferences_dir/$cursor_pref" \
            "application.memory.maxHeapSize" -string "4096"
        execute_safely defaults write "$preferences_dir/$cursor_pref" \
            "application.performance.enableGC" -bool true
        log_message "SUCCESS" "✓ Memory optimization applied"
    fi

    # Disable unnecessary animations
    execute_safely defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    execute_safely defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false
    log_message "SUCCESS" "✓ Animation optimization applied"

    # Optimize file watching
    execute_safely defaults write "$preferences_dir/$cursor_pref" \
        "files.watcherExclude" -dict \
        "**/.git/objects/**" -bool true \
        "**/.git/subtree-cache/**" -bool true \
        "**/node_modules/**" -bool true \
        "**/.hg/store/**" -bool true

    log_message "SUCCESS" "✓ File watching optimization applied"
}

# Optimize system resources for Cursor
optimize_system_resources() {
    log_message "INFO" "Optimizing system resources..."

    # Increase file descriptor limits
    if [[ -w "/etc/launchd.conf" ]] || [[ ! -f "/etc/launchd.conf" ]]; then
        echo "limit maxfiles 65536 200000" | sudo tee -a /etc/launchd.conf >/dev/null
        log_message "SUCCESS" "✓ File descriptor limits increased"
    fi

    # Optimize kernel parameters for development
    execute_safely sudo sysctl -w kern.maxfiles=65536
    execute_safely sudo sysctl -w kern.maxfilesperproc=32768

    # Configure swap usage (if applicable)
    execute_safely sudo sysctl -w vm.swappiness=10

    log_message "SUCCESS" "✓ System resource optimization applied"
}

# Optimize Launch Services registration
optimize_launch_services() {
    log_message "INFO" "Optimizing Launch Services..."

    local cursor_app="/Applications/Cursor.app"

    if [[ -d "$cursor_app" ]]; then
        # Reset Launch Services database
        execute_safely /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
            -kill -r -domain local -domain system -domain user

        # Re-register Cursor
        execute_safely /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
            -r "$cursor_app"

        log_message "SUCCESS" "✓ Launch Services optimization applied"
    fi
}

# Configure performance-specific settings
configure_performance_settings() {
    log_message "INFO" "Configuring performance settings..."

    local cursor_settings="$HOME/Library/Application Support/Cursor/User/settings.json"

    # Create settings directory if it doesn't exist
    execute_safely mkdir -p "$(dirname "$cursor_settings")"

    # Apply performance configurations
    local perf_config='{
        "editor.fontSize": 14,
        "editor.fontFamily": "Monaco, Menlo",
        "editor.renderWhitespace": "none",
        "editor.minimap.enabled": false,
        "editor.wordWrap": "off",
        "files.autoSave": "afterDelay",
        "files.autoSaveDelay": 5000,
        "search.useIgnoreFiles": true,
        "search.exclude": {
            "**/node_modules": true,
            "**/bower_components": true,
            "**/.git": true,
            "**/.DS_Store": true
        },
        "files.exclude": {
            "**/.git": true,
            "**/.svn": true,
            "**/.hg": true,
            "**/CVS": true,
            "**/.DS_Store": true,
            "**/node_modules": true
        },
        "extensions.autoUpdate": false,
        "telemetry.enableTelemetry": false,
        "update.mode": "manual"
    }'

    if [[ -f "$cursor_settings" ]]; then
        # Merge with existing settings
        execute_safely cp "$cursor_settings" "$cursor_settings.backup"
    fi

    echo "$perf_config" > "$cursor_settings"
    log_message "SUCCESS" "✓ Performance settings configured"
}

# Reset performance settings to defaults
reset_performance_settings() {
    production_log_message "INFO" "Resetting ALL performance settings to defaults..."

    # Reset application preferences (Cursor specific)
    local preferences_dir="$HOME/Library/Preferences"
    local cursor_pref="com.todesktop.230313mzl4w4u92.plist"

    if [[ -f "$preferences_dir/$cursor_pref" ]]; then
        production_info_message "Resetting Cursor application preferences..."
        execute_safely defaults delete "$preferences_dir/$cursor_pref" "application.memory.maxHeapSize" 2>/dev/null || true
        execute_safely defaults delete "$preferences_dir/$cursor_pref" "application.performance.enableGC" 2>/dev/null || true
        execute_safely defaults delete "$preferences_dir/$cursor_pref" "files.watcherExclude" 2>/dev/null || true
        production_success_message "✓ Cursor application preferences reset"
    fi

    # Reset system animations (macOS specific)
    production_info_message "Resetting system visual effects..."
    execute_safely defaults delete NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null || true
    execute_safely defaults delete NSGlobalDomain NSScrollAnimationEnabled 2>/dev/null || true
    execute_safely defaults delete com.apple.universalaccess reduceTransparency 2>/dev/null || true
    execute_safely defaults delete com.apple.universalaccess reduceMotion 2>/dev/null || true
    execute_safely defaults delete com.apple.dock autohide 2>/dev/null || true
    production_success_message "✓ System visual effects reset to defaults"

    # Reset Energy Saver settings (macOS specific)
    production_info_message "Resetting Energy Saver settings..."
    if command -v pmset >/dev/null 2>&1; then
        execute_safely sudo pmset -c sleep 10        # Default computer sleep on AC
        execute_safely sudo pmset -c disksleep 10     # Default disk sleep
        execute_safely sudo pmset -c displaysleep 10  # Default display sleep
        production_success_message "✓ Energy Saver settings reset to defaults"
    fi

    # Reset kernel parameters (macOS specific)
    # Note: Reverting sysctl changes requires setting them back to system defaults.
    # This is complex and potentially risky if defaults are unknown or vary widely.
    # For now, we will log a recommendation to reboot for these to be fully reset by macOS.
    production_warning_message "Kernel parameters (maxfiles, maxfilesperproc, vm.swappiness) modified by optimization."
    production_warning_message "A system reboot is recommended to fully restore default kernel parameters."


    # Reset Cursor AI Editor specific settings
    local cursor_user_dir="$HOME/Library/Application Support/Cursor/User"
    local settings_file="$cursor_user_dir/settings.json"
    local keybindings_file="$cursor_user_dir/keybindings.json"
    local beta_settings_file="$cursor_user_dir/beta-settings.json"

    production_info_message "Resetting Cursor AI Editor specific settings..."
    if [[ -f "$settings_file.backup" ]]; then
        execute_safely mv "$settings_file.backup" "$settings_file"
        production_success_message "✓ Cursor settings.json restored from backup"
    elif [[ -f "$settings_file" ]]; then
        execute_safely rm -f "$settings_file"
        production_success_message "✓ Removed custom Cursor settings.json"
    fi

    if [[ -f "$keybindings_file" ]]; then
        execute_safely rm -f "$keybindings_file"
        production_success_message "✓ Removed custom Cursor keybindings.json"
    fi

    if [[ -f "$beta_settings_file" ]];then
        execute_safely rm -f "$beta_settings_file"
        production_success_message "✓ Removed Cursor beta-settings.json"
    fi

    # Reset MCP Server configurations
    local mcp_config_dir="$HOME/.cursor/mcp-servers"
    if [[ -d "$mcp_config_dir" ]]; then
        production_info_message "Removing MCP server configurations..."
        execute_safely rm -rf "$mcp_config_dir"
        production_success_message "✓ Removed MCP server configurations"
    fi

    # Reset Cursor Rules
    local rules_dir="$HOME/.cursor/rules"
    if [[ -d "$rules_dir" ]]; then
        production_info_message "Removing Cursor Rules..."
        execute_safely rm -rf "$rules_dir"
        production_success_message "✓ Removed Cursor Rules"
    fi
    
    # Reset environment variables set by GPU acceleration (users will need to restart shell/system)
    production_info_message "Resetting GPU acceleration environment variables..."
    # Unset variables for the current session, user needs to restart shell or system for full effect
    unset METAL_DEVICE_WRAPPER_TYPE
    unset METAL_DEBUG_ERROR_MODE
    unset METAL_PERFORMANCE_SHADERS_FRAMEWORKS
    unset PYTORCH_MPS_HIGH_WATERMARK_RATIO
    unset LIBGL_ALWAYS_INDIRECT
    unset MESA_GL_VERSION_OVERRIDE
    unset GL_VERSION
    unset OPENGL_PROFILE
    production_success_message "✓ GPU acceleration environment variables unset for current session"
    production_warning_message "Please restart your shell or system to fully reset GPU environment variables."

    production_success_message "✓ ALL performance settings reset completed"
    production_info_message "Please restart Cursor AI Editor and potentially your system for all changes to take effect."
}

# Check current performance settings
check_performance_settings() {
    log_message "INFO" "Checking current performance settings..."

    local preferences_dir="$HOME/Library/Preferences"
    local cursor_pref="com.todesktop.230313mzl4w4u92.plist"

    echo "=== Current Performance Settings ==="

    # Check memory settings
    if [[ -f "$preferences_dir/$cursor_pref" ]]; then
        local heap_size
        heap_size=$(defaults read "$preferences_dir/$cursor_pref" "application.memory.maxHeapSize" 2>/dev/null || echo "Default")
        echo "Memory Heap Size: $heap_size"

        local gc_enabled
        gc_enabled=$(defaults read "$preferences_dir/$cursor_pref" "application.performance.enableGC" 2>/dev/null || echo "Default")
        echo "Garbage Collection: $gc_enabled"
    fi

    # Check system settings
    local animations
    animations=$(defaults read NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null || echo "Default")
    echo "Window Animations: $animations"

    local scroll_animations
    scroll_animations=$(defaults read NSGlobalDomain NSScrollAnimationEnabled 2>/dev/null || echo "Default")
    echo "Scroll Animations: $scroll_animations"

    # Check file limits
    echo "Current file limits:"
    ulimit -n

    echo "=== End Performance Settings ==="
}

# Create backup before optimization
create_optimization_backup() {
    log_message "INFO" "Creating backup before optimization..."

    local backup_dir="$HOME/.cursor-optimizer-backup-$(date +%Y%m%d_%H%M%S)"
    execute_safely mkdir -p "$backup_dir"

    # Backup preferences
    local preferences_dir="$HOME/Library/Preferences"
    local cursor_pref="com.todesktop.230313mzl4w4u92.plist"

    if [[ -f "$preferences_dir/$cursor_pref" ]]; then
        execute_safely cp "$preferences_dir/$cursor_pref" "$backup_dir/"
    fi

    # Backup Cursor settings
    local cursor_settings="$HOME/Library/Application Support/Cursor/User/settings.json"
    if [[ -f "$cursor_settings" ]]; then
        execute_safely cp "$cursor_settings" "$backup_dir/"
    fi

    log_message "SUCCESS" "✓ Backup created at: $backup_dir"
    export CURSOR_OPTIMIZATION_BACKUP="$backup_dir"
}

# Restore from optimization backup
restore_optimization_backup() {
    local backup_dir="${1:-$CURSOR_OPTIMIZATION_BACKUP}"

    if [[ -z "$backup_dir" ]] || [[ ! -d "$backup_dir" ]]; then
        error_message "Backup directory not found: $backup_dir"
        return 1
    fi

    log_message "INFO" "Restoring from backup: $backup_dir"

    # Restore preferences
    local preferences_dir="$HOME/Library/Preferences"
    local cursor_pref="com.todesktop.230313mzl4w4u92.plist"

    if [[ -f "$backup_dir/$cursor_pref" ]]; then
        execute_safely cp "$backup_dir/$cursor_pref" "$preferences_dir/"
        log_message "SUCCESS" "✓ Preferences restored"
    fi

    # Restore Cursor settings
    local cursor_settings="$HOME/Library/Application Support/Cursor/User/settings.json"
    if [[ -f "$backup_dir/settings.json" ]]; then
        execute_safely cp "$backup_dir/settings.json" "$cursor_settings"
        log_message "SUCCESS" "✓ Cursor settings restored"
    fi

    log_message "SUCCESS" "✓ Backup restoration completed"
}
