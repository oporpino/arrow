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
#   ──  Updating the system  ────────────────────────────────────────────────
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
#   [1/3] Configuring locale
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
#   Usage: _preview "Install GNOME" "sudo pacman -S gnome" "sudo systemctl enable gdm"
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
#   Usage: _ask "Continue?" && do_something
#
_ask() {
  local prompt="${1:-Continue?}"
  local color="${2:-${BOLD}}"
  printf "  ${color}%s${RESET} ${DIM}[y/N]${RESET} " "$prompt"
  local ans
  read -r ans
  [[ "${ans,,}" == "y" ]]
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
    _ok "Done."
  else
    _err "Failed: ${display[*]}"
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
    _die "Root privileges required but sudo/doas are not installed." \
         "Install sudo: pacman -S sudo   or run as root."
  fi
}

# ── Guards ────────────────────────────────────────────────────────────────────

_require_not_root() {
  [[ $EUID -eq 0 ]] && _die "Do not run as root. Use sudo only when necessary."
  return 0
}

_need_pkg() {
  [[ -z "${1:-}" ]] && _die "Please provide a package name."
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

# Returns 0 if the package exists in the AUR, 1 otherwise.
# Uses the installed AUR helper if available (faster); falls back to AUR API.
_aur_exists() {
  local pkg="$1"
  local helper
  helper=$(_aur_helper)
  if [[ -n "$helper" ]]; then
    "$helper" -Si "$pkg" &>/dev/null 2>&1
  else
    local result
    result=$(curl -fsSL --connect-timeout 3 --max-time 5 \
      "https://aur.archlinux.org/rpc/?v=5&type=info&arg=${pkg}" 2>/dev/null)
    echo "$result" | grep -q '"resultcount":[1-9]'
  fi
}

# Ensures an AUR helper is available. If none found, asks the user which to install
# (yay or paru) and bootstraps it via git + makepkg.
# All output goes to stderr so this can be called without subshell capture.
# Returns 0 on success, 1 on failure.
_ensure_aur_helper() {
  local helper
  helper=$(_aur_helper)
  [[ -n "$helper" ]] && return 0

  _blank
  _warn "No AUR helper installed."
  printf "  ${BOLD}Choose a helper:${RESET}\n" >&2
  printf "    ${CYAN}1${RESET}  yay   (most popular, written in Go)\n" >&2
  printf "    ${CYAN}2${RESET}  paru  (faster, written in Rust)\n" >&2
  printf "\n  Option [1/2]: " >&2
  local choice
  read -r choice </dev/tty
  case "${choice:-1}" in
    2) helper="paru" ;;
    *) helper="yay"  ;;
  esac

  [[ $EUID -eq 0 ]] && _die "makepkg cannot run as root. Run as a normal user."

  _info "Installing build dependencies..."
  _pacman -S --needed base-devel git || true

  local tmp
  tmp=$(mktemp -d)
  _info "Cloning ${helper} from AUR..."
  git clone "https://aur.archlinux.org/${helper}.git" "${tmp}/${helper}" \
    || { rm -rf "$tmp"; _die "Failed to clone ${helper}."; }

  _info "Building and installing ${helper}..."
  (cd "${tmp}/${helper}" && makepkg -si --noconfirm) \
    || { rm -rf "$tmp"; _die "Failed to build ${helper}."; }

  rm -rf "$tmp"
  _ok "${helper} installed."
}

# Detect --disable-sandbox support once (needed on kernels without Landlock, e.g. ARM).
_PACMAN_SANDBOX=""
pacman --disable-sandbox --version &>/dev/null && _PACMAN_SANDBOX="--disable-sandbox"

# Runs pacman non-interactively as root with coloured output.
# Temporarily suppresses kernel console messages (audit noise) during execution.
_pacman() {
  local _lvl
  _lvl=$(cut -f1 /proc/sys/kernel/printk 2>/dev/null)
  _asroot dmesg -n 1 2>/dev/null || true

  _asroot pacman --noconfirm --color=always ${_PACMAN_SANDBOX} "$@"
  local _ret=$?

  [[ -n "$_lvl" ]] && _asroot dmesg -n "$_lvl" 2>/dev/null || true
  return $_ret
}

# Check if packages are installed and return separate lists.
# Usage: _check_installed installed_var not_installed_var pkg1 pkg2 ...
_check_installed() {
  local -n _inst_ref="$1" _not_inst_ref="$2"
  shift 2
  local pkg
  for pkg in "$@"; do
    if pacman -Qq "$pkg" &>/dev/null; then
      _inst_ref+=("$pkg")
    else
      _not_inst_ref+=("$pkg")
    fi
  done
}
