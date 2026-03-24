# ── Package commands ──────────────────────────────────────────────────────────

# arch add <pkg> [pkg2 …]
# Install one or more packages from the official repositories.
cmd_add() {
  [[ $# -eq 0 ]] && _die "Uso: arch add <pacote> [pacote2 …]"
  _info "Instalando: ${BOLD}$*${RESET}"
  _pacman -S "$@"
}

# arch del <pkg> [pkg2 …]
# Remove packages together with any now-orphaned dependencies.
cmd_del() {
  [[ $# -eq 0 ]] && _die "Uso: arch del <pacote> [pacote2 …]"
  _info "Removendo: ${BOLD}$*${RESET}"
  _pacman -Rns "$@"
}

# arch search <term>
# Search package names and descriptions in the sync databases.
cmd_search() {
  [[ $# -eq 0 ]] && _die "Uso: arch search <termo>"
  _info "Buscando por: ${BOLD}$*${RESET}"
  _sep
  pacman -Ss "$@"
}

# arch info <pkg>
# Show detailed information for a package (remote or local).
cmd_info() {
  _need_pkg "${1:-}"
  _sep
  pacman -Si "$@" 2>/dev/null || pacman -Qi "$@"
}

# arch files <pkg>
# List every file owned by an installed package.
cmd_files() {
  _need_pkg "${1:-}"
  pacman -Ql "$1"
}

# arch own <file>
# Identify which installed package owns the given file.
cmd_own() {
  _need_pkg "${1:-}"
  pacman -Qo "$1"
}

# arch deps <pkg>
# Display the full dependency tree for a package.
cmd_deps() {
  _need_pkg "${1:-}"
  if command -v pactree &>/dev/null; then
    pactree "$1"
  else
    _warn "pactree não encontrado. Instale com: arch add pacman-contrib"
    pacman -Si "$1" | grep "Depends On"
  fi
}
