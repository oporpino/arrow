# ── Package commands ──────────────────────────────────────────────────────────

# arrow add <pkg> [pkg2 …]
# Install one or more packages from the official repositories.
cmd_add() {
  [[ $# -eq 0 ]] && _die "Uso: arrow add <pacote> [pacote2 …]"
  _preview "Instalar pacote(s)" "sudo pacman -S $*"
  _ask "Instalar?" || { _warn "Cancelado."; return; }
  _blank
  _run sudo pacman --noconfirm --color=always -S "$@"
}

# arrow delete <pkg> [pkg2 …]
# Remove packages together with any now-orphaned dependencies.
# Aliases: del, rm, remove
cmd_delete() {
  [[ $# -eq 0 ]] && _die "Uso: arrow delete <pacote> [pacote2 …]"
  _preview "Remover pacote(s) e dependências órfãs" "sudo pacman -Rns $*"
  _ask "Remover?" || { _warn "Cancelado."; return; }
  _blank
  _run sudo pacman --noconfirm --color=always -Rns "$@"
}

# arrow search <term>
# Search package names and descriptions in the sync databases.
cmd_search() {
  [[ $# -eq 0 ]] && _die "Uso: arrow search <termo>"
  _info "Buscando por: ${BOLD}$*${RESET}"
  _sep
  pacman -Ss "$@"
}

# arrow info <pkg>
# Show detailed information for a package (remote or local).
cmd_info() {
  _need_pkg "${1:-}"
  _sep
  pacman -Si "$@" 2>/dev/null || pacman -Qi "$@"
}

# arrow files <pkg>
# List every file owned by an installed package.
cmd_files() {
  _need_pkg "${1:-}"
  pacman -Ql "$1"
}

# arrow own <file>
# Identify which installed package owns the given file.
cmd_own() {
  _need_pkg "${1:-}"
  pacman -Qo "$1"
}

# arrow deps <pkg>
# Display the full dependency tree for a package.
cmd_deps() {
  _need_pkg "${1:-}"
  if command -v pactree &>/dev/null; then
    pactree "$1"
  else
    _warn "pactree não encontrado. Instale com: arrow add pacman-contrib"
    pacman -Si "$1" | grep "Depends On"
  fi
}
