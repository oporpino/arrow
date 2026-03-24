# ── Self-management commands ──────────────────────────────────────────────────

# arrow self update  (alias: arrow sharpen, arrow reforge)
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

# arrow self remove
# Download and run uninstall.sh, removing arrow from the system.
cmd_self_remove() {
  local uninstall_url="https://raw.githubusercontent.com/${REPO}/main/uninstall.sh"

  _need_pkg curl

  _preview "Desinstalar o arrow" \
    "curl -fsSL ${uninstall_url} | bash"

  _ask "Remover o arrow do sistema?" \
    || { _warn "Cancelado."; return; }

  _blank
  _info "Baixando e executando o uninstaller…"
  bash <(curl -fsSL "$uninstall_url")
}

# arrow self <subcommand>
cmd_self() {
  local sub="${1:-}"; shift || true
  case "$sub" in
    update)  cmd_self_update "$@" ;;
    remove)  cmd_self_remove "$@" ;;
    "")
      _err "Uso: arrow self <update|remove>"
      exit 1
      ;;
    *)
      _err "Subcomando desconhecido: 'self ${sub}'"
      _err "Uso: arrow self <update|remove>"
      exit 1
      ;;
  esac
}
