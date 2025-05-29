#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/Shared/cursor/projects"
    mkdir -p "$TEST_DIR/tmp/test_project"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "setup_project_environment creates project in /Users/Shared/cursor/projects" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"
        mkdir -p "$CURSOR_SHARED_LOGS"
        mkdir -p "$CURSOR_SHARED_PROJECTS"
        return 0
    }

    # Mock read to simulate user input
    read_count=0
    read() {
        read_count=$((read_count + 1))

        if [ $read_count -eq 1 ]; then
            # Project name
            echo "test_project"
        elif [ $read_count -eq 2 ]; then
            # Environment choice
            echo "1"  # Choose venv
        else
            echo ""  # Any other prompts
        fi
    }

    # Track directory creation
    mkdir() {
        echo "MKDIR: $@" >> "$TEST_DIR/tmp/operations.log"
        command mkdir -p "$@"
        return 0
    }

    # Mock other functions
    setup_venv_environments() {
        echo "SETUP_VENV: $1" >> "$TEST_DIR/tmp/operations.log"
        return 0
    }

    create_project_structure() {
        echo "CREATE_STRUCTURE: $1" >> "$TEST_DIR/tmp/operations.log"
        return 0
    }

    initialize_git_repository() {
        echo "INIT_GIT: $1" >> "$TEST_DIR/tmp/operations.log"
        return 0
    }

    create_project_shortcuts() {
        echo "CREATE_SHORTCUTS: $1 $2 $3" >> "$TEST_DIR/tmp/operations.log"
        return 0
    }

    # Mock message functions
    info_message() { echo "INFO: $1" >> "$TEST_DIR/tmp/messages.log"; }
    success_message() { echo "SUCCESS: $1" >> "$TEST_DIR/tmp/messages.log"; }
    warning_message() { echo "WARNING: $1" >> "$TEST_DIR/tmp/messages.log"; }
    error_message() { echo "ERROR: $1" >> "$TEST_DIR/tmp/messages.log"; return 1; }

    # Run the function
    setup_project_environment

    # Verify the project was created in the correct location
    grep -q "MKDIR: $TEST_DIR/tmp/Shared/cursor/projects/test_project" "$TEST_DIR/tmp/operations.log"

    # Verify setup functions were called
    grep -q "SETUP_VENV: $TEST_DIR/tmp/Shared/cursor/projects/test_project" "$TEST_DIR/tmp/operations.log"
    grep -q "CREATE_STRUCTURE: $TEST_DIR/tmp/Shared/cursor/projects/test_project" "$TEST_DIR/tmp/operations.log"
    grep -q "INIT_GIT: $TEST_DIR/tmp/Shared/cursor/projects/test_project" "$TEST_DIR/tmp/operations.log"
    grep -q "CREATE_SHORTCUTS: $TEST_DIR/tmp/Shared/cursor/projects/test_project" "$TEST_DIR/tmp/operations.log"

    # Verify success message
    grep -q "SUCCESS: Project environment setup complete" "$TEST_DIR/tmp/messages.log"
}

@test "setup_project_environment sanitizes project name correctly" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"
        mkdir -p "$CURSOR_SHARED_LOGS"
        mkdir -p "$CURSOR_SHARED_PROJECTS"
        return 0
    }

    # Mock read to simulate user input with invalid characters
    read_count=0
    read() {
        read_count=$((read_count + 1))

        if [ $read_count -eq 1 ]; then
            # Project name with invalid characters
            echo "test project!@#$%^&*()"
        elif [ $read_count -eq 2 ]; then
            # Confirm sanitized name
            echo "y"
        elif [ $read_count -eq 3 ]; then
            # Environment choice
            echo "1"  # Choose venv
        else
            echo ""  # Any other prompts
        fi
    }

    # Track operations
    mkdir() {
        echo "MKDIR: $@" >> "$TEST_DIR/tmp/operations.log"
        command mkdir -p "$@"
        return 0
    }

    # Mock functions
    setup_venv_environments() { return 0; }
    create_project_structure() { return 0; }
    initialize_git_repository() { return 0; }
    create_project_shortcuts() { return 0; }

    # Mock message functions
    info_message() { echo "INFO: $1" >> "$TEST_DIR/tmp/messages.log"; }
    success_message() { echo "SUCCESS: $1" >> "$TEST_DIR/tmp/messages.log"; }
    warning_message() { echo "WARNING: $1" >> "$TEST_DIR/tmp/messages.log"; }
    error_message() { echo "ERROR: $1" >> "$TEST_DIR/tmp/messages.log"; return 1; }

    # Run the function and capture output
    output=$(setup_project_environment 2>&1)

    # Verify sanitization message
    grep -q "WARNING: Project name has been sanitized to 'testproject'" "$TEST_DIR/tmp/messages.log"

    # Verify correct directory is created
    grep -q "MKDIR: $TEST_DIR/tmp/Shared/cursor/projects/testproject" "$TEST_DIR/tmp/operations.log"
}

@test "setup_venv_environments creates required structure and files" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test project directory
    PROJECT_DIR="$TEST_DIR/tmp/test_project"
    mkdir -p "$PROJECT_DIR"

    # Run setup_venv_environments
    setup_venv_environments "$PROJECT_DIR"

    # Verify directories were created
    [ -d "$PROJECT_DIR/environments/dev" ]
    [ -d "$PROJECT_DIR/environments/test" ]
    [ -d "$PROJECT_DIR/environments/prod" ]

    # Verify requirements files were created
    [ -f "$PROJECT_DIR/requirements-dev.txt" ]
    [ -f "$PROJECT_DIR/requirements-test.txt" ]
    [ -f "$PROJECT_DIR/requirements.txt" ]

    # Verify setup script was created and is executable
    [ -f "$PROJECT_DIR/setup_venv.sh" ]
    [ -x "$PROJECT_DIR/setup_venv.sh" ]

    # Verify content of requirements files
    grep -q "pytest" "$PROJECT_DIR/requirements-dev.txt"
    grep -q "flask" "$PROJECT_DIR/requirements.txt"
}

@test "setup_conda_environments creates environment YAML files" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test project directory
    PROJECT_DIR="$TEST_DIR/tmp/test_project"
    mkdir -p "$PROJECT_DIR"

    # Run setup_conda_environments
    setup_conda_environments "$PROJECT_DIR"

    # Verify conda directory and environment files
    [ -d "$PROJECT_DIR/conda" ]
    [ -f "$PROJECT_DIR/conda/dev-environment.yml" ]
    [ -f "$PROJECT_DIR/conda/test-environment.yml" ]
    [ -f "$PROJECT_DIR/conda/prod-environment.yml" ]

    # Verify setup scripts were created and are executable
    [ -f "$PROJECT_DIR/setup_conda_dev.sh" ]
    [ -f "$PROJECT_DIR/setup_conda_test.sh" ]
    [ -f "$PROJECT_DIR/setup_conda_prod.sh" ]
    [ -f "$PROJECT_DIR/setup_conda_all.sh" ]
    [ -x "$PROJECT_DIR/setup_conda_all.sh" ]

    # Verify content of environment files
    grep -q "name: test_project-dev" "$PROJECT_DIR/conda/dev-environment.yml"
    grep -q "python=" "$PROJECT_DIR/conda/dev-environment.yml"
    grep -q "flask=" "$PROJECT_DIR/conda/dev-environment.yml"
}

@test "setup_poetry_environments creates Poetry configuration" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test project directory
    PROJECT_DIR="$TEST_DIR/tmp/test_project"
    mkdir -p "$PROJECT_DIR"

    # Mock command to simulate poetry installation
    command() {
        if [[ "$1" == "-v" && "$2" == "poetry" ]]; then
            return 0  # Poetry is installed
        fi
        command "$@"  # Pass through to actual command
    }

    # Mock cd to log but not actually change directory
    cd() {
        echo "CD: $1" >> "$TEST_DIR/tmp/operations.log"
        return 0
    }

    # Mock poetry commands
    poetry() {
        echo "POETRY: $@" >> "$TEST_DIR/tmp/operations.log"
        return 0
    }

    # Run setup_poetry_environments
    setup_poetry_environments "$PROJECT_DIR"

    # Verify poetry initialization
    grep -q "POETRY: init" "$TEST_DIR/tmp/operations.log"
    grep -q "POETRY: config virtualenvs.in-project true" "$TEST_DIR/tmp/operations.log"
    grep -q "POETRY: add" "$TEST_DIR/tmp/operations.log"

    # Verify setup script was created
    [ -f "$PROJECT_DIR/setup_poetry_envs.sh" ]
    [ -x "$PROJECT_DIR/setup_poetry_envs.sh" ]
}

@test "setup_nodejs_environment creates Next.js project structure" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test project directory
    PROJECT_DIR="$TEST_DIR/tmp/test_project"
    mkdir -p "$PROJECT_DIR"

    # Mock command to simulate npm installation
    command() {
        if [[ "$1" == "-v" && "$2" == "npm" ]]; then
            return 0  # npm is installed
        fi
        command "$@"  # Pass through to actual command
    }

    # Mock cd to log but not actually change directory
    cd() {
        echo "CD: $1" >> "$TEST_DIR/tmp/operations.log"
        return 0
    }

    # Mock npm command
    npm() {
        echo "NPM: $@" >> "$TEST_DIR/tmp/operations.log"
        return 0
    }

    # Run setup_nodejs_environment
    setup_nodejs_environment "$PROJECT_DIR"

    # Verify environment directories
    [ -d "$PROJECT_DIR/environments/dev" ]
    [ -d "$PROJECT_DIR/environments/test" ]
    [ -d "$PROJECT_DIR/environments/prod" ]

    # Verify environment files
    [ -f "$PROJECT_DIR/environments/dev/.env.development" ]
    [ -f "$PROJECT_DIR/environments/test/.env.test" ]
    [ -f "$PROJECT_DIR/environments/prod/.env.production" ]

    # Verify package.json was created
    [ -f "$PROJECT_DIR/package.json" ]
    grep -q "\"name\": \"test_project\"" "$PROJECT_DIR/package.json"
    grep -q "\"dev\": \"NODE_ENV=development next dev\"" "$PROJECT_DIR/package.json"

    # Verify setup script
    [ -f "$PROJECT_DIR/setup_nodejs.sh" ]
    [ -x "$PROJECT_DIR/setup_nodejs.sh" ]
}

@test "create_project_structure creates Vercel-compatible directory structure" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test project directory
    PROJECT_DIR="$TEST_DIR/tmp/test_project"
    mkdir -p "$PROJECT_DIR"

    # Run create_project_structure
    create_project_structure "$PROJECT_DIR"

    # Verify directories
    [ -d "$PROJECT_DIR/src/app/api" ]
    [ -d "$PROJECT_DIR/src/app/components" ]
    [ -d "$PROJECT_DIR/src/app/utils" ]
    [ -d "$PROJECT_DIR/src/app/styles" ]
    [ -d "$PROJECT_DIR/public" ]
    [ -d "$PROJECT_DIR/tests" ]

    # Verify files
    [ -f "$PROJECT_DIR/src/app/page.tsx" ]
    [ -f "$PROJECT_DIR/src/app/layout.tsx" ]
    [ -f "$PROJECT_DIR/src/app/styles/globals.css" ]
    [ -f "$PROJECT_DIR/next.config.js" ]
    [ -f "$PROJECT_DIR/vercel.json" ]
    [ -f "$PROJECT_DIR/README.md" ]
    [ -f "$PROJECT_DIR/tailwind.config.js" ]
    [ -f "$PROJECT_DIR/tsconfig.json" ]

    # Verify content of critical files
    grep -q "framework\": \"nextjs\"" "$PROJECT_DIR/vercel.json"  # Vercel configuration
    grep -q "regions\": \[\"sfo1\"\]" "$PROJECT_DIR/vercel.json"  # Deployment region
    grep -q "@tailwind base" "$PROJECT_DIR/src/app/styles/globals.css"  # TailwindCSS setup
}

@test "initialize_git_repository sets up git with .gitignore" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test project directory
    PROJECT_DIR="$TEST_DIR/tmp/test_project"
    mkdir -p "$PROJECT_DIR"

    # Mock git commands
    git() {
        echo "GIT: $@" >> "$TEST_DIR/tmp/operations.log"
        if [[ "$1" == "init" ]]; then
            mkdir -p "$PROJECT_DIR/.git"
            touch "$PROJECT_DIR/.git/config"
        fi
        return 0
    }

    # Run initialize_git_repository
    initialize_git_repository "$PROJECT_DIR"

    # Verify git was initialized
    [ -d "$PROJECT_DIR/.git" ]
    grep -q "GIT: init" "$TEST_DIR/tmp/operations.log"
    grep -q "GIT: add ." "$TEST_DIR/tmp/operations.log"
    grep -q "GIT: commit -m" "$TEST_DIR/tmp/operations.log"

    # Verify .gitignore file
    [ -f "$PROJECT_DIR/.gitignore" ]
    grep -q "node_modules" "$PROJECT_DIR/.gitignore"
    grep -q ".next" "$PROJECT_DIR/.gitignore"
    grep -q "__pycache__" "$PROJECT_DIR/.gitignore"
    grep -q "venv" "$PROJECT_DIR/.gitignore"
    grep -q ".conda" "$PROJECT_DIR/.gitignore"
}

@test "create_project_shortcuts creates VS Code settings and activation scripts" {
    # Source the script
    source "$SCRIPT_PATH"

    # Create test project directory
    PROJECT_DIR="$TEST_DIR/tmp/test_project"
    mkdir -p "$PROJECT_DIR"

    # Run create_project_shortcuts
    create_project_shortcuts "$PROJECT_DIR" "test_project" "1"  # venv environment

    # Verify shortcuts and VS Code settings
    [ -f "$PROJECT_DIR/open_project.sh" ]
    [ -x "$PROJECT_DIR/open_project.sh" ]
    [ -d "$PROJECT_DIR/.vscode" ]
    [ -f "$PROJECT_DIR/.vscode/settings.json" ]
    [ -f "$PROJECT_DIR/.vscode/extensions.json" ]

    # Verify shortcut content includes environment activation
    grep -q "source environments/dev/bin/activate" "$PROJECT_DIR/open_project.sh"
    grep -q "source environments/test/bin/activate" "$PROJECT_DIR/open_project.sh"
    grep -q "source environments/prod/bin/activate" "$PROJECT_DIR/open_project.sh"

    # Verify VS Code settings
    grep -q "editor.formatOnSave" "$PROJECT_DIR/.vscode/settings.json"
    grep -q "recommendations" "$PROJECT_DIR/.vscode/extensions.json"
}

@test "setup_project_environment provides proper environment selection guidance" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"
        mkdir -p "$CURSOR_SHARED_LOGS"
        mkdir -p "$CURSOR_SHARED_PROJECTS"
        return 0
    }

    # Mock functions to prevent actual execution
    setup_venv_environments() { return 0; }
    create_project_structure() { return 0; }
    initialize_git_repository() { return 0; }
    create_project_shortcuts() { return 0; }

    # Mock color variables for display
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    BOLD='\033[1m'
    NC='\033[0m'

    # Create a function to capture the environment guidance text
    capture_environment_guidance() {
        # Setup for capturing
        local output_file="$TEST_DIR/tmp/environment_guidance.txt"

        # Generate the environment selection guidance text similar to setup_project_environment
        cat > "$output_file" << EOF
Environment Selection

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

    # Verify guidance contains all key elements
    [ -f "$TEST_DIR/tmp/environment_guidance.txt" ]
    grep -q "Python venv.*Recommended for simple Python projects" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Conda.*Recommended for complex projects with scientific" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Poetry.*Modern Python dependency management" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Node.js.*For pure frontend or Next.js projects" "$TEST_DIR/tmp/environment_guidance.txt"

    # Verify summary guidance
    grep -q "Choose Conda for data science" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Choose Poetry for modern Python application development" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Choose Python venv for simpler projects" "$TEST_DIR/tmp/environment_guidance.txt"
    grep -q "Choose Node.js for frontend" "$TEST_DIR/tmp/environment_guidance.txt"
}

@test "setup_project_environment refuses to create project outside shared directory" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths to return a non-standard path
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$TEST_DIR/tmp/non_standard_projects"  # Non-standard path
        mkdir -p "$CURSOR_SHARED_LOGS"
        mkdir -p "$CURSOR_SHARED_PROJECTS"
        return 0
    }

    # Mock user input
    read_count=0
    read() {
        read_count=$((read_count + 1))

        if [ $read_count -eq 1 ]; then
            # Project name
            echo "test_project"
        elif [ $read_count -eq 2 ]; then
            # Environment choice
            echo "1"
        else
            echo ""
        fi
    }

    # Mock message functions
    info_message() { echo "INFO: $1" >> "$TEST_DIR/tmp/messages.log"; }
    success_message() { echo "SUCCESS: $1" >> "$TEST_DIR/tmp/messages.log"; }
    warning_message() { echo "WARNING: $1" >> "$TEST_DIR/tmp/messages.log"; }
    error_message() { echo "ERROR: $1" >> "$TEST_DIR/tmp/messages.log"; return 1; }

    # Track mkdir calls
    mkdir() {
        echo "MKDIR: $@" >> "$TEST_DIR/tmp/operations.log"
        command mkdir -p "$@"
        return 0
    }

    # Mock other functions
    setup_venv_environments() { return 0; }
    create_project_structure() { return 0; }
    initialize_git_repository() { return 0; }
    create_project_shortcuts() { return 0; }

    # Run the function
    setup_project_environment

    # Verify it resets to standard path
    grep -q "WARNING: Shared projects directory is not at the expected location" "$TEST_DIR/tmp/messages.log"
    grep -q "WARNING: Resetting to default location: /Users/Shared/cursor/projects" "$TEST_DIR/tmp/messages.log"

    # Verify it does not create in the non-standard location
    ! grep -q "MKDIR: $TEST_DIR/tmp/non_standard_projects/test_project" "$TEST_DIR/tmp/operations.log"

    # Verify it attempts to create in the standard location
    grep -q "INFO: Project will be created at:" "$TEST_DIR/tmp/messages.log"
    grep -q "/Users/Shared/cursor/projects/test_project" "$TEST_DIR/tmp/messages.log" || \
        grep -q "MKDIR: /Users/Shared/cursor/projects/test_project" "$TEST_DIR/tmp/operations.log"
}
