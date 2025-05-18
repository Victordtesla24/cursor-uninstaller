# Cursor Background Agent Configuration

This directory contains the configuration files and scripts for the Cursor Background Agent. The Background Agent allows you to run AI assistants in a remote environment that can edit and run your code asynchronously.

## Directory Structure

- `.cursor/` - Root configuration directory
  - `Dockerfile` - Defines the container environment for the background agent
  - `environment.json` - Main configuration file for the background agent
  - `scripts/` - Helper scripts for environment setup and operation
    - `install.sh` - Run during agent initialization to set up the environment
    - `github-setup.sh` - Configures GitHub repository access
    - `retry-utils.sh` - Utility functions for retrying operations
    - `load-env.sh` - Loads environment variables
    - `cleanup.sh` - Cleans up temporary files and resources
    - `create-snapshot.sh` - Creates environment snapshots
  - `docs/` - Documentation files
    - `README.md` - Documentation on the agent configuration
    - `TROUBLESHOOTING.md` - Solutions for common issues
    - `background-agent-prompt.md` - Example prompts for the background agent
  - `tests/` - Test scripts to validate the background agent environment
    - `run-tests.sh` - Master test script that runs all tests
    - `validate_cursor_environment.sh` - Validates overall environment setup
    - `test-env-setup.sh` - Tests environment variable loading
    - `test-github-integration.sh` - Tests GitHub repository access
    - `test-docker-env.sh` - Tests Docker container setup
    - `test-background-agent.sh` - Tests basic agent configuration
    - `test-agent-runtime.sh` - Tests agent runtime behavior
  - `logs/` - Log files from scripts and agent operations
  - `env.txt` - Environment variable template (don't add sensitive data here)
  - `install.sh` -> `scripts/install.sh` - Symlink to the install script
  - `github-setup.sh` -> `scripts/github-setup.sh` - Symlink to GitHub setup script
  - `retry-utils.sh` -> `scripts/retry-utils.sh` - Symlink to retry utilities

## Configuration

The Background Agent is configured via the `environment.json` file according to the [Cursor Background Agent Documentation](https://docs.cursor.com/background-agent).

## Security

- Do not commit sensitive information like API keys or tokens to the repository
- Create a local `.env` file for your personal credentials (add to `.gitignore`)
- Only use the `env.txt` file as a template with placeholders

## Usage

To start using the Background Agent:

1. Make sure you have set up GitHub integration in Cursor
2. Ensure all scripts are executable: `chmod +x .cursor/scripts/*.sh .cursor/tests/*.sh`
3. Run the tests to validate your setup: `bash .cursor/tests/run-tests.sh`

For any issues, refer to the `TROUBLESHOOTING.md` file in the `docs` directory.
