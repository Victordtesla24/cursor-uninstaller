#!/bin/bash

LOG_FILE="/tmp/docker_uninstall.log"

# Function to log messages
log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Function to check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        log "Error: This script must be run as root. Please use sudo."
        exit 1
    fi
}

# Function to safely remove files/directories
safe_remove() {
    local target="$1"
    if [ -e "$target" ]; then
        rm -rf "$target"
        log "Removed: $target"
    fi
}

# Function to safely remove binaries
safe_remove_binary() {
    local binary="$1"
    if [ -f "$binary" ]; then
        rm -f "$binary"
        log "Removed binary: $binary"
    fi
}

# Function to safely remove launch agents or daemons
safe_launchctl_remove() {
    local service="$1"
    if launchctl list | grep -q "$service"; then
        launchctl remove "$service" 2>/dev/null && log "Removed launchctl service: $service"
    fi
}

# Check if running as root
check_root

log "Starting Docker Desktop uninstallation..."

# Quit Docker Desktop (if running)
if osascript -e 'quit app "Docker"' 2>/dev/null; then
    log "Docker Desktop application quit successfully."
else
    log "Docker Desktop application not running or failed to quit."
fi

# Remove Docker Desktop application
safe_remove "/Applications/Docker.app"

# Remove Docker CLI and related binaries
safe_remove_binary "/usr/local/bin/docker"
safe_remove_binary "/usr/local/bin/docker-compose"
safe_remove_binary "/usr/local/bin/docker-credential-desktop"
safe_remove_binary "/usr/local/bin/docker-credential-osxkeychain"
safe_remove_binary "/usr/local/bin/hub-tool"
safe_remove_binary "/usr/local/bin/kubectl.docker"

# Get actual user home directory (handles root execution properly)
if [ "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi

# Remove Docker configuration files and directories
safe_remove "$USER_HOME/.docker"
safe_remove "/usr/local/lib/docker"

# Remove Docker Desktop specific files and directories in Library folders
safe_remove "$USER_HOME/Library/Group Containers/group.com.docker"
safe_remove "$USER_HOME/Library/Containers/com.docker.docker"
safe_remove "$USER_HOME/Library/Application Support/Docker Desktop"
safe_remove "$USER_HOME/Library/Saved Application State/com.electron.docker-frontend.savedState"
safe_remove "$USER_HOME/Library/Preferences/com.docker.docker.plist"
safe_remove "$USER_HOME/Library/Preferences/com.electron.docker-frontend.plist"
safe_remove "$USER_HOME/Library/Caches/com.docker.docker"
safe_remove "$USER_HOME/Library/Logs/Docker Desktop"

# Remove Docker VM-related files (if any)
safe_remove "/Library/PrivilegedHelperTools/com.docker.vmnetd"
safe_remove "/Library/LaunchDaemons/com.docker.vmnetd.plist"

# Remove any Docker-related launch agents or daemons
safe_launchctl_remove "com.docker.helper"
safe_launchctl_remove "com.docker.vmnetd"

# Clean up any remaining Docker processes
if pkill -f docker; then
    log "Terminated remaining Docker processes."
else
    log "No Docker processes found to terminate."
fi

# Remove Docker from login items (if listed)
if osascript -e 'tell application "System Events" to delete every login item whose name is "Docker"' 2>/dev/null; then
    log "Removed Docker from login items."
else
    log "Docker not found in login items or removal failed."
fi

# Flush DNS cache to remove any lingering entries related to Docker networking
dscacheutil -flushcache && log "Flushed DNS cache."
killall -HUP mDNSResponder && log "Restarted mDNSResponder."

# Clean up system logs that might reference Docker
safe_remove "/var/log/docker*"

# Remove any Docker-related entries from /etc/hosts (if present)
if grep -q "# Added by Docker Desktop" /etc/hosts; then
    sed -i '' '/# Added by Docker Desktop/d' /etc/hosts && log "Removed Docker entries from /etc/hosts."
fi

# Clean up any temporary files related to Docker
safe_remove "/tmp/docker*"

# Remove Docker from Spotlight index (if applicable)
mdutil -i off / 2>/dev/null && log "Disabled Spotlight indexing temporarily."
mdutil -E / 2>/dev/null && log "Erased Spotlight index."
mdutil -i on / 2>/dev/null && log "Re-enabled Spotlight indexing."

log "Docker Desktop uninstallation completed."
log "Please restart your computer to ensure all changes take effect."
log "Check the log file at $LOG_FILE for detailed uninstallation information."
