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

# Function to actually remove files/directories with real verification
safe_remove() {
    local target="$1"
    if [ -e "$target" ]; then
        log "Attempting to remove: $target"
        if rm -rf "$target" 2>/dev/null; then
            if [ ! -e "$target" ]; then
                log "SUCCESS: Removed $target"
                return 0
            else
                log "ERROR: Failed to remove $target (still exists)"
                return 1
            fi
        else
            log "ERROR: Remove command failed for $target"
            return 1
        fi
    else
        log "Not found: $target"
        return 0
    fi
}

# Function to actually remove binaries with real verification
safe_remove_binary() {
    local binary="$1"
    if [ -f "$binary" ]; then
        log "Attempting to remove binary: $binary"
        if rm -f "$binary" 2>/dev/null; then
            if [ ! -f "$binary" ]; then
                log "SUCCESS: Removed binary $binary"
                return 0
            else
                log "ERROR: Failed to remove binary $binary (still exists)"
                return 1
            fi
        else
            log "ERROR: Remove command failed for binary $binary"
            return 1
        fi
    else
        log "Binary not found: $binary"
        return 0
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

# Force-terminate ALL Docker processes before removal
log "Force-terminating all Docker processes..."
DOCKER_PIDS=$(pgrep -i docker 2>/dev/null)
if [ -n "$DOCKER_PIDS" ]; then
    log "Found Docker processes: $DOCKER_PIDS"
    for pid in $DOCKER_PIDS; do
        log "Force-killing Docker process PID: $pid"
        sudo kill -9 "$pid" 2>/dev/null || true
    done
else
    log "No Docker processes found"
fi

# Aggressive Docker application removal
log "Attempting aggressive Docker application removal..."
if [ -d "/Applications/Docker.app" ]; then
    log "Docker application found at /Applications/Docker.app"
    if sudo rm -rf "/Applications/Docker.app" 2>/dev/null; then
        if [ ! -d "/Applications/Docker.app" ]; then
            log "SUCCESS: Docker application completely removed"
        else
            log "ERROR: Failed to remove Docker application - still exists"
            exit 1
        fi
    else
        log "ERROR: Remove command failed for Docker application"
        exit 1
    fi
else
    log "Docker application not found at /Applications/Docker.app"
fi

# Remove Docker CLI and related binaries (comprehensive paths)
safe_remove_binary "/usr/local/bin/docker"
safe_remove_binary "/usr/local/bin/docker-compose"
safe_remove_binary "/usr/local/bin/docker-credential-desktop"
safe_remove_binary "/usr/local/bin/docker-credential-osxkeychain"
safe_remove_binary "/usr/local/bin/hub-tool"
safe_remove_binary "/usr/local/bin/kubectl.docker"

# Remove Homebrew Docker installations
safe_remove_binary "/opt/homebrew/bin/docker"
safe_remove_binary "/opt/homebrew/bin/docker-compose"
safe_remove_binary "/usr/local/Homebrew/bin/docker"
safe_remove_binary "/usr/local/Homebrew/bin/docker-compose"

# Remove additional Docker binaries
safe_remove_binary "/usr/bin/docker"
safe_remove_binary "/usr/bin/docker-compose"

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

# Final verification - check if Docker is actually removed
log "Performing final verification..."

ERRORS_FOUND=0

# Check if Docker Desktop app still exists
if [ -d "/Applications/Docker.app" ]; then
    log "ERROR: Docker Desktop application still exists at /Applications/Docker.app"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
else
    log "VERIFIED: Docker Desktop application removed"
fi

# Check if docker command still exists
if command -v docker >/dev/null 2>&1; then
    DOCKER_PATH=$(which docker)
    log "ERROR: Docker command still exists at $DOCKER_PATH"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
else
    log "VERIFIED: Docker command removed"
fi

# Check if Docker processes are still running
if pgrep -f docker >/dev/null 2>&1; then
    log "ERROR: Docker processes still running"
    pgrep -f docker | while read -r pid; do
        log "Running Docker process PID: $pid"
    done
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
else
    log "VERIFIED: No Docker processes running"
fi

# Final result
if [ $ERRORS_FOUND -eq 0 ]; then
    log "SUCCESS: Docker Desktop uninstallation completed successfully"
    log "All Docker components have been verified as removed"
else
    log "FAILURE: Docker Desktop uninstallation failed with $ERRORS_FOUND errors"
    log "Some Docker components still exist on the system"
    exit 1
fi

log "Please restart your computer to ensure all changes take effect."
log "Check the log file at $LOG_FILE for detailed uninstallation information."
