# ── Query commands ────────────────────────────────────────────────────────────

# arch list [filter]
# List all installed packages, optionally filtered by a string.
cmd_list() {
  if [[ -n "${1:-}" ]]; then
    pacman -Q | grep --color=always "$1"
  else
    pacman -Q
  fi
}

# arch history [n]
# Show the last n pacman operations from the system log (default: 20).
cmd_history() {
  local n="${1:-20}"
  _info "Last ${BOLD}${n}${RESET} operations:"
  _sep
  grep -E "installed|removed|upgraded" /var/log/pacman.log | tail -n "$n"
}
