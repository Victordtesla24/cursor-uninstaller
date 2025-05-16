#!/bin/bash

# set -e # We'll handle errors locally for more informative output

echo "--- Starting Background Agent Runtime Test ---"

REPO_ROOT=$(git rev-parse --show-toplevel)
CURSOR_DIR="$REPO_ROOT/.cursor"
DOCKERFILE_PATH="$CURSOR_DIR/Dockerfile"
ENV_JSON_PATH="$CURSOR_DIR/environment.json"
INSTALL_SH_PATH_RELATIVE=".cursor/install.sh" # Relative to repo root for execution inside container

IMAGE_NAME="cursor-agent-test-env:latest"
CONTAINER_NAME_BASE="cursor-agent-test-container" # Base name for containers

error_count=0
jq_available=false
if command -v jq &> /dev/null; then
  jq_available=true
fi

# Function to print success
print_success() {
  echo "✅ $1"
}

# Function to print error
print_error() {
  echo "❌ $1"
  error_count=$((error_count + 1))
}

# Function to print info
print_info() {
  echo "ℹ️ $1"
}

cleanup() {
  print_info "Cleaning up any stray Docker containers..."
  # Clean up any containers that might have been left running from previous tests
  docker ps -a --filter "name=${CONTAINER_NAME_BASE}" -q | xargs -r docker rm -f >/dev/null 2>&1
}
trap cleanup EXIT INT TERM # Ensure cleanup runs on script exit or interruption

# --- Static Configuration Checks ---
print_info "Performing static configuration file checks..."
# (These checks remain largely the same as your current script, simplified here for brevity)
if [ ! -f "$ENV_JSON_PATH" ]; then print_error "$ENV_JSON_PATH missing"; error_count=$((error_count + 1)); fi
if [ ! -f "$REPO_ROOT/$INSTALL_SH_PATH_RELATIVE" ]; then print_error "$REPO_ROOT/$INSTALL_SH_PATH_RELATIVE missing"; error_count=$((error_count + 1)); fi
if [ ! -f "$DOCKERFILE_PATH" ]; then print_error "$DOCKERFILE_PATH missing"; error_count=$((error_count + 1)); fi

if [ "$error_count" -gt 0 ]; then
  print_error "Critical static configuration file(s) missing. Aborting runtime test."
  exit 1
fi

if $jq_available; then
  AGENT_USER_JSON=$(jq -r '.user // "node"' "$ENV_JSON_PATH")
  INSTALL_COMMAND_JSON=$(jq -r '.install // ""' "$ENV_JSON_PATH")
  FIRST_TERMINAL_COMMAND_JSON=$(jq -r '.terminals[0].command // empty' "$ENV_JSON_PATH")

  if [ "$AGENT_USER_JSON" != "node" ]; then print_error "$ENV_JSON_PATH: 'user' is not 'node' (current: $AGENT_USER_JSON)."; fi
  if [ "$INSTALL_COMMAND_JSON" != "$INSTALL_SH_PATH_RELATIVE" ]; then print_error "$ENV_JSON_PATH: 'install' command is not '$INSTALL_SH_PATH_RELATIVE'."; fi
  if [ -z "$FIRST_TERMINAL_COMMAND_JSON" ]; then print_error "$ENV_JSON_PATH: No terminal commands configured."; fi

  AGENT_USER="$AGENT_USER_JSON"
  INSTALL_COMMAND="$INSTALL_COMMAND_JSON"
  FIRST_TERMINAL_COMMAND="$FIRST_TERMINAL_COMMAND_JSON"

  # Determine VITE_PORT
  VITE_PORT=""
  # Try to extract from command: e.g., npm run dev -- --port 3001
  if [ -n "$FIRST_TERMINAL_COMMAND" ]; then
    VITE_PORT_FROM_CMD=$(echo "$FIRST_TERMINAL_COMMAND" | sed -n 's/.*--port[[:space:]]\{1,\}\([0-9]\{4,5\}\).*/\1/p')
  fi

  if [ -n "$VITE_PORT_FROM_CMD" ]; then
      VITE_PORT="$VITE_PORT_FROM_CMD"
  elif [ -f "$REPO_ROOT/ui/dashboard/vite.config.js" ]; then
      # Try to extract from vite.config.js: e.g., server: { port: 3000 }
      VITE_PORT_FROM_CONFIG=$(grep 'port:' "$REPO_ROOT/ui/dashboard/vite.config.js" | sed -n 's/.*port:[[:space:]]*\([0-9]\{4,5\}\).*/\1/p' | head -n 1)
      if [ -n "$VITE_PORT_FROM_CONFIG" ]; then
          VITE_PORT="$VITE_PORT_FROM_CONFIG"
      fi
  fi
else
  print_info "jq not found. Using default assumptions for environment.json values and skipping detailed validation."
  AGENT_USER="node"
  FIRST_TERMINAL_COMMAND="cd ui/dashboard && npx vite optimize --force && npm run dev -- --host --no-open"
fi

# Default if not found or jq not available
if [ -z "$VITE_PORT" ]; then
    print_info "Vite port not explicitly found in command or vite.config.js, defaulting to 3000."
    VITE_PORT="3000"
fi
print_info "Will use Vite port: $VITE_PORT for checks."

if [ "$error_count" -gt 0 ]; then
  print_error "Static configuration validation failed. Aborting runtime test."
  exit 1
else
  print_success "Static configuration files appear valid."
fi
echo "------------------------------------"

# --- Docker Image Build ---
print_info "Building Docker image: $IMAGE_NAME from $DOCKERFILE_PATH..."
if docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" "$REPO_ROOT"; then
  print_success "Docker image '$IMAGE_NAME' built successfully."
else
  print_error "Docker image build failed."
  exit 1
fi
echo "------------------------------------"

# --- Agent Runtime Simulation in Docker ---
print_info "Starting agent runtime simulation..."
PERM_CONTAINER_NAME="${CONTAINER_NAME_BASE}-permcheck"
INSTALL_CONTAINER_NAME="${CONTAINER_NAME_BASE}-install"
TERMINAL_CONTAINER_NAME="${CONTAINER_NAME_BASE}-terminal"

# Check 1: Permissions
print_info "Step 1: Testing write permissions in /agent_workspace for user '$AGENT_USER'..."
if docker run --rm --name "$PERM_CONTAINER_NAME" --user "$AGENT_USER" -v "$REPO_ROOT:/agent_workspace" -w /agent_workspace "$IMAGE_NAME" /bin/sh -c "touch test_write_file.tmp && rm test_write_file.tmp"; then
  print_success "User '$AGENT_USER' has write permissions in /agent_workspace."
else
  print_error "User '$AGENT_USER' FAILED write permission test in /agent_workspace."
fi

# Check 2: Execution of .cursor/install.sh
print_info "Step 2: Executing '$INSTALL_SH_PATH_RELATIVE' (install command) as user '$AGENT_USER'..."
INSTALL_LOG_FILE=$(mktemp)
print_info "Install log will be at: $INSTALL_LOG_FILE"
if docker run --rm --name "$INSTALL_CONTAINER_NAME" --user "$AGENT_USER" -v "$REPO_ROOT:/agent_workspace" -w /agent_workspace "$IMAGE_NAME" /bin/sh -c "./$INSTALL_SH_PATH_RELATIVE" > "$INSTALL_LOG_FILE" 2>&1; then
  print_success "'$INSTALL_SH_PATH_RELATIVE' (install command) executed successfully."
  print_info "Install log output:"
  cat "$INSTALL_LOG_FILE"
else
  print_error "'$INSTALL_SH_PATH_RELATIVE' (install command) FAILED."
  print_info "Install log output (see errors below):"
  cat "$INSTALL_LOG_FILE"
fi
rm -f "$INSTALL_LOG_FILE"


# Check 3: Execution of the first terminal command (e.g., npm run dev)
if [ -n "$FIRST_TERMINAL_COMMAND" ]; then
  print_info "Step 3: Attempting to start first terminal command: '$FIRST_TERMINAL_COMMAND' as user '$AGENT_USER'..."
  LOG_FILE_TERMINAL=$(mktemp)

  print_info "Running '$FIRST_TERMINAL_COMMAND' in foreground for 15 seconds to capture logs..."
  print_info "Terminal command log will be at: $LOG_FILE_TERMINAL"

  # Run the command in the foreground with a timeout.
  # Use a subshell for timeout to ensure the docker command itself is killed.
  ( docker run --rm --name "$TERMINAL_CONTAINER_NAME" --user "$AGENT_USER" \
    -v "$REPO_ROOT:/agent_workspace" -w /agent_workspace \
    -p "$VITE_PORT:$VITE_PORT" -p 5173:5173 \
    "$IMAGE_NAME" /bin/sh -c "$FIRST_TERMINAL_COMMAND" > "$LOG_FILE_TERMINAL" 2>&1 ) &
  FG_PID=$!

  # Wait for up to 15 seconds, checking for Vite's success message in logs
  VITE_STARTED=false
  for i in {1..15}; do
    if ! ps -p $FG_PID > /dev/null; then # Check if process ended
      print_info "Terminal command process ended before 15s timeout."
      break
    fi
    if grep -q -E "Network:|VITE v|ready in|Local:|((Found)|(Found .*ready in))" "$LOG_FILE_TERMINAL"; then # Added more patterns
      print_info "Vite startup signature detected in logs."
      VITE_STARTED=true
      break
    fi
    sleep 1
    echo -n "."
  done
  echo ""

  # Ensure the foreground Docker process is killed if still running
  if ps -p $FG_PID > /dev/null; then
    print_info "Timeout reached or Vite signature not found quickly. Killing foreground Docker process (PID: $FG_PID)..."
    kill $FG_PID >/dev/null 2>&1
    sleep 2 # Give it a moment to die
    if ps -p $FG_PID > /dev/null; then
        print_info "Still running, sending SIGKILL..."
        kill -9 $FG_PID >/dev/null 2>&1
    fi
  fi
  wait $FG_PID 2>/dev/null # Wait for it to be reaped


  print_info "Captured logs for '$FIRST_TERMINAL_COMMAND':"
  cat "$LOG_FILE_TERMINAL"
  echo "--- End of captured logs for terminal command ---"

  if $VITE_STARTED; then
    print_success "Terminal command '$FIRST_TERMINAL_COMMAND' (Vite) appears to have started successfully based on log output."

    print_info "Attempting to check if dashboard service (Vite) is accessible on http://localhost:$VITE_PORT (host)..."
    # For the port check, we need to run the server in detached mode again briefly
    DETACHED_TERMINAL_CONTAINER_NAME="${CONTAINER_NAME_BASE}-terminal-detached"
    docker run -d --rm --name "$DETACHED_TERMINAL_CONTAINER_NAME" --user "$AGENT_USER" \
      -v "$REPO_ROOT:/agent_workspace" -w /agent_workspace \
      -p "$VITE_PORT:$VITE_PORT" -p 5173:5173 \
      "$IMAGE_NAME" /bin/sh -c "$FIRST_TERMINAL_COMMAND" > /dev/null 2>&1

    sleep 8 # Increased wait time for Vite to be ready

    if curl --output /dev/null --silent --head --max-time 5 --fail http://localhost:$VITE_PORT; then
        print_success "Dashboard service (Vite) is ACCESSIBLE on http://localhost:$VITE_PORT."
    else
        print_error "Dashboard service (Vite) is NOT ACCESSIBLE on http://localhost:$VITE_PORT (after 8s wait). Possible issues: Vite not serving on 0.0.0.0, firewall, or other startup error."
    fi
    docker rm -f "$DETACHED_TERMINAL_CONTAINER_NAME" > /dev/null 2>&1 || true
  else
    print_error "Terminal command '$FIRST_TERMINAL_COMMAND' (Vite) did NOT show expected startup signature in logs."
  fi
  rm -f "$LOG_FILE_TERMINAL"
else
  print_info "Step 3: No terminal command found in environment.json to test."
fi

echo "------------------------------------"
if [ "$error_count" -eq 0 ]; then
  print_success "All background agent runtime simulation checks passed!"
else
  print_error "$error_count runtime simulation check(s) FAILED. Review logs above."
fi
echo "--- Background Agent Runtime Test Finished ---"

exit $error_count
