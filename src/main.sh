# ── Entry point ───────────────────────────────────────────────────────────────

main() {
  _require_not_root

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
    update)                       cmd_update       "$@" ;;
    upgrade | up)                 cmd_upgrade      "$@" ;;
    clean)                        cmd_clean        "$@" ;;
    orphans)                      cmd_orphans      "$@" ;;
    purge)                        cmd_purge        "$@" ;;
    self-update | selfupdate)     cmd_self_update  "$@" ;;

    # query
    list | ls)              cmd_list    "$@" ;;
    history | log)          cmd_history "$@" ;;

    # aur
    aur)                    cmd_aur     "$@" ;;

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
