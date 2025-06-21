#!/usr/bin/env bash
#
# Enhanced Comprehensive Fake Code Detection Script
# Purpose: Detect placeholder, mock, and fake code patterns in shell scripts
# Author: Vikram
# Date: June 20, 2025
# Version: 2.6 – Fixed hanging, exit errors, and added keyword/function searches

set -euo pipefail  # robust error handling[1]

# ANSI color codes
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[1;33m"
readonly RED="\033[0;31m"
readonly BLUE="\033[0;34m"
readonly CYAN="\033[0;36m"
readonly BOLD="\033[1m"
readonly DIM="\033[2m"
readonly RESET="\033[0m"

SCRIPT_NAME="$(basename "$0")"
# shellcheck disable=SC2034
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

# Global counters
declare -i HIGH_SEVERITY=0
declare -i MEDIUM_SEVERITY=0
declare -i LOW_SEVERITY=0
declare -i TOTAL_FILES_SCANNED=0

# Check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Logging functions
print_header() {
  echo -e "${BOLD}${BLUE}╔════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${BLUE}║${RESET} $1 ${BOLD}${BLUE}              ║${RESET}"
  echo -e "${BOLD}${BLUE}╚════════════════════════════════════════╝${RESET}\n"
}
print_section() { echo -e "${BOLD}${CYAN}▶ $1${RESET}\n${DIM}────────────────────────────────────────${RESET}"; }
print_status()  { echo -e "${GREEN}[✓]${RESET} $1"; }
print_warning() { echo -e "${YELLOW}[!]${RESET} $1" >&2; }
print_high()    { echo -e "${RED}[HIGH]${RESET} $1"; ((HIGH_SEVERITY++)); }
print_medium()  { echo -e "${YELLOW}[MEDIUM]${RESET} $1"; ((MEDIUM_SEVERITY++)); }
print_low()     { echo -e "${CYAN}[LOW]${RESET} $1"; ((LOW_SEVERITY++)); }

# Count shell script files
count_shell_files() {
  if command_exists find; then
    find . -type f -name "*.sh" -not -path "./.git/*" -not -name "$SCRIPT_NAME" | wc -l
  else
    local count=0
    for f in ./**/*.sh; do
      [[ -f $f && $(basename "$f") != "$SCRIPT_NAME" ]] && ((count++))
    done 2>/dev/null
    echo "$count"
  fi
}

# Generic pattern-search function
search_patterns_with_context() {
  local pattern="$1" section="$2" severity="${3:-MEDIUM}" exclude_legit="${4:-true}"
  print_section "$section"
  local tmp
  tmp="$(mktemp)"
  if command_exists rg; then
    rg -n --color=always -E "$pattern" --glob "!$SCRIPT_NAME" --glob "!*.bak" --glob "!*.tmp" . \
      >"$tmp" 2>/dev/null || true
  else
    grep -rn --color=always -E "$pattern" --include="*.sh" --exclude="$SCRIPT_NAME" \
         --exclude="*.bak" --exclude="*.tmp" . >"$tmp" 2>/dev/null || true
  fi

  if [[ -s $tmp ]]; then
    local found=0
    while IFS= read -r line; do
      if [[ $exclude_legit == "true" && "$line" =~ (Clean\ up|Removing.*|Skip.*|readonly.*Reserved) ]]; then
        continue
      fi
      case "$severity" in
        HIGH)   print_high "$line" ;;
        MEDIUM) print_medium "$line" ;;
        LOW)    print_low "$line" ;;
      esac
      ((found++))
    done <"$tmp"
    [[ $found -eq 0 ]] && echo -e "${DIM}No matches${RESET}"
  else
    echo -e "${DIM}No matches${RESET}"
  fi
  rm -f "$tmp"
  echo
}

# Search for critical patterns
search_critical_patterns() {
  print_section "$1"
  local tmp
  tmp="$(mktemp)"
  local patterns=( "TODO.*FIXME" "XXX.*HACK" "function.*\{.*#.*(TODO|future|reserved|conceptual)" )
  for p in "${patterns[@]}"; do
    if command_exists rg; then
      rg -in --color=always -E "$p" --glob "!$SCRIPT_NAME" . >>"$tmp" 2>/dev/null || true
    else
      grep -rin --color=always -E "$p" --include="*.sh" --exclude="$SCRIPT_NAME" . >>"$tmp" 2>/dev/null || true
    fi
  done
  if [[ -s $tmp ]]; then
    while IFS= read -r line; do
      print_high "$line"
    done <"$tmp"
  else
    echo -e "${DIM}No critical issues${RESET}"
  fi
  rm -f "$tmp"
  echo
}

# Search for comment keywords
search_comment_keywords() {
  print_section "Comment Keyword Analysis"
  local keywords=( conceptual "reserved for future" "for future implementation" "update later" )
  local tmp
  tmp="$(mktemp)"
  for k in "${keywords[@]}"; do
    echo -e "${BOLD}Keyword:${RESET} $k"
    if command_exists rg; then
      rg -n --color=always "#.*\b$k\b" --glob "!$SCRIPT_NAME" --glob "!*.bak" --glob "!*.tmp" . \
        >"$tmp" 2>/dev/null || true
    else
      grep -rn --color=always -E "#.*\b$k\b" --include="*.sh" --exclude="$SCRIPT_NAME" \
           --exclude="*.bak" --exclude="*.tmp" . >"$tmp" 2>/dev/null || true
    fi
    if [[ -s $tmp ]]; then
      while IFS= read -r line; do print_medium "$line"; done <"$tmp"
    else
      echo -e "${DIM}No matches${RESET}"
    fi
    echo
  done
  rm -f "$tmp"
  echo
}

# Search in function names and identifiers
dry_run_analysis() {
  search_patterns_with_context "dry_run" "Dry Run Function Names" LOW false
}
test_code_detection() {
  search_patterns_with_context "test_code" "Test Code Identifiers" LOW false
}
safe_run_checks() {
  search_patterns_with_context "safe_run" "Safe Run Identifiers" LOW false
}
safe_prefix_search() {
  search_patterns_with_context "safe_" "Safe_ Prefix in Names" LOW false
}
test_prefix_search() {
  search_patterns_with_context "test_" "Test_ Prefix in Names" LOW false
}

# Code-quality analysis with ShellCheck
analyze_code_quality() {
  print_section "Code Quality Analysis"
  local tmpdir
  tmpdir="$(mktemp -d)"
  if command_exists shellcheck; then
    echo -e "${CYAN}Running ShellCheck...${RESET}"

    # Phase 1: Separate file collection process - no process substitution
    local files_to_check=()
    local file_count=0

    # Use safer while read loop instead of for loop over find output
    while IFS= read -r -d '' file; do
      if [[ -f "$file" && "$file" != *"$SCRIPT_NAME" ]]; then
        files_to_check+=("$file")
        ((file_count++))
      fi
    done < <(find . -name "*.sh" -type f -print0 2>/dev/null)

    echo -e "${DIM}Processing $file_count shell script files...${RESET}"

    # Phase 2: Separate shellcheck execution process
    local processed=0
    for file in "${files_to_check[@]}"; do
      ((processed++))
      echo -ne "${DIM}[$processed/$file_count] Checking $(basename "$file")...${RESET}\r"

      # Direct shellcheck execution - isolated process
      if command_exists timeout; then
        timeout 5s shellcheck -f json "$file" >> "$tmpdir/shellcheck.json" 2>/dev/null || true
      else
        shellcheck -f json "$file" >> "$tmpdir/shellcheck.json" 2>/dev/null || true
      fi
    done

    echo # Clear progress line

    if [[ -s $tmpdir/shellcheck.json ]]; then
      local errs warns
      errs=$(grep -o '"level":"error"' "$tmpdir/shellcheck.json" | wc -l 2>/dev/null || echo 0)
      warns=$(grep -o '"level":"warning"' "$tmpdir/shellcheck.json" | wc -l 2>/dev/null || echo 0)
      ((errs>0)) && print_high "ShellCheck errors: $errs"
      ((warns>0)) && print_medium "ShellCheck warnings: $warns"
      ((errs==0&&warns==0)) && print_low "No ShellCheck issues"
    else
      print_low "No ShellCheck issues"
    fi
  else
    print_warning "ShellCheck not installed"
  fi
  rm -rf -- "$tmpdir"
  echo
}

# Summary of results
generate_summary() {
  print_header "Analysis Summary"
  echo -e "${BOLD}Files scanned:${RESET} $TOTAL_FILES_SCANNED"
  echo -e "${BOLD}High/Med/Low:${RESET} $HIGH_SEVERITY / $MEDIUM_SEVERITY / $LOW_SEVERITY"
  echo
}

main() {
  print_header "Enhanced Fake Code Detection Analysis"
  TOTAL_FILES_SCANNED=$(count_shell_files)
  echo -e "${CYAN}Target directory:${RESET} $(pwd)"
  echo -e "${CYAN}Shell scripts scanned:${RESET} $TOTAL_FILES_SCANNED"
  echo

  command_exists rg || print_warning "ripgrep not found; falling back to grep"

  search_critical_patterns "1. Critical Code Issues"
  search_patterns_with_context "\b(fake|mock|stub|dummy)\b" \
    "2. Fake Code Implementations" HIGH true
  search_patterns_with_context "^\s*#.*\b(TODO|FIXME)\b" \
    "3. Incomplete Implementation Markers" MEDIUM true
  search_patterns_with_context "\b(placeholder|conceptual)\b" \
    "4. Placeholder Code Requiring Implementation" MEDIUM true
  search_patterns_with_context "function.*\{\s*\$" \
    "5. Empty Function Definitions" MEDIUM false
  search_patterns_with_context "^\s*#.*\b(WIP)\b" \
    "6. Work in Progress Markers" LOW true

  search_comment_keywords
  dry_run_analysis
  test_code_detection
  safe_run_checks
  safe_prefix_search
  test_prefix_search
  analyze_code_quality
  generate_summary

  print_status "Scan complete"
  ((HIGH_SEVERITY>0)) && exit 1
  ((MEDIUM_SEVERITY>0)) && exit 2
  exit 0
}

trap 'print_warning "Interrupted"; exit 130' INT TERM
main "$@"
