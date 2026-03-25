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
  _section "Instalar GNOME"
  _step 1 2 "Instalar pacotes"
  _cmd "pacman -Syu gnome gdm"
  _step 2 2 "Habilitar display manager"
  _cmd "systemctl enable gdm"
  _blank
  _ask "Instalar GNOME?" || { _warn "Cancelado."; return; }
  _blank
  _run _pacman -Syu gnome gdm
  _run _asroot systemctl enable gdm
  _ok "GNOME instalado. Reinicie para entrar no desktop."
}

_spell_desktop_gnome_undo() {
  _section "Remover GNOME"
  _step 1 2 "Desabilitar display manager"
  _cmd "systemctl disable gdm"
  _step 2 2 "Remover pacotes"
  _cmd "pacman -Rns gnome gdm"
  _blank
  _ask "Remover GNOME?" "${RED}${BOLD}" || { _warn "Cancelado."; return; }
  _blank
  _run _asroot systemctl disable gdm 2>/dev/null || true
  _run _pacman -Rns gnome gdm
}

# ── Spell: desktop/kde ─────────────────────────────────────────────────────────────────────────────────────────────────────────────

_spell_desktop_kde_do() {
  _section "Instalar KDE Plasma"
  _step 1 2 "Instalar pacotes"
  _cmd "pacman -Syu plasma sddm"
  _step 2 2 "Habilitar display manager"
  _cmd "systemctl enable sddm"
  _blank
  _ask "Instalar KDE Plasma?" || { _warn "Cancelado."; return; }
  _blank
  _run _pacman -Syu plasma sddm
  _run _asroot systemctl enable sddm
  _ok "KDE Plasma instalado. Reinicie para entrar no desktop."
}

_spell_desktop_kde_undo() {
  _section "Remover KDE Plasma"
  _step 1 2 "Desabilitar display manager"
  _cmd "systemctl disable sddm"
  _step 2 2 "Remover pacotes"
  _cmd "pacman -Rns plasma sddm"
  _blank
  _ask "Remover KDE Plasma?" "${RED}${BOLD}" || { _warn "Cancelado."; return; }
  _blank
  _run _asroot systemctl disable sddm 2>/dev/null || true
  _run _pacman -Rns plasma sddm
}

# ── Spell: desktop/xfce ────────────────────────────────────────────────────────────────────────────────────────────────────────────

_spell_desktop_xfce_do() {
  _section "Instalar XFCE"
  _step 1 2 "Instalar pacotes"
  _cmd "pacman -Syu xfce4 xfce4-goodies lightdm lightdm-gtk-greeter"
  _step 2 2 "Habilitar display manager"
  _cmd "systemctl enable lightdm"
  _blank
  _ask "Instalar XFCE?" || { _warn "Cancelado."; return; }
  _blank
  _run _pacman -Syu xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
  _run _asroot systemctl enable lightdm
  _ok "XFCE instalado. Reinicie para entrar no desktop."
}

_spell_desktop_xfce_undo() {
  _section "Remover XFCE"
  _step 1 2 "Desabilitar display manager"
  _cmd "systemctl disable lightdm"
  _step 2 2 "Remover pacotes"
  _cmd "pacman -Rns xfce4 xfce4-goodies lightdm lightdm-gtk-greeter"
  _blank
  _ask "Remover XFCE?" "${RED}${BOLD}" || { _warn "Cancelado."; return; }
  _blank
  _run _asroot systemctl disable lightdm 2>/dev/null || true
  _run _pacman -Rns xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
}

# ── Spell: desktop/openbox ─────────────────────────────────────────────────────────────────────────────────────────────────────────

_spell_desktop_openbox_do() {
  _section "Instalar Openbox"
  _step 1 2 "Instalar pacotes"
  _cmd "pacman -Syu openbox obconf lxappearance lightdm lightdm-gtk-greeter"
  _step 2 2 "Habilitar display manager"
  _cmd "systemctl enable lightdm"
  _blank
  _ask "Instalar Openbox?" || { _warn "Cancelado."; return; }
  _blank
  _run _pacman -Syu openbox obconf lxappearance lightdm lightdm-gtk-greeter
  _run _asroot systemctl enable lightdm
  _ok "Openbox instalado. Reinicie para entrar no desktop."
}

_spell_desktop_openbox_undo() {
  _section "Remover Openbox"
  _step 1 2 "Desabilitar display manager"
  _cmd "systemctl disable lightdm"
  _step 2 2 "Remover pacotes"
  _cmd "pacman -Rns openbox obconf lxappearance lightdm lightdm-gtk-greeter"
  _blank
  _ask "Remover Openbox?" "${RED}${BOLD}" || { _warn "Cancelado."; return; }
  _blank
  _run _asroot systemctl disable lightdm 2>/dev/null || true
  _run _pacman -Rns openbox obconf lxappearance lightdm lightdm-gtk-greeter
}

# ── Spell: desktop/sway ────────────────────────────────────────────────────────────────────────────────────────────────────────────

_spell_desktop_sway_do() {
  _section "Instalar Sway"
  _step 1 2 "Instalar pacotes"
  _cmd "pacman -Syu sway waybar wofi foot xdg-desktop-portal-wlr"
  _step 2 2 "Configurar auto-start"
  _cmd "echo 'exec sway' >> ~/.bash_profile"
  _blank
  _ask "Instalar Sway?" || { _warn "Cancelado."; return; }
  _blank
  _run _pacman -Syu sway waybar wofi foot xdg-desktop-portal-wlr
  _blank
  _ok "Sway instalado."
  _info "Adicione 'exec sway' ao ~/.bash_profile para iniciar automaticamente."
  _warn "Wayland não requer display manager."
}

_spell_desktop_sway_undo() {
  _section "Remover Sway"
  _step 1 1 "Remover pacotes"
  _cmd "pacman -Rns sway waybar wofi foot xdg-desktop-portal-wlr"
  _blank
  _ask "Remover Sway?" "${RED}${BOLD}" || { _warn "Cancelado."; return; }
  _blank
  _run _pacman -Rns sway waybar wofi foot xdg-desktop-portal-wlr
}

# ── Spell: desktop/i3 ──────────────────────────────────────────────────────────────────────────────────────────────────────────────

_spell_desktop_i3_do() {
  _section "Instalar i3"
  _step 1 2 "Instalar pacotes"
  _cmd "pacman -Syu i3-wm i3status dmenu xterm xorg-server xorg-xinit lightdm lightdm-gtk-greeter"
  _step 2 2 "Habilitar display manager"
  _cmd "systemctl enable lightdm"
  _blank
  _ask "Instalar i3?" || { _warn "Cancelado."; return; }
  _blank
  _run _pacman -Syu i3-wm i3status dmenu xterm xorg-server xorg-xinit lightdm lightdm-gtk-greeter
  _run _asroot systemctl enable lightdm
  _ok "i3 instalado. Reinicie para entrar no desktop."
}

_spell_desktop_i3_undo() {
  _section "Remover i3"
  _step 1 2 "Desabilitar display manager"
  _cmd "systemctl disable lightdm"
  _step 2 2 "Remover pacotes"
  _cmd "pacman -Rns i3-wm i3status dmenu xterm xorg-server xorg-xinit lightdm lightdm-gtk-greeter"
  _blank
  _ask "Remover i3?" "${RED}${BOLD}" || { _warn "Cancelado."; return; }
  _blank
  _run _asroot systemctl disable lightdm 2>/dev/null || true
  _run _pacman -Rns i3-wm i3status dmenu xterm xorg-server xorg-xinit lightdm lightdm-gtk-greeter
}

# ── Desktop dispatcher ────────────────────────────────────────────────────────

_spell_desktop() {
  local de="${1:-}" action="${2:-do}"

  if [[ -z "$de" ]]; then
    printf "\n  ${BOLD}Escolha um ambiente de desktop:${RESET}\n\n" >&2
    printf "    ${CYAN}1${RESET}  gnome    (completo, gdm)\n"      >&2
    printf "    ${CYAN}2${RESET}  kde      (completo, sddm)\n"     >&2
    printf "    ${CYAN}3${RESET}  xfce     (leve, lightdm)\n"      >&2
    printf "    ${CYAN}4${RESET}  openbox  (minimalista, lightdm)\n" >&2
    printf "    ${CYAN}5${RESET}  sway     (Wayland tiling, ARM)\n" >&2
    printf "    ${CYAN}6${RESET}  i3       (X11 tiling)\n"         >&2
    printf "\n  Opção [1-6]: " >&2
    local choice
    read -r choice </dev/tty
    case "${choice:-1}" in
      1) de="gnome"   ;;
      2) de="kde"     ;;
      3) de="xfce"    ;;
      4) de="openbox" ;;
      5) de="sway"    ;;
      6) de="i3"      ;;
      *) _die "Opção inválida: '${choice}'" ;;
    esac
  fi

  case "$de" in
    gnome | kde | xfce | openbox | sway | i3)
      "_spell_desktop_${de}_${action}"
      ;;
    *)
      _err "Ambiente desconhecido: '${de}'"
      printf "\n  Disponíveis: gnome  kde  xfce  openbox  sway  i3\n\n"
      return 1
      ;;
  esac
}

# ── Spell menu ──────────────────────────────────────────────────────────────

_spell_menu() {
  _section "arrow spell"
  printf "  ${BOLD}O que deseja configurar?${RESET}\n\n"
  printf "    ${CYAN}1${RESET}  desktop   Ambiente de desktop\n"
  printf "\n  Opção: "
  local choice
  read -r choice </dev/tty
  case "${choice:-}" in
    1 | desktop) _spell_desktop ;;
    *) _err "Opção inválida: '${choice}'"; return 1 ;;
  esac
}

# arrow spell [categoria] [nome] [undo]
# arrow setup   [categoria] [nome] [undo]   (alias)
cmd_spell() {
  local category="${1:-}"; shift || true

  case "$category" in
    desktop) _spell_desktop "${1:-}" "${2:-do}" ;;
    "")      _spell_menu ;;
    *)
      _err "Categoria desconhecida: '${category}'"
      printf "\n  Categorias disponíveis: desktop\n\n"
      return 1
      ;;
  esac
}

cmd_setup() { cmd_spell "$@"; }
