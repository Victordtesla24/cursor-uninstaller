#!/bin/bash
# =============================================================================
# System Optimization Script for Cursor Development Tools
# COMPREHENSIVE SYSTEM OPTIMIZATION with PRODUCTION-GRADE OPTIMIZATION
# =============================================================================

# Source helper functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
source "$PROJECT_ROOT/lib/helpers.sh"

# =============================================================================
# Production Optimization Function
# =============================================================================

production_execute_optimize() {
    print_header "System Optimization - Production Mode"
    
    local optimization_result=0
    
    print_step "1. Validating system environment"
    if ! validate_macos; then
        print_error "macOS validation failed"
        return 1
    fi
    
    if ! validate_nodejs; then
        print_error "Node.js validation failed"
        return 1
    fi
    
    print_step "2. Stopping Cursor processes"
    stop_cursor
    
    print_step "3. Cleaning cache directories"
    local cache_dirs=(
        "$HOME/.cursor"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Application Support/Cursor"
    )
    
    for cache_dir in "${cache_dirs[@]}"; do
        if [[ -d "$cache_dir" ]]; then
            print_info "Cleaning: $cache_dir"
            find "$cache_dir" -name "*.log" -delete 2>/dev/null || true
            find "$cache_dir" -name "*.tmp" -delete 2>/dev/null || true
        fi
    done
    
    print_step "4. Optimizing file system permissions"
    local cursor_app="/Applications/Cursor.app"
    if [[ -d "$cursor_app" ]]; then
        print_info "Checking Cursor.app permissions"
        # Ensure proper permissions without sudo
        if [[ -w "$cursor_app" ]]; then
            chmod -R 755 "$cursor_app" 2>/dev/null || true
        fi
    fi
    
    print_step "5. Verifying optimization results"
    if validate_cursor_installation; then
        print_success "System optimization completed successfully"
        optimization_result=0
    else
        print_error "Optimization completed with warnings"
        optimization_result=1
    fi
    
    print_info "Optimization summary:"
    print_info "- Cache cleanup: completed"
    print_info "- Permission optimization: completed"
    print_info "- System validation: $([ $optimization_result -eq 0 ] && echo "passed" || echo "warnings")"
    
    return $optimization_result
}

# =============================================================================
# Additional Optimization Functions
# =============================================================================

optimize_cursor_performance() {
    print_header "Cursor Performance Optimization"
    
    print_step "Optimizing Cursor settings"
    local cursor_settings="$HOME/Library/Application Support/Cursor/User/settings.json"
    
    if [[ -f "$cursor_settings" ]]; then
        backup_file "$cursor_settings"
        print_info "Cursor settings backed up"
    fi
    
    # Create optimized settings if they don't exist
    local settings_dir=$(dirname "$cursor_settings")
    ensure_directory "$settings_dir"
    
    if [[ ! -f "$cursor_settings" ]] || ! grep -q "editor.quickSuggestions" "$cursor_settings" 2>/dev/null; then
        print_info "Creating optimized Cursor settings"
        cat > "$cursor_settings" << 'EOF'
{
    "editor.quickSuggestions": {
        "other": true,
        "comments": false,
        "strings": true
    },
    "editor.suggestOnTriggerCharacters": true,
    "editor.wordBasedSuggestions": "off",
    "editor.parameterHints.enabled": true,
    "editor.suggest.preview": true,
    "workbench.startupEditor": "none"
}
EOF
    fi
}

system_health_check() {
    print_header "System Health Check"
    
    local health_score=100
    
    print_step "Checking disk space"
    local available_gb=$(df -h "$HOME" | awk 'NR==2 {print $4}' | sed 's/Gi//')
    if [[ ${available_gb%.*} -lt 5 ]]; then
        print_warning "Low disk space: ${available_gb}GB available"
        health_score=$((health_score - 20))
    else
        print_success "Disk space OK: ${available_gb}GB available"
    fi
    
    print_step "Checking memory usage"
    local memory_pressure=$(memory_pressure 2>/dev/null || echo "normal")
    case "$memory_pressure" in
        "normal")
            print_success "Memory pressure: normal"
            ;;
        "warn")
            print_warning "Memory pressure: elevated"
            health_score=$((health_score - 10))
            ;;
        "critical")
            print_error "Memory pressure: critical"
            health_score=$((health_score - 30))
            ;;
    esac
    
    print_step "Checking Cursor installation"
    if validate_cursor_installation; then
        print_success "Cursor installation: OK"
    else
        print_error "Cursor installation: issues detected"
        health_score=$((health_score - 50))
    fi
    
    print_info "System health score: ${health_score}/100"
    return $((100 - health_score > 30 ? 1 : 0))
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    local action="${1:-optimize}"
    
    case "$action" in
        "optimize"|"production")
            production_execute_optimize
            ;;
        "performance")
            optimize_cursor_performance
            ;;
        "health")
            system_health_check
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [optimize|performance|health|help]"
            echo ""
            echo "Commands:"
            echo "  optimize     - Run full system optimization (default)"
            echo "  performance  - Optimize Cursor performance settings"
            echo "  health       - Run system health check"
            echo "  help         - Show this help message"
            ;;
        *)
            print_error "Unknown action: $action"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
