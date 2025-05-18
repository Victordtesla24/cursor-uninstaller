# Cursor Background Agent Configuration

This directory contains configuration files and scripts for the Cursor Background Agent, enabling AI-powered agents to run asynchronously in a remote environment.

## Directory Structure

- `.cursor/`
  - `environment.json` - Main configuration file for the background agent. Defines build (referencing `../../Dockerfile`), install/start scripts, and terminals.
  - `install.sh` - Run during agent initialization to set up the environment (e.g., install dependencies).
  - `github-setup.sh` - Configures GitHub repository access for the agent.
  - `retry-utils.sh` - Utility functions for retrying operations, sourced by other scripts.
  - `load-env.sh` - Loads environment variables from `.env` or `env.txt`, sourced by other scripts.
  - `cleanup.sh` - Cleans up temporary files, logs, and resources.
  - `create-snapshot.sh` - Helper script to prepare an environment for snapshot creation. This is for an alternative setup to the Dockerfile approach. If using the Dockerfile defined in the project root, this script is not part of the primary agent startup but can be used for manual snapshot creation if desired.
  - `README.md` - This file, explaining the `.cursor` directory.
  - `TROUBLESHOOTING.md` - Solutions for common issues with the background agent setup.
  - `background-agent-prompt.md` - Example prompts and guidelines for interacting with the background agent.
  - `env.txt` - A template for environment variables. Actual secrets should be in a `.env` file (ignored by git).
  - `tests/` - Test scripts to validate the background agent environment.
    - `run-tests.sh` - Master test script that runs all other tests in this directory.
    - `validate_cursor_environment.sh` - Validates overall environment setup integrity.
    - `test-env-setup.sh` - Tests environment variable loading and file/directory permissions.
    - `test-github-integration.sh` - Tests GitHub repository access, cloning, push/pull operations.
    - `test-docker-env.sh` - Tests the Docker container setup, including environment variable propagation and script execution within the container (expects `../../Dockerfile`).
    - `test-background-agent.sh` - Performs basic checks on the agent's core configuration files.
    - `test-agent-runtime.sh` - Simulates and validates the agent's runtime behavior.
  - `logs/` - Log files from scripts and agent operations (e.g., `agent.log`, `install.log`).

Note: The `Dockerfile` for the agent environment should be located in the project root (`../../Dockerfile` relative to this README within `.cursor`).

## Usage

### Setting Up the Background Agent

1. Ensure your repository is connected to GitHub through the Cursor app.
2. Make sure all necessary scripts are executable: `chmod +x .cursor/*.sh .cursor/tests/*.sh`.
3. Validate your environment setup by running the master test script from the project root: `bash .cursor/tests/run-tests.sh`.

### Background Agent Commands

- `Cmd + '` (Mac) or `Ctrl + '` (Windows/Linux): Open the list of background agents.
- `Cmd + ;` (Mac) or `Ctrl + ;` (Windows/Linux): View agent status and enter the machine.

## Environment Configuration

The background agent is configured via the `.cursor/environment.json` file, which contains:

- Container build information (referencing the root `Dockerfile`).
- User context for script execution.
- Installation and startup scripts (e.g., `.cursor/install.sh`).
- Terminal configurations for running processes.

## GitHub Integration

This repository connects to GitHub via the Cursor GitHub app. The background agent needs read-write access to:

- Clone the repository.
- Create branches.
- Push changes.
- Create pull requests.

## Testing and Validation

Run the test suite from the project root to validate your environment:

```bash
bash .cursor/tests/run-tests.sh
```

This will test all aspects of the background agent environment and report any issues that need to be addressed.

## Troubleshooting

If you encounter issues, refer to `.cursor/TROUBLESHOOTING.md` for common problems and solutions.

## References

- [Cursor Background Agent Documentation](https://docs.cursor.com/background-agent)
- [Project Repository](https://github.com/Victordtesla24/cursor-uninstaller.git)
