# ── Howto — step-by-step guides ───────────────────────────────────────────────

# ── Individual guides ─────────────────────────────────────────────────────────

# arrow howto sudoers
# Add a user to sudoers via the wheel group.
_howto_sudoers() {
  local target_user="${1:-$USER}"

  _section "Como adicionar ${target_user} ao sudoers"

  _step 1 3 "Instalar o sudo"
  _cmd "pacman -S sudo"

  _step 2 3 "Adicionar ${target_user} ao grupo wheel"
  _cmd "usermod -aG wheel ${target_user}"

  _step 3 3 "Habilitar o grupo wheel no /etc/sudoers"
  _cmd "sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers"

  _blank
  _ask "Executar agora?" || { _warn "Cancelado."; return; }
  _blank

  # Step 1 — install sudo if missing
  if ! command -v sudo &>/dev/null; then
    _info "Instalando sudo…"
    local _sandbox=""
    pacman --disable-sandbox --version &>/dev/null && _sandbox="--disable-sandbox"
    _asroot pacman -S --noconfirm ${_sandbox} sudo \
      && _ok "sudo instalado." \
      || { _err "Falha ao instalar sudo."; return 1; }
  else
    _ok "sudo já instalado."
  fi

  # Step 2 — add to wheel group
  _info "Adicionando ${target_user} ao grupo wheel…"
  _asroot usermod -aG wheel "$target_user" \
    && _ok "${target_user} adicionado ao wheel." \
    || { _err "Falha ao adicionar ao wheel."; return 1; }

  # Step 3 — uncomment wheel in sudoers
  _info "Habilitando wheel em /etc/sudoers…"
  if grep -q '^%wheel ALL=(ALL:ALL) ALL' /etc/sudoers 2>/dev/null; then
    _ok "Wheel já habilitado em /etc/sudoers."
  else
    _asroot sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers \
      && _ok "Wheel habilitado." \
      || { _err "Falha ao editar /etc/sudoers."; return 1; }
  fi

  _blank
  _ok "Pronto! Faça logout e login novamente para aplicar."
  _warn "Ou recarregue os grupos: newgrp wheel"
}

# arrow howto add.user
# Create a new system user with home directory and common groups.
_howto_add_user() {
  local target_user="${1:-}"
  [[ -z "$target_user" ]] && _die "Uso: arrow howto add.user <nome>"

  _section "Criar usuário: ${target_user}"

  _step 1 3 "Criar o usuário com diretório home"
  _cmd "useradd -m -s /bin/bash ${target_user}"

  _step 2 3 "Definir a senha"
  _cmd "passwd ${target_user}"

  _step 3 3 "Adicionar aos grupos comuns"
  _cmd "usermod -aG wheel,audio,video,storage,optical ${target_user}"

  _blank
  _ask "Executar agora?" || { _warn "Cancelado."; return; }
  _blank

  # Step 1 — create user
  if id "$target_user" &>/dev/null; then
    _ok "Usuário '${target_user}' já existe."
  else
    _info "Criando usuário '${target_user}'…"
    _asroot useradd -m -s /bin/bash "$target_user" \
      && _ok "Usuário criado." \
      || { _err "Falha ao criar usuário."; return 1; }
  fi

  # Step 2 — set password (interactive)
  _info "Defina a senha para '${target_user}':"
  _asroot passwd "$target_user" \
    || { _err "Falha ao definir senha."; return 1; }

  # Step 3 — add to groups (skip groups that don't exist)
  _info "Adicionando '${target_user}' aos grupos…"
  local groups=()
  local g
  for g in wheel audio video storage optical; do
    getent group "$g" &>/dev/null && groups+=("$g")
  done
  if [[ ${#groups[@]} -gt 0 ]]; then
    local group_list
    group_list=$(IFS=','; echo "${groups[*]}")
    _asroot usermod -aG "$group_list" "$target_user" \
      && _ok "Adicionado aos grupos: ${group_list}." \
      || { _err "Falha ao adicionar aos grupos."; return 1; }
  fi

  _blank
  _ok "Usuário '${target_user}' criado com sucesso."
  _info "Para acesso sudo, execute: arrow howto user.sudoers ${target_user}"
}

# ── Registry ──────────────────────────────────────────────────────────────────

_howto_list() {
  echo
  echo -e "  ${BOLD}Guias disponíveis:${RESET}"
  _blank
  echo -e "  ${CYAN}user.add${RESET}      Criar novo usuário com home e grupos comuns"
  echo -e "  ${CYAN}user.sudoers${RESET}  Adicionar usuário ao sudoers via grupo wheel"
  _blank
  echo -e "  ${DIM}Uso: arrow howto <guia> [args]${RESET}"
  echo
}

# arrow howto [guide] [args]
cmd_howto() {
  local guide="${1:-}"; shift || true

  case "$guide" in
    sudoers | sudo | user.sudoers) _howto_sudoers "$@" ;;
    user.add)                      _howto_add_user "$@" ;;
    "" | list)       _howto_list ;;
    *)
      _err "Guia desconhecido: '${guide}'"
      _howto_list
      exit 1
      ;;
  esac
}
