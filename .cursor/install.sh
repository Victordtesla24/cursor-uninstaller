#!/bin/sh
set -e

echo "--- Running install script ---"

# Install root dependencies
echo "Installing root dependencies..."
npm install

# Install dashboard dependencies
echo "Installing ui/dashboard dependencies..."
if [ -d "ui/dashboard" ]; then
  cd ui/dashboard
  npm install
  cd ..
else
  echo "Warning: ui/dashboard directory not found. Skipping dashboard dependencies."
fi

echo "--- Install script finished ---"

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
