#!/bin/bash

################################################################################
# Simple Git Integration Module for Cursor AI Editor Management Utility
# PRODUCTION-GRADE GIT OPERATIONS FOR CURRENT REPOSITORY ONLY
################################################################################

# Simple git operations for the current cursor-uninstaller repository
# GitHub repository: https://github.com/Victordtesla24/cursor-uninstaller.git

# Display git repository status for current project
display_git_repository_info() {
    echo -e "\n${BOLD}${BLUE}📊 CURSOR-UNINSTALLER GIT REPOSITORY STATUS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        production_error_message "✗ Current directory is not a git repository"
        return 1
    fi
    
    # Check git installation
    if command -v git >/dev/null 2>&1; then
        local git_version
        git_version=$(git --version 2>/dev/null)
        production_success_message "✓ Git is installed: $git_version"
    else
        production_error_message "✗ Git is not installed on this system"
        return 1
    fi
    
    echo -e "\n${BOLD}REPOSITORY INFORMATION:${NC}"
    
    # Current repository path
    local repo_path
    repo_path=$(pwd)
    echo -e "  ${CYAN}Repository Path:${NC} $repo_path"
    
    # Current branch
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "Not available")
    echo -e "  ${CYAN}Current Branch:${NC} $current_branch"
    
    # Remote information
    echo -e "\n${BOLD}REMOTE CONFIGURATION:${NC}"
    if git remote >/dev/null 2>&1; then
        local remote_count
        remote_count=$(git remote | wc -l | xargs)
        echo -e "  ${CYAN}Remotes Configured:${NC} $remote_count"
        
        if [[ $remote_count -gt 0 ]]; then
            git remote -v | while read -r line; do
                echo -e "  ${CYAN}•${NC} $line"
            done
        fi
    else
        echo -e "  ${YELLOW}⚠ No remote repositories configured${NC}"
    fi
    
    # Repository status
    echo -e "\n${BOLD}WORKING DIRECTORY STATUS:${NC}"
    local status_output
    status_output=$(git status --porcelain 2>/dev/null)
    if [[ -n "$status_output" ]]; then
        local changes_count
        changes_count=$(echo "$status_output" | wc -l | xargs)
        echo -e "  ${YELLOW}⚠ Uncommitted Changes:${NC} $changes_count files"
        
        # Separate relevant changes from generated files
        local relevant_files=()
        local generated_files=()
        
        while IFS= read -r line; do
            local file_path="${line:3}"  # Remove the status prefix
            
            # Check if file should be ignored
            if [[ "$file_path" =~ ^coverage/ ]] || \
               [[ "$file_path" =~ ^node_modules/ ]] || \
               [[ "$file_path" =~ ^\.coverage/ ]] || \
               [[ "$file_path" =~ \.log$ ]] || \
               [[ "$file_path" =~ \.tmp$ ]] || \
               [[ "$file_path" =~ ^tmp/ ]]; then
                generated_files+=("$line")
            else
                relevant_files+=("$line")
            fi
        done <<< "$status_output"
        
        if [[ ${#relevant_files[@]} -gt 0 ]]; then
            echo -e "\n${BOLD}Important Changes (${#relevant_files[@]} files):${NC}"
            for line in "${relevant_files[@]}"; do
                echo -e "    ${CYAN}•${NC} $line"
            done
        fi
        
        if [[ ${#generated_files[@]} -gt 0 ]]; then
            echo -e "\n${BOLD}Generated Files (${#generated_files[@]} files - will be ignored):${NC}"
            for line in "${generated_files[@]}"; do
                echo -e "    ${YELLOW}•${NC} $line"
            done
        fi
    else
        echo -e "  ${GREEN}✓ Clean Working Directory${NC}"
    fi
    
    # Recent commits
    echo -e "\n${BOLD}RECENT COMMITS (Last 5):${NC}"
    if git log --oneline -5 2>/dev/null; then
        :
    else
        echo -e "  ${YELLOW}No commits found${NC}"
    fi
    
    # Repository statistics
    echo -e "\n${BOLD}REPOSITORY STATISTICS:${NC}"
    local commit_count
    commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    echo -e "  ${CYAN}Total Commits:${NC} $commit_count"
    
    local branch_count
    branch_count=$(git branch -a | wc -l | xargs)
    echo -e "  ${CYAN}Total Branches:${NC} $branch_count"
    
    # Check if there are any tags
    local tag_count
    tag_count=$(git tag | wc -l | xargs)
    echo -e "  ${CYAN}Total Tags:${NC} $tag_count"
    
    echo ""
    return 0
}

# Simple git commit and push operation for current repository
perform_git_commit_and_push() {
    echo -e "\n${BOLD}${BLUE}📝 GIT COMMIT AND PUSH OPERATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        production_error_message "✗ Current directory is not a git repository"
        return 1
    fi
    
    # Clean up any generated files first
    production_info_message "Cleaning up generated files..."
    if [[ -d "coverage" ]]; then
        production_info_message "Removing coverage directory..."
        rm -rf coverage
    fi
    
    # Check for changes after cleanup
    local status_output
    status_output=$(git status --porcelain 2>/dev/null)
    if [[ -z "$status_output" ]]; then
        production_info_message "✓ No changes to commit - working directory is clean"
        return 0
    fi
    
    # Filter out files that should not be committed
    local filtered_files=()
    while IFS= read -r line; do
        local file_path="${line:3}"  # Remove the status prefix (e.g., "M  " or "?? ")
        
        # Skip generated/temporary files
        if [[ "$file_path" =~ ^coverage/ ]] || \
           [[ "$file_path" =~ ^node_modules/ ]] || \
           [[ "$file_path" =~ ^\.coverage/ ]] || \
           [[ "$file_path" =~ \.log$ ]] || \
           [[ "$file_path" =~ \.tmp$ ]] || \
           [[ "$file_path" =~ ^tmp/ ]]; then
            log_with_level "DEBUG" "Skipping generated file: $file_path"
            continue
        fi
        
        filtered_files+=("$file_path")
    done <<< "$status_output"
    
    # If no files to commit after filtering
    if [[ ${#filtered_files[@]} -eq 0 ]]; then
        production_info_message "✓ No relevant changes to commit after filtering generated files"
        return 0
    fi
    
    # Show what will be committed
    echo -e "${BOLD}FILES TO BE COMMITTED (${#filtered_files[@]} files):${NC}"
    for file in "${filtered_files[@]}"; do
        local status_char
        status_char=$(git status --porcelain "$file" 2>/dev/null | cut -c1-2)
        echo -e "    ${CYAN}•${NC} [$status_char] $file"
    done
    echo ""
    
    if [[ "$NON_INTERACTIVE_MODE" != "true" ]]; then
        echo -n "Proceed with git add, commit, and push? (Y/n): "
        if read -r -t 30 response 2>/dev/null; then
            case "$response" in
                [Nn]|[Nn][Oo])
                    production_info_message "Git operations cancelled by user"
                    return 0
                    ;;
                ""|[Yy]|[Yy][Ee][Ss])
                    # Continue with operations
                    ;;
                *)
                    production_warning_message "Invalid response, defaulting to 'no'"
                    return 0
                    ;;
            esac
        else
            production_warning_message "No response received, cancelling operations"
            return 0
        fi
    fi
    
    # Create backup point for rollback capability
    local backup_ref
    backup_ref=$(git rev-parse HEAD 2>/dev/null || echo "none")
    if [[ "$backup_ref" != "none" ]]; then
        production_info_message "Creating backup reference: $backup_ref"
    fi
    
    # Add only the filtered files
    production_info_message "Adding relevant changes to staging area..."
    local add_success=true
    for file in "${filtered_files[@]}"; do
        if ! git add "$file" 2>/dev/null; then
            production_warning_message "⚠ Could not add file: $file"
            add_success=false
        fi
    done
    
    if [[ "$add_success" == "true" ]]; then
        production_success_message "✓ Relevant changes staged successfully"
    else
        production_warning_message "⚠ Some files could not be staged, continuing with available files"
    fi
    
    # Verify we have something to commit
    if ! git diff --cached --quiet 2>/dev/null; then
        # Generate commit message
        local commit_message
        commit_message="Update cursor-uninstaller: $(date '+%Y-%m-%d %H:%M:%S')"
        
        if [[ "$NON_INTERACTIVE_MODE" != "true" ]]; then
            echo -n "Enter commit message (or press Enter to use default): "
            read -r user_message
            if [[ -n "$user_message" ]]; then
                commit_message="$user_message"
            fi
        fi
        
        # Commit changes
        production_info_message "Committing changes with message: '$commit_message'"
        if git commit -m "$commit_message"; then
            production_success_message "✓ Changes committed successfully"
        else
            production_error_message "✗ Failed to commit changes"
            return 1
        fi
        
        # Push to remote
        local current_branch
        current_branch=$(git branch --show-current)
        local git_push_timeout=120 # 120 seconds timeout for git push
        
        production_info_message "Pushing changes to remote repository (timeout: ${git_push_timeout}s)..."
        if timeout "${git_push_timeout}" git push origin "$current_branch"; then
            production_success_message "✓ Changes pushed to remote repository successfully"
        else
            local push_exit_code=$?
            production_warning_message "⚠ Failed to push to remote (exit code: $push_exit_code)"
            production_info_message "Commit was successful. If needed, you can reset to the state before this commit using: git reset --hard $backup_ref"
            production_info_message "You can try pushing manually later with: git push origin $current_branch"
        fi
        
        # Show final status
        echo -e "\n${BOLD}FINAL REPOSITORY STATUS:${NC}"
        local final_status
        final_status=$(git status --porcelain 2>/dev/null)
        if [[ -z "$final_status" ]]; then
            production_success_message "✓ Working directory is now clean"
        else
            production_info_message "Remaining files (ignored by commit):"
            git status --short | while read -r line; do
                echo -e "    ${YELLOW}•${NC} $line"
            done
        fi
    else
        production_info_message "✓ No staged changes to commit"
    fi
    
    echo ""
    return 0
}

# Simple git status function (legacy compatibility)
perform_pre_uninstall_backup() {
    echo -e "\n${BOLD}${BLUE}📋 GIT REPOSITORY STATUS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    production_info_message "Showing current repository status instead of backup"
    
    # Display current repository status
    display_git_repository_info
    
    # Suggest committing changes if there are any
    local status_output
    status_output=$(git status --porcelain 2>/dev/null)
    if [[ -n "$status_output" ]]; then
        echo -e "${YELLOW}${BOLD}RECOMMENDATION:${NC}"
        echo -e "  • You have uncommitted changes in the cursor-uninstaller repository"
        echo -e "  • Consider committing and pushing these changes before uninstalling Cursor"
        echo -e "  • Use option 4 again to commit and push changes"
        echo ""
    fi
    
    return 0
}

# Confirm git operations (simplified)
confirm_git_backup_operations() {
    echo -e "\n${YELLOW}${BOLD}📋 GIT REPOSITORY OPERATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}This will show the current cursor-uninstaller repository status${NC}"
    echo -e "${BOLD}and allow you to commit and push any changes.${NC}"
    echo ""
    
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        production_info_message "Non-interactive mode: Proceeding with git status"
        return 0
    fi
    
    echo -n "Continue with git operations? (Y/n): "
    read -r response
    case "$response" in
        [Nn]|[Nn][Oo]) 
            production_info_message "Git operations cancelled by user"
            return 1 
            ;;
        *) 
            production_info_message "User confirmed git operations"
            return 0 
            ;;
    esac
}

# Git integration module loaded
export GIT_INTEGRATION_LOADED=true
log_with_level "DEBUG" "Simple git integration module loaded" 