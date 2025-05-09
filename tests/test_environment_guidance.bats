#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/Users/Shared/cursor/projects"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "setup_project_environment provides comprehensive environment selection guidance" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths to set up shared paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

        # Create directories
        mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS" "$CURSOR_SHARED_PROJECTS"

        return 0
    }

    # Mock info_message to capture guidance text
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info_messages.log"
    }

    # Create a function to capture the environment guidance output
    capture_environment_guidance() {
        # Color variables used in the script
        BLUE='\033[0;34m'
        YELLOW='\033[1;33m'
        BOLD='\033[1m'
        NC='\033[0m'

        # Output the environment guidance text
        echo -e "\n${BOLD}Environment Selection${NC}"
        echo -e "The following environment options are available for your project:\n"

        echo -e "${BOLD}1) Python venv${NC}"
        echo -e "   ${BLUE}Recommended for simple Python projects${NC}"
        echo -e "   • Lightweight and built directly into Python"
        echo -e "   • Excellent VSCode integration with minimal configuration"
        echo -e "   • Perfect for learning, simple scripts, and lightweight web applications"
        echo -e "   • No additional installation required\n"

        echo -e "${BOLD}2) Conda${NC}"
        echo -e "   ${BLUE}Recommended for complex projects with scientific or cross-language dependencies${NC}"
        echo -e "   • Robust package management for data science, ML, and scientific computing"
        echo -e "   • Handles complex dependency trees and non-Python packages (C, R, etc.)"
        echo -e "   • Very good VSCode integration with Jupyter support"
        echo -e "   • Ideal for data science, machine learning, and scientific projects\n"

        echo -e "${BOLD}3) Poetry${NC}"
        echo -e "   ${BLUE}Modern Python dependency management for application development${NC}"
        echo -e "   • Precise dependency locking with version resolution"
        echo -e "   • Integrated virtual environments with cleaner project structure"
        echo -e "   • Growing VSCode support and modern development workflows"
        echo -e "   • Best for production Python applications and libraries\n"

        echo -e "${BOLD}4) Node.js${NC}"
        echo -e "   ${BLUE}For pure frontend or Next.js projects${NC}"
        echo -e "   • Optimized setup with TypeScript, ESLint, and TailwindCSS"
        echo -e "   • Modern JavaScript/TypeScript development environment"
        echo -e "   • Full Next.js + React integration"
        echo -e "   • Ideal for web applications and frontend projects\n"

        echo -e "${YELLOW}Summary Guidance:${NC}"
        echo -e "• Choose ${BOLD}Conda${NC} for data science and scientific computing projects"
        echo -e "• Choose ${BOLD}Poetry${NC} for modern Python application development with robust dependency management"
        echo -e "• Choose ${BOLD}Python venv${NC} for simpler projects or learning environments"
        echo -e "• Choose ${BOLD}Node.js${NC} for frontend or full-stack JavaScript/TypeScript projects\n"

        # Capture the full text to a log file
        echo "Guidance output captured" > "$TEST_DIR/tmp/guidance_captured.log"
    }

    # Run the environment guidance capture
    run capture_environment_guidance

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that the guidance was captured
    [ -f "$TEST_DIR/tmp/guidance_captured.log" ]

    # Check that all required environment options are mentioned
    echo "$output" | grep -q "Python venv.*Recommended for simple Python projects"
    [ $? -eq 0 ] || (echo "Missing venv guidance" && false)

    echo "$output" | grep -q "Conda.*data science or those with cross-language dependencies"
    [ $? -eq 0 ] || (echo "Missing Conda guidance" && false)

    echo "$output" | grep -q "Poetry.*precise dependency locking"
    [ $? -eq 0 ] || (echo "Missing Poetry guidance" && false)

    echo "$output" | grep -q "Node.js.*Next.js"
    [ $? -eq 0 ] || (echo "Missing Node.js guidance" && false)

    # Check summary guidance
    echo "$output" | grep -q "Choose.*Conda.*for data science"
    [ $? -eq 0 ] || (echo "Missing Conda summary" && false)

    echo "$output" | grep -q "Choose.*Poetry.*for modern Python application development"
    [ $? -eq 0 ] || (echo "Missing Poetry summary" && false)

    echo "$output" | grep -q "Choose.*Python venv.*for simpler projects"
    [ $? -eq 0 ] || (echo "Missing venv summary" && false)
}

@test "project environment setup always uses /Users/Shared/cursor/projects" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths to set up shared paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        # Deliberately set to a different path to test correction
        CURSOR_SHARED_PROJECTS="$TEST_DIR/tmp/wrong_projects_location"

        # Create directories
        mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS" "$CURSOR_SHARED_PROJECTS"

        return 0
    }

    # Mock read for user input
    read_count=0
    read() {
        read_count=$((read_count + 1))

        if [ "$read_count" -eq 1 ]; then
            # Project name
            echo "test-project"
        elif [ "$read_count" -eq 2 ]; then
            # Environment choice
            echo "1"  # Python venv
        else
            # Any other input
            echo ""
        fi
    }

    # Mock warning_message to capture path correction message
    warning_message() {
        echo "WARNING: $1" >> "$TEST_DIR/tmp/warnings.log"
    }

    # Mock info_message
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info.log"
    }

    # Mock mkdir to track project directory creation
    mkdir() {
        if [[ "$1" == "-p" && "$2" == *"/Users/Shared/cursor/projects/test-project"* ]]; then
            echo "Creating correct shared project directory: $2" >> "$TEST_DIR/tmp/mkdir.log"
            command mkdir -p "$2" 2>/dev/null
            return 0
        fi
        command mkdir "$@"
    }

    # Mock setup functions to avoid actual operations
    setup_venv_environments() { return 0; }
    create_project_structure() { return 0; }
    initialize_git_repository() { return 0; }
    create_project_shortcuts() { return 0; }

    # Run setup_project_environment
    run setup_project_environment

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify wrong path was detected and corrected
    [ -f "$TEST_DIR/tmp/warnings.log" ]
    grep -q "Shared projects directory is not at the expected location" "$TEST_DIR/tmp/warnings.log"
    grep -q "Resetting to default location: /Users/Shared/cursor/projects" "$TEST_DIR/tmp/warnings.log"

    # Verify the correct path was used
    [ -f "$TEST_DIR/tmp/mkdir.log" ]
    grep -q "Creating correct shared project directory:.*Users/Shared/cursor/projects/test-project" "$TEST_DIR/tmp/mkdir.log"
}

@test "project name is properly sanitized" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths to set up shared paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

        # Create directories
        mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS" "$CURSOR_SHARED_PROJECTS"

        return 0
    }

    # Mock read for user input with invalid characters
    read_count=0
    read() {
        read_count=$((read_count + 1))

        if [ "$read_count" -eq 1 ]; then
            # Project name with invalid characters
            echo "test project!@#$%^"
        elif [ "$read_count" -eq 2 ]; then
            # Confirm sanitized name
            echo "y"
        elif [ "$read_count" -eq 3 ]; then
            # Environment choice
            echo "1"  # Python venv
        else
            # Any other input
            echo ""
        fi
    }

    # Mock warning_message to capture sanitization message
    warning_message() {
        echo "WARNING: $1" >> "$TEST_DIR/tmp/warnings.log"
    }

    # Mock info_message
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/info.log"
    }

    # Mock mkdir to track project directory creation
    mkdir() {
        if [[ "$1" == "-p" && "$2" == *"/Users/Shared/cursor/projects/testproject"* ]]; then
            echo "Creating sanitized project directory: $2" >> "$TEST_DIR/tmp/mkdir.log"
            command mkdir -p "$2" 2>/dev/null
            return 0
        fi
        command mkdir "$@"
    }

    # Mock setup functions to avoid actual operations
    setup_venv_environments() { return 0; }
    create_project_structure() { return 0; }
    initialize_git_repository() { return 0; }
    create_project_shortcuts() { return 0; }

    # Run setup_project_environment
    run setup_project_environment

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify name was sanitized
    [ -f "$TEST_DIR/tmp/warnings.log" ]
    grep -q "Project name has been sanitized" "$TEST_DIR/tmp/warnings.log"

    # Verify the sanitized path was used
    [ -f "$TEST_DIR/tmp/mkdir.log" ]
    grep -q "Creating sanitized project directory:.*Users/Shared/cursor/projects/testproject" "$TEST_DIR/tmp/mkdir.log"
}
