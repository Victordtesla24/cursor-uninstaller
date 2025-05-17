#!/bin/bash
set -e

echo "--- Running Background Agent install.sh ---"
echo "Current directory: $(pwd)"
echo "User: $(whoami)"
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"

# Install root dependencies
if [ -f "package.json" ]; then
  echo "Root package.json found. Running npm install in root..."
  npm install
  echo "Root npm install completed."
else
  echo "No root package.json found. Skipping npm install in root."
fi

# Install ui/dashboard dependencies and optimize
DASHBOARD_DIR="ui/dashboard"
if [ -d "$DASHBOARD_DIR" ]; then
  echo "Changing to $DASHBOARD_DIR directory..."
  cd "$DASHBOARD_DIR"
  if [ -f "package.json" ]; then
    echo "Dashboard package.json found. Running npm install in $DASHBOARD_DIR..."
    npm install
    echo "Dashboard npm install completed."

    echo "Running npx vite optimize --force in $DASHBOARD_DIR..."
    npx vite optimize --force
    echo "Vite optimization completed."
  else
    echo "No package.json found in $DASHBOARD_DIR. Skipping dashboard setup."
  fi
  echo "Changing back to root directory..."
  cd "$OLDPWD" # Go back to the previous directory (project root)
else
  echo "$DASHBOARD_DIR directory not found. Skipping dashboard setup."
fi

echo "--- install.sh finished ---"
