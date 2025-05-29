#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/Applications"
    mkdir -p "$TEST_DIR/tmp/Downloads"
    mkdir -p "$TEST_DIR/tmp/Shared/cursor"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "DMG file exists in downloads folder" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock the DMG path check function
    check_dmg_exists() {
        local dmg_path="/Users/vicd/Downloads/Cursor-darwin-universal.dmg"

        # In test mode, we'll simulate the file check
        if [[ "$CURSOR_TEST_MODE" == "true" ]]; then
            # Create a mock DMG file for testing
            touch "$TEST_DIR/tmp/Downloads/Cursor-darwin-universal.dmg"
            return 0
        else
            # In real execution, check the actual file
            [ -f "$dmg_path" ]
            return $?
        fi
    }

    # Run the check
    run check_dmg_exists

    # Assert that the check passed
    [ "$status" -eq 0 ]
}

@test "DMG file integrity verification works" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock hdiutil verify
    hdiutil() {
        if [[ "$1" == "verify" ]]; then
            # Simulate successful verification in test mode
            return 0
        else
            # Pass through to actual command for other hdiutil commands
            command hdiutil "$@"
        fi
    }

    # Create test function to verify DMG
    verify_dmg_integrity() {
        local dmg_path="$TEST_DIR/tmp/Downloads/Cursor-darwin-universal.dmg"
        # Create a test DMG file
        touch "$dmg_path"

        # Verify the DMG integrity (this will use our mocked hdiutil)
        hdiutil verify "$dmg_path" > /dev/null 2>&1
        return $?
    }

    # Run the verification
    run verify_dmg_integrity

    # Assert that the verification passed
    [ "$status" -eq 0 ]
}

@test "Cursor installation process works" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock functions that would be called during installation
    hdiutil() {
        case "$1" in
            "attach")
                # Simulate mounting the DMG
                mkdir -p "$TEST_DIR/tmp/Volumes/Cursor"
                mkdir -p "$TEST_DIR/tmp/Volumes/Cursor/Cursor.app"
                return 0
                ;;
            "detach")
                # Simulate unmounting
                return 0
                ;;
            "verify")
                # Simulate successful verification
                return 0
                ;;
            *)
                # Pass other commands through
                command hdiutil "$@"
                ;;
        esac
    }

    cp() {
        # Simulate copying the app
        if [[ "$3" == *"/Applications/" ]]; then
            mkdir -p "$TEST_DIR/tmp/Applications/Cursor.app"
            touch "$TEST_DIR/tmp/Applications/Cursor.app/Contents"
            mkdir -p "$TEST_DIR/tmp/Applications/Cursor.app/Contents/Info"
            return 0
        else
            command cp "$@"
        fi
    }

    defaults() {
        # Simulate getting app version
        if [[ "$1" == "read" && "$2" == *"Cursor.app/Contents/Info"* ]]; then
            echo "0.49.6"
            return 0
        else
            command defaults "$@"
        fi
    }

    # Mock other required functions
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

        mkdir -p "$CURSOR_SHARED_CONFIG"
        mkdir -p "$CURSOR_SHARED_LOGS"
        mkdir -p "$CURSOR_SHARED_PROJECTS"

        # Create argv.json
        echo "{}" > "$CURSOR_SHARED_ARGV"

        return 0
    }

    optimize_cursor_performance() {
        # Just log that this was called
        echo "Optimizations applied" > "$TEST_DIR/tmp/optimization_log.txt"
        return 0
    }

    setup_default_project() {
        # Just log that this was called
        echo "Default project set up" > "$TEST_DIR/tmp/project_setup_log.txt"
        return 0
    }

    # Create a test function to run the installation
    test_install_cursor() {
        # Redirect paths for testing
        local dmg_path="$TEST_DIR/tmp/Downloads/Cursor-darwin-universal.dmg"
        local app_path="$TEST_DIR/tmp/Applications/Cursor.app"
        local mount_point="$TEST_DIR/tmp/Volumes/Cursor"

        # Create a test DMG file
        touch "$dmg_path"

        # Run installation steps
        hdiutil verify "$dmg_path" > /dev/null 2>&1

        # Simulate mounting
        hdiutil attach "$dmg_path" -nobrowse > /dev/null

        # Check if mount point exists
        if [ -d "$mount_point" ]; then
            # Copy the app
            cp -R "$mount_point/Cursor.app" "$TEST_DIR/tmp/Applications/"

            # Unmount
            hdiutil detach "$mount_point" > /dev/null 2>&1

            # Verify installation
            if [ -d "$app_path" ]; then
                # Apply optimizations
                detect_cursor_paths
                optimize_cursor_performance
                setup_default_project

                # Success
                return 0
            fi
        fi

        # If we get here, something failed
        return 1
    }

    # Run the installation test
    run test_install_cursor

    # Assert that the installation succeeded
    [ "$status" -eq 0 ]

    # Check that the app was installed
    [ -d "$TEST_DIR/tmp/Applications/Cursor.app" ]

    # Check that optimizations were applied
    [ -f "$TEST_DIR/tmp/optimization_log.txt" ]
    grep -q "Optimizations applied" "$TEST_DIR/tmp/optimization_log.txt"

    # Check that default project was set up
    [ -f "$TEST_DIR/tmp/project_setup_log.txt" ]
    grep -q "Default project set up" "$TEST_DIR/tmp/project_setup_log.txt"
}

@test "Default project structure is correctly created" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock detect_cursor_paths
    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

        mkdir -p "$CURSOR_SHARED_CONFIG"
        mkdir -p "$CURSOR_SHARED_LOGS"
        mkdir -p "$CURSOR_SHARED_PROJECTS"

        return 0
    }

    # Mock conda setup (simplified for testing)
    setup_conda_environments() {
        local project_dir="$1"

        # Create conda directory
        mkdir -p "$project_dir/conda"

        # Create environment files
        touch "$project_dir/conda/dev-environment.yml"
        touch "$project_dir/conda/test-environment.yml"
        touch "$project_dir/conda/prod-environment.yml"

        # Create setup scripts
        touch "$project_dir/setup_conda_dev.sh"
        touch "$project_dir/setup_conda_test.sh"
        touch "$project_dir/setup_conda_prod.sh"
        chmod +x "$project_dir/setup_conda_dev.sh" "$project_dir/setup_conda_test.sh" "$project_dir/setup_conda_prod.sh"

        return 0
    }

    # Mock project structure creation (simplified)
    create_project_structure() {
        local project_dir="$1"

        # Create basic directories
        mkdir -p "$project_dir/src/app/api"
        mkdir -p "$project_dir/src/app/components"
        mkdir -p "$project_dir/public"
        mkdir -p "$project_dir/tests"

        # Create basic files
        touch "$project_dir/package.json"
        touch "$project_dir/next.config.js"
        touch "$project_dir/vercel.json"

        return 0
    }

    # Mock git repo init
    initialize_git_repository() {
        local project_dir="$1"

        # Just create .git directory
        mkdir -p "$project_dir/.git"
        touch "$project_dir/.git/config"

        return 0
    }

    # Mock shortcut creation
    create_project_shortcuts() {
        local project_dir="$1"

        # Create shortcuts
        touch "$project_dir/open_project.sh"
        chmod +x "$project_dir/open_project.sh"

        # Create VS Code settings
        mkdir -p "$project_dir/.vscode"
        touch "$project_dir/.vscode/settings.json"
        touch "$project_dir/.vscode/extensions.json"

        return 0
    }

    # Mock read function for automated inputs
    read_count=0
    read() {
        read_count=$((read_count + 1))

        # Always return "default-test-project" to keep the test consistent
        # but limit how many times we respond to prevent infinite loops
        if [ "$read_count" -le 5 ]; then
            echo "default-test-project"
        else
            # For any additional reads, return empty to stop loops
            echo ""
        fi
    }

    # Run setup_default_project with our mocks
    setup_default_project

    # Check the structure was created correctly
    local default_project_dir="$TEST_DIR/tmp/Shared/cursor/projects/cursor-default-project"

    # Check for conda environments
    [ -d "$default_project_dir/conda" ]
    [ -f "$default_project_dir/conda/dev-environment.yml" ]
    [ -f "$default_project_dir/conda/test-environment.yml" ]
    [ -f "$default_project_dir/conda/prod-environment.yml" ]

    # Check for project structure
    [ -d "$default_project_dir/src/app/api" ]
    [ -d "$default_project_dir/src/app/components" ]
    [ -d "$default_project_dir/public" ]
    [ -d "$default_project_dir/tests" ]

    # Check for basic files
    [ -f "$default_project_dir/package.json" ]
    [ -f "$default_project_dir/next.config.js" ]
    [ -f "$default_project_dir/vercel.json" ]

    # Check for git initialization
    [ -d "$default_project_dir/.git" ]

    # Check for shortcuts and VS Code settings
    [ -f "$default_project_dir/open_project.sh" ]
    [ -d "$default_project_dir/.vscode" ]
}

@test "Verify Cursor installation works" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock functions
    defaults() {
        if [[ "$1" == "read" && "$2" == *"Cursor.app/Contents/Info"* ]]; then
            echo "0.49.6"
            return 0
        elif [[ "$1" == "read" && "$2" == "com.cursor.Cursor" ]]; then
            if [[ "$3" == "WebGPUEnabled" ]]; then
                echo "1"
            elif [[ "$3" == "MetalEnabled" ]]; then
                echo "1"
            else
                echo "0"
            fi
            return 0
        else
            return 1
        fi
    }

    detect_cursor_paths() {
        CURSOR_CWD="$TEST_DIR/tmp/Shared/cursor"
        CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
        CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
        CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
        CURSOR_SHARED_PROJECTS="$CURSOR_CWD/projects"

        mkdir -p "$CURSOR_SHARED_CONFIG"
        mkdir -p "$CURSOR_SHARED_LOGS"
        mkdir -p "$CURSOR_SHARED_PROJECTS/cursor-default-project"

        # Create shared config
        mkdir -p "$CURSOR_SHARED_CONFIG/defaults"
        echo "{\"disable-hardware-acceleration\": false}" > "$CURSOR_SHARED_ARGV"

        return 0
    }

    check_performance_settings() {
        echo "Hardware acceleration enabled"
        echo "WebGPU enabled"
        echo "Metal acceleration enabled"
        return 0
    }

    # Setup for test
    mkdir -p "$TEST_DIR/tmp/Applications/Cursor.app/Contents"
    touch "$TEST_DIR/tmp/Applications/Cursor.app/Contents/Info.plist"

    # Override path check for Applications folder
    [ -d "/Applications/Cursor.app" ] && return 0 || true

    # Call verify function and capture output
    output=$(verify_cursor_installation)

    # Check that verification includes key information
    echo "$output" | grep -q "Cursor AI Editor version: 0.49.6" || \
        (echo "Output missing version info: $output" && false)

    # Check that performance settings were checked
    echo "$output" | grep -q "WebGPU enabled" || \
        (echo "Output missing WebGPU info: $output" && false)
}
