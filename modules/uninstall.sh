#!/bin/bash

################################################################################
# Uninstall Module for Cursor AI Editor Management Utility
# PRODUCTION UNINSTALL FUNCTIONS
################################################################################

# Enhanced uninstall function
enhanced_uninstall_cursor() {
    local removal_errors=0
    
    echo -e "\n${BOLD}${BLUE}🗑️ ENHANCED CURSOR UNINSTALL${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Terminate any running Cursor processes
    echo "[INFO] Checking for running Cursor processes..."
    if terminate_cursor_processes; then
        echo "[SUCCESS] Cursor processes terminated"
    else
        echo "[WARNING] Could not terminate all Cursor processes"
        ((removal_errors++))
    fi
    
    # Remove main application
    if [[ -d "/Applications/Cursor.app" ]]; then
        echo "[INFO] Removing Cursor.app..."
        if sudo rm -rf "/Applications/Cursor.app"; then
            echo "[SUCCESS] Removed Cursor.app"
        else
            echo "[ERROR] Failed to remove Cursor.app" >&2
            ((removal_errors++))
        fi
    fi
    
    # Remove user data directories
    for dir in "${CURSOR_USER_DIRS[@]}"; do
        if [[ -e "$dir" ]]; then
            echo "[INFO] Removing: $dir"
            if rm -rf "$dir"; then
                echo "[SUCCESS] Removed: $dir"
            else
                echo "[ERROR] Failed to remove: $dir" >&2
                ((removal_errors++))
            fi
        fi
    done
    
    # Remove CLI tools
    for cli_path in "${CURSOR_CLI_PATHS[@]}"; do
        if [[ -f "$cli_path" ]] || [[ -L "$cli_path" ]]; then
            echo "[INFO] Removing CLI tool: $cli_path"
            if sudo rm -f "$cli_path"; then
                echo "[SUCCESS] Removed: $cli_path"
            else
                echo "[ERROR] Failed to remove: $cli_path" >&2
                ((removal_errors++))
            fi
        fi
    done
    
    # Reset Launch Services database
    echo "[INFO] Resetting Launch Services database..."
    if sudo "$LAUNCH_SERVICES_CMD" -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
        echo "[SUCCESS] Launch Services database reset"
    else
        echo "[WARNING] Could not reset Launch Services database"
        ((removal_errors++))
    fi
    
    # Return proper success/failure status
    if [[ $removal_errors -eq 0 ]]; then
        echo "[SUCCESS] Enhanced uninstall completed successfully"
        return 0
    elif [[ $removal_errors -le 3 ]]; then
        echo "[INFO] Enhanced uninstall completed with $removal_errors minor warnings/errors"
        return 0  # Return success for minor issues
    else
        echo "[ERROR] Enhanced uninstall completed with $removal_errors significant errors"
        return 1  # Return error for critical failures
    fi
}

# Uninstall module loaded
export UNINSTALL_LOADED=true 