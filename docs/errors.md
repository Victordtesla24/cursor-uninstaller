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
[INFO]   PID 67757: /System/Library/PrivateFrameworks/TextInputUIMacHelper.framework/Versions/A/XPCServices/CursorUIViewService.xpc/Contents/MacOS/CursorUIViewService
[INFO]   PID 73796: /Applications/Cursor.app/Contents/MacOS/Cursor
[INFO]   PID 73798: /Applications/Cursor.app/Contents/Frameworks/Electron Framework.framework/Helpers/chrome_crashpad_handler
[INFO]   PID 73800: /Applications/Cursor.app/Contents/Frameworks/Cursor Helper (GPU).app/Contents/MacOS/Cursor Helper (GPU)
[INFO]   PID 73801: /Applications/Cursor.app/Contents/Frameworks/Cursor Helper.app/Contents/MacOS/Cursor Helper
[INFO]   PID 73804: /Applications/Cursor.app/Contents/Frameworks/Cursor Helper (Renderer).app/Contents/MacOS/Cursor Helper (Renderer)
[INFO]   PID 74107: Cursor Helper: shared-process
[INFO]   PID 74108: Cursor Helper: fileWatcher [1]
[INFO]   PID 74133: Cursor Helper (Plugin): extension-host [1-1]
[INFO]   PID 74134: Cursor Helper: terminal pty-host
[INFO]   PID 74466: /Applications/Cursor.app/Contents/Frameworks/Cursor Helper (Plugin).app/Contents/MacOS/Cursor Helper (Plugin)
[INFO]   PID 74872: /Applications/Cursor.app/Contents/Frameworks/Cursor Helper (Plugin).app/Contents/MacOS/Cursor Helper (Plugin)
[INFO] Attempting graceful termination...
[SUCCESS]   Sent TERM signal to PID 67757
[SUCCESS]   Sent TERM signal to PID 73796
[SUCCESS]   Sent TERM signal to PID 73798
[SUCCESS]   Sent TERM signal to PID 73800
[SUCCESS]   Sent TERM signal to PID 73801
[SUCCESS]   Sent TERM signal to PID 73804
[SUCCESS]   Sent TERM signal to PID 74107
[SUCCESS]   Sent TERM signal to PID 74108
[SUCCESS]   Sent TERM signal to PID 74133
[SUCCESS]   Sent TERM signal to PID 74134
[SUCCESS]   Sent TERM signal to PID 74466
[SUCCESS]   Sent TERM signal to PID 74872
[WARNING] Force killing remaining processes...
[WARNING]   Force killed PID 67757
[WARNING]   Force killed PID 73796
[WARNING]   Force killed PID 75924
[WARNING]   Force killed PID 75925
[WARNING]   Force killed PID 75926
[INFO] Stopped 17 processes
[SUCCESS] ✓ Cursor processes stopped
[INFO] Step 2: Removing main application...
[INFO] Verified Cursor application bundle: com.todesktop.230313mzl4w4u92 (Cursor)
[2025-05-30 05:50:05] [INFO] [PROD_SAFE_REMOVE] Attempting to remove: /Applications/Cursor.app
[2025-05-30 05:50:05] [SUCCESS] [PROD_SAFE_REMOVE] Successfully removed: /Applications/Cursor.app
[SUCCESS] Removed Cursor.app (630M)
[SUCCESS] ✓ Cursor.app removed
[INFO] Step 3: Removing user data and preferences...
[INFO] Removing: /Users/vicd/Library/Application Support/Cursor (120M)
[2025-05-30 05:50:05] [INFO] [PROD_SAFE_REMOVE] Attempting to remove: /Users/vicd/Library/Application Support/Cursor
[2025-05-30 05:50:05] [SUCCESS] [PROD_SAFE_REMOVE] Successfully removed: /Users/vicd/Library/Application Support/Cursor
[SUCCESS]   ✓ Removed: /Users/vicd/Library/Application Support/Cursor
[INFO] Removing: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist (4.0K)
[2025-05-30 05:50:05] [INFO] [PROD_SAFE_REMOVE] Attempting to remove: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist
[2025-05-30 05:50:05] [SUCCESS] [PROD_SAFE_REMOVE] Successfully removed: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist
[SUCCESS]   ✓ Removed: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist
[INFO] Removing: /Users/vicd/.cursor (8.0K)
[2025-05-30 05:50:05] [INFO] [PROD_SAFE_REMOVE] Attempting to remove: /Users/vicd/.cursor
[2025-05-30 05:50:05] [SUCCESS] [PROD_SAFE_REMOVE] Successfully removed: /Users/vicd/.cursor
[SUCCESS]   ✓ Removed: /Users/vicd/.cursor
[SUCCESS] ✓ User data removed (3 items)
[INFO] Step 4: Removing CLI tools...
[INFO] Removed 0 CLI tools
[SUCCESS] ✓ CLI tools removed
[INFO] Step 5: Cleaning system caches...
[INFO] Cleaned 0 cache items
[SUCCESS] ✓ System caches cleaned
[INFO] Step 6: Resetting system registrations...
[INFO] Resetting Launch Services database...
[SUCCESS] ✓ Launch Services database reset
[INFO] Clearing Spotlight index...
Password:
[SUCCESS] ✓ Spotlight index cleared
[INFO] Reset 2 system registrations
[SUCCESS] ✓ System registrations reset

[INFO] UNINSTALLATION SUMMARY:
[INFO]   Items removed: 6
[INFO]   Errors encountered: 0
[SUCCESS] 🎉 Enhanced uninstallation completed successfully
[INFO] Phase 1: Component Detection
[INFO] No Cursor components detected
[INFO] Performing system-wide search for Cursor files...
[SUCCESS] Found 155 additional Cursor files
[INFO] Phase 2: Background Process Cleanup
[INFO] No running Cursor processes found
[INFO] Phase 3: Application Removal
[INFO] Cursor.app not found at /Applications/Cursor.app
[INFO] Phase 4: User Data Cleanup
[INFO] User data removal: 0 removed, 0 failed
[INFO] Phase 5: CLI Tools Removal
[INFO] CLI tools removal: 0 items removed
[INFO] Phase 6: System Database Cleanup
[INFO] Resetting Launch Services database...
[SUCCESS] Launch Services database reset successfully
[INFO] Removing specific Cursor entries...
[INFO] Searching for Cursor keychain entries...
[WARNING] Found 3 potential Cursor keychain entries
[INFO] Manual keychain cleanup may be required
[INFO] Phase 7: Removal Verification
[INFO] Performing final system search for remaining Cursor files...
[WARNING] ⚠ 92 Cursor components still remain
[WARNING]   REMAINING_FILE: /Users/vicd/Library/Mobile Documents/com~apple~CloudDocs/Family/Downloads_Personal_Projects/Python Dev /containerised-birth-time-rectifier/mcp-servers/CURSOR-INTEGRATION.md
[WARNING]   REMAINING_FILE: /Users/vicd/Library/Mobile Documents/com~apple~CloudDocs/Family/Downloads_Personal_Projects/containerised-birth-time-rectifier/mcp-servers/CURSOR-INTEGRATION.md
[WARNING]   REMAINING_FILE: /Users/vicd/Downloads/cursor_uninstaller
[WARNING]   REMAINING_FILE: /Users/vicd/Downloads/cursor_uninstaller/uninstall_cursor.sh
[WARNING]   REMAINING_FILE: /Users/vicd/Downloads/backup/uninstall_cursor.sh
[WARNING]   REMAINING_FILE: /Users/vicd/Downloads/backup/cursor_uninstaller
[WARNING]   REMAINING_FILE: /Users/vicd/Downloads/backup/cursor_uninstaller/enhanced_uninstall_cursor.sh
[WARNING]   REMAINING_FILE: /Users/vicd/Downloads/backup/cursor_uninstaller/uninstall_cursor
[WARNING]   REMAINING_FILE: /Applications/Firefox.app/Contents/Resources/res/cursors
[WARNING]   REMAINING_FILE: /Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk/usr/share/man/man3/DBIx::Class::Storage::DBI::Cursor5.34.3pm
[WARNING]   ... and 82 more items
[WARNING] Some Cursor components may still remain
[ERROR] ✗ Complete removal verification failed
[SUCCESS] Removal report saved: /Users/vicd/.cursor-uninstaller/temp/cursor_removal_report_20250530_055052.txt
[ERROR] Complete removal finished with 1 errors
[ERROR] Manual cleanup may be required - see re