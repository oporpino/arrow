# ── Package commands ──────────────────────────────────────────────────────────

# arrow add <pkg> [pkg2 …]
# Install one or more packages from the official repositories.
cmd_add() {
  local upgrade=true sync=true
  while [[ "${1:-}" == --* ]]; do
    case "$1" in
      --no-upgrade) upgrade=false ;;
      --no-sync)    sync=false; upgrade=false ;;
      *) _die "Opção desconhecida: $1" ;;
    esac
    shift
  done
  [[ $# -eq 0 ]] && _die "Uso: arrow add [--no-upgrade|--no-sync] <pacote> [pacote2 …]"

  # Classify each package: installed / pacman repo / AUR / not found.
  local already=() to_install=() aur_pkgs=() not_found=()
  _info "Verificando pacotes…"
  local pkg
  for pkg in "$@"; do
    if pacman -Qq "$pkg" &>/dev/null; then
      already+=("$pkg")
    elif pacman -Si "$pkg" &>/dev/null 2>&1; then
      to_install+=("$pkg")
    elif _aur_exists "$pkg"; then
      aur_pkgs+=("$pkg")
    else
      not_found+=("$pkg")
    fi
  done

  [[ ${#already[@]}   -gt 0 ]] && _warn "Já instalado(s): ${already[*]}"
  [[ ${#aur_pkgs[@]}  -gt 0 ]] && _info "Encontrado(s) no AUR: ${BOLD}${aur_pkgs[*]}${RESET}"
  [[ ${#not_found[@]} -gt 0 ]] && _err  "Não encontrado(s): ${not_found[*]}"

  if [[ ${#to_install[@]} -eq 0 && ${#aur_pkgs[@]} -eq 0 ]]; then
    [[ ${#not_found[@]} -gt 0 ]] && return 1
    _ok "Nada a instalar."
    return
  fi

  # Resolve AUR helper upfront (may prompt user to choose yay/paru).
  local helper=""
  if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
    helper=$(_ensure_aur_helper) || return 1
  fi

  # ── Build unified preview with all commands ──────────────────────────────────
  local preview_cmds=()
  if [[ ${#to_install[@]} -gt 0 ]]; then
    if $upgrade; then
      preview_cmds+=("pacman -Syu  # -S sync  -y atualiza db  -u upgrade")
    elif $sync; then
      preview_cmds+=("pacman -Syy  # -S sync  -yy força refresh do db")
    fi
    preview_cmds+=("pacman -S ${to_install[*]}  # instala pacote(s) dos repos")
  fi
  if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
    preview_cmds+=("${helper} -S ${aur_pkgs[*]}  # AUR")
  fi

  _blank
  _preview "Instalar pacote(s)" "${preview_cmds[@]}"
  _ask "Instalar?" || { _warn "Cancelado."; return; }
  _blank

  # ── Execute ──────────────────────────────────────────────────────────────────
  if [[ ${#to_install[@]} -gt 0 ]]; then
    $upgrade && _run _pacman -Syu
    $sync && ! $upgrade && _run _pacman -Syy
    _run _pacman -S "${to_install[@]}"
  fi

  if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
    _run "$helper" -S --noconfirm "${aur_pkgs[@]}"
  fi
}

# arrow delete <pkg> [pkg2 …]
# Remove packages together with any now-orphaned dependencies.
# Aliases: del, rm, remove
cmd_delete() {
  [[ $# -eq 0 ]] && _die "Uso: arrow delete <pacote> [pacote2 …]"
  _preview "Remover pacote(s) e dependências órfãs" "pacman -Rns $*  # -R remover  -n sem backup  -s remove deps órfãs"
  _ask "Remover?" || { _warn "Cancelado."; return; }
  _blank

  # First attempt: capture stderr to detect dependent packages.
  _cmd "pacman -Rns $*"
  local err
  if err=$(_pacman -Rns "$@" 2>&1); then
    _ok "Concluído."
    return
  fi

  # Parse packages that block the removal.
  local dependents
  dependents=$(printf '%s\n' "$err" | grep "required by" | sed 's/.*required by //' | sort -u | tr '\n' ' ' | sed 's/[[:space:]]*$//')

  if [[ -z "$dependents" ]]; then
    [[ "${ARROW_DEBUG:-0}" == "1" ]] && printf '%s\n' "$err" >&2
    _err "Falhou."
    return 1
  fi

  _blank
  _warn "Os seguintes pacotes dependem de ${*} e precisam ser removidos junto:"
  local dep
  for dep in $dependents; do
    echo -e "    ${YELLOW}•${RESET}  ${YELLOW}${dep}${RESET}"
  done
  _blank

  _preview "Remover tudo" "pacman -Rns $* ${dependents}  # -R remover  -n sem backup  -s remove deps órfãs"
  _ask "Remover tudo?" "${RED}${BOLD}" || { _warn "Cancelado."; return; }
  _blank
  # shellcheck disable=SC2086
  _run _pacman -Rns "$@" $dependents
}

# arrow search <term>
# Search pacman repos, then AUR if a helper is available.
cmd_search() {
  [[ $# -eq 0 ]] && _die "Uso: arrow search <termo>"
  _info "Buscando por: ${BOLD}$*${RESET}"
  _sep
  pacman -Ss "$@" || true
  local helper
  helper=$(_aur_helper)
  if [[ -n "$helper" ]]; then
    _blank
    _info "AUR:"
    _sep
    "$helper" -Ss --aur "$@" 2>/dev/null || true
  fi
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
