#!/bin/bash
# This script helps with creating a snapshot for Cursor Background Agent
# It can be run manually in the interactive setup environment to prepare the snapshot.

set -e

echo "=== Cursor Background Agent Snapshot Preparation ==="
echo "This script prepares the environment for snapshot creation."
echo "Run this in the interactive setup environment provided by Cursor."

# Install essential tools
echo "Installing essential tools..."
sudo apt-get update && sudo apt-get install -y \
    git \
    curl \
    wget \
    jq \
    tmux \
    vim \
    build-essential \
    nodejs \
    npm \
    ca-certificates \
    gnupg \
    bash \
    procps \
    lsof \
    net-tools

# Install Node.js via NVM (alternative approach)
echo "Installing NVM and Node.js (latest LTS)..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

# Install global npm packages
echo "Installing global npm packages..."
npm install -g npm@latest vite

# Set up git configuration
echo "Configuring git..."
git config --global user.email "background-agent@cursor.sh"
git config --global user.name "Cursor Background Agent"
git config --global credential.helper 'cache --timeout=3600'

# Create workspace directory
echo "Creating workspace directory..."
sudo mkdir -p /agent_workspace
sudo chown -R $(whoami):$(whoami) /agent_workspace

# Create npm global directory for non-root user
echo "Setting up npm global directory..."
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global

# Document the environment for snapshot reference
echo "Documenting environment state..."
{
  echo "--- Environment Documentation for Snapshots ---"
  echo "Date: $(date)"
  echo "Node version: $(node -v)"
  echo "NPM version: $(npm -v)"
  echo "Global NPM packages:"
  npm list -g --depth=0
  echo "Disk usage:"
  df -h .
  echo "Git configuration:"
  git config --list
  echo "----------------------------------------"
} > environment-snapshot-info.txt

# Create a sample environment-snapshot.json file
echo "Creating a sample environment-snapshot.json file..."
cat > environment-snapshot.json << 'EOF'
{
  "$schema": "https://json-schema.org/draft/2019-09/schema",
  "snapshot": "REPLACE_WITH_SNAPSHOT_ID_FROM_CURSOR_UI",
  "user": "node",
  "install": "./.cursor/install.sh",
  "start": "echo 'Background agent environment started.' && if command -v docker &> /dev/null; then sudo service docker start || true; fi",
  "terminals": [
    {
      "name": "dashboard_dev_server",
      "command": "cd ui/dashboard && npm run dev -- --host --no-open",
      "description": "Runs the UI dashboard development server. Access it via the port Vite announces (usually 3000 or 5173 if 3000 is taken)."
    },
    {
      "name": "agent_validation",
      "command": "echo 'Running validation tests...' && bash ./test-background-agent.sh || echo 'Validation tests completed with status: $?'",
      "description": "Validates the background agent configuration files."
    },
    {
      "name": "runtime_validation",
      "command": "echo 'Running runtime validation...' && bash ./test-agent-runtime.sh || echo 'Runtime validation completed with status: $?'",
      "description": "Validates the background agent runtime environment."
    },
    {
      "name": "git_status",
      "command": "git config --list && echo '----- Repository Status -----' && git status && echo '----- Branches -----' && git branch -a",
      "description": "Displays git configuration and repository status for debugging purposes."
    }
  ]
}
EOF

echo "=== Environment is now ready for snapshot ==="
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"
echo ""
echo "In the Cursor setup UI, you can now take a snapshot."
echo "This snapshot will be used for future background agents."
echo ""
echo "IMPORTANT NEXT STEPS:"
echo "1. Take a snapshot in the Cursor UI"
echo "2. Replace REPLACE_WITH_SNAPSHOT_ID_FROM_CURSOR_UI in environment-snapshot.json with the actual snapshot ID"
echo "3. Rename environment-snapshot.json to .cursor/environment.json if you want to use the snapshot approach"
echo "   instead of the Dockerfile approach" 