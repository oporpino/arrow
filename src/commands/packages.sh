# ── Package commands ──────────────────────────────────────────────────────────

# arrow add <pkg> [pkg2 …]
# Install one or more packages from the official repositories.
cmd_add() {
  local upgrade=true sync=true
  while [[ "${1:-}" == --* ]]; do
    case "$1" in
      --no-upgrade) upgrade=false ;;
      --no-sync)    sync=false; upgrade=false ;;
      *) _die "Unknown option: $1" ;;
    esac
    shift
  done
  [[ $# -eq 0 ]] && _die "Usage: arrow add [--no-upgrade|--no-sync] <package> [package2 …]"

  # Classify each package: installed / pacman repo / AUR / not found.
  local already=() to_install=() aur_pkgs=() not_found=() not_installed=()
  _info "Checking packages..."

  # First check what's already installed
  _check_installed already not_installed "$@"

  # Then classify non-installed packages
  local pkg
  for pkg in "${not_installed[@]}"; do
    if pacman -Si "$pkg" &>/dev/null 2>&1; then
      to_install+=("$pkg")
    elif _aur_exists "$pkg"; then
      aur_pkgs+=("$pkg")
    else
      not_found+=("$pkg")
    fi
  done

  [[ ${#already[@]}  -gt 0 ]] && _warn "Already installed: ${already[*]}"
  [[ ${#aur_pkgs[@]} -gt 0 ]] && _info "Found in AUR: ${BOLD}${aur_pkgs[*]}${RESET}"

  if [[ ${#not_found[@]} -gt 0 ]]; then
    _err "Not found: ${not_found[*]}"
    # Check if the database might just be stale (no entries at all).
    local db_count
    db_count=$(pacman -Sl 2>/dev/null | wc -l)
    if [[ "$db_count" -lt 100 ]]; then
      _warn "Package database appears empty or stale."
      _info "Run ${BOLD}arrow update${RESET} to refresh it, then try again."
    else
      # Suggest close matches from the repos.
      local pkg
      for pkg in "${not_found[@]}"; do
        local matches
        matches=$(pacman -Ssq "^${pkg}" 2>/dev/null | head -3 | tr '\n' ' ')
        [[ -n "$matches" ]] && _info "Did you mean: ${BOLD}${matches}${RESET}"
      done
    fi
  fi

  if [[ ${#to_install[@]} -eq 0 && ${#aur_pkgs[@]} -eq 0 ]]; then
    [[ ${#not_found[@]} -gt 0 ]] && return 1
    _ok "Nothing to install."
    return
  fi

  # Resolve AUR helper upfront (may prompt user to choose yay/paru).
  local helper=""
  if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
    _ensure_aur_helper || return 1
    helper=$(_aur_helper)
  fi

  # ── Build unified preview with all commands ──────────────────────────────────
  local preview_cmds=()
  if [[ ${#to_install[@]} -gt 0 ]]; then
    if $upgrade; then
      preview_cmds+=("pacman -Syu  # -S sync  -y refresh db  -u upgrade")
    elif $sync; then
      preview_cmds+=("pacman -Syy  # -S sync  -yy force db refresh")
    fi
    preview_cmds+=("pacman -S ${to_install[*]}  # install package(s) from repos")
  fi
  if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
    preview_cmds+=("${helper} -S ${aur_pkgs[*]}  # AUR")
  fi

  _blank
  _preview "Install package(s)" "${preview_cmds[@]}"
  _ask "Install?" || { _warn "Cancelled."; return; }
  _blank

  # ── Execute ──────────────────────────────────────────────────────────────────
  if [[ ${#to_install[@]} -gt 0 ]]; then
    $upgrade && _run _pkg -Syu
    $sync && ! $upgrade && _run _pkg -Syy
    _run _pkg -S "${to_install[@]}"
  fi

  if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
    _run "$helper" -S --noconfirm "${aur_pkgs[@]}"
  fi
}

# arrow delete <pkg> [pkg2 …]
# Remove packages together with any now-orphaned dependencies.
# Aliases: del, rm, remove
cmd_delete() {
  [[ $# -eq 0 ]] && _die "Usage: arrow delete <package> [package2 …]"

  # Check which packages are actually installed
  local installed=() not_installed=()
  _check_installed installed not_installed "$@"

  [[ ${#not_installed[@]} -gt 0 ]] && _warn "Not installed: ${not_installed[*]}"

  if [[ ${#installed[@]} -eq 0 ]]; then
    _err "No installed packages to remove."
    return 1
  fi

  _preview "Remove package(s) and orphaned deps" "pacman -Rns ${installed[*]}  # -R remove  -n no backup  -s remove orphaned deps"
  _ask "Remove?" || { _warn "Cancelled."; return; }
  _blank

  # First attempt: capture stderr to detect dependent packages.
  _cmd "pacman -Rns ${installed[*]}"
  local err
  if err=$(_pkg -Rns "${installed[@]}" 2>&1); then
    _ok "Done."
    return
  fi

  # Parse packages that block the removal.
  local dependents
  dependents=$(printf '%s\n' "$err" | grep "required by" | sed 's/.*required by //' | sort -u | tr '\n' ' ' | sed 's/[[:space:]]*$//')

  if [[ -z "$dependents" ]]; then
    [[ "${ARROW_DEBUG:-0}" == "1" ]] && printf '%s\n' "$err" >&2
    _err "Failed."
    return 1
  fi

  _blank
  _warn "The following packages depend on ${installed[*]} and must be removed too:"
  local dep
  for dep in $dependents; do
    echo -e "    ${YELLOW}•${RESET}  ${YELLOW}${dep}${RESET}"
  done
  _blank

  _preview "Remove all" "pacman -Rns ${installed[*]} ${dependents}  # -R remove  -n no backup  -s remove orphaned deps"
  _ask "Remove all?" "${RED}${BOLD}" || { _warn "Cancelled."; return; }
  _blank
  # shellcheck disable=SC2086
  _run _pkg -Rns "${installed[@]}" $dependents
}

# arrow search <term>
# Search pacman repos, then AUR if a helper is available.
cmd_search() {
  [[ $# -eq 0 ]] && _die "Usage: arrow search <term>"
  _info "Searching for: ${BOLD}$*${RESET}"
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
    _warn "pactree not found. Install with: arrow add pacman-contrib"
    pacman -Si "$1" | grep "Depends On"
  fi
}
