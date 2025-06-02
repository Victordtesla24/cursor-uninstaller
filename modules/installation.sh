#!/bin/bash

################################################################################
# Installation Module for Cursor AI Editor Management Utility
# PRODUCTION INSTALLATION FUNCTIONS
################################################################################

# Install Cursor from DMG file
install_cursor_from_dmg() {
    local dmg_path="$1"
    
    if [[ ! -f "$dmg_path" ]]; then
        echo "[ERROR] DMG file not found: $dmg_path" >&2
        return 1
    fi
    
    echo "[INFO] Installing Cursor from DMG: $dmg_path"
    
    # Mount the DMG
    local mount_point
    mount_point=$(hdiutil attach "$dmg_path" 2>/dev/null | grep -E '/Volumes/' | tail -1 | awk '{print $3}')
    
    if [[ -z "$mount_point" ]]; then
        echo "[ERROR] Failed to mount DMG file" >&2
        return 1
    fi
    
    echo "[INFO] Mounted DMG at: $mount_point"
    
    # Find Cursor.app in the mounted volume
    local cursor_app
    cursor_app=$(find "$mount_point" -name "Cursor.app" -type d | head -1)
    
    if [[ -z "$cursor_app" ]]; then
        echo "[ERROR] Cursor.app not found in DMG" >&2
        hdiutil detach "$mount_point" 2>/dev/null
        return 1
    fi
    
    # Copy Cursor.app to Applications
    echo "[INFO] Copying Cursor.app to /Applications/"
    if cp -R "$cursor_app" "/Applications/"; then
        echo "[SUCCESS] Cursor.app installed successfully"
    else
        echo "[ERROR] Failed to copy Cursor.app to Applications" >&2
        hdiutil detach "$mount_point" 2>/dev/null
        return 1
    fi
    
    # Unmount the DMG
    if hdiutil detach "$mount_point" 2>/dev/null; then
        echo "[INFO] DMG unmounted successfully"
    else
        echo "[WARNING] Could not unmount DMG (non-critical)"
    fi
    
    return 0
}

# Confirm installation action
confirm_installation_action() {
    echo -e "\n${YELLOW}${BOLD}⚠️  INSTALLATION CONFIRMATION${NC}"
    echo -e "${BOLD}This will install Cursor AI Editor to /Applications/${NC}"
    echo ""
    
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        echo "[INFO] Non-interactive mode: Auto-confirming installation"
        return 0
    fi
    
    echo -n "Proceed with installation? (y/N): "
    read -r response
    case "$response" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# Check installation status
check_cursor_installation() {
    local issues_found=0
    
    echo -e "\n${BOLD}${BLUE}🔍 CURSOR INSTALLATION CHECK${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Check main application
    if [[ -d "/Applications/Cursor.app" ]]; then
        echo -e "${GREEN}✅ Cursor.app found in Applications${NC}"
        
        # Check version info
        if [[ -f "/Applications/Cursor.app/Contents/Info.plist" ]]; then
            local version
            version=$(defaults read "/Applications/Cursor.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")
            echo -e "   ${CYAN}Version: $version${NC}"
        fi
    else
        echo -e "${RED}❌ Cursor.app not found in Applications${NC}"
        ((issues_found++))
    fi
    
    # Check CLI tools
    local cli_found=false
    for cli_path in "${CURSOR_CLI_PATHS[@]}"; do
        if [[ -f "$cli_path" ]] && [[ -x "$cli_path" ]]; then
            echo -e "${GREEN}✅ CLI tool found: $cli_path${NC}"
            cli_found=true
            break
        fi
    done
    
    if [[ "$cli_found" == "false" ]]; then
        echo -e "${YELLOW}⚠️ CLI tools not installed${NC}"
        echo -e "   ${CYAN}Install CLI tools from within Cursor app${NC}"
    fi
    
    return $issues_found
}

# Installation module loaded
export INSTALLATION_LOADED=true 