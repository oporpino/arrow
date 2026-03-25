# fish completion for arrow(1)
# Install to /usr/share/fish/vendor_completions.d/arrow.fish

# ── Helpers ────────────────────────────────────────────────────────────────────

function __arrow_no_subcommand
    not __fish_seen_subcommand_from \
        add del rm remove \
        search find s \
        update upgrade up \
        info files own deps \
        list ls history log \
        orphans clean purge \
        howto \
        self sharpen reforge \
        aur help version
end

function __arrow_using_subcommand
    __fish_seen_subcommand_from $argv
end

function __arrow_installed_packages
    pacman -Qq 2>/dev/null
end

function __arrow_sync_packages
    pacman -Slq 2>/dev/null
end

# ── Global flags ───────────────────────────────────────────────────────────────

complete -c arrow -n __arrow_no_subcommand -s h -l help    -d 'Show help and exit'
complete -c arrow -n __arrow_no_subcommand -s v -l version -d 'Print version and exit'

# ── Top-level commands ────────────────────────────────────────────────────────

complete -c arrow -f -n __arrow_no_subcommand -a add     -d 'Install packages'
complete -c arrow -f -n __arrow_no_subcommand -a del     -d 'Remove packages and orphaned deps'
complete -c arrow -f -n __arrow_no_subcommand -a rm      -d 'Alias for del'
complete -c arrow -f -n __arrow_no_subcommand -a remove  -d 'Alias for del'
complete -c arrow -f -n __arrow_no_subcommand -a search  -d 'Search repositories'
complete -c arrow -f -n __arrow_no_subcommand -a find    -d 'Alias for search'
complete -c arrow -f -n __arrow_no_subcommand -a s       -d 'Alias for search'
complete -c arrow -f -n __arrow_no_subcommand -a update  -d 'Sync package databases'
complete -c arrow -f -n __arrow_no_subcommand -a upgrade -d 'Upgrade all packages'
complete -c arrow -f -n __arrow_no_subcommand -a up      -d 'Alias for upgrade'
complete -c arrow -f -n __arrow_no_subcommand -a info    -d 'Show package details'
complete -c arrow -f -n __arrow_no_subcommand -a files   -d 'List files owned by a package'
complete -c arrow -f -n __arrow_no_subcommand -a own     -d 'Find package that owns a file'
complete -c arrow -f -n __arrow_no_subcommand -a deps    -d 'Show dependency tree'
complete -c arrow -f -n __arrow_no_subcommand -a list    -d 'List installed packages'
complete -c arrow -f -n __arrow_no_subcommand -a ls      -d 'Alias for list'
complete -c arrow -f -n __arrow_no_subcommand -a history -d 'Show pacman log entries'
complete -c arrow -f -n __arrow_no_subcommand -a log     -d 'Alias for history'
complete -c arrow -f -n __arrow_no_subcommand -a orphans -d 'List orphaned packages'
complete -c arrow -f -n __arrow_no_subcommand -a clean   -d 'Clean package cache'
complete -c arrow -f -n __arrow_no_subcommand -a purge   -d 'Remove all orphaned packages'
complete -c arrow -f -n __arrow_no_subcommand -a howto   -d 'Step-by-step guides'
complete -c arrow -f -n __arrow_no_subcommand -a self     -d 'Manage arrow itself'
complete -c arrow -f -n __arrow_no_subcommand -a sharpen   -d 'Update arrow to the latest version'
complete -c arrow -f -n __arrow_no_subcommand -a reforge   -d 'Alias for sharpen'
complete -c arrow -f -n __arrow_no_subcommand -a reinstall -d 'Force reinstall arrow'
complete -c arrow -f -n __arrow_no_subcommand -a aur      -d 'AUR helper commands'
complete -c arrow -f -n __arrow_no_subcommand -a help    -d 'Show help'
complete -c arrow -f -n __arrow_no_subcommand -a version -d 'Print version'

# ── Per-command argument completions ──────────────────────────────────────────

# Commands that accept an installed package name
for _cmd in del rm remove files info deps
    complete -c arrow -f -n "__arrow_using_subcommand $_cmd" \
        -a '(__arrow_installed_packages)'
end

# 'add' flags
complete -c arrow -f -n '__arrow_using_subcommand add' -a --no-upgrade -d 'Skip system upgrade'
complete -c arrow -f -n '__arrow_using_subcommand add' -a --no-sync    -d 'Skip db sync'

# Commands that accept a sync-db package name
for _cmd in add search find s
    complete -c arrow -f -n "__arrow_using_subcommand $_cmd" \
        -a '(__arrow_sync_packages)'
end

# 'arw' alias gets the same completions
complete -c arw -w arrow

# 'own' completes with file paths
complete -c arrow -F -n '__arrow_using_subcommand own'

# 'clean' accepts --all
complete -c arrow -f -n '__arrow_using_subcommand clean' \
    -a --all -d 'Wipe the entire package cache'

# 'howto' sub-commands
complete -c arrow -f -n '__arrow_using_subcommand howto' -a user.add     -d 'Create new user'
complete -c arrow -f -n '__arrow_using_subcommand howto' -a user.sudoers -d 'Add user to sudoers'
complete -c arrow -f -n '__arrow_using_subcommand howto' -a list         -d 'List available guides'

# 'self' sub-commands
complete -c arrow -f -n '__arrow_using_subcommand self' -a update     -d 'Update arrow to the latest version'
complete -c arrow -f -n '__arrow_using_subcommand self' -a reinstall  -d 'Force reinstall arrow'
complete -c arrow -f -n '__arrow_using_subcommand self' -a remove     -d 'Uninstall arrow from the system'

# 'aur' sub-commands
complete -c arrow -f -n '__arrow_using_subcommand aur' -a add     -d 'Install from AUR'
complete -c arrow -f -n '__arrow_using_subcommand aur' -a search  -d 'Search the AUR'
complete -c arrow -f -n '__arrow_using_subcommand aur' -a upgrade -d 'Upgrade AUR packages'
