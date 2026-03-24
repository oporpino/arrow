# ── Output helpers ────────────────────────────────────────────────────────────

_info() { echo -e "${CYAN}::${RESET} $*"; }
_ok()   { echo -e "${GREEN}✔${RESET}  $*"; }
_warn() { echo -e "${YELLOW}⚠${RESET}  $*"; }
_err()  { echo -e "${RED}✘${RESET}  $*" >&2; }
_die()  { _err "$*"; exit 1; }
_sep()  { echo -e "${DIM}────────────────────────────────────${RESET}"; }

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

# Runs pacman non-interactively with sudo and coloured output.
_pacman() { sudo pacman --noconfirm --color=always "$@"; }
