# ── Help & version ────────────────────────────────────────────────────────────

cmd_version() {
  echo "arch v${VERSION}"
}

cmd_help() {
  cat <<EOF

$(echo -e "${BOLD}${CYAN}arch${RESET} ${DIM}v${VERSION}${RESET}") — wrapper intuitivo para o pacman
$(echo -e "${DIM}${REPO}${RESET}")

$(echo -e "${BOLD}USO${RESET}")
  arch <comando> [argumentos]

$(echo -e "${BOLD}PACOTES${RESET}")
  $(echo -e "${GREEN}add${RESET}")     <pkg…>         Instala pacote(s)
  $(echo -e "${RED}del${RESET}")     <pkg…>         Remove pacote(s) e deps órfãs
  $(echo -e "${BLUE}search${RESET}")  <termo>        Busca nos repositórios
  $(echo -e "${CYAN}info${RESET}")    <pkg>          Detalhes de um pacote
  $(echo -e "${CYAN}files${RESET}")   <pkg>          Arquivos instalados de um pacote
  $(echo -e "${CYAN}deps${RESET}")    <pkg>          Árvore de dependências
  $(echo -e "${CYAN}own${RESET}")     <arquivo>      Qual pacote possui este arquivo

$(echo -e "${BOLD}SISTEMA${RESET}")
  $(echo -e "${GREEN}update${RESET}")                  Sincroniza base de dados
  $(echo -e "${GREEN}upgrade${RESET}")                 Atualiza todo o sistema
  $(echo -e "${YELLOW}clean${RESET}")   [--all]         Limpa cache (--all remove tudo)
  $(echo -e "${YELLOW}orphans${RESET}")                 Lista pacotes órfãos
  $(echo -e "${YELLOW}purge${RESET}")                   Remove todos os pacotes órfãos

$(echo -e "${BOLD}LISTAGEM${RESET}")
  $(echo -e "${CYAN}list${RESET}")    [filtro]        Lista pacotes instalados
  $(echo -e "${CYAN}history${RESET}") [n=20]          Histórico de operações

$(echo -e "${BOLD}AUR${RESET}")
  $(echo -e "${BLUE}aur add${RESET}")    <pkg>          Instala do AUR (yay/paru)
  $(echo -e "${BLUE}aur search${RESET}") <termo>        Busca no AUR
  $(echo -e "${BLUE}aur upgrade${RESET}")               Atualiza pacotes AUR

$(echo -e "${DIM}Exemplos:
  arch add firefox neovim
  arch del vlc
  arch search python
  arch upgrade
  arch aur add yay${RESET}")

EOF
}
