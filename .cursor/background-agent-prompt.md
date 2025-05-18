# Background Agent Prompt Guide

This document provides guidelines and examples for creating effective prompts when using Cursor's Background Agents. Well-crafted prompts lead to better agent performance and more successful task completion.

## Principles for Effective Agent Prompts

1. **Be specific and clear** - Define exactly what you want the agent to accomplish
2. **Provide context** - Include necessary background information
3. **Set boundaries** - Specify constraints and requirements
4. **Define scope** - Clarify what files/directories the agent should work with
5. **Request verification** - Ask the agent to verify its work through tests

## Prompt Structure

A well-structured prompt typically includes:

```
<Task Description>
<Context/Background>
<Specific Requirements>
<Scope/Boundaries>
<Verification Steps>
<Expected Output/Deliverable>
```

## Example Prompts

### Example 1: Bug Fix

```
Fix the issue in the GitHub repository integration where it fails with "not a git repository" error.

Context:
- The error occurs in the install.sh script when it tries to add the remote origin
- The error message is "fatal: not a git repository (or any of the parent directories): .git"

Requirements:
- Modify the github-setup.sh script in .cursor/scripts/
- Add proper error handling for the scenario where .git directory doesn't exist
- Implement initialization of git repository if it doesn't exist
- Ensure all changes follow our bash scripting standards with proper logging

Scope:
- Only modify the github-setup.sh script
- You can reference retry-utils.sh for utility functions

Verification:
- Run the script and verify it properly initializes a git repository if needed
- Run the test-github-integration.sh script to confirm the fix works

Deliverable:
- Modified github-setup.sh with the fix
- Short explanation of the changes made
```

### Example 2: New Feature Implementation

```
Implement a new validation script for npm packages in the cursor-uninstaller repo.

Context:
- We need to verify npm packages are installed correctly
- The script should be part of our test suite in .cursor/tests/

Requirements:
- Create a new script named test-npm-packages.sh
- The script should verify:
  * Node.js and npm are installed
  * Required global npm packages are installed
  * The npm cache is healthy
  * npm can install a simple test package
- Follow the pattern of existing test scripts with proper logging and error handling
- Exit with appropriate status codes based on test results

Scope:
- Create only in .cursor/tests/
- Reference existing utility functions from .cursor/scripts/retry-utils.sh

Verification:
- Make the script executable
- Run the script manually to verify it works
- Update the run-tests.sh to include this new test

Deliverable:
- New test-npm-packages.sh script that passes all verifications
- Update to run-tests.sh to include the new test
```

### Example 3: Refactoring

```
Refactor the environment.json file to improve organization and readability.

Context:
- The current environment.json has redundant configurations
- Terminal commands could be better organized

Requirements:
- Reorganize the environment.json file structure
- Group related terminals together
- Update script paths to use the new .cursor/scripts/ directory
- Ensure backward compatibility

Scope:
- Only modify the environment.json file
- Don't change actual functionality

Verification:
- Run validate_cursor_environment.sh to ensure everything still works
- Test each terminal configuration to verify it functions correctly

Deliverable:
- Refactored environment.json file
- Brief explanation of the improvements made
```

### Example 4: Documentation Update

```
Update the documentation in .cursor/docs/ to reflect our new directory structure.

Context:
- We recently reorganized files into scripts/, docs/, and tests/ subdirectories
- The current documentation doesn't reflect this new structure

Requirements:
- Update README.md, TROUBLESHOOTING.md, and any other documentation files
- Add information about the purpose of each subdirectory
- Update any file paths mentioned in the documentation
- Add a section about how to run the test suite with the new structure

Scope:
- Only modify files in .cursor/docs/
- Don't change any scripts or configuration files

Verification:
- Review the documentation for accuracy
- Ensure all file paths mentioned are correct

Deliverable:
- Updated documentation files that accurately reflect the new structure
```

## Tips for Complex Tasks

For more complex tasks, consider these additional strategies:

1. **Break down the task** - Divide complex tasks into smaller steps
2. **Provide examples** - Show examples of the expected outcome or similar existing code
3. **Prioritize subtasks** - Indicate which parts are most important
4. **Set decision criteria** - Help the agent make good choices when faced with alternatives
5. **Specify output format** - Describe how you want the results presented

## When to Take Over

Sometimes it's more efficient to take over from the agent:

1. When the agent gets stuck in a loop
2. When the task requires complex debugging that's easier for a human
3. When the task needs access to resources the agent can't access
4. When the agent heads in the wrong direction despite corrections

To take over an agent's work:
- Press Cmd+; (Mac) or Ctrl+; (Windows/Linux)
- This brings you into the agent's environment where you can directly execute commands
- After making changes, you can continue letting the agent work or complete the task yourself

## Limitations to Be Aware Of

1. **File Access** - The agent can only access files within the repository
2. **Authentication** - The agent relies on GitHub credentials provided through Cursor
3. **Resource Limits** - Agents have limits on execution time and resources
4. **External Services** - Access to external services may be limited

By following these guidelines, you'll be able to craft more effective prompts that lead to successful agent outcomes.
