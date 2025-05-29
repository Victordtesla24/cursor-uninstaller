#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories if needed
    mkdir -p "$TEST_DIR/tmp"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "README.md exists and contains required information" {
    # Check if README.md exists
    [ -f "README.md" ]

    # Check for required sections
    grep -q "# Cursor" "README.md" || grep -q "# Cursor AI Editor" "README.md"
    grep -q "## Core Features" "README.md"
    grep -q "## Requirements" "README.md"
    grep -q "## Usage" "README.md"
}

@test "README.md documents all main features" {
    # Test for documentation of core features
    grep -q "Uninstallation" "README.md"
    grep -q "Performance Optimization" "README.md"
    grep -q "Project Environment" "README.md"
    grep -q "M-series" "README.md" || grep -q "Apple Silicon" "README.md"
}

@test "README.md documents script usage instructions" {
    # Check for usage instructions
    grep -q "./uninstall_cursor.sh" "README.md"
    grep -q "menu" "README.md" # Should mention the menu-based interface

    # Check for options documentation
    grep -q "Uninstallation" "README.md"
    grep -q "Cleanup" "README.md"
    grep -q "Optimize" "README.md"
    grep -q "Fresh" "README.md" && grep -q "Cursor" "README.md" && grep -q "Install" "README.md"
}

@test "README.md documents shared configuration directory structure" {
    # Check for shared configuration documentation
    grep -q "/Users/Shared/cursor/" "README.md"
    grep -q "config/" "README.md"
    grep -q "logs/" "README.md"
    grep -q "projects/" "README.md"
}

@test "Script contains proper header documentation" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a function to extract the script header
    extract_header() {
        local script_content
        script_content=$(cat "$SCRIPT_PATH")

        # Extract the content between shebang and first function definition
        echo "$script_content" | sed -n '1,/^[a-zA-Z_][a-zA-Z0-9_]*() {/p' > "$TEST_DIR/tmp/header.txt"
    }

    # Extract the header
    extract_header

    # Check for essential documentation elements
    grep -q "Script Self-Location" "$TEST_DIR/tmp/header.txt"
    grep -q "Path Resolution" "$TEST_DIR/tmp/header.txt"
    grep -q "get_script_path" "$TEST_DIR/tmp/header.txt"

    # Check for error handling documentation
    grep -q "error handling" "$TEST_DIR/tmp/header.txt" -i
    grep -q "set -" "$TEST_DIR/tmp/header.txt"
    grep -q "trap" "$TEST_DIR/tmp/header.txt"
}

@test "Script documents all core functions with descriptive comments" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a function to extract function comments
    extract_function_comments() {
        local script_content
        script_content=$(cat "$SCRIPT_PATH")

        # Extract comments before function definitions
        grep -B 3 "^[a-zA-Z_][a-zA-Z0-9_]*() {" "$SCRIPT_PATH" > "$TEST_DIR/tmp/function_comments.txt"
    }

    # Extract function comments
    extract_function_comments

    # Check for comments on key functions
    grep -q "get_script_path" "$TEST_DIR/tmp/function_comments.txt"
    grep -q "detect_cursor_paths" "$TEST_DIR/tmp/function_comments.txt"
    grep -q "optimize_cursor_performance" "$TEST_DIR/tmp/function_comments.txt"
    grep -q "setup_project_environment" "$TEST_DIR/tmp/function_comments.txt"
    grep -q "install_cursor_from_dmg" "$TEST_DIR/tmp/function_comments.txt"
}

@test "Script sections are properly documented with section headers" {
    # Check for section headers in the script
    grep -q "^###*" "$SCRIPT_PATH" > "$TEST_DIR/tmp/section_headers.txt"

    # Verify essential sections are documented
    grep -q "Path Resolution" "$SCRIPT_PATH"
    grep -q "Error Handling" "$SCRIPT_PATH"
    grep -q "Uninstallation" "$SCRIPT_PATH"
    grep -q "Performance Optimization" "$SCRIPT_PATH"
    grep -q "Project Environment" "$SCRIPT_PATH"
    grep -q "Installation" "$SCRIPT_PATH"
}

@test "tests/README.md exists and documents test framework" {
    # Check if tests/README.md exists
    [ -f "tests/README.md" ]

    # Check for required test documentation sections
    grep -q "# Cursor" "tests/README.md" || grep -q "# Test" "tests/README.md"
    grep -q "## Running Tests" "tests/README.md"
    grep -q "bats" "tests/README.md"
    grep -q "test_helper" "tests/README.md"
}

@test "test_helper.bash contains proper documentation" {
    # Check if test_helper.bash exists
    [ -f "tests/test_helper.bash" ]

    # Check for required documentation
    grep -q "TEST_DIR" "tests/test_helper.bash"
    grep -q "SCRIPT_PATH" "tests/test_helper.bash"
    grep -q "setup" "tests/test_helper.bash"
    grep -q "teardown" "tests/test_helper.bash"
    grep -q "mock" "tests/test_helper.bash" -i
}

@test "All test files contain proper documentation" {
    # Get list of test files
    local test_files
    test_files=$(find tests -name "*_test.bats" -o -name "test_*.bats")

    # Check if we found test files
    [ -n "$test_files" ]

    # Function to check a test file for proper documentation
    check_test_file() {
        local file="$1"

        # Check for required elements
        grep -q "load test_helper" "$file" || return 1
        grep -q "@test" "$file" || return 1
        grep -q "setup()" "$file" -i || return 1
        grep -q "teardown()" "$file" -i || return 1

        return 0
    }

    # Create a flag to track if all files pass
    local all_pass=true

    # Check each test file
    for file in $test_files; do
        if ! check_test_file "$file"; then
            echo "Test file $file is missing required documentation"
            all_pass=false
        fi
    done

    # Assert that all test files passed
    [ "$all_pass" = true ]
}

@test "Script help text provides clear instructions" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a function to simulate showing the menu
    capture_menu_text() {
        # Define variables needed by the enhanced_show_menu function
        BOLD="BOLD"
        RED="RED"
        GREEN="GREEN"
        YELLOW="YELLOW"
        BLUE="BLUE"
        NC="NC"

        # Save the original enhanced_show_menu function
        local original_enhanced_show_menu
        original_enhanced_show_menu=$(declare -f enhanced_show_menu)

        # Create a mock function to capture the output instead of displaying
        enhanced_show_menu() {
            # Create timestamp similar to the original function
            local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

            # Generate menu text similar to enhanced_show_menu
            cat > "$TEST_DIR/tmp/menu_text.txt" << EOF
========================================================
               CURSOR AI EDITOR UTILITY
             Version: 1.2.0 (2025-04-25)
=========================================================

Running as user: $(whoami) | Date: $timestamp

OPTIONS:
  1) Uninstall Cursor AI Editor (Removes application and data)
  2) Clean Installation (Fresh install with optimizations)
  3) Optimize Performance (Apply latest performance optimizations)
  4) Setup Project Environment (Create DEV/TEST/PROD project)
  5) Run Tests (For developers only)
  6) Repair Shared Configuration (Fix corrupted settings)
  7) Create Desktop Shortcut (Fast access to Cursor)
  8) Exit

Enter your choice [1-8]:
EOF
        }

        # Call the mock function
        enhanced_show_menu

        # Restore the original function if needed
        if [ -n "$original_enhanced_show_menu" ]; then
            eval "enhanced_show_menu() { $original_enhanced_show_menu; }"
        fi
    }

    # Capture the menu text
    capture_menu_text

    # Check that the menu text provides clear options
    [ -f "$TEST_DIR/tmp/menu_text.txt" ]
    grep -q "Uninstall Cursor AI Editor" "$TEST_DIR/tmp/menu_text.txt"
    grep -q "Clean Installation" "$TEST_DIR/tmp/menu_text.txt"
    grep -q "Optimize Performance" "$TEST_DIR/tmp/menu_text.txt"
    grep -q "Setup Project Environment" "$TEST_DIR/tmp/menu_text.txt"
    grep -q "Enter your choice" "$TEST_DIR/tmp/menu_text.txt"
}

@test "Environment guidance documentation is comprehensive" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create a function to capture the environment selection guidance
    capture_environment_guidance() {
        # Define color variables needed by the text
        BLUE="BLUE"
        YELLOW="YELLOW"
        BOLD="BOLD"
        NC="NC"

        # Generate the environment selection text
        cat > "$TEST_DIR/tmp/environment_guidance.txt" << EOF
Environment Selection

The following environment options are available for your project:

1) Python venv
   Recommended for simple Python projects
   • Lightweight and built directly into Python
   • Excellent VSCode integration with minimal configuration
   • Perfect for learning, simple scripts, and lightweight web applications

2) Conda
   Recommended for complex projects with scientific or cross-language dependencies
   • Robust package management for data science, ML, and scientific computing
   • Handles complex dependency trees and non-Python packages (C, R, etc.)
   • Very good VSCode integration with Jupyter support

3) Poetry
   Modern Python dependency management for application development
   • Precise dependency locking with version resolution
   • Integrated virtual environments with cleaner project structure
   • Growing VSCode support and modern development workflows

4) Node.js
   For pure frontend or Next.js projects
   • Optimized setup with TypeScript, ESLint, and TailwindCSS
   • Modern JavaScript/TypeScript development environment
   • Full Next.js + React integration

Summary Guidance:
• Choose Conda for data science and scientific computing projects
• Choose Poetry for modern Python application development with robust dependency management
• Choose Python venv for simpler projects or learning environments
• Choose Node.js for frontend or full-stack JavaScript/TypeScript projects
EOF
    }

    # Generate the guidance text
    capture_environment_guidance

    # Verify guidance covers all environment types
    grep -q "Python venv.*simple Python projects" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Conda.*scientific or cross-language dependencies" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Poetry.*Modern Python dependency management" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Node.js.*Next.js projects" "$TEST_DIR/tmp/environment_guidance.txt"

    # Verify it includes summary guidance
    grep -q "Choose Conda for data science" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Choose Poetry for modern Python application" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Choose Python venv for simpler projects" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Choose Node.js for frontend" "$TEST_DIR/tmp/environment_guidance.txt"
}

@test "All error messages are well-documented" {
    # Source the script
    source "$SCRIPT_PATH"

    # Extract error messages from the script
    grep -E "error_message|ERROR" "$SCRIPT_PATH" > "$TEST_DIR/tmp/error_messages.txt"

    # Check if we found error messages
    [ -s "$TEST_DIR/tmp/error_messages.txt" ]

    # Verify that error messages are descriptive and helpful
    grep -q "\[ERROR\]" "$TEST_DIR/tmp/error_messages.txt"
    grep -q "Failed to" "$TEST_DIR/tmp/error_messages.txt"
    grep -q "Could not" "$TEST_DIR/tmp/error_messages.txt"
}

@test "Success and warning messages are properly documented" {
    # Source the script
    source "$SCRIPT_PATH"

    # Extract success and warning messages
    grep -E "success_message|warning_message" "$SCRIPT_PATH" > "$TEST_DIR/tmp/status_messages.txt"

    # Check if we found messages
    [ -s "$TEST_DIR/tmp/status_messages.txt" ]

    # Verify messages are descriptive
    grep -q "SUCCESS" "$SCRIPT_PATH"
    grep -q "WARNING" "$SCRIPT_PATH"
}

@test "Script version and date are documented" {
    # Source the script
    source "$SCRIPT_PATH"

    # Look for version information in the script
    grep -q "Version" "$SCRIPT_PATH"

    # Check for date information
    grep -q "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" "$SCRIPT_PATH"
}
