#!/bin/bash

################################################################################
# Git Integration Module - PRODUCTION GRADE GitHub Safety Operations
# Comprehensive Git operations for safe Cursor uninstallation
################################################################################

# Prevent multiple loading
if [[ "${GIT_INTEGRATION_LOADED:-}" == "true" ]]; then
    return 0
fi

################################################################################
# Git Detection and Validation Functions
################################################################################

# Detect if current directory is a Git repository
detect_git_repository() {
    local current_dir
    current_dir=$(pwd)
    
    production_log_message "INFO" "Checking Git repository status in: $current_dir"
    
    # Check for .git directory
    if [[ ! -d ".git" ]]; then
        production_log_message "INFO" "No .git directory found in current location"
        return 1
    fi
    
    # Verify git status command works
    if ! git status >/dev/null 2>&1; then
        production_error_message "Git repository appears corrupted - git status failed"
        return 1
    fi
    
    production_success_message "Valid Git repository detected"
    return 0
}

# Validate Git repository has remote origin
validate_git_remote() {
    production_log_message "INFO" "Validating Git remote configuration"
    
    local remote_output
    remote_output=$(git remote -v 2>/dev/null)
    
    if [[ -z "$remote_output" ]]; then
        production_error_message "No Git remotes configured"
        return 1
    fi
    
    if ! echo "$remote_output" | grep -q "origin"; then
        production_error_message "No 'origin' remote found"
        production_info_message "Available remotes:"
        echo "$remote_output"
        return 1
    fi
    
    local origin_url
    origin_url=$(git remote get-url origin 2>/dev/null)
    
    if [[ -z "$origin_url" ]]; then
        production_error_message "Origin remote URL is not set"
        return 1
    fi
    
    production_success_message "Git remote 'origin' validated: $origin_url"
    return 0
}

# Check for uncommitted changes
check_uncommitted_changes() {
    production_log_message "INFO" "Checking for uncommitted changes"
    
    local status_output
    status_output=$(git status --porcelain 2>/dev/null)
    
    if [[ -n "$status_output" ]]; then
        production_warning_message "Uncommitted changes detected:"
        echo "$status_output"
        return 0  # Return success to indicate changes found
    else
        production_info_message "No uncommitted changes found"
        return 1  # Return failure to indicate no changes
    fi
}

# Get current branch name
get_current_branch() {
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null)
    
    if [[ -z "$current_branch" ]]; then
        production_error_message "Unable to determine current branch"
        return 1
    fi
    
    echo "$current_branch"
    return 0
}

################################################################################
# Git Backup Operations
################################################################################

# Perform complete pre-uninstall Git backup
perform_pre_uninstall_backup() {
    production_log_message "INFO" "Starting pre-Cursor-uninstall Git backup process"
    
    local current_dir
    current_dir=$(pwd)
    
    # Step 1: Detect Git repository
    if ! detect_git_repository; then
        production_info_message "No Git repository in current directory: $current_dir"
        production_info_message "Skipping Git backup operations"
        return 0
    fi
    
    # Step 2: Validate remote configuration
    if ! validate_git_remote; then
        production_error_message "Git repository validation failed"
        production_error_message "Please configure Git remote origin before proceeding"
        return 1
    fi
    
    # Step 3: Check for uncommitted changes
    local has_changes=false
    if check_uncommitted_changes; then
        has_changes=true
        production_warning_message "Found uncommitted changes that need to be backed up"
    fi
    
    # Step 4: Get current branch
    local current_branch
    current_branch=$(get_current_branch)
    if [[ $? -ne 0 ]]; then
        production_error_message "Failed to determine current branch"
        return 1
    fi
    
    production_info_message "Working on branch: $current_branch"
    
    # Step 5: Perform backup operations if needed
    if [[ "$has_changes" == "true" ]]; then
        if ! perform_git_commit_sequence "$current_branch"; then
            production_error_message "Git commit sequence failed"
            return 1
        fi
    else
        production_info_message "No changes to commit, verifying remote synchronization"
        if ! verify_remote_synchronization "$current_branch"; then
            production_error_message "Remote synchronization verification failed"
            return 1
        fi
    fi
    
    production_success_message "Pre-Cursor-uninstall Git backup completed successfully"
    return 0
}

# Perform Git commit sequence
perform_git_commit_sequence() {
    local branch_name="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    production_log_message "INFO" "Performing Git commit sequence for branch: $branch_name"
    
    # Stage all changes
    production_info_message "Staging all changes..."
    if ! git add .; then
        production_error_message "Failed to stage changes with 'git add .'"
        return 1
    fi
    
    # Verify staging was successful
    local staged_files
    staged_files=$(git diff --cached --name-only 2>/dev/null | wc -l)
    if [[ "$staged_files" -eq 0 ]]; then
        production_warning_message "No files were staged for commit"
        return 1
    fi
    
    production_success_message "Successfully staged $staged_files files"
    
    # Create commit with timestamp
    local commit_message="Pre-Cursor-uninstall backup: $timestamp"
    production_info_message "Creating commit: $commit_message"
    
    # Set environment variables to bypass hooks completely
    export SKIP=1
    export PRE_COMMIT_ALLOW_NO_CONFIG=1
    
    if ! git -c core.hooksPath=/dev/null commit --no-verify -m "$commit_message"; then
        production_error_message "Failed to create commit"
        # Clean up environment variables
        unset SKIP PRE_COMMIT_ALLOW_NO_CONFIG
        return 1
    fi
    
    # Clean up environment variables
    unset SKIP PRE_COMMIT_ALLOW_NO_CONFIG
    
    # Verify commit was created
    local latest_commit
    latest_commit=$(git log --oneline -1 2>/dev/null)
    if [[ -z "$latest_commit" ]]; then
        production_error_message "Failed to verify commit creation"
        return 1
    fi
    
    production_success_message "Commit created: $latest_commit"
    
    # Push to remote repository
    production_info_message "Pushing to remote repository..."
    if ! git push origin "$branch_name"; then
        production_error_message "Failed to push to remote repository"
        production_error_message "Manual intervention required before proceeding"
        return 1
    fi
    
    # Verify push success
    if ! verify_remote_synchronization "$branch_name"; then
        production_error_message "Push verification failed"
        return 1
    fi
    
    production_success_message "Git backup sequence completed successfully"
    return 0
}

# Verify remote synchronization
verify_remote_synchronization() {
    local branch_name="$1"
    
    production_log_message "INFO" "Verifying remote synchronization for branch: $branch_name"
    
    # Fetch latest remote information
    if ! git fetch origin >/dev/null 2>&1; then
        production_error_message "Failed to fetch remote information"
        return 1
    fi
    
    # Compare local and remote commits
    local local_commit
    local remote_commit
    
    local_commit=$(git rev-parse HEAD 2>/dev/null)
    remote_commit=$(git rev-parse "origin/$branch_name" 2>/dev/null)
    
    if [[ -z "$local_commit" ]] || [[ -z "$remote_commit" ]]; then
        production_error_message "Failed to get commit information for synchronization check"
        return 1
    fi
    
    if [[ "$local_commit" == "$remote_commit" ]]; then
        production_success_message "Local and remote branches are synchronized"
        production_info_message "Local commit:  $local_commit"
        production_info_message "Remote commit: $remote_commit"
        return 0
    else
        production_error_message "Local and remote branches are NOT synchronized"
        production_error_message "Local commit:  $local_commit"
        production_error_message "Remote commit: $remote_commit"
        return 1
    fi
}

################################################################################
# Interactive Git Operations
################################################################################

# Get user confirmation for Git operations
confirm_git_backup_operations() {
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        production_info_message "Non-interactive mode: Automatically proceeding with Git backup"
        return 0
    fi
    
    echo -e "\n${YELLOW}${BOLD}🔄 PRE-UNINSTALL GIT BACKUP CONFIRMATION${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    echo -e "${BOLD}Git Backup Operations will:${NC}"
    echo -e "  ${BLUE}•${NC} Check current directory for Git repository"
    echo -e "  ${BLUE}•${NC} Validate remote origin configuration"
    echo -e "  ${BLUE}•${NC} Detect any uncommitted changes"
    echo -e "  ${BLUE}•${NC} Stage and commit all changes with timestamp"
    echo -e "  ${BLUE}•${NC} Push commits to remote repository"
    echo -e "  ${BLUE}•${NC} Verify successful synchronization"
    echo ""
    echo -e "${RED}${BOLD}CRITICAL: Cursor uninstallation will only proceed after 100% successful Git operations${NC}"
    echo ""
    
    while true; do
        echo -n "Proceed with Git backup operations? (y/n): "
        read -r response
        
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                production_info_message "User confirmed Git backup operations"
                return 0
                ;;
            [Nn]|[Nn][Oo])
                production_info_message "User declined Git backup operations"
                return 1
                ;;
            *)
                production_warning_message "Please answer 'y' or 'n'"
                ;;
        esac
    done
}

# Display Git repository information
display_git_repository_info() {
    if ! detect_git_repository; then
        production_info_message "Current directory is not a Git repository"
        return 1
    fi
    
    echo -e "\n${BOLD}${BLUE}📁 GIT REPOSITORY INFORMATION${NC}"
    echo -e "${BOLD}═══════════════════════════════════════${NC}\n"
    
    # Current directory
    echo -e "${BOLD}Current Directory:${NC} $(pwd)"
    
    # Current branch
    local current_branch
    current_branch=$(get_current_branch)
    if [[ $? -eq 0 ]]; then
        echo -e "${BOLD}Current Branch:${NC} $current_branch"
    fi
    
    # Remote information
    local remote_output
    remote_output=$(git remote -v 2>/dev/null)
    if [[ -n "$remote_output" ]]; then
        echo -e "${BOLD}Remote Origins:${NC}"
        echo "$remote_output" | sed 's/^/  /'
    fi
    
    # Repository status
    local status_output
    status_output=$(git status --porcelain 2>/dev/null)
    if [[ -n "$status_output" ]]; then
        echo -e "${BOLD}Uncommitted Changes:${NC}"
        echo "$status_output" | sed 's/^/  /'
    else
        echo -e "${BOLD}Repository Status:${NC} Clean (no uncommitted changes)"
    fi
    
    # Recent commits
    echo -e "${BOLD}Recent Commits:${NC}"
    git log --oneline -5 2>/dev/null | sed 's/^/  /' || echo "  No commits found"
    
    echo ""
    return 0
}

################################################################################
# Error Recovery Functions
################################################################################

# Provide specific error resolution guidance
provide_git_error_resolution() {
    local error_type="$1"
    
    echo -e "\n${YELLOW}${BOLD}🔧 GIT ERROR RESOLUTION GUIDANCE${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    case "$error_type" in
        "no_git_repo")
            echo -e "${BOLD}Issue:${NC} No Git repository found"
            echo -e "${BOLD}Resolution:${NC}"
            echo "  1. Initialize Git repository: git init"
            echo "  2. Add remote origin: git remote add origin <repository-url>"
            echo "  3. Make initial commit: git add . && git commit -m 'Initial commit'"
            echo "  4. Push to remote: git push -u origin main"
            ;;
        "no_remote")
            echo -e "${BOLD}Issue:${NC} No Git remote configured"
            echo -e "${BOLD}Resolution:${NC}"
            echo "  1. Add remote origin: git remote add origin <repository-url>"
            echo "  2. Verify remote: git remote -v"
            echo "  3. Push current branch: git push -u origin \$(git branch --show-current)"
            ;;
        "commit_failed")
            echo -e "${BOLD}Issue:${NC} Git commit operation failed"
            echo -e "${BOLD}Resolution:${NC}"
            echo "  1. Check for merge conflicts: git status"
            echo "  2. Resolve any conflicts manually"
            echo "  3. Stage resolved files: git add <resolved-files>"
            echo "  4. Complete commit: git commit"
            ;;
        "push_failed")
            echo -e "${BOLD}Issue:${NC} Git push operation failed"
            echo -e "${BOLD}Resolution:${NC}"
            echo "  1. Check network connectivity"
            echo "  2. Verify authentication: git remote -v"
            echo "  3. Pull latest changes: git pull origin \$(git branch --show-current)"
            echo "  4. Retry push: git push origin \$(git branch --show-current)"
            ;;
        *)
            echo -e "${BOLD}General Git Troubleshooting:${NC}"
            echo "  1. Check Git status: git status"
            echo "  2. Verify remote configuration: git remote -v"
            echo "  3. Check recent commits: git log --oneline -5"
            echo "  4. Verify authentication credentials"
            ;;
    esac
    
    echo -e "\n${RED}${BOLD}IMPORTANT:${NC} Cursor uninstallation will not proceed until Git operations are successful"
    echo ""
}

################################################################################
# Module Initialization
################################################################################

# Mark module as loaded
GIT_INTEGRATION_LOADED="true"

# Export functions for use in other modules
export -f detect_git_repository validate_git_remote check_uncommitted_changes
export -f perform_pre_uninstall_backup display_git_repository_info
export -f confirm_git_backup_operations provide_git_error_resolution 