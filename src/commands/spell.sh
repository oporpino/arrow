# ── Spells — guided sequences with do/undo ────────────────────────────────────
#
#   Each spell exposes two functions:
#     _spell_<name>_do   — install / configure
#     _spell_<name>_undo — remove / revert  (mirror of do)
#
#   Usage:
#     arrow spell desktop gnome        # do (default)
#     arrow spell desktop gnome undo   # undo

# ── Spell: desktop/gnome ──────────────────────────────────────────────────────

_spell_desktop_gnome_do() {
  _section "Install GNOME"
  _step 1 2 "Install packages"
  _cmd "pacman -Syu gnome gdm"
  _step 2 2 "Enable display manager"
  _cmd "systemctl enable gdm"
  _blank
  _ask "Install GNOME?" || { _warn "Cancelled."; return; }
  _blank
  _run _pkg -Syu gnome gdm || return 1
  _run _asroot systemctl enable gdm || return 1
  _ok "GNOME installed. Reboot to enter the desktop."
}

_spell_desktop_gnome_undo() {
  _section "Remove GNOME"
  _step 1 2 "Disable display manager"
  _cmd "systemctl disable gdm"
  _step 2 2 "Remove packages"
  _cmd "pacman -Rns gnome gdm"
  _blank
  _ask "Remove GNOME?" "${RED}${BOLD}" || { _warn "Cancelled."; return; }
  _blank
  _run _asroot systemctl disable gdm 2>/dev/null || true
  _run _pkg -Rns gnome gdm
}

# ── Spell: desktop/kde ─────────────────────────────────────────────────────────────────────────────────────────────────────────────

_spell_desktop_kde_do() {
  _section "Install KDE Plasma"
  _step 1 2 "Install packages"
  _cmd "pacman -Syu plasma sddm"
  _step 2 2 "Enable display manager"
  _cmd "systemctl enable sddm"
  _blank
  _ask "Install KDE Plasma?" || { _warn "Cancelled."; return; }
  _blank
  _run _pkg -Syu plasma sddm || return 1
  _run _asroot systemctl enable sddm || return 1
  _ok "KDE Plasma installed. Reboot to enter the desktop."
}

_spell_desktop_kde_undo() {
  _section "Remove KDE Plasma"
  _step 1 2 "Disable display manager"
  _cmd "systemctl disable sddm"
  _step 2 2 "Remove packages"
  _cmd "pacman -Rns plasma sddm"
  _blank
  _ask "Remove KDE Plasma?" "${RED}${BOLD}" || { _warn "Cancelled."; return; }
  _blank
  _run _asroot systemctl disable sddm 2>/dev/null || true
  _run _pkg -Rns plasma sddm
}

# ── Spell: desktop/xfce ────────────────────────────────────────────────────────────────────────────────────────────────────────────

_spell_desktop_xfce_do() {
  _section "Install XFCE"
  _step 1 2 "Install packages"
  _cmd "pacman -Syu xfce4 xfce4-goodies lightdm lightdm-gtk-greeter"
  _step 2 2 "Enable display manager"
  _cmd "systemctl enable lightdm"
  _blank
  _ask "Install XFCE?" || { _warn "Cancelled."; return; }
  _blank
  _run _pkg -Syu xfce4 xfce4-goodies lightdm lightdm-gtk-greeter || return 1
  _run _asroot systemctl enable lightdm || return 1
  _ok "XFCE installed. Reboot to enter the desktop."
}

_spell_desktop_xfce_undo() {
  _section "Remove XFCE"
  _step 1 2 "Disable display manager"
  _cmd "systemctl disable lightdm"
  _step 2 2 "Remove packages"
  _cmd "pacman -Rns xfce4 xfce4-goodies lightdm lightdm-gtk-greeter"
  _blank
  _ask "Remove XFCE?" "${RED}${BOLD}" || { _warn "Cancelled."; return; }
  _blank
  _run _asroot systemctl disable lightdm 2>/dev/null || true
  _run _pkg -Rns xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
}

# ── Spell: desktop/openbox ─────────────────────────────────────────────────────────────────────────────────────────────────────────

_spell_desktop_openbox_do() {
  _section "Install Openbox"
  _step 1 3 "Install Xorg"
  _cmd "pacman -Syu xorg-server xorg-xinit"
  _step 2 3 "Install Openbox and display manager"
  _cmd "pacman -S openbox lightdm lightdm-gtk-greeter"
  _step 3 3 "Enable display manager"
  _cmd "systemctl enable lightdm"
  _blank
  _ask "Install Openbox?" || { _warn "Cancelled."; return; }
  _blank
  _run _pkg -Syu xorg-server xorg-xinit || return 1
  _run _pkg -S openbox lightdm lightdm-gtk-greeter || return 1
  _run _asroot systemctl enable lightdm || return 1
  _ok "Openbox installed. Reboot to enter the desktop."
}

_spell_desktop_openbox_undo() {
  _section "Remove Openbox"
  _step 1 2 "Disable display manager"
  _cmd "systemctl disable lightdm"
  _step 2 2 "Remove packages"
  _cmd "pacman -Rns openbox lightdm lightdm-gtk-greeter xorg-server xorg-xinit"
  _blank
  _ask "Remove Openbox?" "${RED}${BOLD}" || { _warn "Cancelled."; return; }
  _blank
  _run _asroot systemctl disable lightdm 2>/dev/null || true
  _run _pkg -Rns openbox lightdm lightdm-gtk-greeter xorg-server xorg-xinit
}

# ── Spell: desktop/sway ────────────────────────────────────────────────────────────────────────────────────────────────────────────

_spell_desktop_sway_do() {
  _section "Install Sway"
  _step 1 2 "Install packages"
  _cmd "pacman -Syu sway waybar wofi foot xdg-desktop-portal-wlr"
  _step 2 2 "Configure auto-start"
  _cmd "echo 'exec sway' >> ~/.bash_profile"
  _blank
  _ask "Install Sway?" || { _warn "Cancelled."; return; }
  _blank
  _run _pkg -Syu sway waybar wofi foot xdg-desktop-portal-wlr || return 1
  _blank
  _ok "Sway installed."
  _info "Add 'exec sway' to ~/.bash_profile to start automatically."
  _warn "Wayland does not require a display manager."
}

_spell_desktop_sway_undo() {
  _section "Remove Sway"
  _step 1 1 "Remove packages"
  _cmd "pacman -Rns sway waybar wofi foot xdg-desktop-portal-wlr"
  _blank
  _ask "Remove Sway?" "${RED}${BOLD}" || { _warn "Cancelled."; return; }
  _blank
  _run _pkg -Rns sway waybar wofi foot xdg-desktop-portal-wlr
}

# ── Spell: desktop/i3 ──────────────────────────────────────────────────────────────────────────────────────────────────────────────

_spell_desktop_i3_do() {
  _section "Install i3"
  _step 1 2 "Install packages"
  _cmd "pacman -Syu i3-wm i3status dmenu xterm xorg-server xorg-xinit lightdm lightdm-gtk-greeter"
  _step 2 2 "Enable display manager"
  _cmd "systemctl enable lightdm"
  _blank
  _ask "Install i3?" || { _warn "Cancelled."; return; }
  _blank
  _run _pkg -Syu i3-wm i3status dmenu xterm xorg-server xorg-xinit lightdm lightdm-gtk-greeter || return 1
  _run _asroot systemctl enable lightdm || return 1
  _ok "i3 installed. Reboot to enter the desktop."
}

_spell_desktop_i3_undo() {
  _section "Remove i3"
  _step 1 2 "Disable display manager"
  _cmd "systemctl disable lightdm"
  _step 2 2 "Remove packages"
  _cmd "pacman -Rns i3-wm i3status dmenu xterm xorg-server xorg-xinit lightdm lightdm-gtk-greeter"
  _blank
  _ask "Remove i3?" "${RED}${BOLD}" || { _warn "Cancelled."; return; }
  _blank
  _run _asroot systemctl disable lightdm 2>/dev/null || true
  _run _pkg -Rns i3-wm i3status dmenu xterm xorg-server xorg-xinit lightdm lightdm-gtk-greeter
}

# ── Desktop dispatcher ────────────────────────────────────────────────────────

_spell_desktop() {
  local de="${1:-}" action="${2:-do}"

  if [[ -z "$de" ]]; then
    printf "\n  ${BOLD}Choose a desktop environment:${RESET}\n\n" >&2
    printf "    ${CYAN}1${RESET}  gnome    (full, gdm)\n"         >&2
    printf "    ${CYAN}2${RESET}  kde      (full, sddm)\n"        >&2
    printf "    ${CYAN}3${RESET}  xfce     (lightweight, lightdm)\n" >&2
    printf "    ${CYAN}4${RESET}  openbox  (minimal, lightdm)\n"  >&2
    printf "    ${CYAN}5${RESET}  sway     (Wayland tiling, ARM)\n" >&2
    printf "    ${CYAN}6${RESET}  i3       (X11 tiling)\n"        >&2
    printf "\n  Option [1-6]: " >&2
    local choice
    read -r choice </dev/tty
    case "${choice:-1}" in
      1) de="gnome"   ;;
      2) de="kde"     ;;
      3) de="xfce"    ;;
      4) de="openbox" ;;
      5) de="sway"    ;;
      6) de="i3"      ;;
      *) _die "Invalid option: '${choice}'" ;;
    esac
  fi

  case "$de" in
    gnome | kde | xfce | openbox | sway | i3)
      "_spell_desktop_${de}_${action}"
      ;;
    *)
      _err "Unknown environment: '${de}'"
      printf "\n  Available: gnome  kde  xfce  openbox  sway  i3\n\n"
      return 1
      ;;
  esac
}

# ── Spell menu ─────────────────────────────────────────────────────────────────

_spell_menu() {
  _section "arrow spell"
  printf "  ${BOLD}What would you like to set up?${RESET}\n\n"
  printf "    ${CYAN}1${RESET}  desktop  Desktop environment\n"
  printf "\n  Option: "
  local choice
  read -r choice </dev/tty
  case "${choice:-}" in
    1 | desktop) _spell_desktop ;;
    *) _err "Invalid option: '${choice}'"; return 1 ;;
  esac
}

# arrow spell [category] [name] [undo]
# arrow setup [category] [name] [undo]   (alias)
cmd_spell() {
  local category="${1:-}"; shift || true

  case "$category" in
    desktop) _spell_desktop "${1:-}" "${2:-do}" ;;
    "")      _spell_menu ;;
    *)
      _err "Unknown category: '${category}'"
      printf "\n  Available categories: desktop\n\n"
      return 1
      ;;
  esac
}

cmd_setup() { cmd_spell "$@"; }
