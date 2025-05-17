# Background Agent Troubleshooting Guide

This guide provides solutions for common issues encountered with Cursor Background Agents.

## GitHub Authentication Issues

### Symptoms
- "Unable to fetch from GitHub" errors
- Repository connection failures
- Failed to push commits
- Permission denied errors

### Solutions
1. **Check GitHub App Permission**
   - Ensure the Cursor GitHub App has read/write access to your repository
   - Go to GitHub → Settings → Applications → Authorized OAuth Apps → Cursor
   - Verify permissions include repository access

2. **Reset GitHub Token**
   - In Cursor, go to Command Palette → "Background Agent: Reconnect GitHub"
   - Follow the authentication flow to refresh your token

3. **Manual Token Configuration**
   - Generate a GitHub personal access token with repo scope
   - Set as environment variable: `GITHUB_TOKEN=your_token_here`
   - Restart the background agent

## Log Directory Issues

### Symptoms
- "No such file or directory" errors when writing to logs
- Missing `.cursor/agent.log` file

### Solutions
1. **Create Required Directories**
   ```bash
   mkdir -p .cursor/logs
   touch .cursor/agent.log
   ```

2. **Check File Permissions**
   ```bash
   chmod 755 .cursor
   chmod 644 .cursor/agent.log
   ```

## Repository Configuration Issues

### Symptoms
- "Not a git repository" errors
- Remote configuration failures

### Solutions
1. **Verify Git Installation**
   ```bash
   git --version
   ```

2. **Initialize Repository Properly**
   ```bash
   git init
   git config --global init.defaultBranch main
   git remote add origin https://github.com/Victordtesla24/cursor-uninstaller.git
   ```

3. **Update Remote URL**
   ```bash
   git remote set-url origin https://github.com/Victordtesla24/cursor-uninstaller.git
   ```

## Connection and Network Issues

### Symptoms
- Timeout errors
- Network connection failures
- "Connection refused" errors

### Solutions
1. **Check Internet Connection**
   ```bash
   curl -I https://github.com
   ```

2. **Test DNS Resolution**
   ```bash
   nslookup github.com
   ```

3. **Proxy Configuration**
   If behind a proxy, set:
   ```bash
   git config --global http.proxy http://proxy-url:port
   ```

## Background Agent Setup Issues

### Symptoms
- "Agent setup failed" errors
- GitHub initialization failures
- Docker-related errors

### Solutions
1. **Check Prerequisite Software**
   - Docker: `docker --version`
   - Git: `git --version`
   - Node.js: `node --version`

2. **Verify Environment Configuration**
   - Check `.cursor/environment.json` format
   - Validate `.cursor/Dockerfile` syntax
   - Ensure `.cursor/install.sh` is executable

3. **Run Validation Scripts**
   ```bash
   bash ./test-background-agent.sh
   bash ./test-agent-runtime.sh
   ```

## Performance and Resource Issues

### Symptoms
- Agent running slowly
- High CPU or memory usage
- Container timeout errors

### Solutions
1. **Monitor Container Resources**
   ```bash
   docker stats
   ```

2. **Increase Container Resources**
   - Adjust Docker settings to allow more CPU/memory
   - Split complex tasks into smaller subtasks

3. **Optimize Build Process**
   - Use caching in Docker builds
   - Optimize npm/yarn installation with frozen lockfiles

## Log Inspection and Debugging

### How to Access Logs
1. **Agent Logs**
   ```bash
   cat .cursor/agent.log
   ```

2. **Terminal Logs**
   - Use the `log_monitor` terminal in the agent UI
   - Command: `tail -f .cursor/agent.log`

3. **Docker Container Logs**
   ```bash
   docker logs <container-id>
   ```

## Contacting Support

If you continue to experience issues after trying these solutions:

1. Collect the following information:
   - Background agent logs (`.cursor/agent.log`)
   - Validation test results
   - Cursor version
   - Error messages

2. Contact support via:
   - Email: support@cursor.sh
   - Discord: #background-agent channel
   - GitHub Issues 