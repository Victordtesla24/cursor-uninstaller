#!/bin/bash

################################################################################
# Complete Removal Module for Cursor AI Editor Management Utility
# THOROUGH CURSOR REMOVAL FUNCTIONS
################################################################################

# Perform complete Cursor removal
perform_complete_cursor_removal() {
    local removal_errors=0
    
    echo -e "\n${BOLD}${RED}🧹 COMPLETE CURSOR REMOVAL${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Additional thorough cleanup beyond standard uninstall
    echo "[INFO] Performing thorough system cleanup..."
    
    # Clean system caches related to Cursor
    local cache_dirs=(
        "/Library/Caches/com.todesktop.230313mzl4w4u92"
        "/tmp/com.todesktop.230313mzl4w4u92"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92"
    )
    
    for cache_dir in "${cache_dirs[@]}"; do
        if [[ -d "$cache_dir" ]]; then
            echo "[INFO] Removing cache directory: $cache_dir"
            if sudo rm -rf "$cache_dir" 2>/dev/null; then
                echo "[SUCCESS] Removed: $cache_dir"
            else
                echo "[WARNING] Could not remove: $cache_dir"
                ((removal_errors++))
            fi
        fi
    done
    
    # Remove any residual preferences
    local pref_files=(
        "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        "$HOME/Library/Preferences/ByHost/com.todesktop.230313mzl4w4u92.*.plist"
    )
    
    for pref_pattern in "${pref_files[@]}"; do
        for pref_file in $pref_pattern; do
            if [[ -f "$pref_file" ]]; then
                echo "[INFO] Removing preference file: $pref_file"
                if rm -f "$pref_file"; then
                    echo "[SUCCESS] Removed: $pref_file"
                else
                    echo "[WARNING] Could not remove: $pref_file"
                    ((removal_errors++))
                fi
            fi
        done
    done
    
    # Clear any remaining database entries
    echo "[INFO] Clearing system database entries..."
    if sudo periodic daily 2>/dev/null; then
        echo "[SUCCESS] System maintenance completed"
    else
        echo "[WARNING] Could not run system maintenance"
        ((removal_errors++))
    fi
    
    echo "[INFO] Complete removal finished with $removal_errors warnings"
    
    # Return proper success/failure status
    if [[ $removal_errors -eq 0 ]]; then
        return 0
    else
        echo "[INFO] Complete removal completed with $removal_errors warnings/errors"
        return 0  # Return success even with warnings to prevent script exit
    fi
}

# Complete removal module loaded
export COMPLETE_REMOVAL_LOADED=true 