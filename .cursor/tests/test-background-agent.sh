#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

echo "Testing Background Agent Setup..."
echo "------------------------------------"

REPO_ROOT=$(git rev-parse --show-toplevel)
CURSOR_DIR="$REPO_ROOT/.cursor"
ENV_JSON="$CURSOR_DIR/environment.json"
INSTALL_SH="$CURSOR_DIR/install.sh"
DOCKERFILE="$REPO_ROOT/Dockerfile"
AGENT_PROMPT="$CURSOR_DIR/background-agent-prompt.md"

# Initialize error count
error_count=0

# Function to print success
print_success() {
  echo "✅ $1"
}

# Function to print error
print_error() {
  echo "❌ $1"
  error_count=$((error_count + 1))
}

# 1. Check existence of critical configuration files
if [ -f "$ENV_JSON" ]; then print_success "$ENV_JSON exists"; else print_error "$ENV_JSON missing"; fi
if [ -f "$INSTALL_SH" ]; then print_success "$INSTALL_SH exists"; else print_error "$INSTALL_SH missing"; fi
if [ -f "$DOCKERFILE" ]; then print_success "$DOCKERFILE exists"; else print_error "$DOCKERFILE missing"; fi
if [ -f "$AGENT_PROMPT" ]; then print_success "$AGENT_PROMPT exists"; else print_error "$AGENT_PROMPT missing"; fi

# 2. Check executability of install.sh
if [ -x "$INSTALL_SH" ]; then print_success "$INSTALL_SH is executable"; else print_error "$INSTALL_SH not executable"; fi

# 3. Validate Dockerfile content (basic checks)
if [ -f "$DOCKERFILE" ]; then
  if ! grep -q "COPY .* \./" "$DOCKERFILE" && ! grep -q "COPY .*\./" "$DOCKERFILE" && ! grep -Eq "COPY[[:space:]]+\.[[:space:]]+" "$DOCKERFILE"; then
    print_success "$DOCKERFILE does not appear to COPY project root (as per docs)"
  else
    print_error "$DOCKERFILE seems to COPY project files (e.g. 'COPY . .'), which is not recommended by Cursor docs for agents."
  fi
  if grep -q "apk add .*git" "$DOCKERFILE" || grep -q "apt-get .*install .*git" "$DOCKERFILE"; then
    print_success "$DOCKERFILE installs git (good for agent cloning)"
  else
    print_error "$DOCKERFILE does not appear to install git."
  fi
  if grep -q "FROM node:" "$DOCKERFILE"; then
    print_success "$DOCKERFILE uses a Node.js base image."
  else
    print_error "$DOCKERFILE does not seem to use a Node.js base image."
  fi
else
  echo "ℹ️ $DOCKERFILE not found, skipping content validation."
fi

# 4. Validate environment.json content (basic checks using jq if available)
if [ -f "$ENV_JSON" ] && command -v jq &> /dev/null; then
  if jq -e '.build.dockerfile == "Dockerfile"' "$ENV_JSON" > /dev/null; then print_success "$ENV_JSON: build.dockerfile is 'Dockerfile'"; else print_error "$ENV_JSON: build.dockerfile is not 'Dockerfile'"; fi
  if jq -e '.install | length > 0' "$ENV_JSON" > /dev/null; then print_success "$ENV_JSON: 'install' command is present"; else print_error "$ENV_JSON: 'install' command is missing or empty"; fi
  if jq -e '(.terminals | length > 0) or (.start | length > 0)' "$ENV_JSON" > /dev/null; then print_success "$ENV_JSON: 'terminals' or 'start' command is present"; else print_error "$ENV_JSON: Neither 'terminals' nor 'start' command is present/configured"; fi
  if jq -e '.user | length > 0' "$ENV_JSON" > /dev/null; then print_success "$ENV_JSON: 'user' is specified"; else print_error "$ENV_JSON: 'user' is not specified (e.g., 'node' or 'ubuntu')"; fi
elif [ -f "$ENV_JSON" ]; then
  echo "ℹ️ jq is not installed. Skipping detailed $ENV_JSON content validation. Basic grep checks:"
  if grep -q '"dockerfile": "Dockerfile"' "$ENV_JSON"; then print_success "$ENV_JSON: contains '\"dockerfile\": \"Dockerfile\"'"; else print_error "$ENV_JSON: missing '\"dockerfile\": \"Dockerfile\"'"; fi
  if grep -q '"install":' "$ENV_JSON"; then print_success "$ENV_JSON: contains 'install' key"; else print_error "$ENV_JSON: missing 'install' key"; fi
else
  echo "ℹ️ $ENV_JSON not found, skipping content validation."
fi

# 5. Validate install.sh content (basic checks)
if [ -f "$INSTALL_SH" ]; then
  if grep -q "npm install" "$INSTALL_SH"; then
    print_success "$INSTALL_SH contains 'npm install' (good for dependencies)"
  else
    print_error "$INSTALL_SH does not seem to run 'npm install'."
  fi
  if ! grep -q "uninstall_cursor.sh" "$INSTALL_SH"; then
    print_success "$INSTALL_SH does not try to manage uninstall_cursor.sh (correct)"
  else
    print_error "$INSTALL_SH should not manage uninstall_cursor.sh"
  fi
else
  echo "ℹ️ $INSTALL_SH not found, skipping content validation."
fi


# 6. Check for Git repository configuration (unchanged from original)
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    print_success "Git repository is configured correctly"
else
    print_error "Not a Git repository or Git is not configured"
fi


echo "------------------------------------"
if [ "$error_count" -eq 0 ]; then
  echo "Background Agent Setup Status: ✅ PRELIMINARY CHECKS PASSED"
  echo "The Background Agent configuration files seem to align with Cursor documentation."
  echo "Further testing involves the agent successfully cloning, installing dependencies, and running tasks."
else
  echo "Background Agent Setup Status: ❌ $error_count PRELIMINARY CHECK(S) FAILED"
  echo "Please review the errors above."
fi
echo "------------------------------------"

# Attempt to check if the dashboard service *could* be started by the agent
# This is an OPTIONAL check and might not always be reliable or necessary
# for agent *configuration* validity.
echo "Attempting to check if dashboard service is accessible on port 3000 (this may take a moment)..."
if nc -z localhost 3000; then
    print_success "✅ Dashboard service is accessible on port 3000"
else
    echo "⚠️ Dashboard service is not accessible on port 3000"
fi
