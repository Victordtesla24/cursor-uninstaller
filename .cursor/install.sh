#!/bin/bash

# Display initial message
echo "Setting up cursor-uninstaller environment..."

# Install dependencies
npm install

# Install dashboard dependencies
echo "Installing dashboard dependencies..."
cd ui/dashboard && npm install
cd ../..

# Make sure the uninstall script is executable
chmod +x ./uninstall_cursor.sh

# Setup background agent protocol directories if they don't exist
mkdir -p .cursor/rules

# Verify background agent prompt configuration
if [ -f .cursor/background-agent-prompt.md ]; then
  echo "Background agent prompt is configured."
else
  echo "Warning: Background agent prompt configuration is missing."
fi

# Display completion message
echo "Environment setup complete! You can now run the dashboard with 'npm run dashboard'"
