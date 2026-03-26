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

# Ensures this is a plain Arch Linux system (x86_64 or ARM).
# Morphs are not supported on Arch-based distros (Manjaro, EndeavourOS, etc.)
# because their custom packages and repos will conflict with the morph's
# assumptions, producing an inconsistent system.
# Accepted IDs: "arch" (x86_64) and "archarm" (Arch Linux ARM).
_distro_require_arch() {
  local id
  id=$(grep '^ID=' /etc/os-release 2>/dev/null | cut -d= -f2)
  if [[ "$id" != "arch" && "$id" != "archarm" ]]; then
    _err "This command requires plain Arch Linux."
    _info "Detected distro: ${BOLD}${id:-unknown}${RESET}"
    _warn "On other distros (Manjaro, EndeavourOS, etc.) the morph may produce an inconsistent system."
    return 1
  fi
}

# Ensures this is specifically Arch Linux ARM.
# Used by morphs whose installers are ARM-only.
_distro_require_archarm() {
  local id
  id=$(grep '^ID=' /etc/os-release 2>/dev/null | cut -d= -f2)
  if [[ "$id" != "archarm" ]]; then
    _err "This morph requires Arch Linux ARM."
    _info "Detected distro: ${BOLD}${id:-unknown}${RESET}"
    _warn "The Archcraft ARM installer is ARM-only and will not work on x86_64."
    return 1
  fi
}

# ── Boot restore helper ────────────────────────────────────────────────────────
#
#   Restores /boot from a backup directory created by the morph pre-flight.
#   No-op if no backup path is given (backup was never created).
#
_distro_restore_boot() {
  local backup="${1:-}"
  [[ -z "$backup" ]] && return 0
  _blank
  _warn "Restoring /boot from backup..."
  if _asroot cp -a "$backup/." /boot/; then
    _ok "/boot restored."
    _asroot rm -rf "$backup"
  else
    _err "Restore failed. Backup is still at: ${backup}"
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
#     - /boot space: if < 300MB free, arrow offers to back up + clear + restore on failure
#     - Internet connection

_distro_morph_archcraft() {
  _section "Morph: Arch Linux ARM → Archcraft ARM"

  # Guard: Arch Linux ARM only (Archcraft ARM installer is ARM-specific)
  _distro_require_archarm || return 1

  # Pre-flight: archlinuxarm-keyring
  # The Archcraft installer initializes the archlinuxarm keyring directly;
  # if the package is missing, it exits with a fatal error.
  if ! pacman -Qq archlinuxarm-keyring &>/dev/null; then
    _info "Installing archlinuxarm-keyring (required by the Archcraft installer)..."
    _run _pkg -S archlinuxarm-keyring || return 1
    _asroot pacman-key --populate archlinuxarm \
      || { _err "Failed to populate archlinuxarm keyring."; return 1; }
    _ok "Keyring ready."
    _blank
  fi

  # Pre-flight: / space (check before touching /boot)
  local root_avail root_avail_gb
  root_avail=$(df / 2>/dev/null | awk 'NR==2 {print $4}')
  root_avail_gb=$(( ${root_avail:-0} / 1024 / 1024 ))
  if [[ ${root_avail:-0} -lt 10485760 ]]; then
    _err "/ space insufficient: ${root_avail_gb}GB available (minimum: 10GB, required by Archcraft)"
    return 1
  fi

  # Pre-flight: /boot space
  # If space is tight, offer to back up /boot, clear it, and restore on failure.
  # Even after clearing, a small /boot partition may still be under 300MB —
  # we let the install attempt proceed and rely on the backup for recovery.
  local boot_avail boot_avail_mb boot_backup=""
  boot_avail=$(df /boot 2>/dev/null | awk 'NR==2 {print $4}')
  boot_avail_mb=$(( ${boot_avail:-0} / 1024 ))
  if [[ ${boot_avail:-0} -lt 307200 ]]; then
    _warn "/boot has only ${boot_avail_mb}MB free (Archcraft requires 300MB)."
    _blank
    _info "Current /boot usage:"
    du -h --max-depth=1 /boot 2>/dev/null | sort -rh | while read -r size path; do
      printf "    ${DIM}%s${RESET}  %s\n" "$size" "$path"
    done
    _blank
    _info "arrow can back up /boot to /var/tmp, clear it, run the install,"
    _info "and restore the backup automatically if anything goes wrong."
    _warn "Do NOT reboot or lose power while the install is running."
    _blank
    _ask "Back up /boot, clear it, and proceed?" "${YELLOW}${BOLD}" \
      || { _warn "Cancelled."; return; }
    _blank

    boot_backup="/var/tmp/arrow-boot-backup-$$"
    _info "Backing up /boot to ${boot_backup}..."
    _asroot mkdir -p "$boot_backup"
    _asroot cp -a /boot/. "$boot_backup/" \
      || { _err "Backup failed."; _asroot rm -rf "$boot_backup"; return 1; }
    _ok "Backup complete ($(du -sh "$boot_backup" 2>/dev/null | cut -f1))."

    _info "Clearing /boot..."
    _asroot find /boot -mindepth 1 -delete \
      || { _err "Failed to clear /boot."; _asroot cp -a "$boot_backup/." /boot/; _asroot rm -rf "$boot_backup"; return 1; }
    _ok "/boot cleared."
    _blank
  fi

  # Show what will happen
  _step 1 4 "Detect latest Archcraft ARM version"
  _step 2 4 "Download and extract the installer"
  _step 3 4 "Configure hostname, locale, timezone and user"
  _step 4 4 "Run install.sh as root"

  _blank
  _sep
  echo -e "  ${RED}${BOLD}WARNING — THIS OPERATION CANNOT BE UNDONE${RESET}"
  _sep
  _blank
  _warn "The system will be permanently converted to Archcraft ARM."
  _warn "Packages, configs, services and the bootloader will be changed."
  _warn "To revert, you must restore from a backup or reinstall Arch."
  _blank
  _ask "I understand this is irreversible. Continue?" "${RED}${BOLD}" \
    || { _warn "Cancelled."; return; }
  _blank

  # Step 1 — detect version
  _info "Detecting latest version..."
  local version
  version=$(curl -fsSL "https://api.github.com/repos/archcraft-os/archcraft-arm/releases/latest" \
    2>/dev/null | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
  if [[ -z "$version" ]]; then
    _warn "Could not detect version automatically."
    printf "  Version (e.g. 1.0): " >&2
    read -r version </dev/tty
  fi
  _ok "Version: ${BOLD}${version}${RESET}"

  # Step 2 — download and extract
  local workdir="/tmp/archcraft-arm-morph"
  mkdir -p "$workdir"
  _info "Downloading archcraft-arm ${version}..."
  local url="https://github.com/archcraft-os/archcraft-arm/releases/download/${version}/archcraft-arm.tar.gz"
  curl -L --progress-bar "$url" -o "$workdir/archcraft-arm.tar.gz" \
    || { _err "Download failed."; rm -rf "$workdir"; _distro_restore_boot "$boot_backup"; return 1; }
  _info "Extracting..."
  tar -xzf "$workdir/archcraft-arm.tar.gz" -C "$workdir" --strip-components=1 \
    || { _err "Extraction failed."; rm -rf "$workdir"; _distro_restore_boot "$boot_backup"; return 1; }

  # Step 3 — configure
  _blank
  _info "Opening customize.sh — set hostname, locale, timezone and user:"
  _blank
  _warn "  your_hostname  — machine name"
  _warn "  your_locale    — e.g. en_US.UTF-8"
  _warn "  your_timezone  — e.g. America/New_York"
  _warn "  your_username  — new user (do not use 'alarm')"
  _warn "  your_password  — password for the new user"
  _blank
  "${EDITOR:-nano}" "$workdir/customize.sh"
  _blank

  _ask "Configuration looks good? Start the morph?" "${RED}${BOLD}" \
    || { _warn "Cancelled."; rm -rf "$workdir"; _distro_restore_boot "$boot_backup"; return; }
  _blank

  # Step 4 — run as root
  # Ensure pacman sandbox is disabled system-wide before running the Archcraft
  # installer — it calls pacman directly and ARM kernels lack Landlock support.
  if ! grep -q '^DisableSandbox' /etc/pacman.conf 2>/dev/null; then
    _info "Disabling pacman sandbox in /etc/pacman.conf (ARM kernel, no Landlock)..."
    _asroot sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf
  fi

  if (cd "$workdir" && _asroot bash install.sh); then
    rm -rf "$workdir"
    if [[ -n "$boot_backup" ]]; then
      _asroot rm -rf "$boot_backup"
      _info "Boot backup removed."
    fi
    _blank
    _ok "Morph complete. Reboot to enter Archcraft."
    _info "Run: sudo reboot"
  else
    _err "Morph failed."
    rm -rf "$workdir"
    _distro_restore_boot "$boot_backup"
    return 1
  fi
}

# ── Morph list ─────────────────────────────────────────────────────────────────

_distro_list() {
  echo
  echo -e "  ${BOLD}Available morphs:${RESET}"
  _blank
  echo -e "  ${RED}archcraft${RESET}  Arch Linux ARM → Archcraft ARM  ${DIM}(irreversible)${RESET}"
  _blank
  echo -e "  ${DIM}Usage: arrow distro morph <name>${RESET}"
  echo -e "  ${DIM}Requires plain Arch Linux. Not supported on Manjaro, EndeavourOS, etc.${RESET}"
  echo
}

# ── Dispatchers ────────────────────────────────────────────────────────────────

_distro_morph() {
  local name="${1:-}"

  if [[ -z "$name" ]]; then
    printf "\n  ${BOLD}Choose a morph:${RESET}\n\n" >&2
    printf "    ${CYAN}1${RESET}  archcraft  ${DIM}Arch Linux ARM → Archcraft ARM (irreversible)${RESET}\n" >&2
    printf "\n  Option [1]: " >&2
    local choice
    read -r choice </dev/tty
    case "${choice:-1}" in
      1) name="archcraft" ;;
      *) _die "Invalid option: '${choice}'" ;;
    esac
  fi

  case "$name" in
    archcraft) _distro_morph_archcraft ;;
    *)
      _err "Unknown morph: '${name}'"
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
      _err "Unknown subcommand: 'distro ${sub}'"
      printf "\n  Usage: arrow distro morph <name>\n\n"
      return 1
      ;;
  esac
}
