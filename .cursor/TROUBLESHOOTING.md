# Background Agent Troubleshooting Guide

This guide helps you troubleshoot common issues with Cursor Background Agents.

## Common Issues and Solutions

### 1. GitHub Authentication Issues

**Symptoms:**
- Error messages about GitHub authentication failure
- Failed pull/push operations 
- Messages about "Permission denied" or "Could not read from remote repository"

**Solutions:**
1. **Verify GitHub Integration in Cursor:**
   - Open Cursor settings and check that GitHub integration is enabled
   - Make sure you've granted Cursor read-write permissions to your repository
   - If needed, disconnect and reconnect your GitHub account in Cursor settings

2. **Check Git Configuration:**
   - Run `git config --list` to see your current configuration
   - Ensure your user name and email are properly set
   - Verify that credential helper is configured: `git config --global credential.helper 'cache --timeout=3600'`

3. **Force Token Refresh:**
   - Disconnect and reconnect GitHub in Cursor settings
   - Restart Cursor and try again

### 2. Agent Cannot Access Files or Directories

**Symptoms:**
- "Permission denied" errors
- "No such file or directory" errors
- File operation failures

**Solutions:**
1. **Check Directory Structure:**
   - Ensure the `.cursor` directory exists and has the right permissions
   - Make sure all necessary subdirectories like `.cursor/logs` exist

2. **Fix Ownership and Permissions:**
   - Run `ls -la .cursor` to check file permissions
   - Ensure files are owned by the correct user and have appropriate permissions
   - Run `chmod +x .cursor/*.sh` to make scripts executable

3. **Create Missing Files/Directories:**
   - Ensure `.cursor/agent.log` exists: `touch .cursor/agent.log` 
   - Create missing directories: `mkdir -p .cursor/logs`

### 3. Background Agent Startup Fails

**Symptoms:**
- Agent status shows "Error" or "Failed"
- Agent process terminates prematurely

**Solutions:**
1. **Check Docker Configuration:**
   - Ensure Docker is installed and running
   - Verify the Dockerfile in `.cursor/Dockerfile` is valid
   - Try building the Docker image manually: `docker build -t cursor-agent-test -f .cursor/Dockerfile .`

2. **Verify Environment.json:**
   - Check `.cursor/environment.json` for syntax errors
   - Remove any trailing commas or invalid JSON
   - Ensure all paths in the file are correct

3. **Run Validation Script:**
   - Run `./test-background-agent.sh` to check for configuration issues
   - Address any errors reported by the script

### 4. Agent Cannot Install Dependencies

**Symptoms:**
- npm install failures
- Package resolution errors
- Messages about network issues

**Solutions:**
1. **Check Package.json:**
   - Ensure package.json files have valid syntax
   - Verify that all dependencies exist and are accessible

2. **Network Issues:**
   - Check if npm registry is accessible
   - If behind a proxy, configure npm to use it: `npm config set proxy YOUR_PROXY`

3. **Clear npm Cache:**
   - In the agent environment, try: `npm cache clean --force` 
   - Then retry installation

### 5. Agent Cannot Start Services or Terminals

**Symptoms:**
- Terminals fail to start or crash immediately
- Services report errors or don't respond

**Solutions:**
1. **Check Terminal Commands:**
   - Verify commands in `environment.json` terminals section
   - Make sure paths in commands are correct
   - Consider using absolute paths rather than relative ones

2. **Port Conflicts:**
   - If services fail because ports are in use, modify them in your config
   - Check if multiple services try to use the same port

3. **Run Commands Manually:**
   - Connect to the agent environment
   - Run terminal commands manually to identify specific errors

## Advanced Troubleshooting

### Accessing Logs

Background agent logs are stored in the following locations:
- `.cursor/agent.log` - Main agent log
- `.cursor/logs/` - Additional log files
- `.cursor/environment-snapshot-info.txt` - Environment information

To inspect logs:
```bash
cat .cursor/agent.log
ls -la .cursor/logs/
```

### Running Validation Tests

```bash
# Run basic validation
./test-background-agent.sh

# Run runtime validation
./test-agent-runtime.sh
```

### Manual Environment Testing

You can test building the environment manually:
```bash
# Build Docker image
docker build -t cursor-agent-test -f .cursor/Dockerfile .

# Run container with mounted directory
docker run -it --rm -v "$(pwd):/agent_workspace" cursor-agent-test bash

# Inside the container, run the install script
cd /agent_workspace
bash ./.cursor/install.sh
```

## Contacting Support

If you've tried the above troubleshooting steps and still encounter issues:

1. Collect the following information:
   - Background agent logs
   - Output from validation scripts
   - Cursor version
   - OS and environment details

2. Contact Cursor support:
   - Submit an issue on GitHub
   - Share your logs and environment details
   - Be specific about the error and steps to reproduce 