#!/usr/bin/env bash
# Ensure script runs under bash
if [ -z "${BASH_VERSION-}" ]; then
  exec /usr/bin/env bash "$0" "$@"
fi
# Disable zsh history expansion if sourced in zsh
if [ -n "${ZSH_VERSION-}" ]; then
  setopt NO_HIST_EXPAND
fi
set -euo pipefail
shopt -s nullglob

readonly VERSION="2.0.0"
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[0;33m"
readonly RED="\033[0;31m"
readonly NC="\033[0m"

if [[ -n "${SUDO_USER-}" && "${SUDO_USER}" != "root" ]]; then
  USER_HOME="$(eval echo "~${SUDO_USER}")"
else
  USER_HOME="${HOME}"
fi

APP_BUNDLES=(
  "/Applications/Cursor.app"
  "/Applications/Cursor AI Editor.app"
  "${USER_HOME}/Applications/Cursor.app"
)

SUPPORT_DIRS=(
  "${USER_HOME}/Library/Application Support/Cursor*"
  "${USER_HOME}/Library/Application Support/Cursor AI Editor*"
  "/Library/Application Support/Cursor*"
)

CACHE_DIRS=(
  "${USER_HOME}/Library/Caches/com.cursor.*"
  "${USER_HOME}/Library/Caches/dev.cursor.*"
)

PREF_FILES=(
  "${USER_HOME}/Library/Preferences/com.cursor.*.plist"
)

LOG_DIRS=(
  "${USER_HOME}/Library/Logs/Cursor*"
)

LAUNCH_AGENTS=(
  "${USER_HOME}/Library/LaunchAgents/com.cursor.*.plist"
  "/Library/LaunchAgents/com.cursor.*.plist"
  "/Library/LaunchDaemons/com.cursor.*.plist"
)

BIN_LINKS=(
  "/usr/local/bin/cursor"
  "/opt/homebrew/bin/cursor"
)

ALL_TARGETS=(
  "${APP_BUNDLES[@]}" "${SUPPORT_DIRS[@]}" "${CACHE_DIRS[@]}" "${PREF_FILES[@]}"
  "${LOG_DIRS[@]}" "${LAUNCH_AGENTS[@]}" "${BIN_LINKS[@]}"
)

log()    { printf "%b\n" "$*"; }
ok()     { printf "${GREEN}✔ %s${NC}\n" "$*"; }
warn()   { printf "${YELLOW}⚠ %s${NC}\n" "$*"; }
error()  { printf "${RED}✖ %s${NC}\n" "$*"; }

expand_glob() {
  compgen -G "$1" || true
}

detect_cursor() {
  local found=()
  for pat in "${ALL_TARGETS[@]}"; do
    while IFS= read -r match; do
      [[ -e "$match" ]] && found+=("$match")
    done < <(expand_glob "$pat")
  done
  printf '%s\n' "${found[@]}"
}

list_installation() {
  local items
  items="$(detect_cursor)" || true
  if [[ -z "$items" ]]; then
    ok "No Cursor AI Editor components found."
  else
    warn "The following Cursor artefacts are present:"
    while IFS= read -r line; do
      printf "  • %s\n" "$line"
    done <<< "$items"
  fi
}

remove_cursor() {
  local items
  items="$(detect_cursor)" || true
  if [[ -z "$items" ]]; then
    ok "Nothing to remove. System already clean."
    return
  fi
  local count
  count=$(printf "%s" "$items" | awk 'END {print NR}')
  warn "Removing ${count} items…"
  while IFS= read -r p; do
    warn "  • Deleting $p"
    sudo rm -rf "$p" || error "Failed to delete $p"
  done <<< "$items"
  ok "Removal complete."
}

verify_removal() {
  warn "Running post-uninstall verification scan…"
  local leftovers
  leftovers="$(detect_cursor)" || true
  if [[ -z "$leftovers" ]]; then
    ok "All Cursor components successfully removed."
  else
    error "Residual files detected:"
    while IFS= read -r line; do
      printf "  • %s\n" "$line"
    done <<< "$leftovers"
    return 1
  fi
}

run_shellcheck() {
  if command -v shellcheck >/dev/null 2>&1; then
    warn "Running shellcheck for static analysis…"
    shellcheck -x "$0" && ok "Shellcheck passed with no issues."
  else
    warn "Shellcheck not found; skipping static analysis. Install via: brew install shellcheck"
  fi
}

print_header() {
  log "\n${GREEN}Cursor AI Editor Removal Utility — v${VERSION}${NC}"
  log "${GREEN}───────────────────────────────────────────────${NC}\n"
}

print_menu() {
  cat <<'MENU'
Please choose an option:
  1) Check current Cursor installation status
  2) Uninstall Cursor completely
  3) Verify removal status
  4) Run shellcheck on this script
  0) Exit
MENU
}

main() {
  print_header
  while true; do
    print_menu
    read -rp "Selection: " choice
    case "$choice" in
      1) list_installation ;;  
      2) remove_cursor ;;  
      3) verify_removal ;;  
      4) run_shellcheck ;;  
      0) ok "Goodbye!" ; exit 0 ;;  
      *) error "Invalid option." ;;  
    esac
    echo ""
  done
}

main "$@"
