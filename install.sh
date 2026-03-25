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

# ── Privilege escalation ───────────────────────────────────────────────────────
# Runs a command as root, trying sudo → doas → plain (if already root).
# Dies with a helpful message if escalation is not possible.
_asroot() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  elif command -v doas &>/dev/null; then
    doas "$@"
  else
    _die "Root privileges required but neither sudo nor doas is available." \
         "Re-run as root: su -c 'bash <(curl -fsSL ${REPO_URL}/raw/main/install.sh)'"
  fi
}

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
  for dep in curl tar; do
    command -v "$dep" &>/dev/null || missing+=("$dep")
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    _warn "Missing dependencies: ${missing[*]}"
    if command -v pacman &>/dev/null; then
      _info "Syncing mirrors…"
      # Kernels without Landlock support (e.g. ARM) need --disable-sandbox.
      local _sandbox=""
      pacman --disable-sandbox --version &>/dev/null && _sandbox="--disable-sandbox"
      _asroot pacman -Syy --noconfirm ${_sandbox}
      _info "Installing via pacman…"
      _asroot pacman -S --noconfirm ${_sandbox} "${missing[@]}"
    else
      _die "Please install manually: ${missing[*]}"
    fi
  fi

  # Ensure bash-completion is installed so tab completion works out of the box.
  if [[ "${SHELL:-}" == */bash ]] && ! command -v bash &>/dev/null; then
    : # non-bash shell, skip
  elif command -v pacman &>/dev/null \
    && ! pacman -Qq bash-completion &>/dev/null 2>&1; then
    _info "Installing bash-completion for tab completion support…"
    local _sandbox=""
    pacman --disable-sandbox --version &>/dev/null && _sandbox="--disable-sandbox"
    _asroot pacman -S --noconfirm ${_sandbox} bash-completion || true
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
  local src="$WORK_DIR/src"
  local out="$WORK_DIR/arrow"
  local version
  version="$(grep -oP '(?<=VERSION=")[^"]+' "$src/src/version.sh")"
  local repo
  repo="$(grep -oP '(?<=REPO=")[^"]+' "$src/src/version.sh")"

  {
    printf '#!/usr/bin/env bash\n'
    printf '# arrow v%s\n' "$version"
    printf '# %s\n' "$repo"
    printf '# SPDX-License-Identifier: MIT\n\n'
    for f in \
      src/version.sh \
      src/colors.sh \
      src/helpers.sh \
      src/commands/packages.sh \
      src/commands/system.sh \
      src/commands/query.sh \
      src/commands/self.sh \
      src/commands/howto.sh \
      src/commands/spell.sh \
      src/commands/distro.sh \
      src/help.sh \
      src/main.sh; do
      sed '/^[[:space:]]*#/d; /^$/d' "$src/$f"
      printf '\n'
    done
  } > "$out"
  chmod +x "$out"
  _ok "Build complete."
}

_do_install() {
  local src="$WORK_DIR/src"
  local out="$WORK_DIR/arrow"
  local bindir="${PREFIX}/bin"
  local mandir="${PREFIX}/share/man/man1"

  install -Dm755 "$out"      "${bindir}/arrow"
  ln -sf arrow               "${bindir}/arw"
  install -Dm644 "$src/man/arrow.1" "${mandir}/arrow.1"

  # Shell completions — use system-wide paths when installing to /usr/local or /usr,
  # otherwise fall back to PREFIX-relative paths.
  local bash_comp zsh_comp fish_comp
  if [[ "$PREFIX" == /usr* ]]; then
    bash_comp="/usr/share/bash-completion/completions/arrow"
    zsh_comp="/usr/share/zsh/site-functions/_arrow"
    fish_comp="/usr/share/fish/vendor_completions.d/arrow.fish"
  else
    bash_comp="${PREFIX}/share/bash-completion/completions/arrow"
    zsh_comp="${PREFIX}/share/zsh/site-functions/_arrow"
    fish_comp="${PREFIX}/share/fish/vendor_completions.d/arrow.fish"
  fi

  install -Dm644 "$src/completions/arrow.bash" "$bash_comp"
  install -Dm644 "$src/completions/_arrow"     "$zsh_comp"
  install -Dm644 "$src/completions/arrow.fish" "$fish_comp"
}

_install() {
  _info "Installing to ${BOLD}${PREFIX}${RESET}…"
  if [[ $EUID -eq 0 || -w "${PREFIX}/bin" ]]; then
    _do_install
  else
    _asroot bash -c "$(declare -f _do_install); WORK_DIR='$WORK_DIR' PREFIX='$PREFIX' _do_install"
  fi
  _ok "Installed."
}

_fix_path() {
  local bin_dir="${PREFIX}/bin"
  local export_line="export PATH=\"\$PATH:${bin_dir}\""

  # Detect the right shell config file.
  local rc_file=""
  case "${SHELL:-}" in
    */zsh)  rc_file="${ZDOTDIR:-$HOME}/.zshrc" ;;
    */fish) rc_file="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
            export_line="fish_add_path ${bin_dir}" ;;
    *)      rc_file="$HOME/.bashrc" ;;
  esac

  # Nothing to do if already in PATH.
  if [[ ":${PATH}:" == *":${bin_dir}:"* ]]; then
    return 0
  fi

  # Append if not already present in the rc file.
  if [[ -n "$rc_file" ]] && ! grep -qF "$bin_dir" "$rc_file" 2>/dev/null; then
    echo "" >> "$rc_file"
    echo "# Added by arrow installer" >> "$rc_file"
    echo "$export_line" >> "$rc_file"
    _ok "PATH updated in ${rc_file}"
    _warn "Reload your shell or run: source ${rc_file}"
  fi
}

_verify() {
  if command -v arrow &>/dev/null && arrow version &>/dev/null 2>&1; then
    _ok "$(arrow version) is ready."
  else
    _fix_path
    _warn "Restart your shell or run:"
    echo -e "  ${DIM}export PATH=\"\$PATH:${PREFIX}/bin\"${RESET}"
  fi

  # Remind user to activate bash completion in the current session.
  if [[ "${SHELL:-}" == */bash ]]; then
    local comp="/usr/share/bash-completion/completions/arrow"
    [[ "$PREFIX" != /usr* ]] && comp="${PREFIX}/share/bash-completion/completions/arrow"
    _info "To enable tab completion now:"
    echo -e "  ${DIM}source ${comp}${RESET}"
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
