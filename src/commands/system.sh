# ── System commands ───────────────────────────────────────────────────────────

# arrow update
# Synchronise the package databases.
cmd_update() {
  _preview "Sync package databases" "pacman -Sy  # -S sync  -y refresh db"
  _ask "Continue?" || { _warn "Cancelled."; return; }
  _blank
  _run _pkg -Sy
}

# arrow upgrade
# Synchronise databases and upgrade all packages.
# Uses the AUR helper when available — it handles both official and AUR packages.
cmd_upgrade() {
  local cmd="${_PKG_HELPER:-pacman}"
  _preview "Upgrade the system" "${cmd} -Syu  # -S sync  -y refresh db  -u upgrade"
  _ask "Continue?" || { _warn "Cancelled."; return; }
  _blank
  _run _pkg -Syu
}

# arrow clean [--all]
# Remove stale packages from the cache.
# With --all, wipe the entire cache.
cmd_clean() {
  if [[ "${1:-}" == "--all" ]]; then
    _preview "Wipe the entire package cache" "pacman -Scc  # -S cache  -cc remove everything"
    _ask "This will remove all cached packages. Continue?" || { _warn "Cancelled."; return; }
  else
    _preview "Remove old versions from cache" "pacman -Sc  # -S cache  -c remove old versions"
    _ask "Continue?" || { _warn "Cancelled."; return; }
  fi
  _blank
  if [[ "${1:-}" == "--all" ]]; then
    _run _pkg -Scc
  else
    _run _pkg -Sc
  fi
}

# arrow orphans
# List packages that were installed as dependencies but are no longer required.
cmd_orphans() {
  local pkgs
  pkgs=$(pacman -Qdtq 2>/dev/null || true)
  if [[ -z "$pkgs" ]]; then
    _ok "No orphaned packages found."
  else
    _warn "Orphaned packages (no longer required):"
    _blank
    while IFS= read -r pkg; do
      echo -e "    ${DIM}•${RESET}  ${pkg}"
    done <<< "$pkgs"
    _blank
    _info "Run ${BOLD}arrow purge${RESET} to remove them."
  fi
}

# arrow purge
# Remove all orphaned packages in one shot.
cmd_purge() {
  local pkgs
  pkgs=$(pacman -Qdtq 2>/dev/null || true)
  if [[ -z "$pkgs" ]]; then
    _ok "No orphaned packages to remove."
    return
  fi

  local pkg_list
  pkg_list=$(echo "$pkgs" | tr '\n' ' ')

  _preview "Remove orphaned packages" "pacman -Rns ${pkg_list}  # -R remove  -n no backup  -s remove orphaned deps"
  _ask "Remove?" || { _warn "Cancelled."; return; }
  _blank
  # shellcheck disable=SC2086
  _run _pkg -Rns $pkgs
}
