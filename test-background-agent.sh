#!/bin/bash

# Test Background Agent setup
echo "Testing Background Agent Setup..."

# Required files to check
ENV_JSON=".cursor/environment.json"
INSTALL_SCRIPT=".cursor/install.sh"
DOCKERFILE=".cursor/Dockerfile"
UNINSTALL_SCRIPT="./uninstall_cursor.sh"
BACKGROUND_PROMPT=".cursor/background-agent-prompt.md"

# Check if environment.json exists
if [ -f "$ENV_JSON" ]; then
    echo "✅ environment.json exists"
else
    echo "❌ environment.json is missing"
fi

# Check if install.sh exists and is executable
if [ -f "$INSTALL_SCRIPT" ] && [ -x "$INSTALL_SCRIPT" ]; then
    echo "✅ install.sh exists and is executable"
else
    echo "❌ install.sh is missing or not executable"
fi

# Check if Dockerfile exists
if [ -f "$DOCKERFILE" ]; then
    echo "✅ Dockerfile exists"
else
    echo "❌ Dockerfile is missing"
fi

# Check if uninstall_cursor.sh exists and is executable
if [ -f "$UNINSTALL_SCRIPT" ] && [ -x "$UNINSTALL_SCRIPT" ]; then
    echo "✅ uninstall_cursor.sh exists and is executable"
else
    echo "❌ uninstall_cursor.sh is missing or not executable"
fi

# Check if background agent prompt exists
if [ -f "$BACKGROUND_PROMPT" ]; then
    echo "✅ background-agent-prompt.md exists"
else
    echo "❌ background-agent-prompt.md is missing"
fi

# Check if the dashboard service is running on port 3000
if nc -z localhost 3000 2>/dev/null; then
    echo "✅ Dashboard service is accessible on port 3000"
else
    echo "⚠️ Dashboard service is not accessible on port 3000"
fi

# Check if the git repository is correctly configured
if git remote -v | grep -q "https://github.com/Victordtesla24/cursor-uninstaller.git"; then
    echo "✅ Git repository is configured correctly"
else
    echo "❌ Git repository is not correctly configured"
fi

# Overall status
if [ -f "$ENV_JSON" ] && [ -f "$INSTALL_SCRIPT" ] && [ -x "$INSTALL_SCRIPT" ] && [ -f "$DOCKERFILE" ] && [ -f "$UNINSTALL_SCRIPT" ] && [ -x "$UNINSTALL_SCRIPT" ] && [ -f "$BACKGROUND_PROMPT" ] && git remote -v | grep -q "https://github.com/Victordtesla24/cursor-uninstaller.git"; then
    echo -e "\nBackground Agent Setup Status: ✅ COMPLETE"
    echo "The Background Agent should be properly configured."
else
    echo -e "\nBackground Agent Setup Status: ❌ INCOMPLETE"
    echo "Please check the errors above and fix the configuration."
fi
