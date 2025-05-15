#!/bin/bash

# Installation script for cursor-uninstaller project
echo "Setting up cursor-uninstaller environment..."

# Install project dependencies
npm install

# Install dashboard dependencies
if [ -d "ui/dashboard" ]; then
  echo "Installing dashboard dependencies..."
  cd ui/dashboard && npm install
  cd ../..
fi

# Make uninstaller script executable
chmod +x ./uninstall_cursor.sh

echo "Environment setup complete! You can now run the dashboard with 'npm run dashboard'" 