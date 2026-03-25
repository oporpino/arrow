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
  local -a cmd_parts=() note_parts=()
  local max_len=0

  # First pass: split commands from annotations and find longest command.
  for c in "$@"; do
    local cmd_part="${c%%  #*}"
    local note_part=""
    [[ "$cmd_part" != "$c" ]] && note_part="${c#*  #}"
    cmd_parts+=("$cmd_part")
    note_parts+=("$note_part")
    (( ${#cmd_part} > max_len )) && max_len=${#cmd_part}
  done

  echo
  echo -e "  ${DIM}┌─${RESET} ${BOLD}${label}${RESET}"
  local i
  for i in "${!cmd_parts[@]}"; do
    local cmd="${cmd_parts[$i]}"
    local note="${note_parts[$i]}"
    local pad
    pad=$(printf '%*s' $(( max_len - ${#cmd} )) '')
    if [[ -n "$note" ]]; then
      echo -e "  ${DIM}│${RESET}  ${DIM_CYAN}\$${RESET}  ${CYAN}${cmd}${RESET}${pad}  ${DIM_WHITE}# ${note}${RESET}"
    else
      echo -e "  ${DIM}│${RESET}  ${DIM_CYAN}\$${RESET}  ${CYAN}${cmd}${RESET}"
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
  local color="${2:-${BOLD}}"
  printf "  ${color}%s${RESET} ${DIM}[s/N]${RESET} " "$prompt"
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
  local display=("$@")

  # Resolve _asroot or _pacman to a user-friendly prefix for display.
  local _prefix=""
  if [[ $EUID -ne 0 ]]; then
    command -v sudo &>/dev/null && _prefix="sudo"
    command -v doas &>/dev/null && _prefix="doas"
  fi

  case "${display[0]}" in
    _asroot)
      if [[ -n "$_prefix" ]]; then display[0]="$_prefix"
      else display=("${display[@]:1}"); fi
      ;;
    _pacman)
      if [[ -n "$_prefix" ]]; then display=("$_prefix" "pacman" "${display[@]:1}")
      else display=("pacman" "${display[@]:1}"); fi
      ;;
  esac

  # In normal mode, strip internal flags from display.
  # ARROW_DEBUG=1 shows the full command as executed.
  if [[ "${ARROW_DEBUG:-0}" != "1" ]]; then
    local filtered=()
    for arg in "${display[@]}"; do
      [[ "$arg" == "--noconfirm" || "$arg" == "--color=always" || "$arg" == "--disable-sandbox" ]] && continue
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

# Detect --disable-sandbox support once (needed on kernels without Landlock, e.g. ARM).
_PACMAN_SANDBOX=""
pacman --disable-sandbox --version &>/dev/null && _PACMAN_SANDBOX="--disable-sandbox"

# Runs pacman non-interactively as root with coloured output.
_pacman() { _asroot pacman --noconfirm --color=always ${_PACMAN_SANDBOX} "$@"; }
