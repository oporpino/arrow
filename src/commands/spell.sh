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
  _run _pacman -Syu gnome gdm || return 1
  _run _asroot systemctl enable gdm || return 1
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
  _run _pacman -Syu plasma sddm || return 1
  _run _asroot systemctl enable sddm || return 1
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
  _run _pacman -Syu xfce4 xfce4-goodies lightdm lightdm-gtk-greeter || return 1
  _run _asroot systemctl enable lightdm || return 1
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
  _step 1 3 "Instalar Xorg"
  _cmd "pacman -Syu xorg-server xorg-xinit"
  _step 2 3 "Instalar Openbox e display manager"
  _cmd "pacman -S openbox lightdm lightdm-gtk-greeter"
  _step 3 3 "Habilitar display manager"
  _cmd "systemctl enable lightdm"
  _blank
  _ask "Instalar Openbox?" || { _warn "Cancelado."; return; }
  _blank
  _run _pacman -Syu xorg-server xorg-xinit || return 1
  _run _pacman -S openbox lightdm lightdm-gtk-greeter || return 1
  _run _asroot systemctl enable lightdm || return 1
  _ok "Openbox instalado. Reinicie para entrar no desktop."
}

_spell_desktop_openbox_undo() {
  _section "Remover Openbox"
  _step 1 2 "Desabilitar display manager"
  _cmd "systemctl disable lightdm"
  _step 2 2 "Remover pacotes"
  _cmd "pacman -Rns openbox lightdm lightdm-gtk-greeter xorg-server xorg-xinit"
  _blank
  _ask "Remover Openbox?" "${RED}${BOLD}" || { _warn "Cancelado."; return; }
  _blank
  _run _asroot systemctl disable lightdm 2>/dev/null || true
  _run _pacman -Rns openbox lightdm lightdm-gtk-greeter xorg-server xorg-xinit
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
  _run _pacman -Syu sway waybar wofi foot xdg-desktop-portal-wlr || return 1
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
  _run _pacman -Syu i3-wm i3status dmenu xterm xorg-server xorg-xinit lightdm lightdm-gtk-greeter || return 1
  _run _asroot systemctl enable lightdm || return 1
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

# ── Spell: layer/archcraft ────────────────────────────────────────────────────

_spell_layer_archcraft_do() {
  _section "Instalar Archcraft ARM"

  _step 1 4 "Detectar versão mais recente"
  local version
  version=$(curl -fsSL "https://api.github.com/repos/archcraft-os/archcraft-arm/releases/latest" \
    2>/dev/null | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
  if [[ -z "$version" ]]; then
    _err "Não foi possível detectar a versão. Informe manualmente:"
    printf "  Versão (ex: 24.01): " >&2
    read -r version </dev/tty
  fi
  _ok "Versão: ${BOLD}${version}${RESET}"

  _step 2 4 "Baixar archcraft-arm.tar.gz"
  _cmd "curl -LO https://github.com/archcraft-os/archcraft-arm/releases/download/${version}/archcraft-arm.tar.gz"
  _cmd "tar -xzvf archcraft-arm.tar.gz"

  _step 3 4 "Configurar hostname, locale, timezone e usuário"
  _cmd "nano customize.sh"

  _step 4 4 "Executar instalação"
  _cmd "./install.sh"

  _blank
  _ask "Continuar?" || { _warn "Cancelado."; return; }
  _blank

  local workdir="/tmp/archcraft-arm-install"
  mkdir -p "$workdir"

  _info "Baixando archcraft-arm ${version}…"
  local url="https://github.com/archcraft-os/archcraft-arm/releases/download/${version}/archcraft-arm.tar.gz"
  curl -L --progress-bar "$url" -o "$workdir/archcraft-arm.tar.gz" \
    || { _err "Falha no download."; return 1; }

  _info "Extraindo…"
  tar -xzf "$workdir/archcraft-arm.tar.gz" -C "$workdir" --strip-components=1 \
    || { _err "Falha ao extrair."; return 1; }

  _info "Abrindo customize.sh para configuração…"
  _warn "Edite hostname, locale, timezone e usuário antes de continuar."
  _blank
  "${EDITOR:-nano}" "$workdir/customize.sh"
  _blank

  _ask "Configuração ok? Iniciar instalação?" || { _warn "Cancelado."; return; }
  _blank

  (cd "$workdir" && bash install.sh) || { _err "Instalação falhou."; return 1; }

  rm -rf "$workdir"
  _blank
  _ok "Archcraft ARM instalado. Reinicie para entrar no desktop."
}

_spell_layer_archcraft_undo() {
  _section "Remover Archcraft ARM"
  _warn "Não há procedimento oficial de remoção — este undo é best-effort."
  _blank

  _step 1 6 "Desabilitar sddm e restaurar target multi-user"
  _cmd "systemctl disable sddm"
  _cmd "systemctl set-default multi-user.target"
  _cmd "systemctl enable systemd-networkd"

  _step 2 6 "Remover pacotes archcraft-*"
  _cmd "pacman -Rns <archcraft-*>"

  _step 3 6 "Remover repositório archcraft-arm do pacman.conf"
  _cmd "sed -i '/\\[archcraft-arm\\]/,/^$/d' /etc/pacman.conf"

  _step 4 6 "Remover arquivos instalados manualmente"
  _cmd "rm -f /usr/local/bin/xflock4"
  _cmd "rm -f /etc/sudoers.d/01_wheel"

  _step 5 6 "Reverter hook plymouth no mkinitcpio.conf"
  _cmd "sed -i 's/udev plymouth/udev/' /etc/mkinitcpio.conf && mkinitcpio -P"

  _step 6 6 "Reverter parâmetros do kernel"
  _cmd "sed -i 's/ quiet splash loglevel=3 udev.log_level=3 vt.global_cursor_default=0//' /boot/cmdline.txt"

  _blank
  _warn "O que NÃO é revertido: hostname, locale, timezone, usuário criado, configs em /etc/skel e ~/"
  _blank
  _ask "Remover Archcraft?" "${RED}${BOLD}" || { _warn "Cancelado."; return; }
  _blank

  # Step 1 — services
  _info "Restaurando serviços…"
  _asroot systemctl disable sddm 2>/dev/null || true
  _asroot systemctl set-default multi-user.target 2>/dev/null || true
  _asroot systemctl enable systemd-networkd 2>/dev/null || true

  # Step 2 — remove archcraft packages (only those actually installed)
  _info "Removendo pacotes archcraft-*…"
  local pkgs=()
  local p
  for p in $(pacman -Qq 2>/dev/null | grep '^archcraft-'); do
    pkgs+=("$p")
  done
  # Also remove sddm if installed
  pacman -Qq sddm &>/dev/null && pkgs+=("sddm")
  pacman -Qq plymouth &>/dev/null && pkgs+=("plymouth")

  if [[ ${#pkgs[@]} -gt 0 ]]; then
    _run _pacman -Rns "${pkgs[@]}" || true
  else
    _warn "Nenhum pacote archcraft encontrado."
  fi

  # Step 3 — remove repo from pacman.conf
  _info "Removendo repositório archcraft-arm…"
  if grep -q '\[archcraft-arm\]' /etc/pacman.conf 2>/dev/null; then
    _asroot sed -i '/\[archcraft-arm\]/,/^$/d' /etc/pacman.conf
    _ok "Repositório removido."
  else
    _warn "Repositório archcraft-arm não encontrado em pacman.conf."
  fi

  # Step 4 — remove manually installed files
  _info "Removendo arquivos instalados…"
  [[ -f /usr/local/bin/xflock4 ]]   && _asroot rm -f /usr/local/bin/xflock4   && _ok "xflock4 removido."
  [[ -f /etc/sudoers.d/01_wheel ]]  && _asroot rm -f /etc/sudoers.d/01_wheel  && _ok "sudoers 01_wheel removido."

  # Step 5 — revert mkinitcpio plymouth hook
  if grep -q 'udev plymouth' /etc/mkinitcpio.conf 2>/dev/null; then
    _info "Revertendo hook plymouth no mkinitcpio.conf…"
    _asroot sed -i 's/udev plymouth/udev/' /etc/mkinitcpio.conf
    _run _asroot mkinitcpio -P || true
  fi

  # Step 6 — revert boot kernel params
  if [[ -f /boot/cmdline.txt ]] && grep -q 'quiet splash loglevel=3' /boot/cmdline.txt 2>/dev/null; then
    _info "Revertendo parâmetros do kernel em /boot/cmdline.txt…"
    _asroot sed -i 's/ quiet splash loglevel=3 udev.log_level=3 vt.global_cursor_default=0//' /boot/cmdline.txt
    _ok "Parâmetros revertidos."
  fi

  _blank
  _ok "Archcraft removido (best-effort)."
  _warn "Hostname, locale, timezone e usuário criado devem ser revertidos manualmente."
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

# ── Layer dispatcher ───────────────────────────────────────────────────────────

_spell_layer() {
  local name="${1:-}" action="${2:-do}"

  if [[ -z "$name" ]]; then
    printf "\n  ${BOLD}Escolha uma layer:${RESET}\n\n" >&2
    printf "    ${CYAN}1${RESET}  archcraft  (Archcraft ARM sobre Arch Linux)\n" >&2
    printf "\n  Opção [1]: " >&2
    local choice
    read -r choice </dev/tty
    case "${choice:-1}" in
      1) name="archcraft" ;;
      *) _die "Opção inválida: '${choice}'" ;;
    esac
  fi

  case "$name" in
    archcraft)
      "_spell_layer_${name}_${action}"
      ;;
    *)
      _err "Layer desconhecida: '${name}'"
      printf "\n  Disponíveis: archcraft\n\n"
      return 1
      ;;
  esac
}

# ── Spell menu ─────────────────────────────────────────────────────────────────

_spell_menu() {
  _section "arrow spell"
  printf "  ${BOLD}O que deseja configurar?${RESET}\n\n"
  printf "    ${CYAN}1${RESET}  desktop  Ambiente de desktop\n"
  printf "    ${CYAN}2${RESET}  layer    Layer sobre o sistema (ex: Archcraft)\n"
  printf "\n  Opção: "
  local choice
  read -r choice </dev/tty
  case "${choice:-}" in
    1 | desktop) _spell_desktop ;;
    2 | layer)   _spell_layer   ;;
    *) _err "Opção inválida: '${choice}'"; return 1 ;;
  esac
}

# arrow spell [categoria] [nome] [undo]
# arrow setup [categoria] [nome] [undo]   (alias)
cmd_spell() {
  local category="${1:-}"; shift || true

  case "$category" in
    desktop) _spell_desktop "${1:-}" "${2:-do}" ;;
    layer)   _spell_layer   "${1:-}" "${2:-do}" ;;
    "")      _spell_menu ;;
    *)
      _err "Categoria desconhecida: '${category}'"
      printf "\n  Categorias disponíveis: desktop  layer\n\n"
      return 1
      ;;
  esac
}

cmd_setup() { cmd_spell "$@"; }
