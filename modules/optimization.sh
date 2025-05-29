#!/bin/bash

################################################################################
# Optimization Module - Cursor Editor Performance Optimization Functions
# Part of Cursor Uninstaller Modular Architecture
################################################################################

# Enhanced optimization function with comprehensive performance improvements
enhanced_optimize_cursor_performance() {
    log_message "INFO" "Starting enhanced Cursor performance optimization..."

    if [[ "${DRY_RUN:-}" == "true" ]]; then
        info_message "DRY RUN: Would perform Cursor optimization"
        return 0
    fi

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
    local required_tools=("defaults" "plutil" "lsregister")

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            error_message "Required tool not found: $tool"
            deps_missing=1
        fi
    done

    if [[ $deps_missing -eq 1 ]]; then
        error_message "Missing required dependencies for optimization"
        return "$ERR_DEPENDENCIES"
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
    log_message "INFO" "Resetting Cursor performance settings to defaults..."

    if [[ "${DRY_RUN:-}" == "true" ]]; then
        info_message "DRY RUN: Would reset performance settings"
        return 0
    fi

    # Reset application preferences
    local preferences_dir="$HOME/Library/Preferences"
    local cursor_pref="com.todesktop.230313mzl4w4u92.plist"

    if [[ -f "$preferences_dir/$cursor_pref" ]]; then
        execute_safely defaults delete "$preferences_dir/$cursor_pref" "application.memory.maxHeapSize" 2>/dev/null || true
        execute_safely defaults delete "$preferences_dir/$cursor_pref" "application.performance.enableGC" 2>/dev/null || true
        execute_safely defaults delete "$preferences_dir/$cursor_pref" "files.watcherExclude" 2>/dev/null || true
        log_message "SUCCESS" "✓ Application preferences reset"
    fi

    # Reset system animations
    execute_safely defaults delete NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null || true
    execute_safely defaults delete NSGlobalDomain NSScrollAnimationEnabled 2>/dev/null || true
    log_message "SUCCESS" "✓ System animations reset"

    # Restore settings backup if available
    local cursor_settings="$HOME/Library/Application Support/Cursor/User/settings.json"
    if [[ -f "$cursor_settings.backup" ]]; then
        execute_safely mv "$cursor_settings.backup" "$cursor_settings"
        log_message "SUCCESS" "✓ Cursor settings restored from backup"
    fi

    log_message "SUCCESS" "✓ Performance settings reset completed"
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
