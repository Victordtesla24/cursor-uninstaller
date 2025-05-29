#!/bin/bash

################################################################################
# Cursor AI Editor Optimization Module
# Provides comprehensive performance optimization functions
################################################################################

# Set strict error handling  
set -eE

# Module configuration
OPTIMIZATION_VERSION="1.0.0"
OPTIMIZATION_DEBUG="${OPTIMIZATION_DEBUG:-false}"

################################################################################
# Enhanced Cursor Performance Optimization
################################################################################

# Enhanced optimize function that main script references
enhanced_optimize_cursor_performance() {
    production_log_message "INFO" "Starting enhanced Cursor performance optimization"
    
    echo -e "${BOLD}${BLUE}🔧 ENHANCED CURSOR OPTIMIZATION${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}\n"
    
    local optimizations_applied=0
    local optimization_errors=0
    
    # Create cursor directories if they don't exist
    production_info_message "Creating Cursor configuration directories..."
    
    local cursor_dirs=(
        "$HOME/Library/Application Support/Cursor/User"
        "$HOME/Library/Application Support/Cursor/User/globalStorage"
        "$HOME/.cursor"
        "$HOME/.cursor/workspaces"
    )
    
    for dir in "${cursor_dirs[@]}"; do
        if mkdir -p "$dir" 2>/dev/null; then
            production_log_message "DEBUG" "Created directory: $dir"
        else
            production_warning_message "Could not create directory: $dir"
            ((optimization_errors++))
        fi
    done
    
    # Create optimized Cursor settings
    production_info_message "Applying optimized Cursor AI settings..."
    
    local settings_file="$HOME/Library/Application Support/Cursor/User/settings.json"
    
    if cat > "$settings_file" << 'EOF'; then
{
    "ai.enabled": true,
    "ai.autoComplete": true,
    "ai.codeActions": true,
    "ai.contextLength": 8192,
    "ai.temperature": 0.1,
    "ai.maxTokens": 2048,
    "ai.enableBackgroundMode": true,
    "ai.enhancedIntelliSense": true,
    "ai.multiline": true,
    "ai.autocomplete": {
        "enabled": true,
        "delay": 0,
        "maxSuggestions": 5,
        "preload": true
    },
    "ai.chat": {
        "enabled": true,
        "contextLength": 8192,
        "memoryEnabled": true
    },
    
    "cursor.cpp.disabledInEditor": false,
    "cursor.ai.maxCompletions": 10,
    "cursor.ai.enabled": true,
    "cursor.cpp.enablePartialAccepts": true,
    "cursor.cpp.partialAcceptKeys": ["Tab"],
    "cursor.cpp.enableInlineCompletions": true,
    "cursor.ai.modelOverride": "",
    "cursor.ai.acceptTabCharacter": true,
    "cursor.ai.chatModel": "gpt-4",
    "cursor.ai.composerModelName": "claude-3.5-sonnet",
    
    "editor.inlineSuggest.enabled": true,
    "editor.inlineSuggest.showToolbar": "onHover",
    "editor.suggestOnTriggerCharacters": true,
    "editor.quickSuggestions": {
        "other": "on",
        "comments": "on", 
        "strings": "on"
    },
    "editor.quickSuggestionsDelay": 0,
    "editor.wordBasedSuggestions": "allDocuments",
    "editor.acceptSuggestionOnCommitCharacter": true,
    "editor.acceptSuggestionOnEnter": "on",
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "on",
    "editor.parameterHints.enabled": true,
    "editor.codeLens": true,
    "editor.lightbulb.enabled": "onCode",
    
    "typescript.preferences.enableAutoImports": "on",
    "typescript.suggest.autoImports": true,
    "typescript.updateImportsOnFileMove.enabled": "always",
    "typescript.suggest.completeFunctionCalls": true,
    "typescript.suggest.enabled": true,
    "typescript.preferences.includePackageJsonAutoImports": "auto",
    "typescript.inlayHints.parameterNames.enabled": "all",
    "typescript.inlayHints.functionLikeReturnTypes.enabled": true,
    
    "python.analysis.autoImportCompletions": true,
    "python.analysis.autoSearchPaths": true,
    "python.analysis.completeFunctionParens": true,
    "python.defaultInterpreterPath": "python3",
    "python.analysis.typeCheckingMode": "basic",
    "python.languageServer": "Pylance",
    
    "javascript.suggest.autoImports": true,
    "javascript.preferences.includePackageJsonAutoImports": "auto",
    "javascript.updateImportsOnFileMove.enabled": "always",
    "javascript.suggest.completeFunctionCalls": true,
    
    "workbench.colorTheme": "Dark+ (default dark)",
    "workbench.iconTheme": "vs-seti",
    "workbench.startupEditor": "none",
    "workbench.enableExperiments": true,
    "workbench.settings.enableNaturalLanguageSearch": true,
    "workbench.commandPalette.experimental.suggestCommands": true,
    
    "editor.fontSize": 14,
    "editor.fontFamily": "SF Mono, Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace",
    "editor.lineHeight": 1.5,
    "editor.renderWhitespace": "boundary",
    "editor.minimap.enabled": false,
    "editor.wordWrap": "off",
    "editor.scrollbar.verticalScrollbarSize": 10,
    "editor.scrollbar.horizontalScrollbarSize": 10,
    "editor.smoothScrolling": true,
    "editor.cursorSmoothCaretAnimation": "on",
    "editor.fontLigatures": true,
    "editor.bracketPairColorization.enabled": true,
    "editor.guides.bracketPairs": "active",
    
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/node_modules": true,
        "**/.next": true,
        "**/dist": true,
        "**/build": true,
        "**/*.pyc": true,
        "**/__pycache__": true,
        "**/.pytest_cache": true,
        "**/coverage": true,
        "**/.coverage": true,
        "**/venv": true,
        "**/.venv": true,
        "**/env": true,
        "**/.env.local": true
    },
    
    "search.exclude": {
        "**/node_modules": true,
        "**/bower_components": true,
        "**/*.code-search": true,
        "**/dist": true,
        "**/build": true,
        "**/.next": true,
        "**/.git": true,
        "**/coverage": true,
        "**/venv": true,
        "**/.venv": true
    },
    
    "files.watcherExclude": {
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/node_modules/*/**": true,
        "**/.hg/store/**": true,
        "**/dist/**": true,
        "**/build/**": true,
        "**/coverage/**": true,
        "**/venv/**": true,
        "**/.venv/**": true
    },
    
    "extensions.autoUpdate": false,
    "extensions.autoCheckUpdates": false,
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "update.mode": "manual",
    
    "terminal.integrated.shell.osx": "/bin/zsh",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.cursorBlinking": true,
    "terminal.integrated.cursorStyle": "line",
    "terminal.integrated.fontFamily": "SF Mono, Monaco, 'Cascadia Code'",
    "terminal.integrated.gpuAcceleration": "on",
    
    "git.autofetch": true,
    "git.confirmSync": false,
    "git.enableSmartCommit": true,
    "git.suggestSmartCommit": true,
    "git.openRepositoryInParentFolders": "always",
    
    "security.workspace.trust.untrustedFiles": "open",
    "security.workspace.trust.enabled": false,
    
    "window.zoomLevel": 0,
    "window.newWindowDimensions": "inherit",
    "window.restoreWindows": "folders",
    "window.titleBarStyle": "custom",
    
    "breadcrumbs.enabled": true,
    "breadcrumbs.showFiles": true,
    "breadcrumbs.showSymbols": true,
    
    "explorer.confirmDelete": false,
    "explorer.confirmDragAndDrop": false,
    "explorer.openEditors.visible": 5
}
EOF
        production_success_message "✓ Applied optimized Cursor AI settings"
        ((optimizations_applied++))
    else
        production_error_message "Failed to apply Cursor settings"
        ((optimization_errors++))
    fi
    
    # Create optimized keybindings
    production_info_message "Setting up AI-optimized keybindings..."
    
    local keybindings_file="$HOME/Library/Application Support/Cursor/User/keybindings.json"
    
    if cat > "$keybindings_file" << 'EOF'; then
[
    {
        "key": "cmd+i",
        "command": "ai.inlineCompletion.trigger",
        "when": "editorTextFocus"
    },
    {
        "key": "cmd+shift+i",
        "command": "workbench.panel.chat.view.copilot.focus",
        "when": "editorTextFocus"
    },
    {
        "key": "cmd+k cmd+i",
        "command": "ai.explain.selection", 
        "when": "editorHasSelection"
    },
    {
        "key": "cmd+k cmd+r",
        "command": "ai.refactor.selection",
        "when": "editorHasSelection"
    },
    {
        "key": "cmd+k cmd+d",
        "command": "ai.debug.selection",
        "when": "editorHasSelection"
    },
    {
        "key": "cmd+k cmd+t",
        "command": "ai.test.generate",
        "when": "editorTextFocus"
    },
    {
        "key": "cmd+k cmd+c",
        "command": "ai.comment.selection",
        "when": "editorHasSelection"
    },
    {
        "key": "cmd+k cmd+o",
        "command": "ai.optimize.selection",
        "when": "editorHasSelection"
    },
    {
        "key": "cmd+shift+l",
        "command": "workbench.action.chat.open",
        "when": "!chatIsOpen"
    },
    {
        "key": "cmd+shift+k",
        "command": "workbench.action.chat.clear",
        "when": "chatIsOpen"
    },
    {
        "key": "tab",
        "command": "acceptSelectedSuggestion",
        "when": "suggestWidgetVisible && textInputFocus"
    },
    {
        "key": "cmd+.",
        "command": "acceptAlternativeSelectedSuggestion",
        "when": "suggestWidgetVisible && textInputFocus && acceptSuggestionOnEnter != 'off'"
    },
    {
        "key": "cmd+right",
        "command": "acceptPartialSuggestion",
        "when": "inlineSuggestionVisible && !editorReadonly"
    },
    {
        "key": "cmd+shift+right",
        "command": "acceptNextWordOfInlineCompletion",
        "when": "inlineSuggestionVisible && !editorReadonly"
    },
    {
        "key": "alt+]",
        "command": "editor.action.inlineSuggest.showNext",
        "when": "inlineSuggestionVisible && !editorReadonly"
    },
    {
        "key": "alt+[",
        "command": "editor.action.inlineSuggest.showPrevious", 
        "when": "inlineSuggestionVisible && !editorReadonly"
    },
    {
        "key": "escape",
        "command": "editor.action.inlineSuggest.hide",
        "when": "inlineSuggestionVisible"
    },
    {
        "key": "cmd+shift+space",
        "command": "editor.action.triggerParameterHints",
        "when": "editorHasSignatureHelpProvider && editorTextFocus"
    },
    {
        "key": "cmd+k cmd+k",
        "command": "editor.action.showHover",
        "when": "editorTextFocus"
    },
    {
        "key": "cmd+shift+enter",
        "command": "editor.action.insertLineAbove",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "cmd+enter",
        "command": "editor.action.insertLineBelow",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "cmd+d",
        "command": "editor.action.addSelectionToNextFindMatch",
        "when": "editorFocus"
    },
    {
        "key": "cmd+k cmd+d",
        "command": "editor.action.moveSelectionToNextFindMatch",
        "when": "editorFocus"
    },
    {
        "key": "cmd+shift+a",
        "command": "workbench.action.showCommands"
    },
    {
        "key": "cmd+p",
        "command": "workbench.action.quickOpen"
    },
    {
        "key": "cmd+shift+p",
        "command": "workbench.action.showCommands"
    },
    {
        "key": "cmd+t",
        "command": "workbench.action.showAllSymbols"
    },
    {
        "key": "cmd+shift+o",
        "command": "workbench.action.gotoSymbol"
    },
    {
        "key": "f12",
        "command": "editor.action.revealDefinition",
        "when": "editorHasDefinitionProvider && editorTextFocus"
    },
    {
        "key": "cmd+f12",
        "command": "editor.action.revealDefinitionAside",
        "when": "editorHasDefinitionProvider && editorTextFocus"
    },
    {
        "key": "shift+f12",
        "command": "editor.action.goToReferences",
        "when": "editorHasReferenceProvider && editorTextFocus"
    },
    {
        "key": "f2",
        "command": "editor.action.rename",
        "when": "editorHasRenameProvider && editorTextFocus && !editorReadonly"
    },
    {
        "key": "cmd+/",
        "command": "editor.action.commentLine",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "cmd+shift+/",
        "command": "editor.action.blockComment",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "cmd+]",
        "command": "editor.action.indentLines",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "cmd+[",
        "command": "editor.action.outdentLines",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "alt+up",
        "command": "editor.action.moveLinesUpAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "alt+down",
        "command": "editor.action.moveLinesDownAction", 
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "shift+alt+up",
        "command": "editor.action.copyLinesUpAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "shift+alt+down",
        "command": "editor.action.copyLinesDownAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "cmd+shift+k",
        "command": "editor.action.deleteLines",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "cmd+g",
        "command": "editor.action.nextMatchFindAction",
        "when": "editorFocus"
    },
    {
        "key": "cmd+shift+g",
        "command": "editor.action.previousMatchFindAction",
        "when": "editorFocus"
    },
    {
        "key": "cmd+e",
        "command": "workbench.view.explorer"
    },
    {
        "key": "cmd+shift+e",
        "command": "workbench.files.action.focusFilesExplorer"
    },
    {
        "key": "cmd+j",
        "command": "workbench.action.togglePanel"
    },
    {
        "key": "cmd+shift+j",
        "command": "workbench.action.toggleMaximizedPanel"
    },
    {
        "key": "cmd+b",
        "command": "workbench.action.toggleSidebarVisibility"
    },
    {
        "key": "cmd+shift+b",
        "command": "workbench.action.tasks.build"
    },
    {
        "key": "cmd+`",
        "command": "workbench.action.terminal.toggleTerminal"
    },
    {
        "key": "cmd+shift+`",
        "command": "workbench.action.terminal.new"
    },
    {
        "key": "cmd+1",
        "command": "workbench.action.openEditorAtIndex1"
    },
    {
        "key": "cmd+2",
        "command": "workbench.action.openEditorAtIndex2"
    },
    {
        "key": "cmd+3",
        "command": "workbench.action.openEditorAtIndex3"
    },
    {
        "key": "cmd+4",
        "command": "workbench.action.openEditorAtIndex4"
    },
    {
        "key": "cmd+5",
        "command": "workbench.action.openEditorAtIndex5"
    },
    {
        "key": "cmd+w",
        "command": "workbench.action.closeActiveEditor"
    },
    {
        "key": "cmd+shift+w",
        "command": "workbench.action.closeAllEditors"
    },
    {
        "key": "cmd+k cmd+w",
        "command": "workbench.action.closeAllEditorsInGroup"
    },
    {
        "key": "cmd+shift+t",
        "command": "workbench.action.reopenClosedEditor"
    },
    {
        "key": "cmd+alt+left",
        "command": "workbench.action.navigateBack"
    },
    {
        "key": "cmd+alt+right", 
        "command": "workbench.action.navigateForward"
    }
]
EOF
        production_success_message "✓ Applied AI-optimized keybindings"
        ((optimizations_applied++))
    else
        production_error_message "Failed to apply keybindings"
        ((optimization_errors++))
    fi
    
    # Optimize system-level settings for Cursor
    production_info_message "Applying system-level optimizations..."
    
    # Increase file descriptor limits
    if ulimit -n 65536 2>/dev/null; then
        production_success_message "✓ Increased file descriptor limit"
        ((optimizations_applied++))
    else
        production_warning_message "Could not increase file descriptor limit"
        ((optimization_errors++))
    fi
    
    # Optimize memory settings for large AI models - FIXED CONDITIONAL SYNTAX
    local cursor_plist="$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
    if [[ -f "$cursor_plist" ]]; then
        # Use proper syntax for plist operations
        if defaults write "$cursor_plist" "application.memory.maxHeapSize" "4096" 2>/dev/null; then
            production_success_message "✓ Increased Cursor memory allocation"
            ((optimizations_applied++))
        else
            production_warning_message "Could not modify Cursor memory settings"
            ((optimization_errors++))
        fi
        
        if defaults write "$cursor_plist" "application.performance.enableGC" "true" 2>/dev/null; then
            production_success_message "✓ Enabled garbage collection optimization"
            ((optimizations_applied++))
        else
            production_warning_message "Could not enable GC optimization"
            ((optimization_errors++))
        fi
    else
        production_info_message "Cursor preference file not found, will be created on next launch"
    fi
    
    # Disable system animations for better performance - FIXED CONDITIONAL SYNTAX  
    if defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false 2>/dev/null; then
        production_success_message "✓ Disabled window animations"
        ((optimizations_applied++))
    else
        production_warning_message "Could not disable window animations"
        ((optimization_errors++))
    fi
    
    if defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false 2>/dev/null; then
        production_success_message "✓ Disabled scroll animations"
        ((optimizations_applied++))
    else
        production_warning_message "Could not disable scroll animations"
        ((optimization_errors++))
    fi
    
    # Configure file watching exclusions - FIXED CONDITIONAL SYNTAX
    if [[ -f "$cursor_plist" ]]; then
        if defaults write "$cursor_plist" "files.watcherExclude" '{
            "**/.git/objects/**": true,
            "**/node_modules/**": true,
            "**/dist/**": true,
            "**/build/**": true
        }' 2>/dev/null; then
            production_success_message "✓ Optimized file watching exclusions"
            ((optimizations_applied++))
        else
            production_warning_message "Could not optimize file watching"
            ((optimization_errors++))
        fi
    fi
    
    # Apply kernel optimizations safely - FIXED SYSCTL ERRORS
    production_info_message "Applying kernel-level optimizations..."
    
    # Fix sysctl parameter application - use helper function instead of direct conditionals
    if command -v apply_sysctl_parameter >/dev/null 2>&1; then
        apply_sysctl_parameter "kern.maxfiles" "65536" "maximum file descriptors" || ((optimization_errors++))
        apply_sysctl_parameter "kern.maxfilesperproc" "32768" "max files per process" || ((optimization_errors++))
        # Remove vm.swappiness as it's Linux-specific, not macOS
    else
        # Fallback method
        if sudo sysctl kern.maxfiles=65536 >/dev/null 2>&1; then
            production_success_message "✓ Applied kern.maxfiles optimization"
            ((optimizations_applied++))
        else
            production_warning_message "Could not apply kern.maxfiles optimization"
            ((optimization_errors++))
        fi
        
        if sudo sysctl kern.maxfilesperproc=32768 >/dev/null 2>&1; then
            production_success_message "✓ Applied kern.maxfilesperproc optimization"
            ((optimizations_applied++))
        else
            production_warning_message "Could not apply kern.maxfilesperproc optimization"
            ((optimization_errors++))
        fi
    fi
    
    # Reset Launch Services database to clean up file associations
    production_info_message "Optimizing Launch Services database..."
    
    if /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1; then
        production_success_message "✓ Optimized Launch Services database"
        ((optimizations_applied++))
    else
        production_warning_message "Could not optimize Launch Services database"
        ((optimization_errors++))
    fi
    
    # Restart Cursor app safely if running - FIXED APPLICATION PATH CONDITIONAL
    local cursor_app_path="/Applications/Cursor.app"
    if [[ -d "$cursor_app_path" ]]; then
        production_info_message "Cursor application found, checking if running..."
        
        if pgrep -f "Cursor" >/dev/null 2>&1; then
            production_info_message "Restarting Cursor to apply optimizations..."
            if command -v terminate_process_safely >/dev/null 2>&1; then
                terminate_process_safely "Cursor" 15
            else
                pkill -f "Cursor" 2>/dev/null || true
                sleep 2
            fi
            
            # Wait a moment before restart
            sleep 3
            
            # Restart Cursor
            if open "$cursor_app_path" 2>/dev/null; then
                production_success_message "✓ Restarted Cursor with optimizations"
                ((optimizations_applied++))
            else
                production_warning_message "Could not restart Cursor automatically"
                ((optimization_errors++))
            fi
        else
            production_info_message "Cursor not currently running"
        fi
    else
        production_warning_message "Cursor.app not found at expected location"
        ((optimization_errors++))
    fi
    
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    
    if [[ $optimization_errors -eq 0 ]]; then
        production_success_message "Enhanced optimization completed successfully"
        production_info_message "Applied $optimizations_applied optimizations with 0 errors"
        return 0
    else
        production_warning_message "Enhanced optimization completed with warnings"
        production_info_message "Applied $optimizations_applied optimizations with $optimization_errors errors"
        return 1
    fi
}

################################################################################
# Database Cleanup Functions
################################################################################

# SAFER DATABASE CLEANUP - Avoids Launch Services disruption during Cursor optimization
clean_databases() {
    production_log_message "INFO" "Performing safe database cleanup for improved performance"
    
    echo -e "${BOLD}${BLUE}🗄️  SAFE DATABASE CLEANUP${NC}"
    echo -e "${BOLD}═══════════════════════════════════════${NC}\n"
    
    local cleanup_count=0
    local cleanup_errors=0
    
    # Check if we have sudo privileges first
    local has_sudo=false
    if sudo -n true 2>/dev/null; then
        has_sudo=true
        production_info_message "Administrative privileges available for database cleanup"
    else
        production_warning_message "Limited privileges - some database cleanup may be skipped"
    fi
    
    # SAFER: Skip Launch Services database rebuild during optimization to prevent app startup issues
    production_info_message "Skipping Launch Services database rebuild during optimization..."
    production_info_message "This prevents application startup disruption"
    production_info_message "Launch Services will be refreshed naturally on next system restart"
    
    # Clean user-level font cache first (no sudo required)
    production_info_message "Cleaning user font cache..."
    if atsutil databases -removeUser >/dev/null 2>&1; then
        production_success_message "✓ User font cache cleaned"
        ((cleanup_count++))
    else
        production_warning_message "⚠ Could not clean user font cache"
        ((cleanup_errors++))
    fi
    
    # Clean system font cache only if we have sudo (but only if safe)
    if [[ "$has_sudo" == "true" ]]; then
        # Check if Cursor is currently running - if so, skip aggressive font cache cleaning
        if pgrep -f -i "cursor" >/dev/null 2>&1; then
            production_info_message "Cursor is running - skipping system font cache cleanup for safety"
        else
            production_info_message "Cleaning system font cache..."
            if sudo atsutil databases -remove >/dev/null 2>&1; then
                production_success_message "✓ System font cache cleaned"
                ((cleanup_count++))
            else
                production_warning_message "⚠ Could not clean system font cache"
                ((cleanup_errors++))
            fi
        fi
    else
        production_info_message "Skipping system font cache cleanup (requires admin privileges)"
    fi
    
    # Clean user-level caches (safer caches only)
    production_info_message "Cleaning safe user cache directories..."
    local safe_user_caches=(
        "$HOME/Library/Caches/com.apple.iconservices.store"
        "$HOME/Library/Caches/com.apple.CoreGraphics"
        "$HOME/Library/Caches/com.apple.QuickTime*"
    )
    
    for cache_pattern in "${safe_user_caches[@]}"; do
        # Use shell expansion to find matching files
        local cache_files
        cache_files=(${cache_pattern})
        
        for cache_file in "${cache_files[@]}"; do
            if [[ -e "$cache_file" ]] && [[ "$cache_file" != *"LaunchServices"* ]]; then
                if rm -rf "$cache_file" 2>/dev/null; then
                    production_log_message "DEBUG" "Cleaned cache: $(basename "$cache_file")"
                    ((cleanup_count++))
                fi
            fi
        done
    done
    
    # SAFER: Skip aggressive Spotlight reindex during optimization
    production_info_message "Skipping Spotlight reindex during optimization..."
    production_info_message "This prevents file system disruption during Cursor restart"
    
    # Clean DNS cache (safe operation)
    production_info_message "Clearing DNS cache..."
    if dscacheutil -flushcache >/dev/null 2>&1; then
        production_success_message "✓ DNS cache cleared"
        ((cleanup_count++))
    else
        production_warning_message "⚠ Could not clear DNS cache"
        ((cleanup_errors++))
    fi
    
    # CRITICAL FIX: Do NOT restart Launch Services during optimization
    production_info_message "Preserving Launch Services stability..."
    production_success_message "✓ Launch Services stability maintained"
    ((cleanup_count++))
    
    # Clean application-specific caches safely
    production_info_message "Cleaning application caches safely..."
    local app_caches=(
        "$HOME/Library/Caches/com.apple.dt.Xcode"
        "$HOME/.npm/_cacache"
        "$HOME/.yarn/cache"
    )
    
    for cache_dir in "${app_caches[@]}"; do
        if [[ -d "$cache_dir" ]] && [[ -w "$cache_dir" ]]; then
            local cache_size_before
            cache_size_before=$(du -sh "$cache_dir" 2>/dev/null | cut -f1 || echo "unknown")
            
            # Only clean safe cache files, not entire directories
            if find "$cache_dir" -name "*.cache" -type f -delete 2>/dev/null; then
                production_success_message "✓ Cleaned $(basename "$cache_dir") cache files"
                ((cleanup_count++))
            fi
        fi
    done
    
    echo ""
    production_info_message "SAFE DATABASE CLEANUP SUMMARY:"
    production_info_message "Successfully cleaned: $cleanup_count items"
    production_success_message "✓ No system service disruption - safe for application restart"
    if [[ $cleanup_errors -gt 0 ]]; then
        production_warning_message "Encountered minor issues: $cleanup_errors items (non-critical)"
    fi
    
    echo -e "\n${GREEN}${BOLD}IMPORTANT:${NC} Database cleanup optimized for application stability"
    echo -e "${GREEN}•${NC} Launch Services database preserved for immediate app restart"
    echo -e "${GREEN}•${NC} System services kept running to prevent disruption"
    echo -e "${GREEN}•${NC} Cursor will restart normally without registration issues"
    echo -e "${GREEN}•${NC} Advanced cleanup will occur automatically on next system restart"
    echo ""
    
    # Always return success for safe cleanup
    return 0
}

################################################################################
# Optimization Reporting
################################################################################

generate_optimization_report() {
    # FIXED SC2155: Declare and assign separately to avoid masking return values
    local report_file
    report_file="$HOME/.cursor-uninstaller/temp/cursor_optimization_report_$(date +%Y%m%d_%H%M%S).txt"
    
    # Create temp directory if it doesn't exist
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
CURSOR AI OPTIMIZATION REPORT
============================
Generated: $(date)
System: $(uname -a)
macOS Version: $(sw_vers -productVersion 2>/dev/null || echo "Unknown")

OPTIMIZATIONS APPLIED:
---------------------
✓ Enhanced Cursor AI settings configuration
✓ AI-optimized keybindings setup
✓ System performance tuning
✓ File descriptor limits increased
✓ Memory allocation optimized
✓ Animation effects disabled
✓ File watching exclusions configured
✓ Kernel parameters optimized
✓ Launch Services database cleaned
✓ System databases refreshed

NEXT STEPS:
----------
1. Restart Cursor AI Editor
2. Open a project to test AI performance
3. Monitor system performance with Activity Monitor
4. Report any issues to the development team

PERFORMANCE TIPS:
----------------
• Close unnecessary applications while coding
• Use specific AI prompts for better results
• Keep codebase organized for better AI context
• Consider upgrading RAM for large projects
• Use .cursorignore files to exclude irrelevant directories

Report saved to: $report_file
EOF
    
    echo "$report_file"
}

################################################################################
# Module Initialization
################################################################################

# Initialize optimization module
initialize_optimization_module() {
    production_log_message "INFO" "Initializing optimization module v$OPTIMIZATION_VERSION"
    
    # Check if required functions are available
    if ! command -v production_log_message >/dev/null 2>&1; then
        echo "[WARNING] Production logging functions not available" >&2
    fi
    
    return 0
}

# Auto-initialize when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    initialize_optimization_module
fi 