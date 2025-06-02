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

ENTER YOUR CHOICE [1-8,Q]: 4
[INFO] EXECUTING GIT BACKUP OPERATION

⚠️  GIT BACKUP CONFIRMATION
═══════════════════════════════════════════════
This will create a comprehensive backup of your git repositories
before proceeding with Cursor uninstallation.

BACKUP WILL INCLUDE:
  • Complete repository history and branches
  • Uncommitted changes and working directories
  • Repository metadata and configuration
  • Detailed backup logs and restore instructions

BACKUP LOCATION: /Users/vicd/cursor_backup_20250602_152021

Create comprehensive git backup? (Y/n): y
[INFO] User confirmed git backup operation

📦 PRODUCTION-GRADE GIT BACKUP OPERATIONS
═══════════════════════════════════════════════

[INFO] Git version: git version 2.39.5 (Apple Git-154)
[SUCCESS] ✓ Backup directory created: /Users/vicd/cursor_backup_20250602_152021
[INFO] Scanning for git repositories...
[INFO] Found 3 git repositories

REPOSITORIES FOUND FOR BACKUP:
  1. perplexity-mcp (/Users/vicd/Documents/Cline/MCP/perplexity-mcp)
  2. servers (/Users/vicd/Documents/Cline/MCP/servers)
  3. Software-planning-mcp (/Users/vicd/Documents/Cline/MCP/Software-planning-mcp)

Proceed with backing up 3 repositories? (Y/n): Y
[INFO] Starting backup of 3 repositories...

[1/3] Processing repository: perplexity-mcp
[INFO] Backing up repository: perplexity-mcp
[ERROR] ✗ Failed to create bare clone for perplexity-mcp
[ERROR] ✗ Repository backup failed

[2/3] Processing repository: servers
[INFO] Backing up repository: servers
[ERROR] ✗ Failed to create bare clone for servers
[ERROR] ✗ Repository backup failed

[3/3] Processing repository: Software-planning-mcp
[INFO] Backing up repository: Software-planning-mcp
[ERROR] ✗ Failed to create bare clone for Software-planning-mcp
[ERROR] ✗ Repository backup failed

📊 BACKUP COMPLETION SUMMARY
═══════════════════════════════════════════════
Total Repositories: 3
Successfully Backed Up: 0
Failed Backups: 3
Backup Location: /Users/vicd/cursor_backup_20250602_152021

[ERROR] ❌ BACKUP FAILED FOR ALL REPOSITORIES
[ERROR] Manual backup recommended before proceeding with uninstall

[ERROR] LINE 1035: COMMAND FAILED: return 1
[ERROR] ERROR COUNT: 1
vicd@Vics-MacBook-Air bin % 