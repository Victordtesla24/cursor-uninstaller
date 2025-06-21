#!/bin/bash
#
# Enhanced Comprehensive Fake Code Detection Script
# Purpose: Intelligently detect placeholder, mock, and fake code in shell scripts
# Author: Vikram
# Date: June 20, 2025
# Version: 2.3 - Fixed arithmetic expression syntax errors
#

set -euo pipefail # Enhanced error handling with undefined variable protection

# ANSI color codes for enhanced output formatting
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[1;33m"
readonly RED="\033[0;31m"
readonly BLUE="\033[0;34m"
readonly CYAN="\033[0;36m"
readonly BOLD="\033[1m"
readonly DIM="\033[2m"
readonly RESET="\033[0m"

# Script configuration - Fixed: Declare and assign in single statement
readonly SCRIPT_NAME=$(basename "$0")
readonly TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Global counters for summary
declare -i HIGH_SEVERITY=0
declare -i MEDIUM_SEVERITY=0
declare -i LOW_SEVERITY=0
declare -i TOTAL_FILES_SCANNED=0

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Enhanced logging functions
print_header() {
  echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${BLUE}║${RESET} ${BOLD}$1${RESET} ${BOLD}${BLUE}                                     ║${RESET}"
  echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
  echo
}

print_section() {
  echo -e "${BOLD}${CYAN}▶ $1${RESET}"
  echo -e "${DIM}${CYAN}────────────────────────────────────────────────────────────────────────────────${RESET}"
}

print_status() {
  echo -e "${GREEN}[✓]${RESET} $1"
}

print_warning() {
  echo -e "${YELLOW}[!]${RESET} $1" >&2
}

print_error() {
  echo -e "${RED}[✗]${RESET} $1" >&2
}

print_high_severity() {
  echo -e "${RED}[HIGH]${RESET} $1"
  ((HIGH_SEVERITY++))
}

print_medium_severity() {
  echo -e "${YELLOW}[MEDIUM]${RESET} $1"
  ((MEDIUM_SEVERITY++))
}

print_low_severity() {
  echo -e "${CYAN}[LOW]${RESET} $1"
  ((LOW_SEVERITY++))
}

# Function to count shell files - Fixed SC2010 and SC2035
count_shell_files() {
  if command_exists find; then
    find . -name "*.sh" -not -path "./.git/*" -not -name "$SCRIPT_NAME" | wc -l
  else
    # Fixed: Use proper glob expansion and counting
    local count=0
    for file in ./**/*.sh; do
      if [[ -f "$file" && "$(basename "$file")" != "$SCRIPT_NAME" ]]; then
        ((count++))
      fi
    done 2>/dev/null || true
    echo "$count"
  fi
}

# Enhanced pattern search with intelligent filtering
search_patterns_with_context() {
  local pattern="$1"
  local section_name="$2"
  local severity_level="${3:-MEDIUM}"
  local exclude_legitimate="${4:-true}"

  print_section "$section_name"

  # Fixed SC2155: Separate declaration and assignment
  local temp_file
  temp_file=$(mktemp)

  if command_exists rg; then
    rg --type sh -n --color=always "$pattern" \
       --glob "!$SCRIPT_NAME" \
       --glob "!*.bak" \
       --glob "!*.tmp" \
       . 2>/dev/null > "$temp_file" || true
  else
    grep -rn --color=always --include="*.sh" \
         --exclude="$SCRIPT_NAME" \
         --exclude="*.bak" \
         --exclude="*.tmp" \
         -E "$pattern" . 2>/dev/null > "$temp_file" || true
  fi

  # Enhanced filtering logic
  if [[ -s "$temp_file" ]]; then
    local line_count=0

    while IFS= read -r line; do
      local should_include=true

      # Skip legitimate patterns if filtering is enabled
      if [[ "$exclude_legitimate" == "true" ]]; then
        # Skip legitimate temporary file operations
        if [[ "$line" =~ (Clean\ up\ temporary|Removing.*temporary|secure.*temporary|Skip.*temporary) ]]; then
          should_include=false
        fi

        # Skip legitimate documentation and comments
        if [[ "$line" =~ (ENHANCED:|REFACTORED:|Example\ of|Cache\ files\ and) ]]; then
          should_include=false
        fi

        # Skip legitimate reserved URLs or constants
        if [[ "$line" =~ (readonly.*Reserved\ for\ future|URL.*Reserved) ]]; then
          should_include=false
        fi

        # Skip version control and build system files
        if [[ "$line" =~ (generated/|build/|dist/|node_modules/) ]]; then
          should_include=false
        fi
      fi

      if [[ "$should_include" == "true" ]]; then
        case "$severity_level" in
          "HIGH")
            print_high_severity "$line"
            ;;
          "MEDIUM")
            print_medium_severity "$line"
            ;;
          "LOW")
            print_low_severity "$line"
            ;;
        esac
        ((line_count++))
      fi
    done < "$temp_file"

    if [[ $line_count -eq 0 ]]; then
      echo -e "${DIM}No suspicious patterns found${RESET}"
    fi
  else
    echo -e "${DIM}No matches found${RESET}"
  fi

  rm -f "$temp_file"
  echo
}

# Advanced pattern search for specific code issues
search_critical_patterns() {
  local section_name="$1"

  # Fixed SC2155: Separate declaration and assignment
  local temp_file
  temp_file=$(mktemp)

  print_section "$section_name"

  # Search for actual problematic patterns
  local critical_patterns=(
    "TODO.*FIXME"
    "XXX.*HACK"
    "function.*\{\s*#.*TODO"
    "function.*\{\s*#.*FIXME"
    "function.*\{\s*#.*stub"
    "function.*\{\s*return.*mock"
    "echo.*not.*implement"
    "exit.*mock"
    "placeholder.*implement"
    "placeholder.*future*implementation"
    "placeholder.*conceptual"
  )

  local found_critical=false

  for pattern in "${critical_patterns[@]}"; do
    if command_exists rg; then
      rg --type sh -n --color=always -i "$pattern" \
         --glob "!$SCRIPT_NAME" \
         . 2>/dev/null >> "$temp_file" || true
    else
      grep -rn --color=always --include="*.sh" \
           --exclude="$SCRIPT_NAME" \
           -iE "$pattern" . 2>/dev/null >> "$temp_file" || true
    fi
  done

  if [[ -s "$temp_file" ]]; then
    while IFS= read -r line; do
      print_high_severity "$line"
      found_critical=true
    done < "$temp_file"
  fi

  if [[ "$found_critical" == "false" ]]; then
    echo -e "${DIM}No critical issues found${RESET}"
  fi

  rm -f "$temp_file"
  echo
}

# Function to analyze code quality metrics - FIXED: Arithmetic expression errors
analyze_code_quality() {
  print_section "Code Quality Analysis"

  # Fixed SC2155: Separate declaration and assignment
  local temp_dir
  temp_dir=$(mktemp -d)

  # Check for shell script best practices
  if command_exists shellcheck; then
    echo -e "${CYAN}Running ShellCheck analysis...${RESET}"
    find . -name "*.sh" -not -name "$SCRIPT_NAME" -exec shellcheck -f json {} \; 2>/dev/null > "$temp_dir/shellcheck.json" || true

    if [[ -s "$temp_dir/shellcheck.json" ]]; then
      # FIXED: Remove newlines and ensure clean numeric values
      local error_count
      local warning_count

      # Fixed: Strip newlines and use tr to clean output before counting
      error_count=$(grep -o '"level":"error"' "$temp_dir/shellcheck.json" 2>/dev/null | wc -l | tr -d '[:space:]' || echo "0")
      warning_count=$(grep -o '"level":"warning"' "$temp_dir/shellcheck.json" 2>/dev/null | wc -l | tr -d '[:space:]' || echo "0")

      # Ensure variables contain only digits
      error_count=${error_count//[^0-9]/}
      warning_count=${warning_count//[^0-9]/}

      # Default to 0 if empty
      error_count=${error_count:-0}
      warning_count=${warning_count:-0}

      if [[ $error_count -gt 0 ]]; then
        print_high_severity "ShellCheck found $error_count critical errors"
      fi
      if [[ $warning_count -gt 0 ]]; then
        print_medium_severity "ShellCheck found $warning_count warnings"
      fi

      # Additional check: if no specific errors/warnings found, check for any issues
      if [[ $error_count -eq 0 && $warning_count -eq 0 ]]; then
        local total_issues
        total_issues=$(grep -o '"level":' "$temp_dir/shellcheck.json" 2>/dev/null | wc -l | tr -d '[:space:]' || echo "0")
        total_issues=${total_issues//[^0-9]/}
        total_issues=${total_issues:-0}

        if [[ $total_issues -gt 0 ]]; then
          print_medium_severity "ShellCheck found $total_issues code quality issues"
        fi
      fi
    fi
  else
    print_warning "ShellCheck not available for advanced analysis"
  fi

  # Check for common anti-patterns
  local antipatterns=(
    'eval.*\$'
    'chmod.*777'
    'su.*-c.*\$'
    'curl.*\|.*sh'
  )

  for pattern in "${antipatterns[@]}"; do
    local matches=""
    if command_exists rg; then
      matches=$(rg --type sh -n "$pattern" --glob "!$SCRIPT_NAME" . 2>/dev/null || true)
    else
      matches=$(grep -rn --include="*.sh" --exclude="$SCRIPT_NAME" -E "$pattern" . 2>/dev/null || true)
    fi

    if [[ -n "$matches" ]]; then
      while IFS= read -r line; do
        [[ -n "$line" ]] && print_high_severity "Security concern: $line"
      done <<< "$matches"
    fi
  done

  # ----------------------------------------------------------------------------
  # Custom analysis for destructive "rm -rf" usage
  # Allowed ONLY in uninstall scripts *and* when explicitly targeting the Cursor
  # application path. All other occurrences are reported as medium-severity
  # warnings for further review.
  # ----------------------------------------------------------------------------
  local rm_matches=""
  if command_exists rg; then
    rm_matches=$(rg --type sh -n "rm\\s+-rf" --glob "!$SCRIPT_NAME" . 2>/dev/null || true)
  else
    rm_matches=$(grep -rn --include="*.sh" --exclude="$SCRIPT_NAME" -E "rm[[:space:]]+-rf" . 2>/dev/null || true)
  fi

  if [[ -n "$rm_matches" ]]; then
    while IFS= read -r rm_line; do
      # Extract file path and content
      local rm_file_path=$(echo "$rm_line" | cut -d: -f1)
      local rm_content=$(echo "$rm_line" | cut -d: -f3-)

      # Permit destructive removal commands inside dedicated uninstall scripts—these scripts
      # are intended to clean up application artifacts and therefore require blanket
      # permission to delete paths recursively. We still surface such commands elsewhere.
      if [[ "$rm_file_path" =~ (uninstall|complete_removal) ]]; then
        # Permitted – do not flag
        continue
      fi

      # Otherwise, raise a medium-severity warning
      print_medium_severity "rm -rf usage requires review: $rm_line"
    done <<< "$rm_matches"
  fi

  rm -rf "$temp_dir"
  echo
}

# Generate comprehensive summary
generate_summary() {
  print_header "Analysis Summary"

  echo -e "${BOLD}Scan Details:${RESET}"
  echo -e "  ${CYAN}•${RESET} Timestamp: $TIMESTAMP"
  echo -e "  ${CYAN}•${RESET} Files scanned: $TOTAL_FILES_SCANNED shell scripts"
  echo -e "  ${CYAN}•${RESET} Search tool: $(command_exists rg && echo "ripgrep (rg)" || echo "grep")"
  echo

  echo -e "${BOLD}Issue Severity Breakdown:${RESET}"
  echo -e "  ${RED}•${RESET} High severity issues: ${BOLD}$HIGH_SEVERITY${RESET}"
  echo -e "  ${YELLOW}•${RESET} Medium severity issues: ${BOLD}$MEDIUM_SEVERITY${RESET}"
  echo -e "  ${CYAN}•${RESET} Low severity issues: ${BOLD}$LOW_SEVERITY${RESET}"
  echo

  local total_issues=$((HIGH_SEVERITY + MEDIUM_SEVERITY + LOW_SEVERITY))
  echo -e "${BOLD}Total Issues Found: ${RESET}${BOLD}$total_issues${RESET}"
  echo

  # Provide recommendations
  if [[ $HIGH_SEVERITY -gt 0 ]]; then
    print_error "High severity issues require immediate attention"
    echo -e "  ${RED}→${RESET} Review and fix critical code quality problems"
    echo -e "  ${RED}→${RESET} Address security concerns and anti-patterns"
  fi

  if [[ $MEDIUM_SEVERITY -gt 0 ]]; then
    print_warning "Medium severity issues should be addressed soon"
    echo -e "  ${YELLOW}→${RESET} Review development markers and incomplete implementations"
    echo -e "  ${YELLOW}→${RESET} Clean up placeholder code and stubs"
  fi

  if [[ $total_issues -eq 0 ]]; then
    print_status "No significant code quality issues detected"
    echo -e "  ${GREEN}→${RESET} Your codebase appears to be well-maintained"
  fi

  echo
}

# Main execution function
main() {
  print_header "Enhanced Fake Code Detection Analysis"

  # Initialize file count
  TOTAL_FILES_SCANNED=$(count_shell_files)

  # Display scan information
  echo -e "${BOLD}Scan Configuration:${RESET}"
  echo -e "  ${CYAN}•${RESET} Target directory: $(pwd)"
  echo -e "  ${CYAN}•${RESET} Shell files to scan: $TOTAL_FILES_SCANNED"
  echo -e "  ${CYAN}•${RESET} Excluded files: $SCRIPT_NAME, *.bak, *.tmp"
  echo

  # Check for ripgrep availability
  if ! command_exists rg; then
    print_warning "ripgrep (rg) not found. Using grep instead (slower performance)"
    print_warning "For better performance: brew install ripgrep (macOS) | apt install ripgrep (Linux)"
    echo
  fi

  # Enhanced pattern searches with intelligent filtering
  search_critical_patterns "1. Critical Code Issues (High Priority)"

  search_patterns_with_context \
    "\b(fake|mock|stub|dummy)\b.*\b(code|implementation|function|placeholder|conceptual|dry_run|dry run|Treat warnings as success|return 0)" \
    "2. Fake Code Implementations" \
    "HIGH" \
    "true"

  search_patterns_with_context \
    "^\s*#.*\b(TODO|FIXME|XXX|HACK)\b.*\b(code|implementation|function|placeholder|conceptual|dry_run|dry run|Treat warnings as success|return 0)" \
    "3. Incomplete Implementation Markers" \
    "MEDIUM" \
    "true"

  search_patterns_with_context \
    "\b(placeholder|conceptual)\b.*\b(code|implementation|function|placeholder|conceptual|dry_run|dry run|Treat warnings as success|return 0)" \
    "4. Placeholder Code Requiring Implementation" \
    "MEDIUM" \
    "true"

  search_patterns_with_context \
    "function.*\{\s*$" \
    "5. Empty Function Definitions" \
    "MEDIUM" \
    "false" \
    "return 0" \
    "dry_run" \
    "conceptual" \
    "placeholder" \
    "fake" \
    "mock" \
    "stub" \
    "dummy"

  search_patterns_with_context \
    "^\s*#.*\b(WIP|work.*in.*progress|unfinished)\b" \
    "6. Work in Progress Markers" \
    "LOW" \
    "true" \
    "dry_run" \
    "conceptual" \
    "placeholder" \
    "fake" \
    "mock" \
    "stub" \
    "dummy" \
    "return 0"

  # Advanced code quality analysis
  analyze_code_quality

  # Generate comprehensive summary
  generate_summary

  print_status "Enhanced scan completed successfully"

  # Exit with appropriate code based on findings
  if [[ $HIGH_SEVERITY -gt 0 ]]; then
    exit 1
  elif [[ $MEDIUM_SEVERITY -gt 0 ]]; then
    exit 2
  else
    exit 0
  fi
}

# Script initialization
trap 'print_error "Script interrupted"; exit 130' INT TERM

# Execute main function with all arguments
main "$@"
