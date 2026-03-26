# ── Howto — step-by-step guides ───────────────────────────────────────────────

# ── Individual guides ─────────────────────────────────────────────────────────

# arrow howto sudoers
# Add a user to sudoers via the wheel group.
_howto_sudoers() {
  local target_user="${1:-$USER}"

  _section "How to add ${target_user} to sudoers"

  _step 1 3 "Install sudo"
  _cmd "pacman -S sudo"

  _step 2 3 "Add ${target_user} to the wheel group"
  _cmd "usermod -aG wheel ${target_user}"

  _step 3 3 "Enable the wheel group in /etc/sudoers"
  _cmd "sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers"

  _blank
  _ask "Run now?" || { _warn "Cancelled."; return; }
  _blank

  # Step 1 — install sudo if missing
  if ! command -v sudo &>/dev/null; then
    _info "Installing sudo..."
    _run _pkg -S sudo || return 1
  else
    _ok "sudo already installed."
  fi

  # Step 2 — add to wheel group
  _info "Adding ${target_user} to the wheel group..."
  _asroot usermod -aG wheel "$target_user" \
    && _ok "${target_user} added to wheel." \
    || { _err "Failed to add to wheel."; return 1; }

  # Step 3 — uncomment wheel in sudoers
  _info "Enabling wheel in /etc/sudoers..."
  if grep -q '^%wheel ALL=(ALL:ALL) ALL' /etc/sudoers 2>/dev/null; then
    _ok "Wheel already enabled in /etc/sudoers."
  else
    _asroot sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers \
      && _ok "Wheel enabled." \
      || { _err "Failed to edit /etc/sudoers."; return 1; }
  fi

  _blank
  _ok "Done! Log out and back in to apply."
  _warn "Or reload groups now: newgrp wheel"
}

# arrow howto add.user
# Create a new system user with home directory and common groups.
_howto_add_user() {
  local target_user="${1:-}"
  [[ -z "$target_user" ]] && _die "Usage: arrow howto user.add <name>"

  _section "Create user: ${target_user}"

  _step 1 3 "Create the user with a home directory"
  _cmd "useradd -m -s /bin/bash ${target_user}"

  _step 2 3 "Set the password"
  _cmd "passwd ${target_user}"

  _step 3 3 "Add to common groups"
  _cmd "usermod -aG wheel,audio,video,storage,optical ${target_user}"

  _blank
  _ask "Run now?" || { _warn "Cancelled."; return; }
  _blank

  # Step 1 — create user
  if id "$target_user" &>/dev/null; then
    _ok "User '${target_user}' already exists."
  else
    _info "Creating user '${target_user}'..."
    _asroot useradd -m -s /bin/bash "$target_user" \
      && _ok "User created." \
      || { _err "Failed to create user."; return 1; }
  fi

  # Step 2 — set password (interactive)
  _info "Set a password for '${target_user}':"
  _asroot passwd "$target_user" \
    || { _err "Failed to set password."; return 1; }

  # Step 3 — add to groups (skip groups that don't exist)
  _info "Adding '${target_user}' to groups..."
  local groups=()
  local g
  for g in wheel audio video storage optical; do
    getent group "$g" &>/dev/null && groups+=("$g")
  done
  if [[ ${#groups[@]} -gt 0 ]]; then
    local group_list
    group_list=$(IFS=','; echo "${groups[*]}")
    _asroot usermod -aG "$group_list" "$target_user" \
      && _ok "Added to groups: ${group_list}." \
      || { _err "Failed to add to groups."; return 1; }
  fi

  _blank
  _ok "User '${target_user}' created successfully."
  _info "For sudo access, run: arrow howto user.sudoers ${target_user}"
}

# arrow howto user.remove
# Remove a user and optionally their home directory.
_howto_remove_user() {
  local target_user="${1:-}"
  [[ -z "$target_user" ]] && _die "Usage: arrow howto user.remove <name>"

  _section "Remove user: ${target_user}"

  _step 1 2 "Remove the user and their home directory"
  _cmd "userdel -r ${target_user}"

  _step 2 2 "Remove leftover files (optional)"
  _cmd "find / -user ${target_user} -delete 2>/dev/null"

  _blank
  _ask "Remove user '${target_user}'?" "${RED}${BOLD}" || { _warn "Cancelled."; return; }
  _blank

  if ! id "$target_user" &>/dev/null; then
    _err "User '${target_user}' does not exist."
    return 1
  fi

  _info "Removing user '${target_user}'..."
  _asroot userdel -r "$target_user" \
    && _ok "User '${target_user}' removed." \
    || { _err "Failed to remove user."; return 1; }
}

# arrow howto user.passwd
# Change a user's password.
_howto_passwd() {
  local target_user="${1:-$USER}"

  _section "Change password: ${target_user}"

  _step 1 1 "Set new password"
  _cmd "passwd ${target_user}"

  _blank
  _ask "Continue?" || { _warn "Cancelled."; return; }
  _blank

  _asroot passwd "$target_user" \
    || { _err "Failed to change password."; return 1; }

  _ok "Password for '${target_user}' changed successfully."
}

# arrow howto disk.resize
# Transfer a given amount of space from one partition to another.
# Shrinks the source filesystem+partition, then expands the destination.
#
# Lookup helpers — write results via nameref (no subshell).
_disk_part_end() {
  # _disk_part_end <disk> <part_num> <var_out>
  local -n _dpe_out="$3"
  _dpe_out=$(_asroot parted /dev/"$1" unit GB print 2>/dev/null \
    | awk -v n="$2" '$1+0==n+0 {v=$3; gsub(/GB/,"",v); print v+0}')
}

_disk_fs_info() {
  # _disk_fs_info <dev> <var_fstype> <var_mount>
  local -n _dfi_fs="$2" _dfi_mt="$3"
  _dfi_fs=$(lsblk -no FSTYPE "$1" 2>/dev/null | head -1)
  _dfi_mt=$(lsblk -no MOUNTPOINT "$1" 2>/dev/null | head -1)
}

_howto_disk_resize() {
  _section "Move space from one partition to another"

  # Ensure parted is installed before showing any layout.
  if ! command -v parted &>/dev/null; then
    _warn "parted is required."
    _ask "Install parted now?" || { _warn "Cancelled."; return; }
    _run _pkg -S parted || return 1
    _blank
  fi

  _info "Current disk layout:"
  lsblk
  _blank

  printf "  Disk (e.g. vda, sda): "
  local disk
  read -r disk </dev/tty
  [[ -z "$disk" ]] && { _warn "Cancelled."; return; }

  _info "Partitions and free space on /dev/${disk}:"
  _asroot parted /dev/"$disk" unit GB print free 2>/dev/null
  _blank

  printf "  Take space FROM partition (e.g. 6): "
  local src_num
  read -r src_num </dev/tty
  [[ -z "$src_num" ]] && { _warn "Cancelled."; return; }

  printf "  How much to take? (e.g. 10G): "
  local amount
  read -r amount </dev/tty
  [[ -z "$amount" ]] && { _warn "Cancelled."; return; }

  printf "  Give space TO partition (e.g. 5): "
  local dst_num
  read -r dst_num </dev/tty
  [[ -z "$dst_num" ]] && { _warn "Cancelled."; return; }

  # Strip unit suffix to get a plain number for arithmetic.
  local amount_gb="${amount//[GgBb]/}"

  local src_dev="/dev/${disk}${src_num}"
  local dst_dev="/dev/${disk}${dst_num}"

  local src_fs src_mount dst_fs dst_mount
  _disk_fs_info "$src_dev" src_fs src_mount
  _disk_fs_info "$dst_dev" dst_fs dst_mount

  # Calculate new partition end positions.
  local src_end dst_end
  _disk_part_end "$disk" "$src_num" src_end
  _disk_part_end "$disk" "$dst_num" dst_end

  local src_new_end dst_new_end
  src_new_end=$(awk -v e="$src_end" -v a="$amount_gb" 'BEGIN{printf "%.1fGB", e-a}')
  dst_new_end=$(awk -v e="$dst_end" -v a="$amount_gb" 'BEGIN{printf "%.1fGB", e+a}')

  # ── Show plan ──────────────────────────────────────────────────────────────
  # Shrink source first (filesystem before partition), then expand destination.

  _step 1 4 "Shrink ${src_fs:-filesystem} on ${src_dev} by ${amount}"
  case "${src_fs}" in
    btrfs) _cmd "btrfs filesystem resize -${amount} ${src_mount}" ;;
    *)     _cmd "resize2fs ${src_dev} $(awk -v e="$src_end" -v a="$amount_gb" 'BEGIN{printf "%dG", int(e-a)}')" ;;
  esac

  _step 2 4 "Shrink partition ${src_num} to ${src_new_end}"
  _cmd "parted /dev/${disk} resizepart ${src_num} ${src_new_end}"

  _step 3 4 "Expand partition ${dst_num} to ${dst_new_end}"
  _cmd "parted /dev/${disk} resizepart ${dst_num} ${dst_new_end}"

  _step 4 4 "Expand ${dst_fs:-filesystem} on ${dst_dev}"
  case "${dst_fs}" in
    btrfs) _cmd "btrfs filesystem resize max ${dst_mount:-/}" ;;
    *)     _cmd "resize2fs ${dst_dev}" ;;
  esac

  _blank
  _warn "This permanently modifies partitions. Have a backup before continuing."
  _warn "parted may ask: Fix/Ignore? → Fix"
  _blank
  _ask "Run now?" || { _warn "Cancelled."; return; }
  _blank

  # ── Execute ────────────────────────────────────────────────────────────────

  # Step 1 — shrink source filesystem
  case "${src_fs}" in
    btrfs)
      _run _asroot btrfs filesystem resize "-${amount}" "$src_mount" || return 1
      ;;
    *)
      local src_new_size
      src_new_size=$(awk -v e="$src_end" -v a="$amount_gb" 'BEGIN{printf "%dG", int(e-a)}')
      _run _asroot resize2fs "$src_dev" "$src_new_size" || return 1
      ;;
  esac

  # Step 2 — shrink source partition
  _run _asroot parted /dev/"$disk" resizepart "$src_num" "$src_new_end" || return 1

  # Step 3 — expand destination partition
  _run _asroot parted /dev/"$disk" resizepart "$dst_num" "$dst_new_end" || return 1

  # Step 4 — expand destination filesystem
  case "${dst_fs}" in
    btrfs) _run _asroot btrfs filesystem resize max "${dst_mount:-/}" || return 1 ;;
    *)     _run _asroot resize2fs "$dst_dev"                           || return 1 ;;
  esac

  _blank
  _ok "Done. Verifying..."
  df -h
}

# ── Registry ──────────────────────────────────────────────────────────────────

_howto_list() {
  echo
  echo -e "  ${BOLD}Available guides:${RESET}"
  _blank
  echo -e "  ${CYAN}user.add${RESET}      Create a new user with home directory and common groups"
  echo -e "  ${CYAN}user.sudoers${RESET}  Add a user to sudoers via the wheel group"
  echo -e "  ${CYAN}user.remove${RESET}   Remove a user from the system"
  echo -e "  ${CYAN}user.passwd${RESET}   Change a user's password"
  echo -e "  ${CYAN}disk.resize${RESET}   Expand a partition and filesystem to use all available space"
  _blank
  echo -e "  ${DIM}Usage: arrow howto <guide> [args]${RESET}"
  echo
}

# arrow howto [guide] [args]
cmd_howto() {
  local guide="${1:-}"; shift || true

  case "$guide" in
    sudoers | sudo | user.sudoers) _howto_sudoers     "$@" ;;
    user.add)                      _howto_add_user    "$@" ;;
    user.remove)                   _howto_remove_user "$@" ;;
    user.passwd)                   _howto_passwd      "$@" ;;
    disk.resize)                   _howto_disk_resize "$@" ;;
    "" | list)       _howto_list ;;
    *)
      _err "Unknown guide: '${guide}'"
      _howto_list
      exit 1
      ;;
  esac
}
