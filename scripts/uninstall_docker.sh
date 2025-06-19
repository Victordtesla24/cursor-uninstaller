#!/bin/bash

# Docker Uninstaller Script for macOS
# Created: June 20, 2025
# Description: This script completely removes Docker and all its components from macOS

# Function to check for sudo privileges
check_sudo() {
    if [[ "$(id -u)" -ne 0 ]]; then
        echo "This script requires root privileges. Please run with sudo."
        exit 1
    fi
}

echo "=== Docker Uninstaller for macOS ==="
echo "This script will completely remove Docker from your system."
echo "Please make sure Docker is not running before proceeding."
echo "WARNING: This will remove all Docker containers, images, and volumes!"
read -r -p "Continue? (y/n): " confirm

if [[ "$confirm" != "y" ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Check for sudo privileges after user confirmation
check_sudo

echo "=== Checking for Docker installations ==="
docker_desktop_app="/Applications/Docker.app"
docker_cli_path="/usr/local/bin/docker"
docker_user_data_dir="$HOME/.docker"

if [[ -d "$docker_desktop_app" ]]; then
    echo "Docker Desktop application found at: $docker_desktop_app"
else
    echo "Docker Desktop application not found."
fi

if [[ -f "$docker_cli_path" ]]; then
    echo "Docker CLI binary found at: $docker_cli_path"
else
    echo "Docker CLI binary not found."
fi

if [[ -d "$docker_user_data_dir" ]]; then
    echo "Docker user data directory found at: $docker_user_data_dir"
else
    echo "Docker user data directory not found."
fi

if pgrep -q -f "Docker Desktop"; then
    echo "Docker Desktop is currently running."
else
    echo "Docker Desktop is not running."
fi

echo "=== Stopping Docker processes ==="
# Quit Docker if it's running
osascript -e 'quit app "Docker"' &>/dev/null
killall "Docker Desktop" &>/dev/null
killall Docker &>/dev/null # For older versions or other Docker processes

echo "=== Removing Docker Desktop (if installed) ==="
# Try Docker's own uninstaller first
if [ -f "/Applications/Docker.app/Contents/MacOS/uninstall" ]; then
    echo "Running Docker's built-in uninstaller..."
    sudo /Applications/Docker.app/Contents/MacOS/uninstall # Keep sudo here as it's an external executable
fi

echo "=== Removing Docker app bundle ==="
# Remove the application bundle
rm -rf /Applications/Docker.app

echo "=== Removing Docker icon from Dock ==="
# Remove Docker icon from the Dock
defaults delete com.apple.dock persistent-apps &>/dev/null
defaults delete com.apple.dock persistent-others &>/dev/null
killall Dock &>/dev/null

echo "=== Removing Homebrew installations (if any) ==="
# Check if Homebrew is installed before trying to use it
if command -v brew &>/dev/null; then
    echo "Homebrew detected. Attempting to uninstall Docker components via Homebrew..."
    brew uninstall --cask docker &>/dev/null
    brew uninstall docker docker-compose docker-machine &>/dev/null
else
    echo "Homebrew not detected. Skipping Homebrew uninstallation."
fi

echo "=== Removing user-level Docker data ==="
# Remove user-level data
rm -rf "$HOME/.docker"
rm -rf "$HOME/Library/Containers/com.docker.docker"
rm -rf "$HOME/Library/Group Containers/group.com.docker"

echo "=== Removing application support files, caches and preferences ==="
# Delete application support, caches and preferences
rm -rf "$HOME/Library/Application Support/Docker Desktop"
rm -rf "$HOME/Library/Caches/com.docker.docker"
rm -rf "$HOME/Library/Preferences/com.docker.docker.plist"
rm -rf "$HOME/Library/Saved Application State/com.electron.docker-frontend.savedState"

echo "=== Removing command-line tools and frameworks ==="
# Remove command-line tools and frameworks
rm -f /usr/local/bin/docker
rm -f /usr/local/bin/docker-compose
rm -f /usr/local/bin/docker-machine
rm -f /usr/local/bin/docker-credential-*
rm -rf /usr/local/lib/docker

echo "=== Removing privileged helpers ==="
# Remove privileged helpers
rm -rf /Library/PrivilegedHelperTools/com.docker.vmnetd
rm -f /Library/LaunchDaemons/com.docker.vmnetd.plist

echo "=== Removing additional Docker components ==="
# Remove any other Docker-related files that might be left
rm -rf /private/var/tmp/com.docker.docker
rm -rf /private/var/run/docker*

echo "=== Verifying cleanup ==="
cleanup_successful=true

if [[ -d "$docker_desktop_app" ]]; then
    echo "Verification: Docker Desktop application still present at: $docker_desktop_app"
    cleanup_successful=false
else
    echo "Verification: Docker Desktop application removed successfully."
fi

if [[ -f "$docker_cli_path" ]]; then
    echo "Verification: Docker CLI binary still present at: $docker_cli_path"
    cleanup_successful=false
else
    echo "Verification: Docker CLI binary removed successfully."
fi

if [[ -d "$docker_user_data_dir" ]]; then
    echo "Verification: Docker user data directory still present at: $docker_user_data_dir"
    cleanup_successful=false
else
    echo "Verification: Docker user data directory removed successfully."
fi

# Check for running Docker processes
if pgrep -q -f "Docker Desktop"; then
    echo "Verification: Docker Desktop processes are still running."
    cleanup_successful=false
else
    echo "Verification: No Docker Desktop processes found running."
fi

if [[ "$cleanup_successful" == true ]]; then
    echo "=== Docker uninstallation complete and verified successfully! ==="
else
    echo "=== Docker uninstallation complete, but some components may remain. Please review the verification steps above. ==="
fi

echo "Docker has been completely removed from your system (or as much as possible)."
