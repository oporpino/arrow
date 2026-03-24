#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
#  arrow — one-shot installer
#
#  Installs arrow, its shell completions, the arw alias, and the man page.
#
#  Usage (always installs latest):
#    curl -fsSL https://raw.githubusercontent.com/oporpino/arrow/main/install.sh | bash
#
#  Install a specific version:
#    curl -fsSL https://raw.githubusercontent.com/oporpino/arrow/main/install.sh \
#      | ARROW_VERSION=v1.2.0 bash
#
#  Custom prefix (no sudo required):
#    curl ... | PREFIX=~/.local bash
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────

REPO="oporpino/arrow"
REPO_URL="https://github.com/${REPO}"

# ARROW_VERSION can be a tag like "v1.0.0" or "main" for the bleeding edge.
ARROW_VERSION="${ARROW_VERSION:-main}"

# Resolve the archive URL based on the version.
if [[ "$ARROW_VERSION" == "main" ]]; then
  ARCHIVE_URL="${REPO_URL}/archive/refs/heads/main.tar.gz"
else
  ARCHIVE_URL="${REPO_URL}/archive/refs/tags/${ARROW_VERSION}.tar.gz"
fi

PREFIX="${PREFIX:-/usr/local}"
WORK_DIR="$(mktemp -d /tmp/arrow-install.XXXXXX)"

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

# ── Cleanup ───────────────────────────────────────────────────────────────────

_cleanup() { rm -rf "$WORK_DIR"; }
trap _cleanup EXIT

# ── Pre-flight checks ─────────────────────────────────────────────────────────

_check_os() {
  if ! command -v pacman &>/dev/null; then
    _warn "pacman not found — arrow is designed for Arch Linux / Arch-based systems."
    printf "Continue anyway? [y/N] "
    read -r ans
    [[ "${ans,,}" == "y" ]] || _die "Installation cancelled."
  fi
}

_check_deps() {
  local missing=()
  for dep in curl tar make; do
    command -v "$dep" &>/dev/null || missing+=("$dep")
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    _warn "Missing dependencies: ${missing[*]}"
    if command -v pacman &>/dev/null; then
      _info "Installing via pacman…"
      local _sudo=""
      [[ $EUID -ne 0 ]] && _sudo="sudo"
      ${_sudo} pacman -S --noconfirm "${missing[@]}"
    else
      _die "Please install manually: ${missing[*]}"
    fi
  fi
}

# ── Install steps ─────────────────────────────────────────────────────────────

_download() {
  _info "Downloading ${BOLD}arrow ${ARROW_VERSION}${RESET}…"
  curl -fsSL "$ARCHIVE_URL" -o "$WORK_DIR/arrow.tar.gz" \
    || _die "Download failed. Check your internet connection."
  mkdir -p "$WORK_DIR/src"
  tar -xzf "$WORK_DIR/arrow.tar.gz" -C "$WORK_DIR/src" --strip-components=1
  _ok "Downloaded."
}

_build() {
  _info "Building…"
  make -C "$WORK_DIR/src" build --silent
  _ok "Build complete."
}

_install() {
  local need_sudo=""
  [[ $EUID -ne 0 && ! -w "${PREFIX}/bin" ]] && need_sudo="sudo"

  _info "Installing to ${BOLD}${PREFIX}${RESET}…"
  ${need_sudo} make -C "$WORK_DIR/src" install PREFIX="$PREFIX" --silent
  _ok "Installed."
}

_verify() {
  if command -v arrow &>/dev/null && arrow version &>/dev/null 2>&1; then
    _ok "$(arrow version) is ready."
  else
    _warn "'arrow' is not in your PATH yet."
    _warn "Add ${PREFIX}/bin to your PATH:"
    echo -e "  ${DIM}export PATH=\"\$PATH:${PREFIX}/bin\"${RESET}"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

main() {
  echo
  echo -e "  ${BOLD}${CYAN}arrow${RESET} — installer"
  echo -e "  ${DIM}${REPO_URL}${RESET}"
  _sep

  _check_os
  _check_deps
  _download
  _build
  _install
  _verify

  _sep
  echo -e "  ${BOLD}Done!${RESET} Run ${CYAN}arrow help${RESET} to get started."
  echo
}

main "$@"
