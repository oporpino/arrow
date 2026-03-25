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

  _info "Checking remote version..."
  local remote
  remote=$(_remote_version)

  if [[ -z "$remote" ]]; then
    _warn "Could not check remote version. Proceeding anyway."
  elif [[ "$remote" == "$VERSION" ]]; then
    _ok "arrow ${VERSION} is already the latest version."
    return
  else
    _info "New version available: ${BOLD}${remote}${RESET}  (current: ${DIM}${VERSION}${RESET})"
  fi

  _blank
  _preview "Update arrow" "curl -fsSL ${install_url} | bash"
  _ask "Update?" || { _warn "Cancelled."; return; }

  _blank
  _info "Downloading and running installer..."
  bash <(curl -fsSL "$install_url")
}

# arrow self reinstall  (alias: arrow reinstall)
# Force reinstall of the current or latest version, no version check.
cmd_self_reinstall() {
  local install_url="https://raw.githubusercontent.com/${REPO}/main/install.sh"

  _need_pkg curl

  _preview "Reinstall arrow" "curl -fsSL ${install_url} | bash"
  _ask "Reinstall arrow ${VERSION}?" || { _warn "Cancelled."; return; }

  _blank
  _info "Downloading and running installer..."
  bash <(curl -fsSL "$install_url")
}

# arrow self remove
# Download and run uninstall.sh, removing arrow from the system.
cmd_self_remove() {
  local uninstall_url="https://raw.githubusercontent.com/${REPO}/main/uninstall.sh"

  _need_pkg curl

  _preview "Uninstall arrow" \
    "curl -fsSL ${uninstall_url} | bash"

  _ask "Remove arrow from the system?" \
    || { _warn "Cancelled."; return; }

  _blank
  _info "Downloading and running uninstaller..."
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
      _err "Usage: arrow self <update|reinstall|remove>"
      exit 1
      ;;
    *)
      _err "Unknown subcommand: 'self ${sub}'"
      _err "Usage: arrow self <update|reinstall|remove>"
      exit 1
      ;;
  esac
}
