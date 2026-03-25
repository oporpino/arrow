# ── Basic output ──────────────────────────────────────────────────────────────

_info()    { echo -e "  ${CYAN}::${RESET} $*"; }
_ok()      { echo -e "  ${GREEN}✔${RESET}  $*"; }
_warn()    { echo -e "  ${YELLOW}⚠${RESET}  $*"; }
_err()     { echo -e "  ${RED}✘${RESET}  $*" >&2; }
_die()     { _err "$*"; exit 1; }
_sep()     { echo -e "  ${DIM}────────────────────────────────────────${RESET}"; }
_blank()   { echo; }

# ── Section header ────────────────────────────────────────────────────────────
#
#   ──  Atualizando o sistema  ──────────────────────────────────────────────
#
_section() {
  local title=" $* "
  local width=60
  local left="── "
  local right
  right=$(printf '%.0s─' $(seq 1 $(( width - ${#title} - ${#left} )) ))
  echo
  echo -e "  ${BOLD}${CYAN}${left}${RESET}${BOLD}${title}${RESET}${DIM}${right}${RESET}"
  echo
}

# ── Step indicator  ──────────────────────────────────────────────────────────
#
#   [1/3] Configurando locale
#
_step() {
  local n="$1" total="$2"; shift 2
  echo -e "  ${DIM_WHITE}[${n}/${total}]${RESET} ${BOLD}$*${RESET}"
}

# ── Command preview ───────────────────────────────────────────────────────────
#
#   Renders a command the user could run themselves:
#
#     $ sudo pacman -S gnome gdm
#
_cmd() {
  echo -e "  ${DIM_CYAN}  \$${RESET}  ${WHITE}$*${RESET}"
}

# ── Command block ─────────────────────────────────────────────────────────────
#
#   Shows a labelled list of commands before asking for confirmation.
#   Usage: _preview "Instalar GNOME" "sudo pacman -S gnome" "sudo systemctl enable gdm"
#
_preview() {
  local label="$1"; shift
  echo
  echo -e "  ${DIM}┌─${RESET} ${BOLD}${label}${RESET}"
  for c in "$@"; do
    # Split on "  #" to separate command from inline annotation.
    local cmd_part="${c%%  #*}"
    if [[ "$cmd_part" != "$c" ]]; then
      local note_part="${c#*  #}"
      echo -e "  ${DIM}│${RESET}  ${DIM_CYAN}\$${RESET}  ${WHITE}${cmd_part}${RESET}  ${DIM_WHITE}# ${note_part}${RESET}"
    else
      echo -e "  ${DIM}│${RESET}  ${DIM_CYAN}\$${RESET}  ${WHITE}${c}${RESET}"
    fi
  done
  echo -e "  ${DIM}└────────────────────────────────────────${RESET}"
  echo
}

# ── Confirmation prompt ───────────────────────────────────────────────────────
#
#   Returns 0 if confirmed, 1 if declined.
#   Usage: _ask "Continuar?" && do_something
#
_ask() {
  local prompt="${1:-Continuar?}"
  printf "  ${BOLD}%s${RESET} ${DIM}[s/N]${RESET} " "$prompt"
  local ans
  read -r ans
  [[ "${ans,,}" == "s" || "${ans,,}" == "y" ]]
}

# ── Run with display ──────────────────────────────────────────────────────────
#
#   Shows the command (resolving _asroot to sudo/doas/root),
#   executes it, and reports ✔ or ✘.
#   Usage: _run _asroot pacman -S firefox
#
_run() {
  # Build a display-friendly version of the command:
  # replace _asroot with the actual escalation tool (or nothing if already root).
  local display=("$@")
  if [[ "${display[0]}" == "_asroot" ]]; then
    if [[ $EUID -eq 0 ]]; then
      display=("${display[@]:1}")
    elif command -v sudo &>/dev/null; then
      display[0]="sudo"
    elif command -v doas &>/dev/null; then
      display[0]="doas"
    fi
  fi

  # In normal mode, strip internal flags from display (--noconfirm, --color=always).
  # ARROW_DEBUG=1 shows the full command as executed.
  if [[ "${ARROW_DEBUG:-0}" != "1" ]]; then
    local filtered=()
    for arg in "${display[@]}"; do
      [[ "$arg" == "--noconfirm" || "$arg" == "--color=always" ]] && continue
      filtered+=("$arg")
    done
    display=("${filtered[@]}")
  fi

  _cmd "${display[*]}"
  if "$@"; then
    _ok "Concluído."
  else
    _err "Falhou: ${display[*]}"
    return 1
  fi
}

# ── Privilege escalation ──────────────────────────────────────────────────────
#
#   Runs a command as root: directly if already root, else via sudo or doas.
#   Dies with a helpful message if no escalation tool is available.
#
_asroot() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  elif command -v doas &>/dev/null; then
    doas "$@"
  else
    _die "Permissão de root necessária, mas sudo/doas não estão instalados." \
         "Instale sudo: pacman -S sudo   ou execute como root."
  fi
}

# ── Guards ────────────────────────────────────────────────────────────────────

_require_not_root() {
  [[ $EUID -eq 0 ]] && _die "Não execute como root. Use sudo apenas quando necessário."
  return 0
}

_need_pkg() {
  [[ -z "${1:-}" ]] && _die "Informe o nome do pacote."
  return 0
}

# ── Utility ───────────────────────────────────────────────────────────────────

# Prints the name of the first available AUR helper, or empty string.
_aur_helper() {
  local h
  for h in yay paru; do
    command -v "$h" &>/dev/null && echo "$h" && return
  done
  echo ""
}

# Runs pacman non-interactively as root with coloured output.
_pacman() { _asroot pacman --noconfirm --color=always "$@"; }
