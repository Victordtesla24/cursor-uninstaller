==============================================
          CURSOR MANAGEMENT UTILITY           
==============================================

[SUCCESS] STATUS: READY

OPTIONS:
  1) CHECK CURSOR STATUS
  2) UNINSTALL CURSOR
  3) OPTIMIZE SYSTEM
  4) GIT OPERATIONS
  5) HEALTH CHECKS
  6) SHOW HELP

OTHER FEATURES:
  7) GIT STATUS
  8) SYSTEM SPECS

  Q) QUIT

ENTER YOUR CHOICE [1-8,Q]: 2
[INFO] EXECUTING COMPLETE CURSOR UNINSTALL

⚠️  COMPLETE CURSOR REMOVAL
═══════════════════════════════════════════════

THIS WILL COMPLETELY AND PERMANENTLY REMOVE ALL CURSOR COMPONENTS:
  • APPLICATION BUNDLE AND ALL EXECUTABLES
  • ALL USER CONFIGURATIONS AND PREFERENCES
  • CACHE FILES AND TEMPORARY DATA
  • CLI TOOLS AND SYSTEM INTEGRATIONS
  • SYSTEM DATABASE REGISTRATIONS
  • BACKGROUND PROCESSES AND SERVICES
  • ALL SETTINGS AND WORKSPACES

NO BACKUPS WILL BE CREATED - THIS IS IRREVERSIBLE

TYPE 'REMOVE' TO CONFIRM COMPLETE CURSOR REMOVAL: REMOVE
[INFO] USER CONFIRMED COMPLETE REMOVAL WITH EXACT CONFIRMATION
[INFO] STARTING COMPLETE CURSOR REMOVAL PROCESS...

🗑️  ENHANCED CURSOR UNINSTALLATION
═══════════════════════════════════════════════════

[INFO] Step 1: Stopping Cursor processes...
[INFO] Found running Cursor processes:
[INFO]   PID 64154: /System/Library/PrivateFrameworks/TextInputUIMacHelper.framework/Versions/A/XPCServices/CursorUIViewService.xpc/Contents/MacOS/CursorUIViewService
[INFO] Attempting graceful termination...
[SUCCESS]   Sent TERM signal to PID 64154
[WARNING] Force killing remaining processes...
[WARNING]   Force killed PID 64154
[INFO] Stopped 2 processes
[SUCCESS] ✓ Cursor processes stopped
[INFO] Step 2: Removing main application...
[INFO] Verified Cursor application bundle: com.todesktop.230313mzl4w4u92 (Cursor)
/Users/vicd/Downloads/cursor_uninstaller/modules/complete_removal.sh: line 376: enhanced_safe_remove: command not found
[ERROR] Failed to remove Cursor.app
[ERROR] ✗ Failed to remove Cursor.app
[INFO] Step 3: Removing user data and preferences...
[INFO] Removing: /Users/vicd/Library/Application Support/Cursor (108M)
/Users/vicd/Downloads/cursor_uninstaller/modules/uninstall.sh: line 238: enhanced_safe_remove: command not found
[ERROR]   ✗ Failed to remove: /Users/vicd/Library/Application Support/Cursor
[INFO] Removing: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist (4.0K)
/Users/vicd/Downloads/cursor_uninstaller/modules/uninstall.sh: line 238: enhanced_safe_remove: command not found
[ERROR]   ✗ Failed to remove: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist
[INFO] Removing: /Users/vicd/.cursor (8.0K)
/Users/vicd/Downloads/cursor_uninstaller/modules/uninstall.sh: line 238: enhanced_safe_remove: command not found
[ERROR]   ✗ Failed to remove: /Users/vicd/.cursor
[SUCCESS] ✓ User data removed (0 items)
[INFO] Step 4: Removing CLI tools...
[INFO] Removing Cursor symlink: /usr/local/bin/cursor -> /Applications/Cursor.app/Contents/Resources/app/bin/code
/Users/vicd/Downloads/cursor_uninstaller/modules/uninstall.sh: line 311: enhanced_safe_remove: command not found
[ERROR]   ✗ Failed to remove: /usr/local/bin/cursor
[WARNING] Cursor command still available at: /usr/local/bin/cursor
[INFO] Manual removal may be required for: /usr/local/bin/cursor
[INFO] Removed 0 CLI tools
[SUCCESS] ✓ CLI tools removed
[INFO] Step 5: Cleaning system caches...
[INFO] Cleaned 0 cache items
[SUCCESS] ✓ System caches cleaned
[INFO] Step 6: Resetting system registrations...
[INFO] Resetting Launch Services database...
[WARNING] lsregister command not available
[INFO] Clearing Spotlight index...
Password:
[SUCCESS] ✓ Spotlight index cleared
[INFO] Reset 1 system registrations
[SUCCESS] ✓ System registrations reset

[INFO] UNINSTALLATION SUMMARY:
[INFO]   Items removed: 2
[INFO]   Errors encountered: 1
[ERROR] Uninstallation completed with 1 errors
[INFO] Phase 1: Component Detection
[INFO] Found: Cursor.app (630M)
[INFO] Found: /Users/vicd/Library/Application Support/Cursor (108M)
[INFO] Found: /usr/local/bin/cursor -> /Applications/Cursor.app/Contents/Resources/app/bin/code
[SUCCESS] Detected 3 Cursor components
[INFO] Performing system-wide search for Cursor files...
[SUCCESS] Found 255 additional Cursor files
[INFO] Phase 2: Background Process Cleanup
[WARNING] Found running Cursor processes:
  PID TTY           TIME CMD
67446 ??         0:00.05 /System/Library/PrivateFrameworks/TextInputUIMacHelper.framework/Versions/A/XPCServices/CursorUIViewService.xpc/Contents/MacOS/CursorUIViewService
[INFO] Terminating Cursor processes...
[INFO] Stopping process: /System/Library/PrivateFrameworks/TextInputUIMacHelper.framework/Versions/A/XPCServices/CursorUIViewService.xpc/Contents/MacOS/CursorUIViewService
[SUCCESS] Terminated process: 67446
[WARNING] Force killing remaining processes...
[WARNING] Force killing process: /System/Library/PrivateFrameworks/TextInputUIMacHelper.framework/Versions/A/XPCServices/CursorUIViewService.xpc/Contents/MacOS/CursorUIViewService
[INFO] Phase 3: Application Removal
[INFO] Verified Cursor application bundle: com.todesktop.230313mzl4w4u92 (Cursor)
/Users/vicd/Downloads/cursor_uninstaller/modules/complete_removal.sh: line 376: enhanced_safe_remove: command not found
[ERROR] Failed to remove Cursor.app
[INFO] Phase 4: User Data Cleanup
[INFO] Removing: /Users/vicd/Library/Application Support/Cursor (108M)
/Users/vicd/Downloads/cursor_uninstaller/modules/complete_removal.sh: line 428: enhanced_safe_remove: command not found
[ERROR] Failed to remove: /Users/vicd/Library/Application Support/Cursor
/Users/vicd/Downloads/cursor_uninstaller/modules/complete_removal.sh: line 453: enhanced_safe_remove: command not found
[ERROR] Failed to remove: /Users/vicd/Library/Application Support/Cursor
/Users/vicd/Downloads/cursor_uninstaller/modules/complete_removal.sh: line 453: enhanced_safe_remove: command not found
[ERROR] Failed to remove: /Users/vicd/.cursor
[INFO] User data removal: 0 removed, 3 failed
[INFO] Phase 5: CLI Tools Removal
[INFO] Removing symlink: /usr/local/bin/cursor -> /Applications/Cursor.app/Contents/Resources/app/bin/code
/Users/vicd/Downloads/cursor_uninstaller/modules/complete_removal.sh: line 487: enhanced_safe_remove: command not found
[INFO] CLI tools removal: 0 items removed
[INFO] Phase 6: System Database Cleanup
[INFO] Resetting Launch Services database...
[SUCCESS] Launch Services database reset successfully
[INFO] Searching for Cursor keychain entries...
[WARNING] Found 3 potential Cursor keychain entries
[INFO] Manual keychain cleanup may be required
[INFO] Phase 7: Removal Verification
[INFO] Performing final system search for remaining Cursor files...
[WARNING] ⚠ 222 Cursor components still remain
[WARNING]   CLI_COMMAND: /usr/local/bin/cursor
[WARNING]   APPLICATION: /Applications/Cursor.app
[WARNING]   REMAINING_FILE: /Users/vicd/Library/Application Support/Cursor
[WARNING]   REMAINING_FILE: /Users/vicd/Library/Application Support/Cursor/User/workspaceStorage/90f50397c351dea77877032db3634637/anysphere.cursor-retrieval
[WARNING]   REMAINING_FILE: /Users/vicd/Library/Application Support/Cursor/logs/20250530T023301/window1/exthost/anysphere.cursor-always-local
[WARNING]   REMAINING_FILE: /Users/vicd/Library/Application Support/Cursor/logs/20250530T023301/window1/exthost/anysphere.cursor-always-local/Cursor Always Local.log
[WARNING]   REMAINING_FILE: /Users/vicd/Library/Application Support/Cursor/logs/20250530T023301/window1/exthost/anysphere.cursor-always-local/Cursor Tab.log
[WARNING]   REMAINING_FILE: /Users/vicd/Library/Application Support/Cursor/logs/20250530T023301/window1/exthost/anysphere.cursor-retrieval
[WARNING]   REMAINING_FILE: /Users/vicd/Library/Application Support/Cursor/logs/20250530T023301/window1/exthost/anysphere.cursor-retrieval/Cursor Git Graph.log
[WARNING]   REMAINING_FILE: /Users/vicd/Library/Application Support/Cursor/logs/20250530T023301/window1/exthost/anysphere.cursor-retrieval/Cursor Indexing & Retrieval.log
[WARNING]   ... and 212 more items
[WARNING] Some Cursor components may still remain
[ERROR] ✗ Complete removal verification failed
[SUCCESS] Removal report saved: /Users/vicd/.cursor-uninstaller/temp/cursor_removal_report_20250530_045421.txt
[ERROR] Complete removal finished with 5 errors
[ERROR] Manual cleanup may be required - see report: /Users/vicd/.cursor-uninstaller/temp/cursor_removal_report_20250530_045421.txt
[ERROR] COMPLETE REMOVAL ENCOUNTERED ERRORS
[ERROR] SOME COMPONENTS MAY STILL REMAIN - MANUAL CLEANUP MAY BE REQUIRED

[ERROR] LINE 1777: COMMAND FAILED: return 1
[ERROR] ERROR COUNT: 1
vicd@Vics-MacBook-Air cursor_uninstaller %
