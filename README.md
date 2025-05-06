# Cursor AI Editor Uninstaller & Utilities

A comprehensive macOS tool for managing, optimizing, configuring, and installing the Cursor AI Editor, with specific enhancements for Apple Silicon (M-series) chips. This script is designed for users who require meticulous control over their Cursor AI Editor installation and project environments.

## Core Features

-   **Complete Uninstallation**: Thoroughly removes all Cursor-related files, preferences, caches, and support data for a pristine system state, ideal for clean reinstallations.
-   **Targeted Cleanup**: Option to remove only lingering files without performing a full uninstallation.
-   **Advanced Performance Optimization**:
    -   Tailored optimizations for Apple Silicon (M-series) chips, with specific fine-tuning for M1, M2, and M3 generations.
    -   Intelligent detection of chip architecture to apply appropriate settings.
    -   Modifies `argv.json` and system `defaults` for hardware acceleration, GPU rendering (Metal, WebGPU), and other performance-critical aspects.
    -   Includes an Electron preload script (`performance.js`) for runtime optimizations.
    -   Manages Homebrew and necessary dependencies (like `xmlstarlet`) for optimization tasks.
-   **Sophisticated Project Environment Setup**:
    -   Creates isolated Development (DEV), Testing (TEST), and Production (PROD) environments.
    -   Supports four environment management tools, with clear user guidance provided during setup:
        -   **Python venv**: Recommended for simple Python projects; lightweight, built into Python, excellent VSCode integration.
        -   **Conda**: Recommended for complex projects, especially data science or those with cross-language dependencies; robust scientific package support, very good VSCode integration.
        -   **Poetry**: Modern Python dependency management for application development; offers precise dependency locking, integrated virtual environments, and a cleaner project structure with growing VSCode support.
        -   **Node.js**: For pure frontend projects; provides a Next.js optimized setup including TypeScript, ESLint, Prettier, Jest, and TailwindCSS.
    -   Prompts for a project name, sanitizes it, and creates the project in the shared `/Users/Shared/cursor/projects/<project_name>/` directory.
    -   Generates a Vercel-compatible project structure for Next.js applications.
    -   Includes VSCode settings (`settings.json`, `extensions.json`) and project activation shortcuts (`open_project.sh`).
    -   Manages Python and Node.js dependencies appropriately for each environment type.
-   **Fresh Cursor AI Editor Installation**:
    -   Automates the installation of Cursor AI Editor from a specified DMG file (`/Users/vicd/Downloads/Cursor-darwin-universal.dmg`).
    -   Verifies DMG integrity before installation.
    -   Handles removal of any pre-existing `Cursor.app`.
    -   Correctly mounts, copies, and unmounts the DMG.
    -   Verifies the installed application version.
    -   Automatically applies performance optimizations and sets up a default project environment post-installation.
-   **Robust Path Management & Shared Configuration**:
    -   Reliably determines its own script directory, handling symlinks and various execution contexts using `get_script_path`.
    -   All shared configurations, logs, and project files are centrally managed within `/Users/Shared/cursor/` and its subdirectories (`config`, `logs`, `projects`, `cache`, `backups`).
    -   Ensures correct directory and file permissions (e.g., `775` for directories, `664` for specific files) and ownership (`$(whoami):staff`).
-   **Enhanced Error Handling & User Feedback**:
    -   Utilizes `set -Eeou pipefail` for strict error checking.
    -   Comprehensive `trap` for error reporting, including line number and command.
    -   Color-coded helper functions for `INFO`, `SUCCESS`, `WARNING`, and `ERROR` messages.
    -   `execute_safely` wrapper for non-critical commands with retry logic.
    -   Sudo refresh mechanism to maintain privileges during long operations.

## Requirements

-   macOS (Optimized for Apple Silicon M-series chips, compatible with Intel)
-   Bash shell (Script is `#!/bin/bash`)
-   Administrative (sudo) privileges for many operations.
-   For fresh installation: Cursor DMG file must be located at `/Users/vicd/Downloads/Cursor-darwin-universal.dmg`.
-   For some performance optimization tasks: Homebrew and `xmlstarlet`. The script will attempt to install these if missing.
-   For testing: `bats-core` (can be installed via Homebrew).

## Installation of the Utility

1.  Clone this repository or download the `uninstall_cursor.sh` script.
2.  Make the script executable:
    ```bash
    chmod +x uninstall_cursor.sh
    ```

## Usage

Run the script from your terminal:

```bash
./uninstall_cursor.sh
```

This will display an interactive menu with the following options:

1.  **Complete Uninstallation**: Removes ALL Cursor-related files and settings.
2.  **Cleanup Lingering Files Only**: Removes common leftover files without a full uninstall.
3.  **Optimize Performance Settings**: Applies/re-applies performance enhancements.
4.  **Reset Performance Settings**: Reverts performance optimizations to defaults.
5.  **Check Performance Settings**: Displays the current status of key performance settings.
6.  **Set Up Project Environment**: Guides you through creating a new development project.
7.  **Install Fresh Cursor AI Editor**: Installs Cursor from the pre-defined DMG path, applies optimizations, and sets up a default project.
8.  **Verify Cursor Installation**: Checks if Cursor is installed and if shared configurations are in place.
9.  **Run Tests (for development only)**: Executes the `bats` test suite.
10. **Exit**: Quits the script.

## Shared Configuration Directory Structure

The script centralizes its operational data and configurations to ensure consistency:

-   `/Users/Shared/cursor/`: Root directory for all shared data.
    -   `config/`: Performance settings, optimization scripts.
        -   `argv.json`: Shared Electron/Chromium flags for Cursor.
        -   `defaults/`: Scripts for applying macOS `defaults write` settings.
        -   `preload/`: Electron `performance.js` preload script.
    -   `logs/`: Log files for script operations (e.g., `path_detection.log`, `optimization.log`, `project_setup.log`).
    -   `projects/`: Default location for all created project environments.
    -   `cache/`: Shared cache directory (created by the script).
    -   `backups/`: Backup location for configurations (created by the script).

## Testing

The script includes a comprehensive test suite using the **BATS (Bash Automated Testing System)** framework.

-   **Location:** Tests are located in the `tests/` directory.
-   **Running Tests:**
    ```bash
    # Ensure bats-core is installed (brew install bats-core)
    bats tests/*.bats
    ```
-   **Coverage:** The tests cover key functionalities, including:
    -   Path resolution and shared configuration targeting.
    -   Complete uninstallation and lingering file cleanup.
    -   Application and verification of performance optimizations (including M-series detection).
    -   Project environment setup for `venv`, `conda`, `poetry`, and `Node.js`, including directory structure, user guidance prompts, and dependency file generation.
    -   Fresh DMG installation process (DMG verification, app installation, post-install tasks).
    -   Error handling and graceful failure scenarios.
    -   Creation and permission settings for shared directories.
    -   Homebrew and dependency handling in `check_performance_deps`.

Refer to `tests/README.md` for more details on the test suite.

## Key Architectural Decisions

1.  **Centralized Shared Configuration**: Using `/Users/Shared/cursor/` ensures that settings and projects are consistently managed, regardless of the user running the script, and facilitates easier backup and migration.
2.  **Intelligent Chip Detection**: Dynamically detects Apple Silicon chip generation to apply the most relevant and effective performance optimizations.
3.  **Resilient Operations**: Robust error handling, messaging, and sudo management make the script reliable for complex tasks.
4.  **Standardized Project Scaffolding**: Projects are created with modern best practices (e.g., Vercel for Next.js) and offer multiple environment management choices to suit different needs.
5.  **Automated Installation & Optimization**: Streamlines setting up a new Cursor instance by combining installation with immediate performance tuning and default project creation.
6.  **Test-Driven Enhancements**: A comprehensive `bats` test suite underpins the script's reliability and allows for confident modifications.

## License

MIT 
