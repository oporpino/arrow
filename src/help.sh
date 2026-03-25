# ── Help & version ────────────────────────────────────────────────────────────

cmd_version() {
  echo "arrow v${VERSION}"
}

cmd_help() {
  cat <<EOF

$(echo -e "${BOLD}${CYAN}arrow${RESET} ${DIM}v${VERSION}${RESET}") — The missing interface for Arch
$(echo -e "${DIM}${REPO_URL}${RESET}")

$(echo -e "${BOLD}USO${RESET}")
  arrow <comando> [argumentos]

$(echo -e "${BOLD}PACOTES${RESET}")
  $(echo -e "${GREEN}add${RESET}")     <pkg…>         Instala pacote(s)
  $(echo -e "${RED}delete${RESET}")  <pkg…>         Remove pacote(s) e deps órfãs
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


$(echo -e "${BOLD}ARROW${RESET}")
  $(echo -e "${MAGENTA}self update${RESET}")              Atualiza o arrow para a versão mais recente
  $(echo -e "${MAGENTA}self remove${RESET}")              Desinstala o arrow do sistema
  $(echo -e "${DIM}sharpen, reforge${RESET}             Aliases para self update${RESET}")

$(echo -e "${BOLD}SPELLS${RESET}")
  $(echo -e "${WHITE}spell${RESET}")                     Menu de configuração guiada
  $(echo -e "${WHITE}spell desktop${RESET}") [de]        Instala ambiente de desktop
  $(echo -e "${WHITE}spell desktop${RESET}") [de] undo   Remove ambiente de desktop
  $(echo -e "${DIM}setup é alias para spell${RESET}")

$(echo -e "${BOLD}GUIAS${RESET}")
  $(echo -e "${WHITE}howto${RESET}")   <guia>         Guias passo a passo (ex: sudoers)

$(echo -e "${BOLD}LISTAGEM${RESET}")
  $(echo -e "${CYAN}list${RESET}")    [filtro]        Lista pacotes instalados
  $(echo -e "${CYAN}history${RESET}") [n=20]          Histórico de operações

$(echo -e "${BOLD}AUR${RESET}")
  $(echo -e "${BLUE}aur add${RESET}")    <pkg>          Instala do AUR (yay/paru)
  $(echo -e "${BLUE}aur search${RESET}") <termo>        Busca no AUR
  $(echo -e "${BLUE}aur upgrade${RESET}")               Atualiza pacotes AUR

$(echo -e "${DIM}Exemplos:
  arrow add firefox neovim
  arrow delete vlc
  arrow search python
  arrow upgrade
  arrow aur add yay

Variáveis de ambiente:
  ARROW_DEBUG=1   Exibe flags internas dos comandos (ex: --noconfirm)${RESET}")

EOF
}
