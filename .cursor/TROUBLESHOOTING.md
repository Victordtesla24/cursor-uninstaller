# Background Agent Troubleshooting Guide

This document provides solutions to common issues that may arise with the Cursor Background Agent.

## Table of Contents

- [Background Agent Troubleshooting Guide](#background-agent-troubleshooting-guide)
  - [Table of Contents](#table-of-contents)
  - [GitHub Authentication Issues](#github-authentication-issues)
    - [Symptoms](#symptoms)
    - [Solutions](#solutions)
  - [Logging Issues](#logging-issues)
    - [Symptoms](#symptoms-1)
    - [Solutions](#solutions-1)
  - [Terminal Output Issues](#terminal-output-issues)
    - [Symptoms](#symptoms-2)
    - [Solutions](#solutions-2)
  - [Dependencies Installation Issues](#dependencies-installation-issues)
    - [Symptoms](#symptoms-3)
    - [Solutions](#solutions-3)
  - [Docker-related Issues](#docker-related-issues)
    - [Symptoms](#symptoms-4)
    - [Solutions](#solutions-4)
  - [Log File Creation Issues](#log-file-creation-issues)
    - [Symptoms](#symptoms-5)
    - [Solutions](#solutions-5)
  - [Environment Configuration Issues](#environment-configuration-issues)
    - [Symptoms](#symptoms-6)
    - [Solutions](#solutions-6)
  - [Git Repository Issues](#git-repository-issues)
    - [Symptoms](#symptoms-7)
    - [Solutions](#solutions-7)
  - [General Troubleshooting Steps](#general-troubleshooting-steps)
  - [GitHub Permission Errors (403, 401)](#github-permission-errors-403-401)
    - [Symptoms](#symptoms-8)
    - [Solutions](#solutions-8)

## GitHub Authentication Issues

### Symptoms
- Agent cannot push to GitHub
- "Permission denied" errors when attempting to access GitHub
- Failed GitHub operations in the log
- "repository not found" errors when attempting to access a private repository

### Solutions
1. **Verify GitHub App Installation**
   - Ensure you've installed the Cursor GitHub App with read-write permissions for your repository
   - Go to GitHub > Settings > Applications > Installed GitHub Apps and verify Cursor has access

2. **Check Permissions for Private Repositories**
   - If you're using a private repository, you need explicit permissions for GitHub access
   - For GitHub Actions workflows, add the following to your workflow file:
     ```yaml
     permissions:
       contents: read  # Required for accessing private repositories
     ```
   - This is necessary because setting any permissions in a workflow overwrites ALL default permissions
   - See the [GitHub issue #254](https://github.com/actions/checkout/issues/254) for more details

3. **Refresh Authentication**
   - The background agent will automatically attempt to refresh GitHub tokens
   - If issues persist, try disconnecting and reconnecting the GitHub integration in Cursor settings

4. **Manual GitHub Setup**
   - Run the GitHub setup script manually:
     ```bash
     bash .cursor/github-setup.sh
     ```
   - Check the output for any errors

## Logging Issues

### Symptoms
- Missing log files
- "No such file or directory" errors when trying to write logs
- Agent operations not being logged properly
- Log files contain old data making debugging difficult
- Error.md file is not updated after test runs

### Solutions
1. **Create Log Directories**
   - Ensure the log directories exist:
     ```bash
     mkdir -p .cursor/logs
     touch .cursor/logs/agent.log
     ```

2. **Check Permissions**
   - Verify the agent user has write access to log locations:
     ```bash
     sudo chown -R node:node .cursor/logs .cursor/logs/agent.log
     ```

3. **Flush Logs Before Testing**
   - Use the flush-logs.sh script to clear old logs before running tests:
     ```bash
     bash .cursor/flush-logs.sh
     ```
   - This ensures only the latest logs are kept, making debugging easier

4. **Monitor Logs**
   - Use the log_monitor terminal to watch the agent logs in real-time:
     ```bash
     tail -f .cursor/logs/agent.log
     ```

5. **Error.md Management**
   - The error.md file is automatically updated after each test run
   - If it's not being updated, run the update-error-md.sh script manually:
     ```bash
     bash .cursor/update-error-md.sh
     ```
   - This ensures error.md always contains the latest test results

## Terminal Output Issues

### Symptoms
- Agent cannot read command output
- PSReadLine errors in Windows PowerShell
- Incomplete command outputs or missing results

### Solutions
1. **Windows PowerShell Issues**
   - If you're using Windows, the agent may have trouble with PowerShell output
   - In Cursor settings, enable "Use Preview Box" in Terminal preferences
   - Consider using WSL (Windows Subsystem for Linux) for more reliable terminal behavior

2. **Command Output Handling**
   - The agent may have trouble with complex table outputs
   - Prefer commands that output simple, text-based results
   - Consider redirecting command output to files for the agent to read:
     ```bash
     some_command > output.txt
     ```

3. **Background Process Issues**
   - For long-running commands, ensure they provide clear output when completed
   - Use the `wait` command to ensure processes complete before proceeding

## Dependencies Installation Issues

### Symptoms
- Failed npm installations
- Missing dependencies
- Timeout errors during installation

### Solutions
1. **Retry with Timeout Control**
   - The agent uses retry logic for npm installations
   - You can adjust the timeout in `.cursor/retry-utils.sh`
   - For manual retries with longer timeouts:
     ```bash
     run_with_timeout 600 npm install
     ```

2. **Network Issues**
   - If npm install fails due to network issues, try:
     ```bash
     npm config set registry https://registry.npmjs.org/
     npm cache clean --force
     ```

3. **Package Lock Issues**
   - If package-lock.json conflicts occur:
     ```bash
     rm -f package-lock.json
     npm install
     ```

## Docker-related Issues

### Symptoms
- Docker service not starting
- Docker command not found
- Container permission issues

### Solutions
1. **Docker Service Management**
   - The agent tries to start Docker if available
   - Ensure Docker is properly installed in the agent environment
   - Check if Docker needs to be started with different commands:
     ```bash
     # Add to .cursor/environment.json start command if needed
     systemctl start docker || service docker start
     ```

2. **Docker Permissions**
   - If the agent user needs Docker access:
     ```bash
     sudo usermod -aG docker node
     ```

3. **Docker Not Required**
   - If your project doesn't need Docker, you can remove or comment out Docker-related commands in the environment.json file

## Log File Creation Issues

### Symptoms
- `tee: .cursor/agent.log: No such file or directory` errors
- Agent scripts failing when attempting to write logs
- Missing log directories or files

### Solutions
1. **Ensure Directory Structure in Dockerfile**
   - Verify the Dockerfile creates the necessary directories:
     ```docker
     RUN mkdir -p /home/node/.cursor/logs && \
         touch /home/node/.cursor/agent.log && \
         chown -R node:node /home/node/.cursor
     ```

2. **Pre-Create Logs in Scripts**
   - Scripts have been updated to create log directories and files at runtime
   - Ensure you're using the latest script versions from this repository
   - If you encounter issues, manually create the directories and files:
     ```bash
     mkdir -p .cursor/logs
     touch .cursor/agent.log
     chmod 664 .cursor/agent.log
     ```

3. **Verify Working Directory**
   - Issues can occur if scripts run from unexpected directories
   - Make sure commands run from the repository root or with absolute paths
   - Add `cd /agent_workspace` to scripts if needed

## Environment Configuration Issues

### Symptoms
- Agent cannot start properly
- Missing or incorrect environment configuration
- Errors about the environment.json file

### Solutions
1. **Validate Environment JSON**
   - Check that your environment.json follows the correct format:
     ```bash
     cat .cursor/environment.json | jq
     ```
   - Required fields: user, install, start, terminals

2. **Snapshot vs Dockerfile Approach**
   - This project uses the Dockerfile approach - ensure you're not trying to use a snapshot ID
   - If using the Dockerfile approach, include the build section:
     ```json
     "build": {
       "dockerfile": "Dockerfile",
       "context": "."
     }
     ```

3. **Terminal Configuration**
   - Ensure each terminal entry has name, command, and description fields
   - Test terminals manually to ensure commands work:
     ```bash
     bash -c "cd ui/dashboard && npm run dev -- --host --no-open"
     ```

## Git Repository Issues

### Symptoms
- "fatal: not a git repository" errors
- Failed git operations in install.sh
- Agent unable to clone or push to repository

### Solutions
1. **Initialize Repository Properly**
   - If you're seeing errors with git repository initialization:
     ```bash
     git init
     git config --global init.defaultBranch main
     touch README.md
     git add README.md
     git commit -m "Initial commit"
     ```

2. **Check Working Directory**
   - Ensure scripts are running in the correct directory:
     ```bash
     # Add to your scripts to debug:
     echo "Current directory: $(pwd)"
     ```
   - If scripts expect to run in `/agent_workspace` but are running elsewhere, update scripts to change directory:
     ```bash
     if [ -d "/agent_workspace" ] && [ "$(pwd)" != "/agent_workspace" ]; then
       cd /agent_workspace
     fi
     ```

3. **Fix Remote Issues**
   - If remote operations are failing, verify and set the remote correctly:
     ```bash
     # Check current remote
     git remote -v

     # Remove problematic remote if needed
     git remote remove origin

     # Add correct remote
     git remote add origin https://github.com/Victordtesla24/cursor-uninstaller.git
     ```

4. **Permission Issues**
   - If git operations fail due to permission issues:
     ```bash
     # Make directories writable
     chmod -R 755 .git

     # Ensure correct user ownership
     sudo chown -R $(whoami) .git
     ```

## General Troubleshooting Steps

1. **Check the logs**
   ```bash
   cat .cursor/agent.log
   cat .cursor/logs/*
   ```

2. **Verify environment configuration**
   ```bash
   cat .cursor/environment.json
   ```

3. **Run validation scripts**
   ```bash
   bash ./test-background-agent.sh
   bash ./test-agent-runtime.sh
   bash ./validate_cursor_environment.sh
   ```

4. **Check GitHub configuration**
   ```bash
   git config --list
   git remote -v
   ```

5. **Restart the agent**
   - Sometimes, simply restarting the Cursor background agent can resolve issues
   - Use `Cmd/Ctrl + '` to access the agent menu and create a new agent

For issues not covered here, please report them to the Cursor team through the Discord #background-agent channel or via email to background-agent-feedback@cursor.com.

## GitHub Permission Errors (403, 401)

### Symptoms
- "Permission to [repository] denied to [username]" errors when pushing
- "The requested URL returned error: 403" messages 
- Push/pull operations fail with authentication errors
- Error messages indicating "remote: Permission to [repo] denied"

### Solutions

1. **Check and Update GitHub Token**
   - The most common cause of permission errors is an expired or invalid GitHub token
   - Generate a new Personal Access Token (PAT) from GitHub Settings:
     1. Go to https://github.com/settings/tokens
     2. Click "Generate new token" and select "Classic"
     3. Give it a name like "Cursor Background Agent"
     4. Check the "repo" permission to grant full access to repositories
     5. Copy the generated token and update your `.env` file:
     ```
     GITHUB_TOKEN=github_pat_YOUR_NEW_TOKEN_HERE
     ```

2. **Fix Authentication Configuration Issues**
   - Clean up existing token configurations:
   ```bash
   # Remove all token-based URL configurations
   git config --global --unset-all "url.https://x-access-token:*@github.com/.insteadOf"
   
   # Set up proper credential helper
   git config --global credential.helper store
   
   # Add your credentials to the store (replace with your values)
   echo "https://YOUR_USERNAME:YOUR_TOKEN@github.com" > ~/.git-credentials
   chmod 600 ~/.git-credentials
   ```

3. **Run the GitHub Setup Script to Reconfigure**
   - The `.cursor/github-setup.sh` script can automatically fix many GitHub authentication issues:
   ```bash
   bash .cursor/github-setup.sh
   ```

4. **Verify Repository Access**
   - Ensure your GitHub account has proper access to the repository
   - For organization repositories, check if your access is still valid
   - Confirm you have write access to the repository in GitHub repository settings

5. **Check for Two-Factor Authentication Issues**
   - If you have 2FA enabled, you must use a PAT token instead of password
   - Ensure your PAT has the necessary permissions for the repository

6. **Correct Remote URL Format**
   - Verify your remote URL is correctly formatted:
   ```bash
   # Check current remote
   git remote -v
   
   # Set correct remote if needed
   git remote set-url origin https://github.com/USERNAME/REPOSITORY.git
   ```
