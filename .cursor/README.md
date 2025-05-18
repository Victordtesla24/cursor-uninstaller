# Cursor Background Agent Configuration

This directory contains the configuration files for the Cursor Background Agent, which allows for asynchronous AI-powered code editing and task execution in a remote environment.

## Files Overview

| File | Purpose |
|------|---------|
| `environment.json` | Main configuration file for the Background Agent |
| `Dockerfile` | Defines the container environment for the agent (declarative approach) |
| `install.sh` | Script run during agent setup to install dependencies |
| `github-setup.sh` | Script to set up GitHub authentication and configuration |
| `retry-utils.sh` | Utility functions for retry logic and error handling |
| `background-agent-prompt.md` | Contains guidance for the agent on how to work with this repository |
| `TROUBLESHOOTING.md` | Guide for solving common issues with the background agent |
| `agent.log` | Log file for agent operations |
| `logs/` | Directory for additional agent logs |

## Configuration Approach

This repository uses the **Declarative (Dockerfile)** approach for setting up the environment:
- `.cursor/Dockerfile` specifies all tools and dependencies
- No project files are copied into the Dockerfile (these are cloned from GitHub)
- Clean, version-controlled approach with explicit dependencies
- Clear separation between environment setup and project code

## Setup Steps

### Prerequisites
1. **Disable privacy mode in Cursor settings**
   - Background agents require privacy mode to be turned off
   - Go to Cursor settings and ensure privacy mode is disabled

2. **GitHub Integration**
   - Grant GitHub read-write access to Cursor for this repository
   - This is required for the agent to clone, commit, and push changes
   - Follow the prompts in the Cursor UI to connect your GitHub account

3. **Repository Setup**
   - Ensure the repository has a valid remote pointing to GitHub
   - The repository should be properly cloned with all configuration files

### Setting Up the Background Agent
1. **Open the Command Palette in Cursor (Cmd/Ctrl+Shift+P)**
   - Search for "Background Agent" and select "Configure Background Agent"

2. **Follow the Setup Wizard**
   - **GitHub Connection**: Follow the prompts to connect your GitHub account
   - **Environment Selection**: Choose Dockerfile setup
     - Select `.cursor/Dockerfile` when prompted
   - **Maintenance Commands**: Set `./.cursor/install.sh` as the install command
   - **Startup Commands**: Set the start command from `environment.json`
   - **Terminals**: Configure the terminals as defined in `environment.json`

3. **Verification**
   - Run `./test-background-agent.sh` to verify the configuration
   - Run `./test-agent-runtime.sh` to test the runtime environment
   - Check the agent's log file at `.cursor/agent.log`

### Configuration Details
- **User**: The agent runs as the `node` user (non-root for security)
- **Install Command**: `./.cursor/install.sh` runs when the machine starts
- **Start Command**: Starts Docker if available and performs initial setup
- **Terminals**: Several terminals are configured to validate and run the app
- **Logging**: All operations are logged to `.cursor/agent.log`

## How to Use

1. **Open Background Agents**
   - Use `Cmd + '` (macOS) or `Ctrl + '` (Windows/Linux)
   - This will show a list of existing agents and an option to create a new one

2. **Create a New Agent**
   - Click "New Agent" to spawn a new agent
   - Provide a task description (see examples below)

3. **Monitor Agent Progress**
   - Use `Cmd + ;` (macOS) or `Ctrl + ;` (Windows/Linux) to view the agent's status
   - This opens the agent's machine where you can see logs and interact with terminals

4. **Interact with the Agent**
   - Send follow-up messages to provide additional instructions
   - Take over the agent's machine if needed to manually help it

## Example Tasks for the Agent

1. **Run Dashboard Tests**
   ```
   Run the dashboard tests in ui/dashboard and fix any failing tests. Create a pull request with your changes.
   ```

2. **Implement a New Feature**
   ```
   Add a dark mode toggle to the dashboard UI. Implement the feature, test it, and create a PR with your changes.
   ```

3. **Code Analysis and Optimization**
   ```
   Analyze the codebase for potential performance improvements. Focus on the dashboard code and create a PR with optimizations.
   ```

4. **Bug Fixing**
   ```
   Investigate why the dashboard doesn't load correctly on Firefox. Debug the issue and implement a fix.
   ```

## Validation and Testing

The agent is preconfigured with validation terminals:
- `agent_validation`: Runs basic configuration validation
- `runtime_validation`: Tests the runtime environment
- `git_status`: Shows repository status for debugging
- `dashboard_dev_server`: Runs the UI dashboard
- `log_monitor`: Monitors the agent's log file

## Security Considerations

- Your code runs in Cursor's AWS infrastructure
- The agent has full access to run commands in the environment
- Secrets are stored encrypted-at-rest using KMS
- Be aware of potential prompt injection risks if the agent accesses external content
- If privacy mode is off, prompts and environments may be collected to improve the service

## Recommended Models

- For longer-running tasks, use the `o3` model as recommended in Cursor documentation
- Only Max Mode-compatible models are available for background agents
- Pricing is based on token usage with potential future charges for compute resources

## Troubleshooting

If the agent encounters issues:
1. Check the terminal outputs for error messages
2. Review `.cursor/agent.log` for detailed logs
3. Examine the git configuration with `git config --list`
4. Validate GitHub connectivity with the `git_status` terminal
5. Run `test-background-agent.sh` and `test-agent-runtime.sh` for diagnostics
6. Ensure privacy mode is disabled in Cursor settings
7. Verify GitHub permissions are correctly set up
8. Refer to the detailed `.cursor/TROUBLESHOOTING.md` guide

## References

- [Cursor Background Agent Documentation](https://docs.cursor.com/background-agent)
- [GitHub Repository](https://github.com/Victordtesla24/cursor-uninstaller.git)
