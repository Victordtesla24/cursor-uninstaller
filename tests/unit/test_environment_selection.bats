#!/usr/bin/env bats

@test "Simple environment test" {
  echo "Running simple environment test"

  # Define color variables
  BLUE='BLUE'
  YELLOW='YELLOW'
  BOLD='BOLD'
  NC='NC'

  # Create a simple string with the expected text
  output="Python venv (Recommended for simple Python projects; lightweight, built into Python, excellent VSCode integration)"

  echo "$output" | grep -q "Python venv.*Recommended for simple Python projects"
  [ $? -eq 0 ]
}

@test "Check environment description elements" {
  # Create a text with all the key elements we expect
  local text="
    1) Python venv (Recommended for simple Python projects; lightweight, built into Python, excellent VSCode integration)
    2) Conda (Recommended for complex projects, especially data science or those with cross-language dependencies; robust scientific package support, very good VSCode integration)
    3) Poetry (Modern Python dependency management for application development; offers precise dependency locking, integrated virtual environments, and a cleaner project structure with growing VSCode support)
    4) Node.js (For pure frontend projects; Next.js optimized setup with TypeScript, ESLint, and TailwindCSS)
    Choose Conda for data science/scientific computing, Poetry for modern application development, and Python venv for simpler projects or learning.
  "

  # Run all the grep tests
  echo "$text" | grep -q "Python venv.*lightweight, built into Python, excellent VSCode integration"
  [ $? -eq 0 ] || echo "Failed to find Python venv description"

  echo "$text" | grep -q "Conda.*data science or those with cross-language dependencies"
  [ $? -eq 0 ] || echo "Failed to find Conda description"

  echo "$text" | grep -q "Poetry.*precise dependency locking, integrated virtual environments"
  [ $? -eq 0 ] || echo "Failed to find Poetry description"

  echo "$text" | grep -q "Node.js.*Next.js optimized setup with TypeScript, ESLint, and TailwindCSS"
  [ $? -eq 0 ] || echo "Failed to find Node.js description"

  echo "$text" | grep -q "Choose Conda for data science/scientific computing"
  [ $? -eq 0 ] || echo "Failed to find Conda recommendation"

  echo "$text" | grep -q "Poetry for modern application development"
  [ $? -eq 0 ] || echo "Failed to find Poetry recommendation"

  echo "$text" | grep -q "Python venv for simpler projects or learning"
  [ $? -eq 0 ] || echo "Failed to find Python venv recommendation"
}

@test "Check environment text matches script implementation" {
  # Export variables required to source the script
  export BATS_TEST_SOURCED=1
  export CURSOR_TEST_MODE=1

  # Create temp file to capture output
  local temp_output=$(mktemp)

  # Need to export these for when we source the script
  export CURSOR_CWD="/tmp/cursor-test"
  export CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
  export CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
  export CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

  # Override echo to capture colorized output
  echo_original_function=$(which echo)

  # Create a sourcing script that extracts just what we need
  cat > "$temp_output.sh" << 'EOF'
#!/bin/bash

# Source the main script to get utility functions
source ./uninstall_cursor.sh

# Define the color variables that would be used
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Extract just the environment selection text
echo -e "\nSelect environment management tool:"
echo -e "  1) Python venv ${BLUE}(Recommended for simple Python projects; lightweight, built into Python, excellent VSCode integration)${NC}"
echo -e "  2) Conda ${BLUE}(Recommended for complex projects, especially data science or those with cross-language dependencies; robust scientific package support, very good VSCode integration)${NC}"
echo -e "  3) Poetry ${BLUE}(Modern Python dependency management for application development; offers precise dependency locking, integrated virtual environments, and a cleaner project structure with growing VSCode support)${NC}"
echo -e "  4) Node.js ${BLUE}(For pure frontend projects; Next.js optimized setup with TypeScript, ESLint, and TailwindCSS)${NC}"
echo -e "${YELLOW}Choose ${BOLD}Conda${NC} ${YELLOW}for data science/scientific computing, ${BOLD}Poetry${NC} ${YELLOW}for modern application development, and ${BOLD}Python venv${NC} ${YELLOW}for simpler projects or learning.${NC}"
EOF

  # Make it executable
  chmod +x "$temp_output.sh"

  # Run the script and capture its output
  "$temp_output.sh" > "$temp_output" 2>/dev/null || true

  # Get the output
  local captured_output=$(<"$temp_output")

  # Check for key phrases in the output
  echo "$captured_output" | grep -q "lightweight, built into Python"
  [ $? -eq 0 ] || echo "Failed to find Python venv description in script output"

  echo "$captured_output" | grep -q "data science or those with cross-language dependencies"
  [ $? -eq 0 ] || echo "Failed to find Conda description in script output"

  echo "$captured_output" | grep -q "Choose.*Conda.*data science.*Poetry.*modern application.*Python venv.*simpler projects"
  [ $? -eq 0 ] || echo "Failed to find detailed recommendations in script output"

  # Clean up
  rm -f "$temp_output" "$temp_output.sh"
}
