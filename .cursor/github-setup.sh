#!/bin/bash

# Simple GitHub Setup Script
# Uses credentials from .env file for git operations

set -e

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
elif [ -f "../.env" ]; then
    export $(grep -v '^#' ../.env | xargs)
fi

# Set defaults if not provided
GITHUB_USERNAME=${GITHUB_USERNAME:-"Victordtesla24"}
GITHUB_REPO_URL=${GITHUB_REPO_URL:-"https://github.com/Victordtesla24/cursor-uninstaller.git"}

echo "Setting up git repository..."

# Configure git user
git config --global user.name "${GITHUB_USERNAME}"
git config --global user.email "${GITHUB_USERNAME}@users.noreply.github.com"

# Add or update remote origin
if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "${GITHUB_REPO_URL}"
    echo "Updated remote origin: ${GITHUB_REPO_URL}"
else
    git remote add origin "${GITHUB_REPO_URL}"
    echo "Added remote origin: ${GITHUB_REPO_URL}"
fi

echo "Git setup completed." 