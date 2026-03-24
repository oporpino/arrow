#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
#  arrow — uninstaller
#
#  Removes the arrow binary, arw alias, man page, shell completions,
#  and the PATH entry added by the installer.
#
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/oporpino/arrow/main/uninstall.sh | bash
#
#  Custom prefix:
#    curl ... | PREFIX=~/.local bash
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"

BIN_DIR="${PREFIX}/bin"
MAN_DIR="${PREFIX}/share/man/man1"
BASH_COMP="/usr/share/bash-completion/completions/arrow"
ZSH_COMP="/usr/share/zsh/site-functions/_arrow"
FISH_COMP="/usr/share/fish/vendor_completions.d/arrow.fish"

# ── Terminal helpers ───────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  BOLD="\033[1m" GREEN="\033[1;32m" YELLOW="\033[1;33m"
  RED="\033[1;31m" CYAN="\033[1;36m" DIM="\033[2m" RESET="\033[0m"
else
  BOLD="" GREEN="" YELLOW="" RED="" CYAN="" DIM="" RESET=""
fi

_info() { echo -e "${CYAN}::${RESET} $*"; }
_ok()   { echo -e "${GREEN}✔${RESET}  $*"; }
_warn() { echo -e "${YELLOW}⚠${RESET}  $*"; }
_err()  { echo -e "${RED}✘${RESET}  $*" >&2; }
_die()  { _err "$*"; exit 1; }
_sep()  { echo -e "${DIM}────────────────────────────────────${RESET}"; }

# ── Privilege escalation ───────────────────────────────────────────────────────
_asroot() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  elif command -v doas &>/dev/null; then
    doas "$@"
  else
    _die "Root privileges required but neither sudo nor doas is available."
  fi
}

# ── Helpers ───────────────────────────────────────────────────────────────────

_remove() {
  local file="$1"
  if [[ -e "$file" || -L "$file" ]]; then
    if [[ $EUID -eq 0 || -w "$(dirname "$file")" ]]; then
      rm -f "$file"
    else
      _asroot rm -f "$file"
    fi
    _ok "Removed ${DIM}${file}${RESET}"
  fi
}

_clean_path() {
  local rc_files=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
  )
  for rc in "${rc_files[@]}"; do
    if [[ -f "$rc" ]] && grep -q "${BIN_DIR}" "$rc" 2>/dev/null; then
      sed -i "/# Added by arrow installer/d; /$(echo "${BIN_DIR}" | sed 's|/|\\/|g')/d" "$rc"
      _ok "Cleaned PATH from ${rc}"
    fi
  done
}

# ── Main ──────────────────────────────────────────────────────────────────────

main() {
  echo
  echo -e "  ${BOLD}${RED}arrow${RESET} — uninstaller"
  _sep

  # Confirm before removing.
  if [[ -t 0 ]]; then
    printf "  Remove arrow from %s? [y/N] " "${BIN_DIR}"
    read -r ans
    [[ "${ans,,}" == "y" ]] || { _warn "Cancelled."; echo; exit 0; }
    echo
  fi

  _info "Removing files…"
  _remove "${BIN_DIR}/arrow"
  _remove "${BIN_DIR}/arw"
  _remove "${MAN_DIR}/arrow.1"
  _remove "${BASH_COMP}"
  _remove "${ZSH_COMP}"
  _remove "${FISH_COMP}"

  _info "Cleaning up PATH…"
  _clean_path

  _sep
  echo -e "  ${BOLD}Done.${RESET} arrow has been removed."
  _warn "Restart your shell to clear the PATH."
  echo
}

main "$@"
