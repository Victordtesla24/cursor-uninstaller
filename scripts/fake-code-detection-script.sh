#!/bin/bash

# Enhanced Comprehensive Fake Code Detection Script
# Purpose: Intelligently detect placeholder, mock, and fake code in shell scripts
# Author: Vikram
# Date: June 20, 2025
# Version: 2.4 - Fixed brace balance and syntax errors

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

SCRIPT_NAME_TEMP=$(basename "$0")
readonly SCRIPT_NAME="$SCRIPT_NAME_TEMP"

TIMESTAMP_TEMP=$(date '+%Y-%m-%d %H:%M:%S')
readonly TIMESTAMP="$TIMESTAMP_TEMP"

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
  echo -e "${BOLD}${BLUE}║${RESET} ${BOLD}$1${RESET} ${BOLD}${BLUE}                                       ║${RESET}"
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

  if [[ -s "$temp_file" ]]; then
    local line_count=0

    while IFS= read -r line; do
      local should_include=true

      if [[ "$exclude_legitimate" == "true" ]]; then
        if [[ "$line" =~ (Clean\ up\ temporary|Removing.*temporary|secure.*temporary|Skip.*temporary) ]]; then
          should_include=false
        fi

        if [[ "$line" =~ (ENHANCED:|REFACTORED:|Example\ of|Cache\ files\ and) ]]; then
          should_include=false
        fi

        if [[ "$line" =~ (readonly.*Reserved\ for\ future|URL.*Reserved) ]]; then
          should_include=false
        fi

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

  local temp_file
  temp_file=$(mktemp)

  print_section "$section_name"

  local critical_patterns=(
    "TODO.*FIXME"
    "XXX.*HACK"
    "function.*\{\s*#.*TODO"
    "function.*\{\s*#.*future"
    "function.*\{\s*#.*reserved"
    "function.*\{\s*#.*conceptual"
    "function.*\{\s*#.*FIXME"
    "function.*\{\s*#.*stub"
    "function.*\{\s*#.*future implementation"
    "function.*\{\s*return.*mock"
    "echo.*not.*implement"
    "exit.*mock"
    "placeholder.*implement"
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

# Function to analyze code quality metrics
analyze_code_quality() {
  print_section "Code Quality Analysis"

  local temp_dir
  temp_dir=$(mktemp -d)

  if command_exists shellcheck; then
    echo -e "${CYAN}Running ShellCheck analysis...${RESET}"
    find . -name "*.sh" -not -name "$SCRIPT_NAME" -exec shellcheck -f json {} \; 2>/dev/null > "$temp_dir/shellcheck.json" || true

    if [[ -s "$temp_dir/shellcheck.json" ]]; then
      local error_count
      local warning_count

      error_count=$(grep -o '"level":"error"' "$temp_dir/shellcheck.json" 2>/dev/null | wc -l | tr -d '[:space:]' || echo "0")
      warning_count=$(grep -o '"level":"warning"' "$temp_dir/shellcheck.json" 2>/dev/null | wc -l | tr -d '[:space:]' || echo "0")

      error_count=${error_count//[^0-9]/}
      warning_count=${warning_count//[^0-9]/}

      error_count=${error_count:-0}
      warning_count=${warning_count:-0}

      if [[ $error_count -gt 0 ]]; then
        print_high_severity "ShellCheck found $error_count critical errors"
      fi
      if [[ $warning_count -gt 0 ]]; then
        print_medium_severity "ShellCheck found $warning_count warnings"
      fi

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

  local antipatterns=(
    '^[[:space:]]*eval[[:space:]]*[\$"'"'"']'
    'rm[[:space:]]*-rf[[:space:]]*[\$"'"'"']'
    'chmod[[:space:]]*777'
    'su[[:space:]]*-c[[:space:]]*[\$"'"'"']'
    'curl[[:space:]].*\|[[:space:]]*sh'
  )

  local pattern_descriptions=(
    "Dangerous eval usage"
    "Potentially dangerous rm -rf with variables"
    "Overly permissive file permissions"
    "Privilege escalation attempt"
    "Unsafe curl to shell execution"
  )

  for i in "${!antipatterns[@]}"; do
    local pattern="${antipatterns[$i]}"
    local description="${pattern_descriptions[$i]}"
    local matches=""

    if command_exists rg; then
      matches=$(rg --type sh -n "$pattern" --glob "!$SCRIPT_NAME" . 2>/dev/null || true)
    else
      matches=$(grep -rn --include="*.sh" --exclude="$SCRIPT_NAME" -E "$pattern" . 2>/dev/null || true)
    fi

    if [[ -n "$matches" ]]; then
      while IFS= read -r line; do
        [[ -n "$line" ]] && print_high_severity "$description: $line"
      done <<< "$matches"
    fi
  done

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

# Function to search for specific keywords in comments
search_comment_keywords() {
  print_section "Comment Keyword Analysis"

  local keywords=(
    "conceptual"
    "reserved for future"
    "for future implementation"
    "dry run"
    "test"
    "safe"
    "update later"
  )

  local temp_file
  temp_file=$(mktemp)

  echo -e "${CYAN}Searching for specific keywords in comments...${RESET}"

  for keyword in "${keywords[@]}"; do
    echo -e "${BOLD}Keyword: ${keyword}${RESET}"

    if command_exists rg; then
      rg --type sh -n --color=always "#.*\\b${keyword}\\b" \
        --glob "!$SCRIPT_NAME" \
        --glob "!*.bak" \
        --glob "!*.tmp" \
        . 2>/dev/null > "$temp_file" || true
    else
      grep -rn --color=always --include="*.sh" \
        --exclude="$SCRIPT_NAME" \
        --exclude="*.bak" \
        --exclude="*.tmp" \
        -E "#.*\\b${keyword}\\b" . 2>/dev/null > "$temp_file" || true
    fi

    if [[ -s "$temp_file" ]]; then
      while IFS= read -r line; do
        print_medium_severity "$line"
        ((MEDIUM_SEVERITY++))
      done < "$temp_file"
    else
      echo -e "${DIM}No matches found for '${keyword}'${RESET}"
    fi

    echo
  done

  rm -f "$temp_file"
  echo
}

# Main execution function
main() {
  print_header "Enhanced Fake Code Detection Analysis"

  TOTAL_FILES_SCANNED=$(count_shell_files)

  echo -e "${BOLD}Scan Configuration:${RESET}"
  echo -e "  ${CYAN}•${RESET} Target directory: $(pwd)"
  echo -e "  ${CYAN}•${RESET} Shell files to scan: $TOTAL_FILES_SCANNED"
  echo -e "  ${CYAN}•${RESET} Excluded files: $SCRIPT_NAME, *.bak, *.tmp"
  echo

  if ! command_exists rg; then
    print_warning "ripgrep (rg) not found. Using grep instead (slower performance)"
    print_warning "For better performance: brew install ripgrep (macOS) | apt install ripgrep (Linux)"
    echo
  fi

  search_critical_patterns "1. Critical Code Issues (High Priority)"
  search_patterns_with_context \
    "\b(fake|mock|stub|dummy)\b.*\b(code|implementation|function|placeholder|reserved for future|conceptual)" \
    "2. Fake Code Implementations" \
    "HIGH" \
    "true"
  search_patterns_with_context \
    "^\s*#.*\b(TODO|FIXME|XXX|HACK)\b.*\b(implement|fix|complete|conceptual|future|reserved)" \
    "3. Incomplete Implementation Markers" \
    "MEDIUM" \
    "true"
  search_patterns_with_context \
    "\b(placeholder|conceptual)\b.*\b(requires|needs|implementation|future|reserved|conceptual)" \
    "4. Placeholder Code Requiring Implementation" \
    "MEDIUM" \
    "true"
  search_patterns_with_context \
    "function.*\{\s*$" \
    "5. Empty Function Definitions" \
    "MEDIUM" \
    "false"
  search_patterns_with_context \
    "^\s*#.*\b(WIP|work.*in.*progress|unfinished|future|reserved|conceptual)\b" \
    "6. Work in Progress Markers" \
    "LOW" \
    "true"

  search_comment_keywords
  analyze_code_quality
  generate_summary

  print_status "Enhanced scan completed successfully"

  if [[ $HIGH_SEVERITY -gt 0 ]]; then
    exit 1
  elif [[ $MEDIUM_SEVERITY -gt 0 ]]; then
    exit 2
  else
    exit 0
  fi
}

trap 'print_error "Script interrupted"; exit 130' INT TERM
main "$@"
