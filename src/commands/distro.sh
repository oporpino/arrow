# ── Distro — irreversible system morphs ───────────────────────────────────────
#
#   A "morph" converts this Arch Linux installation into a different
#   distribution by adding repos, installing packages, applying configs
#   and enabling services — permanently.
#
#   RULES for adding a morph:
#     1. Must target Arch Linux only (_distro_require_arch guard).
#     2. Must have NO undo — document why if partial cleanup is possible.
#     3. Must show a clear irreversibility warning before any confirmation.
#     4. Must validate pre-conditions (disk space, arch, connectivity).
#
#   To add a new morph:
#     - Add _distro_morph_<name>() following the pattern below.
#     - Register it in _distro_morph_dispatch and _distro_morph_menu.
#     - Add completions in completions/arrow.bash, _arrow, arrow.fish.
#     - Add an entry in _distro_list.

# ── Guard ──────────────────────────────────────────────────────────────────────

# Ensures this is a plain Arch Linux system.
# Morphs are not supported on Arch-based distros (Manjaro, EndeavourOS, etc.)
# because their custom packages and repos will conflict with the morph's
# assumptions, producing an inconsistent system.
_distro_require_arch() {
  local id
  id=$(grep '^ID=' /etc/os-release 2>/dev/null | cut -d= -f2)
  if [[ "$id" != "arch" ]]; then
    _err "Este comando requer Arch Linux puro."
    _info "Distro detectada: ${BOLD}${id:-desconhecida}${RESET}"
    _warn "Em outras distros (Manjaro, EndeavourOS, etc.) o morph pode produzir um sistema inconsistente."
    return 1
  fi
}

# ── Morph: archcraft ───────────────────────────────────────────────────────────
#
#   Converts Arch Linux ARM into Archcraft ARM by running the official
#   install.sh from the Archcraft ARM release tarball.
#
#   What it does (from install.sh):
#     - Adds [archcraft-arm] repo to pacman.conf
#     - Full system upgrade (pacman -Syyu)
#     - Installs ~100 Archcraft packages (WMs, themes, apps, services)
#     - Enables: sddm, NetworkManager, bluetooth, systemd-timesyncd
#     - Disables: systemd-networkd
#     - Sets graphical.target as default
#     - Copies system configs to /etc (sddm, polkit, X11, sudoers, etc.)
#     - Copies skeleton configs to /etc/skel and new user's home
#     - Adds plymouth boot splash + kernel quiet params
#     - Creates a new user (configured in customize.sh)
#
#   Why there is no undo:
#     The morph replaces core system configs, installs a display manager,
#     changes the default shell, modifies the bootloader, and creates users.
#     Reverting requires manually undoing each of these steps — there is
#     no safe automated path back to a clean Arch Linux state.
#     If you need to revert, restore from a system backup or reinstall Arch.
#
#   Requirements:
#     - Arch Linux ARM (aarch64 or armv7)
#     - ≥ 10GB free on /
#     - ≥ 300MB free on /boot (Archcraft's own requirement)
#     - Internet connection

_distro_morph_archcraft() {
  _section "Morph: Arch Linux ARM → Archcraft ARM"

  # Guard: Arch Linux only
  _distro_require_arch || return 1

  # Pre-flight: /boot space
  local boot_avail boot_avail_mb
  boot_avail=$(df /boot 2>/dev/null | awk 'NR==2 {print $4}')
  boot_avail_mb=$(( ${boot_avail:-0} / 1024 ))
  if [[ ${boot_avail:-0} -lt 307200 ]]; then
    _err "Espaço insuficiente em /boot: ${boot_avail_mb}MB disponíveis (mínimo: 300MB, exigido pelo Archcraft)"
    _blank
    _info "Uso atual de /boot:"
    du -h --max-depth=1 /boot 2>/dev/null | sort -rh | while read -r size path; do
      printf "    ${DIM}%s${RESET}  %s\n" "$size" "$path"
    done
    _blank
    if [[ -f /boot/initramfs-linux-fallback.img ]]; then
      local boot_fallback_mb
      boot_fallback_mb=$(du -m /boot/initramfs-linux-fallback.img 2>/dev/null | cut -f1)
      _warn "initramfs-linux-fallback.img (${boot_fallback_mb}MB) raramente é necessário e pode ser removido."
    fi
    _blank
    _warn "Libere espaço em /boot e execute novamente: arrow distro morph archcraft"
    return 1
  fi

  # Pre-flight: / space
  local root_avail root_avail_gb
  root_avail=$(df / 2>/dev/null | awk 'NR==2 {print $4}')
  root_avail_gb=$(( ${root_avail:-0} / 1024 / 1024 ))
  if [[ ${root_avail:-0} -lt 10485760 ]]; then
    _err "Espaço insuficiente em /: ${root_avail_gb}GB disponíveis (mínimo: 10GB, exigido pelo Archcraft)"
    return 1
  fi

  # Show what will happen
  _step 1 4 "Detectar versão mais recente do Archcraft ARM"
  _step 2 4 "Baixar e extrair o instalador"
  _step 3 4 "Configurar hostname, locale, timezone e usuário"
  _step 4 4 "Executar install.sh como root"

  _blank
  _sep
  echo -e "  ${RED}${BOLD}ATENÇÃO — ESTA OPERAÇÃO NÃO PODE SER DESFEITA${RESET}"
  _sep
  _blank
  _warn "O sistema será permanentemente transformado em Archcraft ARM."
  _warn "Pacotes, configs, serviços e bootloader serão alterados."
  _warn "Para reverter, será necessário restaurar um backup ou reinstalar o Arch."
  _blank
  _ask "Entendo que isso é irreversível. Continuar?" "${RED}${BOLD}" \
    || { _warn "Cancelado."; return; }
  _blank

  # Step 1 — detect version
  _info "Detectando versão mais recente…"
  local version
  version=$(curl -fsSL "https://api.github.com/repos/archcraft-os/archcraft-arm/releases/latest" \
    2>/dev/null | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
  if [[ -z "$version" ]]; then
    _warn "Não foi possível detectar a versão automaticamente."
    printf "  Versão (ex: 1.0): " >&2
    read -r version </dev/tty
  fi
  _ok "Versão: ${BOLD}${version}${RESET}"

  # Step 2 — download and extract
  local workdir="/tmp/archcraft-arm-morph"
  mkdir -p "$workdir"
  _info "Baixando archcraft-arm ${version}…"
  local url="https://github.com/archcraft-os/archcraft-arm/releases/download/${version}/archcraft-arm.tar.gz"
  curl -L --progress-bar "$url" -o "$workdir/archcraft-arm.tar.gz" \
    || { _err "Falha no download."; rm -rf "$workdir"; return 1; }
  _info "Extraindo…"
  tar -xzf "$workdir/archcraft-arm.tar.gz" -C "$workdir" --strip-components=1 \
    || { _err "Falha ao extrair."; rm -rf "$workdir"; return 1; }

  # Step 3 — configure
  _blank
  _info "Abrindo customize.sh — configure hostname, locale, timezone e usuário:"
  _blank
  _warn "  your_hostname  — nome da máquina"
  _warn "  your_locale    — ex: pt_BR.UTF-8"
  _warn "  your_timezone  — ex: America/Sao_Paulo"
  _warn "  your_username  — novo usuário (não use 'alarm')"
  _warn "  your_password  — senha do novo usuário"
  _blank
  "${EDITOR:-nano}" "$workdir/customize.sh"
  _blank

  _ask "Configuração ok? Iniciar o morph?" "${RED}${BOLD}" \
    || { _warn "Cancelado."; rm -rf "$workdir"; return; }
  _blank

  # Step 4 — run as root
  (cd "$workdir" && _asroot bash install.sh) \
    || { _err "Morph falhou."; return 1; }

  rm -rf "$workdir"
  _blank
  _ok "Morph concluído. Reinicie para entrar no Archcraft."
  _info "Use: sudo reboot"
}

# ── Morph list ─────────────────────────────────────────────────────────────────

_distro_list() {
  echo
  echo -e "  ${BOLD}Morphs disponíveis:${RESET}"
  _blank
  echo -e "  ${RED}archcraft${RESET}  Arch Linux ARM → Archcraft ARM  ${DIM}(irreversível)${RESET}"
  _blank
  echo -e "  ${DIM}Uso: arrow distro morph <nome>${RESET}"
  echo -e "  ${DIM}Requer Arch Linux puro. Não suportado em Manjaro, EndeavourOS, etc.${RESET}"
  echo
}

# ── Dispatchers ────────────────────────────────────────────────────────────────

_distro_morph() {
  local name="${1:-}"

  if [[ -z "$name" ]]; then
    printf "\n  ${BOLD}Escolha um morph:${RESET}\n\n" >&2
    printf "    ${CYAN}1${RESET}  archcraft  ${DIM}Arch Linux ARM → Archcraft ARM (irreversível)${RESET}\n" >&2
    printf "\n  Opção [1]: " >&2
    local choice
    read -r choice </dev/tty
    case "${choice:-1}" in
      1) name="archcraft" ;;
      *) _die "Opção inválida: '${choice}'" ;;
    esac
  fi

  case "$name" in
    archcraft) _distro_morph_archcraft ;;
    *)
      _err "Morph desconhecido: '${name}'"
      _distro_list
      return 1
      ;;
  esac
}

# arrow distro morph <name>
# arrow distro list
cmd_distro() {
  local sub="${1:-}"; shift || true

  case "$sub" in
    morph)        _distro_morph "${1:-}" ;;
    list | "")    _distro_list ;;
    *)
      _err "Subcomando desconhecido: 'distro ${sub}'"
      printf "\n  Uso: arrow distro morph <nome>\n\n"
      return 1
      ;;
  esac
}
