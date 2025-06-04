══════════════════════════════════════════════════════════
               CURSOR MANAGEMENT UTILITY v4.0.0
══════════════════════════════════════════════════════════

[2025-06-04 18:59:43] [SUCCESS] [MAIN] STATUS: READY

OPTIONS:
  1) Check Cursor Status
  2) Uninstall Cursor  
  3) Optimize System
  4) Git Operations
  5) Health Checks
  6) Show Help
  
ADVANCED:
  7) Git Status
  8) System Specs
  
  Q) Quit

Enter your choice [1-8,Q]: 2
[2025-06-04 18:59:47] [INFO] [UNINSTALL] Executing complete Cursor uninstall

⚠️  COMPLETE CURSOR REMOVAL - SECURITY ENHANCED
═══════════════════════════════════════════════════════════════════════

THIS WILL COMPLETELY AND PERMANENTLY REMOVE ALL CURSOR COMPONENTS:
  • Application bundle and all executables
  • User configurations and preferences  
  • Cache files and temporary data
  • CLI tools and system integrations
  • System database registrations

SECURITY FEATURES:
  • Path validation and traversal protection
  • Process isolation and proper termination
  • Comprehensive cleanup with verification
  • Atomic operations with rollback capability

NO BACKUPS WILL BE CREATED - THIS IS IRREVERSIBLE

Type "REMOVE" to confirm complete removal (attempt 1/3): REMOVE
[2025-06-04 18:59:51] [INFO] [UNINSTALL] User confirmed complete removal
[2025-06-04 18:59:51] [INFO] [UNINSTALL] Starting enhanced uninstall process...
\033[0;36m[2025-06-04 18:59:51] [INFO] [uninstall] Starting enhanced Cursor uninstall process...\033[0m
================================================================================

CURSOR UNINSTALL
Removing Cursor application and associated files

--------------------------------------------------------------------------------
\033[0;36m[2025-06-04 18:59:51] [INFO] [uninstall] Preparing for Cursor uninstall...\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO] Performing comprehensive system validation...\033[0m
\033[0;32m[2025-06-04 18:59:51] [SUCCESS] macOS version 15.5 is supported\033[0m
\033[0;32m[2025-06-04 18:59:51] [SUCCESS] Memory: 8GB available\033[0m
\033[0;32m[2025-06-04 18:59:51] [SUCCESS] Disk space: 151GB available on root\033[0m
\033[0;32m[2025-06-04 18:59:51] [SUCCESS] All required commands available\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO] System Integrity Protection: enabled\033[0m
\033[0;32m[2025-06-04 18:59:51] [SUCCESS] System validation passed with no issues\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO] [uninstall] Found Cursor application at: /Applications/Cursor.app\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO] [uninstall] Found 5 user data directories\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO] [uninstall] Found 1 CLI installations\033[0m
\033[0;32m[2025-06-04 18:59:51] [SUCCESS] [uninstall] Uninstall preparation completed\033[0m
[████░░░░░░░░░░░░░░░░░░░░░░]  16% Terminating Cursor processes\033[0;36m[2025-06-04 18:59:51] [INFO] Initiating cursor process termination...\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO] Termination attempt 1 of 3\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO] Found cursor processes:\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO]   PID 59445: /System/Library/PrivateFrameworks/TextInputUIMacHelper.framework/Versions/A/XPCServices/CursorUIViewService.xpc/Contents/MacOS/CursorUIViewService\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO]   PID 59770: /bin/bash\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO] Attempting graceful shutdown...\033[0m
\033[0;36m[2025-06-04 18:59:51] [INFO] Sent quit signal to Cursor application (attempt 1)\033[0m
\033[0;36m[2025-06-04 19:00:02] [INFO] Sending TERM signal to remaining processes...\033[0m
\033[1;33m[2025-06-04 19:00:07] [WARNING] Some processes require force termination\033[0m
\033[0;36m[2025-06-04 19:00:07] [INFO] Force killing PID 59445\033[0m
\033[0;36m[2025-06-04 19:00:09] [INFO] Termination attempt 2 of 3\033[0m
\033[0;32m[2025-06-04 19:00:10] [SUCCESS] No cursor processes found\033[0m
\033[0;32m[2025-06-04 19:00:10] [SUCCESS] [uninstall] Cursor processes terminated successfully\033[0m
[████████░░░░░░░░░░░░░░░░░░]  33% Removing main application\033[0;36m[2025-06-04 19:00:10] [INFO] [uninstall] Removing Cursor.app (641M)...\033[0m
\033[0;36m[2025-06-04 19:00:10] [INFO] Removing directory: /Applications/Cursor.app (641M (7936 files), mode: 755)\033[0m
\033[0;32m[2025-06-04 19:00:10] [SUCCESS] Successfully removed directory: /Applications/Cursor.app\033[0m
\033[0;32m[2025-06-04 19:00:10] [SUCCESS] [uninstall] Cursor application removed successfully\033[0m
\033[1;33m[█████████████░░░░░░░░░░░░░]  50% Removing user data\033[0m\033[0;36m[2025-06-04 19:00:10] [INFO] [uninstall] Removing user data: /Users/vicd/Library/Application Support/Cursor (255M)\033[0m
\033[0;31m[2025-06-04 19:00:10] [ERROR] SECURITY: Path contains dangerous characters: /Users/vicd/Library/Application Support/Cursor\033[0m
\033[0;31m[2025-06-04 19:00:10] [ERROR] [uninstall] Failed to remove: /Users/vicd/Library/Application Support/Cursor\033[0m
\033[0;36m[2025-06-04 19:00:10] [INFO] [uninstall] Removing user data: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist (4.0K)\033[0m
\033[0;36m[2025-06-04 19:00:10] [INFO] Removing file: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist (4.0K, mode: 600)\033[0m
\033[0;36m[2025-06-04 19:00:10] [INFO] Created backup: /Users/vicd/.cursor_management/backups/com.todesktop.230313mzl4w4u92.plist.backup.1749027610\033[0m
\033[0;32m[2025-06-04 19:00:10] [SUCCESS] Successfully removed file: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist\033[0m
\033[0;32m[2025-06-04 19:00:10] [SUCCESS] [uninstall] Removed: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist\033[0m
\033[0;36m[2025-06-04 19:00:10] [INFO] [uninstall] Removing user data: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92 (212K)\033[0m
\033[0;36m[2025-06-04 19:00:10] [INFO] Removing directory: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92 (212K (3 files), mode: 755)\033[0m
\033[1;33m[2025-06-04 19:00:10] [WARNING] Possible traces remain in parent directory: /Users/vicd/Library/Caches\033[0m
\033[0;32m[2025-06-04 19:00:10] [SUCCESS] Successfully removed directory: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92\033[0m
\033[0;32m[2025-06-04 19:00:10] [SUCCESS] [uninstall] Removed: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92\033[0m
\033[0;36m[2025-06-04 19:00:10] [INFO] [uninstall] Removing user data: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt ( 40K)\033[0m
\033[0;36m[2025-06-04 19:00:10] [INFO] Removing directory: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt ( 40K (3 files), mode: 755)\033[0m
\033[0;32m[2025-06-04 19:00:11] [SUCCESS] Successfully removed directory: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt\033[0m
\033[0;32m[2025-06-04 19:00:11] [SUCCESS] [uninstall] Removed: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt\033[0m
\033[0;36m[2025-06-04 19:00:11] [INFO] [uninstall] Removing user data: /Users/vicd/Library/HTTPStorages/com.todesktop.230313mzl4w4u92 (168K)\033[0m
\033[0;36m[2025-06-04 19:00:11] [INFO] Removing directory: /Users/vicd/Library/HTTPStorages/com.todesktop.230313mzl4w4u92 (168K (3 files), mode: 755)\033[0m
\033[1;33m[2025-06-04 19:00:11] [WARNING] Possible traces remain in parent directory: /Users/vicd/Library/HTTPStorages\033[0m
\033[0;32m[2025-06-04 19:00:11] [SUCCESS] Successfully removed directory: /Users/vicd/Library/HTTPStorages/com.todesktop.230313mzl4w4u92\033[0m
\033[0;32m[2025-06-04 19:00:11] [SUCCESS] [uninstall] Removed: /Users/vicd/Library/HTTPStorages/com.todesktop.230313mzl4w4u92\033[0m
\033[1;33m[2025-06-04 19:00:11] [WARNING] [uninstall] Some user data could not be removed (1 errors)\033[0m
\033[1;33m[█████████████████░░░░░░░░░]  66% Removing CLI tools\033[0m\033[0;36m[2025-06-04 19:00:11] [INFO] [uninstall] No CLI tools found\033[0m
\033[0;36m[█████████████████████░░░░░]  83% Cleaning system registrations\033[0m\033[0;36m[2025-06-04 19:00:11] [INFO] [uninstall] Cleaning system registrations...\033[0m
\033[0;36m[2025-06-04 19:00:11] [INFO] [uninstall] Resetting Launch Services database...\033[0m
\033[0;32m[2025-06-04 19:00:13] [SUCCESS] [uninstall] Launch Services database reset\033[0m
\033[0;36m[2025-06-04 19:00:13] [INFO] [uninstall] Clearing Spotlight metadata...\033[0m
could not find path '/Applications/Cursor.app'
general import and options -t, and -r require one or more paths
\033[0;32m[2025-06-04 19:00:16] [SUCCESS] [uninstall] Spotlight metadata cleared\033[0m
\033[0;34m[2025-06-04 19:00:16] [DEBUG] [uninstall] Font cache clearing skipped (fc-cache not available)\033[0m
\033[0;32m[2025-06-04 19:00:16] [SUCCESS] [uninstall] System registrations cleaned\033[0m
\033[0;32m[██████████████████████████] 100% Verifying removal\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] Verifying uninstall completion...\033[0m
\033[1;33m[2025-06-04 19:00:16] [WARNING] [uninstall] User data still exists: /Users/vicd/Library/Application Support/Cursor\033[0m
\033[1;33m[2025-06-04 19:00:16] [WARNING] [uninstall] Uninstall verification found 1 remaining items\033[0m
\033[1;33m[2025-06-04 19:00:16] [WARNING] [uninstall] Some components may still remain\033[0m


================================================================================
Enhanced Cursor Uninstall SUMMARY
--------------------------------------------------------------------------------
Total Steps: 6
Completed: 6
Successful: 4
Warnings: 2
Duration: 25 seconds
================================================================================

\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] 📋 POST-UNINSTALL INFORMATION\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] ═══════════════════════════════════════════════\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] What was removed:\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • Cursor application bundle\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • User preferences and settings\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • Application caches and temporary files\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • CLI tools and system integrations\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • Launch Services registrations\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] Additional cleanup (optional):\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • Check Keychain Access for any saved Cursor passwords\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • Review browser bookmarks for Cursor-related sites\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • Clear any custom aliases or PATH modifications\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] Reinstallation:\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • Download fresh copy from: https://cursor.sh\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • Previous settings will not be restored automatically\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] • Extensions and customizations will need to be reconfigured\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] 💡 Consider upgrading to the latest version when reinstalling\033[0m
\033[0;36m[2025-06-04 19:00:16] [INFO] [uninstall] Enhanced uninstall completed with 2 warnings\033[0m
[2025-06-04 19:00:17] [SUCCESS] [UNINSTALL] Enhanced uninstall completed
[2025-06-04 19:00:17] [INFO] [UNINSTALL] Starting complete removal process...
\033[0;36m[2025-06-04 19:00:17] [INFO] [complete_removal] Initiating complete Cursor removal process...\033[0m
[███░░░░░░░░░░░░░░░░░░░░░░░]  14% Validating Cursor installation\033[0;36m[2025-06-04 19:00:17] [INFO] [complete_removal] Validating Cursor installation presence...\033[0m
\033[0;36m[2025-06-04 19:00:17] [INFO] [complete_removal] Found user data: /Users/vicd/Library/Application Support/Cursor\033[0m
\033[0;36m[2025-06-04 19:00:17] [INFO] [complete_removal] Found 1 Cursor components for removal\033[0m
[███████░░░░░░░░░░░░░░░░░░░]  28% Terminating Cursor processes\033[0;36m[2025-06-04 19:00:17] [INFO] [complete_removal] Starting comprehensive process termination...\033[0m
\033[0;36m[2025-06-04 19:00:17] [INFO] [complete_removal] Sent application quit signal (attempt 1)\033[0m
\033[0;36m[2025-06-04 19:00:19] [INFO] [complete_removal] Sent application quit signal (attempt 2)\033[0m
\033[0;36m[2025-06-04 19:00:21] [INFO] [complete_removal] Sent application quit signal (attempt 3)\033[0m
\033[0;36m[2025-06-04 19:00:23] [INFO] Initiating cursor process termination...\033[0m
\033[0;36m[2025-06-04 19:00:23] [INFO] Termination attempt 1 of 3\033[0m
\033[0;32m[2025-06-04 19:00:23] [SUCCESS] No cursor processes found\033[0m
\033[0;32m[2025-06-04 19:00:23] [SUCCESS] [complete_removal] All Cursor processes terminated successfully\033[0m
[██████████░░░░░░░░░░░░░░░░]  42% Removing main application\033[0;36m[2025-06-04 19:00:23] [INFO] [complete_removal] Main application not found\033[0m
\033[1;33m[██████████████░░░░░░░░░░░░]  57% Removing user data\033[0m\033[0;31m[2025-06-04 19:00:23] [ERROR] SECURITY: Path contains dangerous characters: /Users/vicd/Library/Application Support/Cursor\033[0m
\033[0;31m[2025-06-04 19:00:23] [ERROR] [complete_removal] Failed to remove user data: /Users/vicd/Library/Application Support/Cursor\033[0m
\033[0;36m[██████████████████████░░░░]  85% Cleaning Core Data caches\033[0m\033[0;36m[2025-06-04 19:00:23] [INFO] [complete_removal] Starting comprehensive Core Data cache cleanup...\033[0m
/Users/Shared/cursor/cursor-uninstaller/modules/complete_removal.sh: line 127: validated_locations[*]: unbound variable
vicd@Vics-MacBook-Air cursor-uninstaller % 