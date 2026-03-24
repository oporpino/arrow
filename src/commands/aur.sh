# ── AUR commands ──────────────────────────────────────────────────────────────

# arrow aur <add|search|upgrade> [pkg]
# Delegate AUR operations to the first available helper (yay or paru).
cmd_aur() {
  local helper
  helper=$(_aur_helper)
  [[ -z "$helper" ]] && _die "Nenhum helper AUR encontrado. Instale yay ou paru primeiro."

  local sub="${1:-}"; shift || true
  case "$sub" in
    add)
      [[ $# -eq 0 ]] && _die "Uso: arrow aur add <pacote> [pacote2 …]"
      _info "AUR · instalando via ${BOLD}${helper}${RESET}: $*"
      "$helper" -S --noconfirm "$@"
      ;;
    search)
      [[ $# -eq 0 ]] && _die "Uso: arrow aur search <termo>"
      _info "AUR · buscando: ${BOLD}$*${RESET}"
      "$helper" -Ss "$@"
      ;;
    upgrade)
      _info "AUR · atualizando pacotes via ${BOLD}${helper}${RESET}…"
      "$helper" -Syu --noconfirm
      ;;
    "")
      _die "Uso: arrow aur <add|search|upgrade> [pacote]"
      ;;
    *)
      _die "Subcomando AUR desconhecido: '${sub}'. Use add, search ou upgrade."
      ;;
  esac
}
