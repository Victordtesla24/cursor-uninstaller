#!/bin/bash

# Test Background Agent setup
echo "Testing Background Agent Setup..."

# Check if the environment.json file exists
if [ -f ".cursor/environment.json" ]; then
  echo "✅ environment.json exists"
else
  echo "❌ environment.json not found"
  exit 1
fi

# Check if install.sh exists and is executable
if [ -f ".cursor/install.sh" ] && [ -x ".cursor/install.sh" ]; then
  echo "✅ install.sh exists and is executable"
else
  echo "❌ install.sh not found or not executable"
  exit 1
fi

# Check if Dockerfile exists
if [ -f "Dockerfile" ]; then
  echo "✅ Dockerfile exists"
else
  echo "❌ Dockerfile not found"
  exit 1
fi

# Check if uninstall_cursor.sh exists and is executable
if [ -f "uninstall_cursor.sh" ] && [ -x "uninstall_cursor.sh" ]; then
  echo "✅ uninstall_cursor.sh exists and is executable"
else
  echo "❌ uninstall_cursor.sh not found or not executable"
  exit 1
fi

# Check if dashboard service is running
if curl -s --head http://localhost:3000 | grep "200 OK" > /dev/null; then
  echo "✅ Dashboard service is running on port 3000"
else
  echo "⚠️ Dashboard service is not accessible on port 3000"
fi

# Check if Git repository is configured
if git config --get remote.origin.url | grep "github.com" > /dev/null; then
  echo "✅ Git repository is configured correctly"
else
  echo "❌ Git repository is not configured correctly"
  exit 1
fi

echo ""
echo "Background Agent Setup Status: ✅ COMPLETE"
echo "The Background Agent should be properly configured." 