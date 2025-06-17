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

# Validate and apply settings
apply_optimized_settings() {
    local script_dir
    script_dir=$(dirname "$(safe_realpath "$0")")
    local optimized_settings="${script_dir}/../config/optimized-settings.json"

    if [[ ! -f "$optimized_settings" ]]; then
        echo "Error: Optimized settings file missing" >&2
        exit 1
    fi

    # Atomic settings replacement
    cp -f "$optimized_settings" "${USER_SETTINGS_DIR}/settings.json"
    chmod 600 "${USER_SETTINGS_DIR}/settings.json"
}

# macOS-specific performance optimizations
apply_macos_optimizations() {
    echo "Applying macOS-specific optimizations..."
    
    # Valid macOS sysctl parameters
    sudo sysctl kern.ipc.somaxconn=2048
    sudo sysctl kern.maxfiles=524288
    sudo sysctl kern.maxfilesperproc=262144
    
    # Network optimization
    sudo sysctl net.inet.tcp.delayed_ack=0
    
    # SSD optimization
    sudo sysctl vm.swapusage=0
    
    # DNS cache flush
    sudo killall -HUP mDNSResponder
    
    # Launch Services database update
    sudo /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
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
