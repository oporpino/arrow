# bash completion for arch(1)
# Source this file or drop it in /usr/share/bash-completion/completions/arrow

_arrow_installed_packages() {
  pacman -Qq 2>/dev/null
}

_arrow() {
  local cur prev words cword
  _init_completion || return

  # Top-level commands
  local commands=(
    add del rm remove
    search find s
    update upgrade up
    info files own deps
    list ls history log
    orphans clean purge
    aur
    help version
  )

  # AUR sub-commands
  local aur_cmds=(add search upgrade)

  case "$prev" in
    arch)
      COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
      return
      ;;
    del | rm | remove | files | info | deps)
      COMPREPLY=($(compgen -W "$(_arrow_installed_packages)" -- "$cur"))
      return
      ;;
    own)
      # complete with file paths
      _filedir
      return
      ;;
    aur)
      COMPREPLY=($(compgen -W "${aur_cmds[*]}" -- "$cur"))
      return
      ;;
    clean)
      COMPREPLY=($(compgen -W "--all" -- "$cur"))
      return
      ;;
    add | search | find | s)
      # package names from sync db (may be slow on large repos; skip if empty)
      local sync_pkgs
      sync_pkgs=$(pacman -Slq 2>/dev/null)
      [[ -n "$sync_pkgs" ]] && COMPREPLY=($(compgen -W "$sync_pkgs" -- "$cur"))
      return
      ;;
  esac

  # Nested: arrow aur <sub>
  if [[ ${#words[@]} -ge 3 && "${words[1]}" == "aur" ]]; then
    case "$prev" in
      add | search)
        return ;;  # no static completion for AUR names
    esac
    COMPREPLY=($(compgen -W "${aur_cmds[*]}" -- "$cur"))
    return
  fi

  if [[ "$cur" == -* ]]; then
    COMPREPLY=($(compgen -W "--help --version" -- "$cur"))
    return
  fi

  COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
}

complete -F _arrow arrow
