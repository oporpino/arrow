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
    local _sandbox=""
    pacman --disable-sandbox --version &>/dev/null && _sandbox="--disable-sandbox"
    _asroot pacman -S --noconfirm ${_sandbox} sudo \
      && _ok "sudo installed." \
      || { _err "Failed to install sudo."; return 1; }
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

# ── Registry ──────────────────────────────────────────────────────────────────

_howto_list() {
  echo
  echo -e "  ${BOLD}Available guides:${RESET}"
  _blank
  echo -e "  ${CYAN}user.add${RESET}      Create a new user with home directory and common groups"
  echo -e "  ${CYAN}user.sudoers${RESET}  Add a user to sudoers via the wheel group"
  echo -e "  ${CYAN}user.remove${RESET}   Remove a user from the system"
  echo -e "  ${CYAN}user.passwd${RESET}   Change a user's password"
  _blank
  echo -e "  ${DIM}Usage: arrow howto <guide> [args]${RESET}"
  echo
}

# arrow howto [guide] [args]
cmd_howto() {
  local guide="${1:-}"; shift || true

  case "$guide" in
    sudoers | sudo | user.sudoers) _howto_sudoers    "$@" ;;
    user.add)                      _howto_add_user   "$@" ;;
    user.remove)                   _howto_remove_user "$@" ;;
    user.passwd)                   _howto_passwd     "$@" ;;
    "" | list)       _howto_list ;;
    *)
      _err "Unknown guide: '${guide}'"
      _howto_list
      exit 1
      ;;
  esac
}
