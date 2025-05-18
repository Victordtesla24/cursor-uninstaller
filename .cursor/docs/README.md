# Cursor Background Agent Configuration

This directory contains configuration files and scripts for the Cursor Background Agent, enabling AI-powered agents to run asynchronously in a remote environment.

## Directory Structure

- `.cursor/`
  - `Dockerfile` - Defines the container environment for the background agent
  - `environment.json` - Main configuration file for the background agent
  - `scripts/` - Helper scripts for environment setup and operation
    - `install.sh` - Run during agent initialization to set up the environment
    - `github-setup.sh` - Configures GitHub repository access
    - `retry-utils.sh` - Utility functions for retrying operations
    - `load-env.sh` - Loads environment variables
    - `cleanup.sh` - Cleans up temporary files and resources
    - `create-snapshot.sh` - Creates environment snapshots (for snapshot-based approach)
  - `docs/` - Documentation files
    - `README.md` - This file
    - `TROUBLESHOOTING.md` - Solutions for common issues
    - `background-agent-prompt.md` - Example prompts for the background agent
  - `tests/` - Test scripts to validate the background agent environment
    - `run-tests.sh` - Master test script that runs all tests
    - `validate_cursor_environment.sh` - Validates overall environment setup
    - `test-env-setup.sh` - Tests environment variable loading and permissions
    - `test-github-integration.sh` - Tests GitHub repository access
    - `test-docker-env.sh` - Tests Docker container setup
    - `test-background-agent.sh` - Tests basic agent configuration
    - `test-agent-runtime.sh` - Tests agent runtime behavior
  - `logs/` - Log files from scripts and agent operations

## Usage

### Setting Up the Background Agent

1. Ensure your repository is connected to GitHub through the Cursor app
2. Make sure all necessary scripts are executable: `chmod +x .cursor/scripts/*.sh .cursor/tests/*.sh`
3. Validate your environment setup: `bash .cursor/tests/run-tests.sh`

### Background Agent Commands

- `Cmd + '` (Mac) or `Ctrl + '` (Windows/Linux): Open the list of background agents
- `Cmd + ;` (Mac) or `Ctrl + ;` (Windows/Linux): View agent status and enter the machine

## Environment Configuration

The background agent is configured via the `environment.json` file, which contains:

- Container build information
- User context for script execution
- Installation and startup scripts
- Terminal configurations for running processes

## GitHub Integration

This repository connects to GitHub via the Cursor GitHub app. The background agent needs read-write access to:

- Clone the repository
- Create branches
- Push changes
- Create pull requests

## Testing and Validation

Run the test suite to validate your environment:

```bash
bash .cursor/tests/run-tests.sh
```

This will test all aspects of the background agent environment and report any issues that need to be addressed.

## Troubleshooting

If you encounter issues, refer to `TROUBLESHOOTING.md` for common problems and solutions.

## References

- [Cursor Background Agent Documentation](https://docs.cursor.com/background-agent)
- [GitHub Repository](https://github.com/Victordtesla24/cursor-uninstaller.git)
