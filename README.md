# Cursor AI Editor Uninstaller & Utilities

A comprehensive macOS tool for managing, optimizing, configuring, and installing the Cursor AI Editor, with specific enhancements for Apple Silicon (M-series) chips. This script provides robust features for uninstallation, optimization, project environment setup, and fresh installation.

## Dependencies

### Project Dependencies
- Node.js and npm (Node Package Manager)
- React and React DOM for the dashboard UI
- Vite for frontend build and development server
- Jest for testing the dashboard components

### Dev Dependencies
- Bats for Bash script testing
- Babel for JavaScript transpilation
- Testing libraries for React components

### Installation
To install all required dependencies:

```bash
# Install root project dependencies
npm install

# Install dashboard dependencies
cd ui/dashboard && npm install
```

## Key Features

### Path Management & Shared Configuration

- **Robust Path Resolution**: The `get_script_path` function reliably determines the script's absolute directory regardless of execution context.
- **Centralized Configuration**: All shared configurations, logs, and projects are managed within `/Users/Shared/cursor/` with proper permissions (775 for directories, 664 for files).
- **Directory Structure**: Creates and maintains a consistent directory structure with `config`, `logs`, `projects`, `cache`, and `backups` subdirectories.

### Performance Optimization

- **M-Series Chip Detection**: Intelligently detects Apple Silicon M1, M2, and M3 chips and applies chip-specific optimizations.
- **Metal & GPU Acceleration**: Configures hardware acceleration, WebGPU, Metal rendering and other graphics settings for optimal performance.
- **Shared Configuration**: All performance settings are stored in `/Users/Shared/cursor/config/argv.json` with symbolic links to user configurations.
- **Optimized Defaults**: Sets appropriate `defaults write` commands for macOS preferences to enhance performance.

### Project Environment Setup

- **Comprehensive Environment Selection**: Guides users through selecting the most appropriate environment:
  - **Python venv**: Recommended for simple Python projects; lightweight, built into Python, excellent VSCode integration.
  - **Conda**: Recommended for complex projects, especially data science or those with cross-language dependencies; robust scientific package support, very good VSCode integration.
  - **Poetry**: Modern Python dependency management for application development; offers precise dependency locking, integrated virtual environments, and a cleaner project structure with growing VSCode support.
  - **Node.js**: For pure frontend or Next.js projects; optimized setup with TypeScript, ESLint, and TailwindCSS.
- **Vercel/Next.js Compatible**: Creates project structures that adhere to Vercel deployment guidelines.
- **Isolated Environments**: Sets up DEV, TEST, and PROD environments for each project.
- **Consistent Path Structure**: All projects are created in `/Users/Shared/cursor/projects/` with proper permissions.

### Fresh Installation

- **DMG Verification**: Verifies the integrity of the DMG file at `/Users/vicd/Downloads/Cursor-darwin-universal.dmg`.
- **Robust Installation**: Handles existing app removal, DMG mounting/unmounting, and proper app installation to `/Applications/`.
- **Post-Installation Setup**: Automatically applies performance optimizations and creates a default project environment.
- **Installation Verification**: Checks for successful installation and confirms app version.

### Uninstallation & Cleanup

- **Complete Removal**: Thoroughly removes all Cursor-related files, preferences, caches, and support data.
- **Enhanced Error Handling**: Uses sudo refresh mechanism to maintain privileges during long operations.
- **Verification System**: Performs a comprehensive scan for leftover files after uninstallation.
- **Graceful Error Recovery**: Continues with non-critical operations even if some steps fail.

### Error Handling & Utility Functions

- **Strict Error Checking**: Uses `set -Eeou pipefail` with proper error trapping.
- **Color-Coded Output**: Provides clear status messages with `info_message`, `warning_message`, `error_message`, and `success_message`.
- **Sudo Management**: Implements `start_sudo_refresh` and `stop_sudo_refresh` to prevent timeout during long operations.
- **Safe Operations**: Uses `execute_safely`, `safe_remove`, and other protective wrappers to prevent script termination.

## Key Architectural Enhancements

1. **Centralized Shared Configuration**: Using `/Users/Shared/cursor/` ensures settings and projects are consistently managed across all users.
2. **Intelligent Chip Detection**: Dynamic detection of Apple Silicon generation for optimized performance settings.
3. **Enhanced DMG Installation**: Robust verification and installation process with post-installation optimization.
4. **Comprehensive Project Environment Guidance**: Clear guidance on environment selection with detailed explanations.
5. **Isolated Environment Structure**: DEV, TEST, and PROD environments for all project types.
6. **Permission Management**: Proper permissions (775 for directories, 664 for files) and ownership (user:staff) for all shared resources.

## Test Suite

A comprehensive BATS (Bash Automated Testing System) test suite ensures the script's reliability and correctness.

### Running Tests

```bash
# Ensure bats-core is installed
brew install bats-core

# Run all tests
bats tests/*.bats

# Run a specific test file
bats tests/test_path_resolution.bats
```

### Test Coverage

1. **Path Resolution & Shared Configuration**:
   - `test_path_resolution.bats`: Tests `get_script_path` and symlink handling
   - `test_shared_configuration.bats`: Tests shared directory management and permissions

2. **Uninstallation & Cleanup**:
   - `test_uninstallation.bats`: Tests complete uninstallation and lingering file cleanup

3. **Performance Optimization**:
   - `test_performance_optimizations.bats`: Tests M-series chip detection and optimization
   - `test_homebrew_dependencies.bats`: Tests Homebrew and dependency management

4. **Project Setup**:
   - `test_environment_guidance.bats`: Tests environment selection guidance
   - `test_project_setup.bats`: Tests project structure creation

5. **Installation**:
   - `test_dmg_installation.bats`: Tests DMG verification and app installation

### Key Testing Techniques

- **Mock Command Functions**: Replaces system commands with test versions
- **Command Tracking**: Logs command executions to verify correct behavior
- **Path Verification**: Ensures files and directories are created in the right locations
- **Permission Testing**: Verifies correct permissions and ownership
- **Error Handling**: Tests graceful error recovery in various scenarios

## Using the Script

```bash
./uninstall_cursor.sh
```

This displays an interactive menu with the following options:

1. **Uninstall Cursor AI Editor**: Removes application and all data
2. **Clean Installation**: Fresh install with optimizations
3. **Optimize Performance**: Apply latest performance optimizations
4. **Setup Project Environment**: Create DEV/TEST/PROD project
5. **Run Tests**: For developers only
6. **Repair Shared Configuration**: Fix corrupted settings
7. **Create Desktop Shortcut**: Fast access to Cursor
8. **Exit**

## Requirements

- macOS (Optimized for Apple Silicon M-series chips, compatible with Intel)
- Bash shell
- Administrative (sudo) privileges
- For fresh installation: Cursor DMG file at `/Users/vicd/Downloads/Cursor-darwin-universal.dmg`
- For performance optimization: Homebrew (installed automatically if missing)
- For testing: `bats-core` (can be installed via Homebrew)
