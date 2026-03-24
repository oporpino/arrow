# ── System commands ───────────────────────────────────────────────────────────

# arch update
# Synchronise the package databases.
cmd_update() {
  _info "Sincronizando base de dados…"
  _pacman -Sy
}

# arch upgrade
# Synchronise databases and upgrade all packages.
cmd_upgrade() {
  _info "Atualizando o sistema…"
  _pacman -Syu
}

# arch clean [--all]
# Remove stale packages from the cache.
# With --all, wipe the entire cache.
cmd_clean() {
  if [[ "${1:-}" == "--all" ]]; then
    _warn "Removendo TODO o cache de pacotes…"
    _pacman -Scc
  else
    _info "Limpando versões antigas do cache…"
    _pacman -Sc
  fi
}

# arch orphans
# List packages that were installed as dependencies but are no longer required.
cmd_orphans() {
  local pkgs
  pkgs=$(pacman -Qdtq 2>/dev/null || true)
  if [[ -z "$pkgs" ]]; then
    _ok "Nenhum pacote órfão encontrado."
  else
    echo -e "${YELLOW}Pacotes órfãos:${RESET}"
    echo "$pkgs"
  fi
}

# arch purge
# Remove all orphaned packages in one shot.
cmd_purge() {
  local pkgs
  pkgs=$(pacman -Qdtq 2>/dev/null || true)
  if [[ -z "$pkgs" ]]; then
    _ok "Nenhum pacote órfão para remover."
    return
  fi
  _warn "Os seguintes pacotes órfãos serão removidos:"
  echo "$pkgs"
  _sep
  # shellcheck disable=SC2086
  _pacman -Rns $pkgs
}
