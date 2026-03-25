# ── Setup — guided system configuration ───────────────────────────────────────

# ── Desktop environments ───────────────────────────────────────────────────────

_setup_desktop_menu() {
  printf "\n  ${BOLD}Escolha um ambiente de desktop:${RESET}\n\n" >&2
  printf "    ${CYAN}1${RESET}  GNOME       (completo, display manager: gdm)\n"    >&2
  printf "    ${CYAN}2${RESET}  KDE Plasma  (completo, display manager: sddm)\n"   >&2
  printf "    ${CYAN}3${RESET}  XFCE        (leve, display manager: lightdm)\n"    >&2
  printf "    ${CYAN}4${RESET}  Sway        (Wayland tiling, ideal para ARM)\n"    >&2
  printf "    ${CYAN}5${RESET}  i3          (X11 tiling, leve)\n"                  >&2
  printf "\n  Opção [1-5]: " >&2
  local choice
  read -r choice </dev/tty
  case "${choice:-1}" in
    1) echo "gnome"   ;;
    2) echo "kde"     ;;
    3) echo "xfce"    ;;
    4) echo "sway"    ;;
    5) echo "i3"      ;;
    *) _die "Opção inválida: '${choice}'" ;;
  esac
}

_setup_desktop() {
  local de="${1:-}"

  # If no DE given, prompt
  if [[ -z "$de" ]]; then
    de=$(_setup_desktop_menu)
  fi

  case "$de" in
    gnome)
      local pkgs=(gnome gdm)
      local dm="gdm"
      local label="GNOME"
      ;;
    kde | plasma)
      local pkgs=(plasma sddm)
      local dm="sddm"
      local label="KDE Plasma"
      ;;
    xfce)
      local pkgs=(xfce4 xfce4-goodies lightdm lightdm-gtk-greeter)
      local dm="lightdm"
      local label="XFCE"
      ;;
    sway)
      local pkgs=(sway waybar wofi foot xdg-desktop-portal-wlr)
      local dm=""
      local label="Sway"
      ;;
    i3)
      local pkgs=(i3-wm i3status dmenu xterm xorg-server xorg-xinit lightdm lightdm-gtk-greeter)
      local dm="lightdm"
      local label="i3"
      ;;
    *)
      _err "Ambiente desconhecido: '${de}'"
      printf "\n  Ambientes disponíveis: gnome  kde  xfce  sway  i3\n\n"
      return 1
      ;;
  esac

  _section "Instalar ${label}"

  _step 1 2 "Instalar pacotes"
  _cmd "pacman -Syu ${pkgs[*]}"

  if [[ -n "$dm" ]]; then
    _step 2 2 "Habilitar display manager ao boot"
    _cmd "systemctl enable ${dm}"
  else
    _step 2 2 "Iniciar via .bash_profile / .zprofile"
    _cmd "echo 'exec sway' >> ~/.bash_profile"
  fi

  _blank
  _ask "Instalar ${label}?" || { _warn "Cancelado."; return; }
  _blank

  _run _pacman -Syu "${pkgs[@]}"

  if [[ -n "$dm" ]]; then
    _run _asroot systemctl enable "$dm"
    _blank
    _ok "${label} instalado. Reinicie para entrar no desktop."
    _info "Ou inicie agora: systemctl start ${dm}"
  else
    _blank
    _ok "${label} instalado."
    _info "Adicione 'exec sway' ao ~/.bash_profile para iniciar automaticamente."
    _warn "No Wayland, não é necessário um display manager."
  fi
}

# ── Setup menu ─────────────────────────────────────────────────────────────────

_setup_menu() {
  _section "arrow setup"
  printf "  ${BOLD}O que deseja configurar?${RESET}\n\n"
  printf "    ${CYAN}1${RESET}  desktop   Instalar ambiente de desktop\n"
  printf "\n  Opção: "
  local choice
  read -r choice </dev/tty
  case "${choice:-}" in
    1 | desktop) _setup_desktop ;;
    *) _err "Opção inválida: '${choice}'"; return 1 ;;
  esac
}

# arrow setup [categoria] [args]
cmd_setup() {
  local category="${1:-}"; shift || true

  case "$category" in
    desktop) _setup_desktop "${1:-}" ;;
    "")      _setup_menu ;;
    *)
      _err "Categoria desconhecida: '${category}'"
      printf "\n  Categorias disponíveis: desktop\n\n"
      return 1
      ;;
  esac
}
