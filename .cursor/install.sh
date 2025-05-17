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

# Display completion message
echo "Environment setup complete! You can now run the dashboard with 'npm run dashboard'"
