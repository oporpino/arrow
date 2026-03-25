# ── Entry point ───────────────────────────────────────────────────────────────

main() {
  local cmd="${1:-help}"; shift || true

  case "$cmd" in
    # packages
    add)                    cmd_add     "$@" ;;
    delete | del | rm | remove) cmd_delete "$@" ;;
    search | find | s)      cmd_search  "$@" ;;
    info)                   cmd_info    "$@" ;;
    files)                  cmd_files   "$@" ;;
    own)                    cmd_own     "$@" ;;
    deps)                   cmd_deps    "$@" ;;

    # system
    update)            cmd_update   "$@" ;;
    upgrade | up)      cmd_upgrade  "$@" ;;
    clean)             cmd_clean    "$@" ;;
    orphans)           cmd_orphans  "$@" ;;
    purge)             cmd_purge    "$@" ;;

    # query
    list | ls)         cmd_list     "$@" ;;
    history | log)     cmd_history  "$@" ;;

    # aur
    aur)               cmd_aur      "$@" ;;

    # howto
    howto)             cmd_howto    "$@" ;;

    # self
    self)                          cmd_self          "$@" ;;
    sharpen | reforge)             cmd_self_update   "$@" ;;
    reinstall)                     cmd_self_reinstall "$@" ;;

    # meta
    help | -h | --help)     cmd_help ;;
    version | -v | --version) cmd_version ;;

    *)
      _err "Comando desconhecido: '${cmd}'"
      cmd_help
      exit 1
      ;;
  esac
}

main "$@"
