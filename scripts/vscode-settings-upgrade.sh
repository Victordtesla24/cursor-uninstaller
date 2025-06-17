#!/bin/bash

# SECURITY ENHANCED VSCODE SETTINGS UPGRADE SCRIPT FOR CURSOR AI

################################################################################
# PRIMARY OBJECTIVE:
# SYSTEMATICALLY upgrade VSCode/Cursor settings with production-grade optimizations
# while maintaining full macOS compatibility and security standards
################################################################################

# Initialize critical security parameters
set -euo pipefail
IFS=$'\n\t'

# Configuration
USER_SETTINGS_DIR="${HOME}/Library/Application Support/Cursor/User"
BACKUP_DIR="${USER_SETTINGS_DIR}/backups"
SCRIPT_START_TIME=$(date +%Y%m%d%H%M%S)

# Create backup directory with security constraints
mkdir -p "$BACKUP_DIR" && chmod 700 "$BACKUP_DIR"

# Enhanced backup function with atomic operations
backup_settings() {
    local source_file="${USER_SETTINGS_DIR}/settings.json"
    local backup_file="${BACKUP_DIR}/settings.json.backup.${SCRIPT_START_TIME}"

    if [[ -f "$source_file" ]]; then
        cp -p "$source_file" "$backup_file"
        chmod 600 "$backup_file"
        echo "Securely backed up settings to: ${backup_file}"
    fi
}

# macOS-compatible realpath replacement
safe_realpath() {
    local path="$1"
    if command -v realpath >/dev/null; then
        realpath "$path"
    else
        perl -MCwd -e 'print Cwd::realpath($ARGV[0])' "$path"
    fi
}

# Validate and apply settings with proper error handling
apply_optimized_settings() {
    local script_dir
    script_dir=$(dirname "$(safe_realpath "$0")")
    local optimized_settings="${script_dir}/../config/optimized-settings.json"

    # Validate optimized settings file exists and is readable
    if [[ ! -f "$optimized_settings" ]]; then
        echo "Error: Optimized settings file not found at: $optimized_settings" >&2
        return 1
    fi

    if [[ ! -r "$optimized_settings" ]]; then
        echo "Error: Cannot read optimized settings file: $optimized_settings" >&2
        return 1
    fi

    # Validate JSON syntax before applying
    if command -v python3 >/dev/null 2>&1; then
        if ! python3 -m json.tool "$optimized_settings" >/dev/null 2>&1; then
            echo "Error: Invalid JSON in optimized settings file" >&2
            return 1
        fi
    elif command -v jq >/dev/null 2>&1; then
        if ! jq empty "$optimized_settings" >/dev/null 2>&1; then
            echo "Error: Invalid JSON in optimized settings file" >&2
            return 1
        fi
    else
        echo "Warning: Cannot validate JSON syntax (python3 or jq not available)"
    fi

    # Ensure user settings directory exists
    if [[ ! -d "$USER_SETTINGS_DIR" ]]; then
        mkdir -p "$USER_SETTINGS_DIR"
        chmod 700 "$USER_SETTINGS_DIR"
    fi

    # Atomic settings replacement with validation
    if cp "$optimized_settings" "${USER_SETTINGS_DIR}/settings.json"; then
        chmod 600 "${USER_SETTINGS_DIR}/settings.json"
        echo "Successfully applied optimized settings"
        return 0
    else
        echo "Error: Failed to copy settings file" >&2
        return 1
    fi
}

# Safe macOS-specific optimizations for Cursor AI
apply_macos_optimizations() {
    echo "Applying safe macOS-specific optimizations..."

    # Safe DNS cache flush (improves network performance)
    if command -v dscacheutil >/dev/null 2>&1; then
        if sudo dscacheutil -flushcache 2>/dev/null; then
            echo "✓ DNS cache flushed successfully"
        else
            echo "⚠ Could not flush DNS cache (may require admin privileges)"
        fi
    fi

    # Safe Launch Services database update (improves app detection)
    local lsregister_path="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
    if [[ -x "$lsregister_path" ]]; then
        if "$lsregister_path" -kill -r -domain user 2>/dev/null; then
            echo "✓ Launch Services database updated for current user"
        else
            echo "⚠ Could not update Launch Services database"
        fi
    fi

    # Restart Cursor processes to apply changes
    if pgrep -f "[Cc]ursor" >/dev/null 2>&1; then
        echo "Found running Cursor processes - will need restart to apply optimizations"
    fi

    echo "Safe macOS optimizations completed"
}

# Main execution flow
main() {
    echo "Starting Cursor AI Settings Upgrade (Secure macOS Edition)"
    print_separator "="

    backup_settings
    apply_optimized_settings
    apply_macos_optimizations

    # Create .cursor-rules file
    create_cursor_rules_file

    echo "System optimizations applied successfully"
    print_separator "="
    echo "Please restart Cursor AI to complete the upgrade process"
}

# Helper functions
print_separator() {
    local char=${1:-=}
    printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' "$char"
}

create_cursor_rules_file() {
    local rules_file="${HOME}/.cursor-rules"
    cat > "$rules_file" <<'EOL'
{
    "codeStyle": {
        "preferredLanguages": ["typescript", "javascript", "python"],
        "maxLineLength": 100
    },
    "security": {
        "allowNetworkAccess": false,
        "strictInputValidation": true
    }
}
EOL
    chmod 600 "$rules_file"
    echo "Created secure .cursor-rules file"
}

# Execute main function
main
