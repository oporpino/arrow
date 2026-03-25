# ── System commands ───────────────────────────────────────────────────────────

# arrow update
# Synchronise the package databases.
cmd_update() {
  _preview "Sincronizar base de dados" "pacman -Sy  # -S sync  -y atualiza db"
  _ask "Continuar?" || { _warn "Cancelado."; return; }
  _blank
  _run _pacman -Sy
}

# arrow upgrade
# Synchronise databases and upgrade all packages.
cmd_upgrade() {
  _preview "Atualizar o sistema" "pacman -Syu  # -S sync  -y atualiza db  -u upgrade"
  _ask "Continuar?" || { _warn "Cancelado."; return; }
  _blank
  _run _pacman -Syu
}

# arrow clean [--all]
# Remove stale packages from the cache.
# With --all, wipe the entire cache.
cmd_clean() {
  if [[ "${1:-}" == "--all" ]]; then
    _preview "Limpar TODO o cache de pacotes" "pacman -Scc  # -S cache  -cc apaga tudo"
    _ask "Isso removerá todos os pacotes em cache. Continuar?" || { _warn "Cancelado."; return; }
  else
    _preview "Limpar versões antigas do cache" "pacman -Sc  # -S cache  -c remove versões antigas"
    _ask "Continuar?" || { _warn "Cancelado."; return; }
  fi
  _blank
  if [[ "${1:-}" == "--all" ]]; then
    _run _pacman -Scc
  else
    _run _pacman -Sc
  fi
}

# arrow orphans
# List packages that were installed as dependencies but are no longer required.
cmd_orphans() {
  local pkgs
  pkgs=$(pacman -Qdtq 2>/dev/null || true)
  if [[ -z "$pkgs" ]]; then
    _ok "Nenhum pacote órfão encontrado."
  else
    _warn "Pacotes órfãos (não mais necessários):"
    _blank
    while IFS= read -r pkg; do
      echo -e "    ${DIM}•${RESET}  ${pkg}"
    done <<< "$pkgs"
    _blank
    _info "Execute ${BOLD}arrow purge${RESET} para removê-los."
  fi
}

# arrow purge
# Remove all orphaned packages in one shot.
cmd_purge() {
  local pkgs
  pkgs=$(pacman -Qdtq 2>/dev/null || true)
  if [[ -z "$pkgs" ]]; then
    _ok "Nenhum pacote órfão para remover."
    return
  fi

  local pkg_list
  pkg_list=$(echo "$pkgs" | tr '\n' ' ')

  _preview "Remover pacotes órfãos" "pacman -Rns ${pkg_list}  # -R remover  -n sem backup  -s remove deps órfãs"
  _ask "Remover?" || { _warn "Cancelado."; return; }
  _blank
  # shellcheck disable=SC2086
  _run _pacman -Rns $pkgs
}
