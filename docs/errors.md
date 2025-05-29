=============================================
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
[INFO] Found application: /Applications/Cursor.app
[INFO] Found user data: /Users/vicd/Library/Application Support/Cursor
[INFO] Found user data: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist
[INFO] Found user data: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92
[INFO] Found user data: /Users/vicd/Library/HTTPStorages/com.todesktop.230313mzl4w4u92
[INFO] Found user data: /Users/vicd/.cursor
[INFO] Stopping process: Cursor
[WARNING] Force killing process: Cursor
[ERROR] Application bundle verification failed: com.todesktop.230313mzl4w4u92
[INFO] Removing lingering file: /Users/vicd/Library/Application Support/Cursor/User/workspaceStorage/90f50397c351dea77877032db3634637/anysphere.cursor-retrieval
Password:
[INFO] Removing lingering file: /Users/vicd/Library/Application Support/Cursor/logs/20250529T210318/window1/exthost/anysphere.cursor-always-local
[INFO] Removing lingering file: /Users/vicd/Library/Application Support/Cursor/logs/20250529T210318/window1/exthost/anysphere.cursor-retrieval
[INFO] Removing lingering file: /Users/vicd/Library/Application Support/Cursor/logs/20250529T204633/window1/exthost/anysphere.cursor-always-local
[INFO] Removing lingering file: /Users/vicd/Library/Application Support/Cursor/logs/20250529T204633/window1/exthost/anysphere.cursor-retrieval
[INFO] Removing lingering file: /Users/vicd/Library/Application Support/sourcery/workspaces/%Users%Shared%cursor%cursor-uninstaller
[INFO] Removing lingering file: /Users/vicd/Library/Application Support/Cursor
[INFO] Removing lingering file: /Users/vicd/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.todesktop.230313mzl4w4u92.sfl3
[INFO] Removing lingering file: /Users/vicd/Library/Preferences/com.todesktop.230313mzl4w4u92.plist
[INFO] Removing lingering file: /Users/vicd/Library/HTTPStorages/com.todesktop.230313mzl4w4u92
[INFO] Removing lingering file: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt
[INFO] Removing lingering file: /Users/vicd/Library/Caches/com.todesktop.230313mzl4w4u92
[INFO] Phase 1: Component Detection
[INFO] Found: Cursor.app (630M)
[INFO] Found: /usr/local/bin/cursor -> /Applications/Cursor.app/Contents/Resources/app/bin/code
[SUCCESS] Detected 2 Cursor components
[INFO] Performing system-wide search for Cursor files...
[SUCCESS] Found 159 additional Cursor files
[INFO] Phase 2: Background Process Cleanup
[WARNING] Found running Cursor processes:
vicd             22463   6.9  0.1 411174320   5392 s000  S+    9:04PM   0:00.11 /bin/bash ./uninstall_cursor.sh
[INFO] Terminating Cursor processes...
zsh: terminated  ./uninstall_cursor.sh
vicd@Vics-MacBook-Air cursor-uninstaller % 