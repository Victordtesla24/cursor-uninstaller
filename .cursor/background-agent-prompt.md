# Background Agent Prompt

## Project Context
This repository contains a Cursor uninstaller tool with a dashboard UI. The background agent can help with:

1. Building and testing the dashboard UI
2. Running validation tests
3. Making improvements to the code
4. Troubleshooting issues

## Prerequisites

### GitHub Connection Setup
- Background agents require read-write access to your GitHub repository
- You need to grant Cursor GitHub app permission to your repository through the Cursor UI
- This is set up once per repository when you first use background agents
- The agent will clone your repo and create new branches for implementing changes

### Environment Setup
- This project uses a Dockerfile-based environment (declarative approach) in `.cursor/Dockerfile`
- The environment includes Node.js, git, and other development tools needed for the project
- Dependencies are installed via the `.cursor/install.sh` script which runs npm install for both root and dashboard
- The `.cursor/environment.json` file configures how the agent works with terminals for the dashboard and validation

### Security Considerations
- Your code runs in Cursor's AWS infrastructure
- Privacy mode must be turned off to use background agents
- Be aware that agent auto-runs all commands (potential for prompt injection)
- Any secrets needed are stored encrypted-at-rest using KMS

## Task Instructions
When working with this repository, follow these instructions:

### Dashboard Development
- The dashboard code is located in `ui/dashboard/`
- Use `npm run dashboard:dev` to run the dashboard locally
- Run tests with `npm run dashboard:test`

### Uninstaller Script
- The main uninstaller script is `uninstall_cursor.sh`
- Handle this script with care as it's the core functionality

### Agent Validation
- Run `./test-background-agent.sh` to validate your background agent configuration
- Run `./test-agent-runtime.sh` to validate your background agent runtime environment

## Commit and Push Guidelines
When making changes to the repository:
- Create a descriptive branch name (e.g., `fix/dashboard-test-failures`)
- Make atomic, focused commits with clear messages
- Include issue numbers in commit messages if applicable
- Push changes to the remote branch
- Create a pull request with a clear description of changes

## First Tasks to Try
1. **Test Repository Setup**:
   ```bash
   # Check repository status and structure
   git status
   ls -la
   
   # Verify GitHub connection
   git remote -v
   ```

2. **Run Dashboard Tests**:
   ```bash
   # Navigate to dashboard
   cd ui/dashboard
   
   # Run tests and fix any failures
   npm test
   ```

3. **Dashboard Development**:
   ```bash
   # Start the dashboard development server
   cd ui/dashboard
   npm run dev -- --host --no-open
   
   # Monitor for errors and log output
   ```

4. **Code Analysis**:
   ```bash
   # Analyze code structure and suggest improvements
   find . -type f -name "*.js" | xargs wc -l | sort -nr
   ```

## Recommended Models
- For longer-running tasks, use o3 model which is recommended in the Cursor documentation
- Remember that pricing is token-based and only Max Mode-compatible models are available

## Agent Usage
- Open agent list with `Cmd + '` (macOS) or `Ctrl + '` (Windows/Linux)
- Spawn a new agent with specific instructions for the task
- View agent status with `Cmd + ;` (macOS) or `Ctrl + ;` (Windows/Linux)
- Take over or send follow-up messages as needed

## Error Handling and Debugging
If you encounter errors during execution:
- Check the terminal output for error messages
- Review logs in `.cursor/agent.log` for detailed information
- Examine logs in `.cursor/environment-snapshot-info.txt` for environment details
- Examine the git configuration with `git config --list`
- Look for any GitHub authentication issues
- Validate the Docker environment with `test-agent-runtime.sh`

## Notes
- Keep changes focused on improving the codebase without changing core functionality
- Document any changes made for future reference
- Communicate any issues encountered during execution
- The agent creates branches for changes, making it easy to review and merge 

## Sample First Task
To verify the background agent is properly set up, please perform this task:

```
Create a simple log file viewer component in the dashboard UI that can display the contents of the agent log file. 
Add a button to the dashboard that opens this viewer in a modal. Make sure to handle errors gracefully if the log 
file doesn't exist or can't be accessed. Create a pull request with your changes.
``` 