# ── Help & version ────────────────────────────────────────────────────────────

cmd_version() {
  echo "arrow v${VERSION}"
}

cmd_help() {
  cat <<EOF

$(echo -e "${BOLD}${CYAN}arrow${RESET} ${DIM}v${VERSION}${RESET}") — The missing interface for Arch
$(echo -e "${DIM}${REPO_URL}${RESET}")

$(echo -e "${BOLD}USAGE${RESET}")
  arrow <command> [arguments]

$(echo -e "${BOLD}PACKAGES${RESET}")
  $(echo -e "${GREEN}add${RESET}")     <pkg…>         Install package(s)
  $(echo -e "${RED}delete${RESET}")  <pkg…>         Remove package(s) and orphaned deps
  $(echo -e "${BLUE}search${RESET}")  <term>         Search repositories
  $(echo -e "${CYAN}info${RESET}")    <pkg>          Show package details
  $(echo -e "${CYAN}files${RESET}")   <pkg>          List files installed by a package
  $(echo -e "${CYAN}deps${RESET}")    <pkg>          Show dependency tree
  $(echo -e "${CYAN}own${RESET}")     <file>         Which package owns this file

$(echo -e "${BOLD}SYSTEM${RESET}")
  $(echo -e "${GREEN}update${RESET}")                  Sync package databases
  $(echo -e "${GREEN}upgrade${RESET}")                 Upgrade all packages
  $(echo -e "${YELLOW}clean${RESET}")   [--all]         Clean cache (--all removes everything)
  $(echo -e "${YELLOW}orphans${RESET}")                 List orphaned packages
  $(echo -e "${YELLOW}purge${RESET}")                   Remove all orphaned packages

$(echo -e "${BOLD}ARROW${RESET}")
  $(echo -e "${MAGENTA}self update${RESET}")              Update arrow to the latest version
  $(echo -e "${MAGENTA}self remove${RESET}")              Uninstall arrow from the system
  $(echo -e "${DIM}sharpen, reforge${RESET}             Aliases for self update${RESET}")

$(echo -e "${BOLD}SPELLS${RESET}")
  $(echo -e "${WHITE}spell${RESET}")                     Guided setup menu
  $(echo -e "${WHITE}spell desktop${RESET}") [de]        Install a desktop environment
  $(echo -e "${WHITE}spell desktop${RESET}") [de] undo   Remove a desktop environment
  $(echo -e "${DIM}setup is an alias for spell${RESET}")

$(echo -e "${BOLD}DISTRO${RESET}")
  $(echo -e "${RED}distro morph${RESET}") <name>        Convert the system (irreversible)
  $(echo -e "${RED}distro morph archcraft${RESET}")     Arch Linux ARM → Archcraft ARM
  $(echo -e "${DIM}distro list${RESET}")                List available morphs

$(echo -e "${BOLD}GUIDES${RESET}")
  $(echo -e "${WHITE}howto${RESET}")   <guide>         Step-by-step guides (e.g. sudoers)

$(echo -e "${BOLD}QUERY${RESET}")
  $(echo -e "${CYAN}list${RESET}")    [filter]        List installed packages
  $(echo -e "${CYAN}history${RESET}") [n=20]          Show operation history

$(echo -e "${BOLD}AUR${RESET}")
  $(echo -e "${BLUE}aur add${RESET}")    <pkg>          Install from AUR (yay/paru)
  $(echo -e "${BLUE}aur search${RESET}") <term>         Search the AUR
  $(echo -e "${BLUE}aur upgrade${RESET}")               Upgrade AUR packages

$(echo -e "${DIM}Examples:
  arrow add firefox neovim
  arrow delete vlc
  arrow search python
  arrow upgrade
  arrow aur add yay

Environment variables:
  ARROW_DEBUG=1   Show internal flags (e.g. --noconfirm)${RESET}")

EOF
}
