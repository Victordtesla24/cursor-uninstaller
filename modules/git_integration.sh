#!/bin/bash

################################################################################
# Git Integration Module for Cursor AI Editor Management Utility
# PRODUCTION-GRADE GIT BACKUP AND REPOSITORY FUNCTIONS
################################################################################

# Global variables for git operations
GIT_BACKUP_BASE_DIR="$HOME/cursor_backup_$(date +%Y%m%d_%H%M%S)"
GIT_BACKUP_LOG="$GIT_BACKUP_BASE_DIR/backup.log"
GIT_REPOSITORIES_FOUND=()
GIT_BACKUP_SUCCESS_COUNT=0
GIT_BACKUP_ERROR_COUNT=0

# Initialize git backup environment
initialize_git_backup() {
    local backup_dir="$1"
    
    # Create backup directory
    if ! mkdir -p "$backup_dir"; then
        production_error_message "Failed to create backup directory: $backup_dir"
        return 1
    fi
    
    # Create log file
    if ! touch "$backup_dir/backup.log"; then
        production_error_message "Failed to create backup log file"
        return 1
    fi
    
    # Log backup session start
    {
        echo "==============================================="
        echo "CURSOR UNINSTALLER GIT BACKUP SESSION"
        echo "==============================================="
        echo "BACKUP STARTED: $(date)"
        echo "BACKUP DIRECTORY: $backup_dir"
        echo "SYSTEM: $(uname -a)"
        echo "USER: $(whoami)"
        echo "==============================================="
        echo ""
    } >> "$backup_dir/backup.log"
    
    return 0
}

# Find git repositories in common development directories
find_git_repositories() {
    local search_dirs=(
        "$HOME/Documents"
        "$HOME/Projects"
        "$HOME/Development"
        "$HOME/Code"
        "$HOME/dev"
        "$HOME/workspace"
        "$HOME/git"
        "$HOME/Desktop"
    )
    
    GIT_REPOSITORIES_FOUND=()
    
    production_info_message "Scanning for git repositories..."
    
    for search_dir in "${search_dirs[@]}"; do
        if [[ -d "$search_dir" ]]; then
            production_log_message "DEBUG" "Scanning directory: $search_dir"
            
            # Find git repositories (look for .git directories)
            while IFS= read -r -d '' git_dir; do
                local repo_dir
                repo_dir="$(dirname "$git_dir")"
                
                # Verify it's a valid git repository
                if git -C "$repo_dir" rev-parse --git-dir >/dev/null 2>&1; then
                    GIT_REPOSITORIES_FOUND+=("$repo_dir")
                    production_log_message "DEBUG" "Found git repository: $repo_dir"
                fi
            done < <(find "$search_dir" -type d -name ".git" -not -path "*/node_modules/*" -not -path "*/.npm/*" -not -path "*/vendor/*" -print0 2>/dev/null)
        fi
    done
    
    # Remove duplicates and sort - using portable method instead of mapfile
    if [[ ${#GIT_REPOSITORIES_FOUND[@]} -gt 0 ]]; then
        local temp_array=()
        while IFS= read -r line; do
            temp_array+=("$line")
        done < <(printf '%s\n' "${GIT_REPOSITORIES_FOUND[@]}" | sort -u)
        GIT_REPOSITORIES_FOUND=("${temp_array[@]}")
    fi
    
    local repo_count=${#GIT_REPOSITORIES_FOUND[@]}
    production_info_message "Found $repo_count git repositories"
    
    return 0
}

# Backup a single git repository
backup_git_repository() {
    local repo_path="$1"
    local backup_dir="$2"
    local repo_name
    repo_name="$(basename "$repo_path")"
    local backup_repo_dir="$backup_dir/repositories/$repo_name"
    
    production_info_message "Backing up repository: $repo_name"
    
    # Validate source repository first
    if [[ ! -d "$repo_path" ]]; then
        production_error_message "Source repository directory does not exist: $repo_path"
        echo "$(date): ERROR: Source repository directory does not exist: $repo_path" >> "$GIT_BACKUP_LOG"
        ((GIT_BACKUP_ERROR_COUNT++))
        return 1
    fi
    
    if [[ ! -d "$repo_path/.git" ]]; then
        production_error_message "Not a valid git repository (missing .git): $repo_path"
        echo "$(date): ERROR: Not a valid git repository: $repo_path" >> "$GIT_BACKUP_LOG"
        ((GIT_BACKUP_ERROR_COUNT++))
        return 1
    fi
    
    # Test git operations in source repository
    if ! git -C "$repo_path" rev-parse --git-dir >/dev/null 2>&1; then
        production_error_message "Invalid git repository state: $repo_path"
        echo "$(date): ERROR: Invalid git repository state: $repo_path" >> "$GIT_BACKUP_LOG"
        ((GIT_BACKUP_ERROR_COUNT++))
        return 1
    fi
    
    # Create backup directory for this repository
    if ! mkdir -p "$backup_repo_dir"; then
        production_error_message "Failed to create backup directory for $repo_name"
        echo "$(date): ERROR: Failed to create backup directory for $repo_name: $backup_repo_dir" >> "$GIT_BACKUP_LOG"
        ((GIT_BACKUP_ERROR_COUNT++))
        return 1
    fi
    
    # Get repository information
    local repo_info_file="$backup_repo_dir/repository_info.txt"
    {
        echo "REPOSITORY BACKUP INFORMATION"
        echo "============================="
        echo "Repository Name: $repo_name"
        echo "Original Path: $repo_path"
        echo "Backup Date: $(date)"
        echo "Git Version: $(git --version 2>/dev/null || echo 'Not available')"
        echo ""
        echo "REPOSITORY STATUS:"
        
        # Get repository status (use git -C to avoid changing directories)
        echo "Current Branch: $(git -C "$repo_path" branch --show-current 2>/dev/null || echo 'Not available')"
        echo "Remote URLs:"
        git -C "$repo_path" remote -v 2>/dev/null || echo "No remotes configured"
        echo ""
        echo "Recent Commits (last 10):"
        git -C "$repo_path" log --oneline -10 2>/dev/null || echo "No commits found"
        echo ""
        echo "Repository Status:"
        git -C "$repo_path" status --porcelain 2>/dev/null || echo "Status not available"
        echo ""
        echo "Branches:"
        git -C "$repo_path" branch -a 2>/dev/null || echo "No branches found"
        echo ""
        echo "Tags:"
        git -C "$repo_path" tag -l 2>/dev/null || echo "No tags found"
        echo ""
        echo "Repository Size:"
        du -sh "$repo_path" 2>/dev/null || echo "Size calculation failed"
        
    } > "$repo_info_file"
    
    # Create bare clone for complete backup with improved error handling
    production_log_message "DEBUG" "Creating bare clone of $repo_name"
    production_log_message "DEBUG" "Source: $repo_path"
    production_log_message "DEBUG" "Destination: $backup_repo_dir/repository.git"
    
    # Attempt the git clone with enhanced error handling
    local clone_output=""
    local clone_exit_code=0
    
    # Use a more robust clone approach with proper error capture
    if [[ -w "$(dirname "$backup_repo_dir/repository.git")" ]]; then
        # Ensure destination directory exists and is writable
        mkdir -p "$(dirname "$backup_repo_dir/repository.git")" || {
            production_error_message "✗ Cannot create destination directory for $repo_name"
            echo "$(date): ERROR: Cannot create destination directory for $repo_name" >> "$GIT_BACKUP_LOG"
            ((GIT_BACKUP_ERROR_COUNT++))
            return 1
        }
        
        # Perform git clone with detailed error capture
        clone_output=$(git clone --bare "$repo_path" "$backup_repo_dir/repository.git" 2>&1)
        clone_exit_code=$?
        
        if [[ $clone_exit_code -eq 0 ]]; then
            production_success_message "✓ Successfully backed up repository structure for $repo_name"
            production_log_message "DEBUG" "Clone output: $clone_output"
        else
            production_error_message "✗ Failed to create bare clone for $repo_name (exit code: $clone_exit_code)"
            production_error_message "Git clone error: $clone_output"
            {
                echo "$(date): ERROR: Failed to create bare clone for $repo_name (exit code: $clone_exit_code)"
                echo "$(date): ERROR: Git clone details: $clone_output"
                echo "$(date): ERROR: Source path: $repo_path"
                echo "$(date): ERROR: Destination path: $backup_repo_dir/repository.git"
            } >> "$GIT_BACKUP_LOG"
            
            # Attempt to diagnose the issue
            if [[ ! -d "$repo_path/.git" ]]; then
                production_error_message "Source repository missing .git directory"
                echo "$(date): ERROR: Source repository missing .git directory: $repo_path" >> "$GIT_BACKUP_LOG"
            fi
            
            if [[ ! -r "$repo_path" ]]; then
                production_error_message "Source repository not readable"
                echo "$(date): ERROR: Source repository not readable: $repo_path" >> "$GIT_BACKUP_LOG"
            fi
            
            ((GIT_BACKUP_ERROR_COUNT++))
            return 1
        fi
    else
        production_error_message "✗ Backup destination directory is not writable for $repo_name"
        echo "$(date): ERROR: Backup destination directory is not writable: $(dirname "$backup_repo_dir/repository.git")" >> "$GIT_BACKUP_LOG"
        ((GIT_BACKUP_ERROR_COUNT++))
        return 1
    fi
    
    # Create working directory backup (if there are uncommitted changes)
    if [[ -n "$(git -C "$repo_path" status --porcelain 2>/dev/null)" ]]; then
        production_info_message "Backing up uncommitted changes for $repo_name"
        
        # Create archive of current working directory
        if tar -czf "$backup_repo_dir/working_directory.tar.gz" -C "$repo_path" . 2>/dev/null; then
            production_success_message "✓ Backed up working directory with uncommitted changes"
        else
            production_warning_message "⚠ Could not backup working directory for $repo_name"
        fi
        
        # Save stash if any uncommitted changes (use git -C to avoid directory changes)
        if git -C "$repo_path" stash push -m "Pre-uninstall backup $(date)" >/dev/null 2>&1; then
            production_success_message "✓ Created stash of uncommitted changes"
        fi
    fi
    
    # Log successful backup
    echo "$(date): SUCCESS: Backed up repository $repo_name from $repo_path" >> "$GIT_BACKUP_LOG"
    ((GIT_BACKUP_SUCCESS_COUNT++))
    
    return 0
}

# Perform comprehensive pre-uninstall backup
perform_pre_uninstall_backup() {
    echo -e "\n${BOLD}${BLUE}📦 PRODUCTION-GRADE GIT BACKUP OPERATIONS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Check if git is available
    if ! command -v git >/dev/null 2>&1; then
        production_error_message "Git is not installed on this system"
        production_info_message "Cannot perform git backup without git installation"
        return 1
    fi
    
    production_info_message "Git version: $(git --version)"
    
    # Initialize backup environment
    if ! initialize_git_backup "$GIT_BACKUP_BASE_DIR"; then
        production_error_message "Failed to initialize git backup environment"
        return 1
    fi
    
    production_success_message "✓ Backup directory created: $GIT_BACKUP_BASE_DIR"
    
    # Find git repositories
    if ! find_git_repositories; then
        production_error_message "Failed to scan for git repositories"
        return 1
    fi
    
    local total_repos=${#GIT_REPOSITORIES_FOUND[@]}
    
    if [[ $total_repos -eq 0 ]]; then
        production_warning_message "No git repositories found in common development directories"
        production_info_message "Backup completed - no repositories to backup"
        
        # Create empty backup record
        echo "$(date): INFO: No git repositories found for backup" >> "$GIT_BACKUP_LOG"
        return 0
    fi
    
    echo -e "\n${BOLD}REPOSITORIES FOUND FOR BACKUP:${NC}"
    for i in "${!GIT_REPOSITORIES_FOUND[@]}"; do
        local repo_path="${GIT_REPOSITORIES_FOUND[$i]}"
        local repo_name
        repo_name="$(basename "$repo_path")"
        echo -e "  ${CYAN}$((i+1)).${NC} $repo_name (${repo_path})"
    done
    echo ""
    
    if [[ "$NON_INTERACTIVE_MODE" != "true" ]]; then
        echo -n "Proceed with backing up $total_repos repositories? (Y/n): "
        read -r response
        case "$response" in
            [Nn]|[Nn][Oo])
                production_info_message "Git backup cancelled by user"
                return 1
                ;;
        esac
    fi
    
    production_info_message "Starting backup of $total_repos repositories..."
    
    # Reset counters
    GIT_BACKUP_SUCCESS_COUNT=0
    GIT_BACKUP_ERROR_COUNT=0
    
    # Backup each repository
    for i in "${!GIT_REPOSITORIES_FOUND[@]}"; do
        local repo_path="${GIT_REPOSITORIES_FOUND[$i]}"
        local progress=$((i + 1))
        
        echo -e "\n${BOLD}[$progress/$total_repos]${NC} Processing repository: $(basename "$repo_path")"
        
        if backup_git_repository "$repo_path" "$GIT_BACKUP_BASE_DIR"; then
            production_success_message "✓ Repository backup completed"
        else
            production_error_message "✗ Repository backup failed"
        fi
    done
    
    # Generate backup summary
    local summary_file="$GIT_BACKUP_BASE_DIR/backup_summary.txt"
    {
        echo "CURSOR UNINSTALLER GIT BACKUP SUMMARY"
        echo "====================================="
        echo "Backup Completed: $(date)"
        echo "Total Repositories Found: $total_repos"
        echo "Successfully Backed Up: $GIT_BACKUP_SUCCESS_COUNT"
        echo "Failed Backups: $GIT_BACKUP_ERROR_COUNT"
        echo "Backup Directory: $GIT_BACKUP_BASE_DIR"
        echo ""
        echo "BACKUP CONTENTS:"
        echo "- Repository structures (bare clones)"
        echo "- Working directories with uncommitted changes"
        echo "- Repository information and metadata"
        echo "- Complete backup logs"
        echo ""
        echo "RESTORE INSTRUCTIONS:"
        echo "To restore a repository:"
        echo "1. Navigate to the desired restore location"
        echo "2. Clone from the bare repository:"
        echo "   git clone $GIT_BACKUP_BASE_DIR/repositories/REPO_NAME/repository.git REPO_NAME"
        echo "3. If working directory backup exists, extract it:"
        echo "   tar -xzf $GIT_BACKUP_BASE_DIR/repositories/REPO_NAME/working_directory.tar.gz"
        echo ""
    } > "$summary_file"
    
    # Final backup status
    echo -e "\n${BOLD}${BLUE}📊 BACKUP COMPLETION SUMMARY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Total Repositories:${NC} $total_repos"
    echo -e "${BOLD}Successfully Backed Up:${NC} ${GREEN}$GIT_BACKUP_SUCCESS_COUNT${NC}"
    echo -e "${BOLD}Failed Backups:${NC} ${RED}$GIT_BACKUP_ERROR_COUNT${NC}"
    echo -e "${BOLD}Backup Location:${NC} $GIT_BACKUP_BASE_DIR"
    echo ""
    
    if [[ $GIT_BACKUP_ERROR_COUNT -eq 0 ]]; then
        production_success_message "🎉 ALL REPOSITORIES BACKED UP SUCCESSFULLY"
        production_info_message "Your git repositories are safely backed up before Cursor uninstallation"
    elif [[ $GIT_BACKUP_SUCCESS_COUNT -gt 0 ]]; then
        production_warning_message "⚠ BACKUP COMPLETED WITH SOME ERRORS"
        production_info_message "$GIT_BACKUP_SUCCESS_COUNT repositories backed up successfully"
        production_info_message "$GIT_BACKUP_ERROR_COUNT repositories failed to backup"
    else
        production_error_message "❌ BACKUP FAILED FOR ALL REPOSITORIES"
        production_error_message "Manual backup recommended before proceeding with uninstall"
        return 1
    fi
    
    echo -e "\n${CYAN}${BOLD}BACKUP FILES CREATED:${NC}"
    echo -e "  📁 $GIT_BACKUP_BASE_DIR/"
    echo -e "  📄 backup_summary.txt - Backup summary and restore instructions"
    echo -e "  📄 backup.log - Detailed backup operation log"
    echo -e "  📁 repositories/ - Individual repository backups"
    echo ""
    
    return 0
}

# Confirm git backup operations
confirm_git_backup_operations() {
    echo -e "\n${YELLOW}${BOLD}⚠️  GIT BACKUP CONFIRMATION${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}This will create a comprehensive backup of your git repositories${NC}"
    echo -e "${BOLD}before proceeding with Cursor uninstallation.${NC}"
    echo ""
    echo -e "${CYAN}BACKUP WILL INCLUDE:${NC}"
    echo -e "  • Complete repository history and branches"
    echo -e "  • Uncommitted changes and working directories"
    echo -e "  • Repository metadata and configuration"
    echo -e "  • Detailed backup logs and restore instructions"
    echo ""
    echo -e "${YELLOW}BACKUP LOCATION:${NC} $GIT_BACKUP_BASE_DIR"
    echo ""
    
    if [[ "$NON_INTERACTIVE_MODE" == "true" ]]; then
        production_info_message "Non-interactive mode: Proceeding with git backup"
        return 0
    fi
    
    echo -n "Create comprehensive git backup? (Y/n): "
    read -r response
    case "$response" in
        [Nn]|[Nn][Oo]) 
            production_info_message "Git backup cancelled by user"
            return 1 
            ;;
        *) 
            production_info_message "User confirmed git backup operation"
            return 0 
            ;;
    esac
}

# Display git repository information
display_git_repository_info() {
    echo -e "\n${BOLD}${BLUE}📊 COMPREHENSIVE GIT REPOSITORY STATUS${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    # Check git installation
    if command -v git >/dev/null 2>&1; then
        local git_version
        git_version=$(git --version 2>/dev/null)
        production_success_message "✓ Git is installed: $git_version"
        
        # Get git configuration
        echo -e "\n${BOLD}GIT CONFIGURATION:${NC}"
        local git_user
        git_user=$(git config --global user.name 2>/dev/null || echo "Not configured")
        local git_email
        git_email=$(git config --global user.email 2>/dev/null || echo "Not configured")
        echo -e "  ${CYAN}User Name:${NC} $git_user"
        echo -e "  ${CYAN}User Email:${NC} $git_email"
        
        # Check default branch configuration
        local default_branch
        default_branch=$(git config --global init.defaultBranch 2>/dev/null || echo "Not configured")
        echo -e "  ${CYAN}Default Branch:${NC} $default_branch"
        
    else
        production_error_message "✗ Git is not installed on this system"
        echo -e "\n${YELLOW}To install Git:${NC}"
        echo -e "  • Download from: https://git-scm.com/download/mac"
        echo -e "  • Or use Homebrew: brew install git"
        echo -e "  • Or use Xcode Command Line Tools: xcode-select --install"
        return 1
    fi
    
    # Find and analyze repositories
    find_git_repositories
    
    local total_repos=${#GIT_REPOSITORIES_FOUND[@]}
    echo -e "\n${BOLD}REPOSITORY DISCOVERY:${NC}"
    echo -e "  ${CYAN}Repositories Found:${NC} $total_repos"
    
    if [[ $total_repos -gt 0 ]]; then
        echo -e "\n${BOLD}REPOSITORY DETAILS:${NC}"
        
        for i in "${!GIT_REPOSITORIES_FOUND[@]}"; do
            local repo_path="${GIT_REPOSITORIES_FOUND[$i]}"
            local repo_name
            repo_name="$(basename "$repo_path")"
            
            echo -e "\n  ${BOLD}$((i+1)). $repo_name${NC}"
            echo -e "     ${CYAN}Path:${NC} $repo_path"
            
            # Get repository status
            if cd "$repo_path" 2>/dev/null; then
                local current_branch
                current_branch=$(git branch --show-current 2>/dev/null || echo "Not available")
                echo -e "     ${CYAN}Current Branch:${NC} $current_branch"
                
                local commit_count
                commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
                echo -e "     ${CYAN}Total Commits:${NC} $commit_count"
                
                local last_commit
                last_commit=$(git log -1 --format="%h - %s (%cr)" 2>/dev/null || echo "No commits")
                echo -e "     ${CYAN}Last Commit:${NC} $last_commit"
                
                local status_output
                status_output=$(git status --porcelain 2>/dev/null)
                if [[ -n "$status_output" ]]; then
                    local changes_count
                    changes_count=$(echo "$status_output" | wc -l | xargs)
                    echo -e "     ${YELLOW}⚠ Uncommitted Changes:${NC} $changes_count files"
                else
                    echo -e "     ${GREEN}✓ Clean Working Directory${NC}"
                fi
                
                local remote_count
                remote_count=$(git remote | wc -l | xargs)
                if [[ $remote_count -gt 0 ]]; then
                    echo -e "     ${CYAN}Remotes:${NC} $remote_count configured"
                    local main_remote
                    main_remote=$(git remote get-url origin 2>/dev/null || git remote | head -1 2>/dev/null || echo "Not available")
                    echo -e "     ${CYAN}Primary Remote:${NC} $main_remote"
                else
                    echo -e "     ${YELLOW}⚠ No Remote Repositories${NC}"
                fi
                
                # Check repository size
                local repo_size
                repo_size=$(du -sh "$repo_path" 2>/dev/null | cut -f1 || echo "Unknown")
                echo -e "     ${CYAN}Repository Size:${NC} $repo_size"
            fi
        done
        
        # Summary statistics
        echo -e "\n${BOLD}BACKUP RECOMMENDATIONS:${NC}"
        
        local repos_with_changes=0
        local repos_without_remotes=0
        
        for repo_path in "${GIT_REPOSITORIES_FOUND[@]}"; do
            if cd "$repo_path" 2>/dev/null; then
                if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
                    ((repos_with_changes++))
                fi
                if [[ $(git remote | wc -l) -eq 0 ]]; then
                    ((repos_without_remotes++))
                fi
            fi
        done
        
        if [[ $repos_with_changes -gt 0 ]]; then
            echo -e "  ${YELLOW}⚠${NC} $repos_with_changes repositories have uncommitted changes"
            echo -e "    ${CYAN}Recommendation:${NC} Commit or stash changes before uninstalling"
        fi
        
        if [[ $repos_without_remotes -gt 0 ]]; then
            echo -e "  ${YELLOW}⚠${NC} $repos_without_remotes repositories have no remote backups"
            echo -e "    ${CYAN}Recommendation:${NC} Push to remote repositories or create local backups"
        fi
        
        echo -e "\n  ${GREEN}✓${NC} All repositories will be included in backup if git backup is performed"
        
    else
        echo -e "\n${YELLOW}No git repositories found in common development directories.${NC}"
        echo -e "\n${CYAN}Searched directories:${NC}"
        echo -e "  • $HOME/Documents"
        echo -e "  • $HOME/Projects"
        echo -e "  • $HOME/Development"
        echo -e "  • $HOME/Code"
        echo -e "  • $HOME/dev"
        echo -e "  • $HOME/workspace"
        echo -e "  • $HOME/git"
        echo -e "  • $HOME/Desktop"
    fi
    
    echo ""
    return 0
}

# Git integration module loaded
export GIT_INTEGRATION_LOADED=true
production_log_message "DEBUG" "Git integration module loaded with production-grade functionality" 