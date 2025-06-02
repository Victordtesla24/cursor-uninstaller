#!/bin/bash

# Test script for git commit functionality
cd /Users/Shared/cursor/cursor-uninstaller

# Source required modules
source lib/config.sh
source lib/helpers.sh
source lib/ui.sh
source modules/git_integration.sh

# Set non-interactive mode
export NON_INTERACTIVE_MODE=true

echo "Testing git commit functionality..."
echo "Current git status:"
git status --short

echo ""
echo "Testing perform_git_commit_and_push function..."
perform_git_commit_and_push

echo ""
echo "Final git status:"
git status --short 