# bash completion for arrow(1)
# Source this file or drop it in /usr/share/bash-completion/completions/arrow

_arrow_installed_packages() {
  pacman -Qq 2>/dev/null
}

_arrow() {
  local cur prev words cword
  if declare -f _init_completion &>/dev/null; then
    _init_completion || return
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")
    cword=$COMP_CWORD
  fi

  # Top-level commands (no aliases)
  local commands=(
    add delete
    search
    update upgrade
    info files own deps
    list history
    orphans clean purge
    howto spell distro
    sharpen reinstall
    help version aliases
  )

  case "$prev" in
    arrow | arw)
      COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
      return
      ;;
    delete | del | rm | remove | files | info | deps)
      COMPREPLY=($(compgen -W "$(_arrow_installed_packages)" -- "$cur"))
      return
      ;;
    own)
      declare -f _filedir &>/dev/null && _filedir || COMPREPLY=($(compgen -f -- "$cur"))
      return
      ;;
    howto)
      COMPREPLY=($(compgen -W "user.add user.sudoers user.remove user.passwd list" -- "$cur"))
      return
      ;;
    distro)
      COMPREPLY=($(compgen -W "morph list" -- "$cur"))
      return
      ;;
    morph)
      COMPREPLY=($(compgen -W "archcraft" -- "$cur"))
      return
      ;;
    spell | setup)
      COMPREPLY=($(compgen -W "desktop" -- "$cur"))
      return
      ;;
    desktop)
      COMPREPLY=($(compgen -W "gnome kde xfce openbox sway i3" -- "$cur"))
      return
      ;;
    gnome | kde | xfce | openbox | sway | i3)
      COMPREPLY=($(compgen -W "undo" -- "$cur"))
      return
      ;;
    self)
      COMPREPLY=($(compgen -W "update reinstall remove" -- "$cur"))
      return
      ;;
    sharpen | reforge)
      return
      ;;
    clean)
      COMPREPLY=($(compgen -W "--all" -- "$cur"))
      return
      ;;
    add)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--no-upgrade --no-sync" -- "$cur"))
        return
      fi
      local sync_pkgs
      sync_pkgs=$(pacman -Slq 2>/dev/null)
      [[ -n "$sync_pkgs" ]] && COMPREPLY=($(compgen -W "$sync_pkgs" -- "$cur"))
      return
      ;;
    search | find | s)
      local sync_pkgs
      sync_pkgs=$(pacman -Slq 2>/dev/null)
      [[ -n "$sync_pkgs" ]] && COMPREPLY=($(compgen -W "$sync_pkgs" -- "$cur"))
      return
      ;;
  esac

  if [[ "$cur" == -* ]]; then
    COMPREPLY=($(compgen -W "--help --version" -- "$cur"))
    return
  fi

  COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
}

complete -F _arrow arrow arw
