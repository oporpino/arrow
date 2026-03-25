# ── Self-management commands ──────────────────────────────────────────────────

# Fetches the remote VERSION string from the repo.
_remote_version() {
  curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/src/version.sh" 2>/dev/null \
    | grep 'VERSION=' | sed 's/.*VERSION="\([^"]*\)".*/\1/'
}

# arrow self update  (alias: arrow sharpen, arrow reforge)
# Check for a new version and update only if one is available.
cmd_self_update() {
  local install_url="https://raw.githubusercontent.com/${REPO}/main/install.sh"

  _need_pkg curl

  _info "Verificando versão remota…"
  local remote
  remote=$(_remote_version)

  if [[ -z "$remote" ]]; then
    _warn "Não foi possível verificar a versão remota. Continuando mesmo assim."
  elif [[ "$remote" == "$VERSION" ]]; then
    _ok "arrow ${VERSION} já é a versão mais recente."
    return
  else
    _info "Nova versão disponível: ${BOLD}${remote}${RESET}  (atual: ${DIM}${VERSION}${RESET})"
  fi

  _blank
  _preview "Atualizar o arrow" "curl -fsSL ${install_url} | bash"
  _ask "Atualizar?" || { _warn "Cancelado."; return; }

  _blank
  _info "Baixando e executando o installer…"
  bash <(curl -fsSL "$install_url")
}

# arrow self reinstall  (alias: arrow reinstall)
# Force reinstall of the current or latest version, no version check.
cmd_self_reinstall() {
  local install_url="https://raw.githubusercontent.com/${REPO}/main/install.sh"

  _need_pkg curl

  _preview "Reinstalar o arrow" "curl -fsSL ${install_url} | bash"
  _ask "Reinstalar arrow ${VERSION}?" || { _warn "Cancelado."; return; }

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
    update)    cmd_self_update    "$@" ;;
    reinstall) cmd_self_reinstall "$@" ;;
    remove)    cmd_self_remove    "$@" ;;
    "")
      _err "Uso: arrow self <update|reinstall|remove>"
      exit 1
      ;;
    *)
      _err "Subcomando desconhecido: 'self ${sub}'"
      _err "Uso: arrow self <update|reinstall|remove>"
      exit 1
      ;;
  esac
}
