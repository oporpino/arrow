# ── System commands ───────────────────────────────────────────────────────────

# arrow update
# Synchronise the package databases.
cmd_update() {
  _preview "Sincronizar base de dados" "sudo pacman -Sy"
  _ask "Continuar?" || { _warn "Cancelado."; return; }
  _blank
  _run sudo pacman --noconfirm --color=always -Sy
}

# arrow upgrade
# Synchronise databases and upgrade all packages.
cmd_upgrade() {
  _preview "Atualizar o sistema" "sudo pacman -Syu"
  _ask "Continuar?" || { _warn "Cancelado."; return; }
  _blank
  _run sudo pacman --noconfirm --color=always -Syu
}

# arrow clean [--all]
# Remove stale packages from the cache.
# With --all, wipe the entire cache.
cmd_clean() {
  if [[ "${1:-}" == "--all" ]]; then
    _preview "Limpar TODO o cache de pacotes" "sudo pacman -Scc"
    _ask "Isso removerá todos os pacotes em cache. Continuar?" || { _warn "Cancelado."; return; }
  else
    _preview "Limpar versões antigas do cache" "sudo pacman -Sc"
    _ask "Continuar?" || { _warn "Cancelado."; return; }
  fi
  _blank
  if [[ "${1:-}" == "--all" ]]; then
    _run sudo pacman --noconfirm --color=always -Scc
  else
    _run sudo pacman --noconfirm --color=always -Sc
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

# arrow self-update
# Download and run the latest install.sh, replacing the current version.
cmd_self_update() {
  local install_url="https://raw.githubusercontent.com/${REPO}/main/install.sh"

  _need_pkg curl

  _preview "Atualizar o arrow" \
    "curl -fsSL ${install_url} | bash"

  _ask "Substituir a versão atual ($(arrow version 2>/dev/null || echo '?')) pela mais recente?" \
    || { _warn "Cancelado."; return; }

  _blank
  _info "Baixando e executando o installer…"
  bash <(curl -fsSL "$install_url")
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

  _preview "Remover pacotes órfãos" "sudo pacman -Rns ${pkg_list}"
  _ask "Remover?" || { _warn "Cancelado."; return; }
  _blank
  # shellcheck disable=SC2086
  _run sudo pacman --noconfirm --color=always -Rns $pkgs
}
