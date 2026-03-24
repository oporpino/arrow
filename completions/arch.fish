# fish completion for arch(1)
# Install to /usr/share/fish/vendor_completions.d/arch.fish

# ── Helpers ────────────────────────────────────────────────────────────────────

function __arch_no_subcommand
    not __fish_seen_subcommand_from \
        add del rm remove \
        search find s \
        update upgrade up \
        info files own deps \
        list ls history log \
        orphans clean purge \
        aur help version
end

function __arch_using_subcommand
    __fish_seen_subcommand_from $argv
end

function __arch_installed_packages
    pacman -Qq 2>/dev/null
end

function __arch_sync_packages
    pacman -Slq 2>/dev/null
end

# ── Global flags ───────────────────────────────────────────────────────────────

complete -c arch -n __arch_no_subcommand -s h -l help    -d 'Show help and exit'
complete -c arch -n __arch_no_subcommand -s v -l version -d 'Print version and exit'

# ── Top-level commands ────────────────────────────────────────────────────────

complete -c arch -f -n __arch_no_subcommand -a add     -d 'Install packages'
complete -c arch -f -n __arch_no_subcommand -a del     -d 'Remove packages and orphaned deps'
complete -c arch -f -n __arch_no_subcommand -a rm      -d 'Alias for del'
complete -c arch -f -n __arch_no_subcommand -a remove  -d 'Alias for del'
complete -c arch -f -n __arch_no_subcommand -a search  -d 'Search repositories'
complete -c arch -f -n __arch_no_subcommand -a find    -d 'Alias for search'
complete -c arch -f -n __arch_no_subcommand -a s       -d 'Alias for search'
complete -c arch -f -n __arch_no_subcommand -a update  -d 'Sync package databases'
complete -c arch -f -n __arch_no_subcommand -a upgrade -d 'Upgrade all packages'
complete -c arch -f -n __arch_no_subcommand -a up      -d 'Alias for upgrade'
complete -c arch -f -n __arch_no_subcommand -a info    -d 'Show package details'
complete -c arch -f -n __arch_no_subcommand -a files   -d 'List files owned by a package'
complete -c arch -f -n __arch_no_subcommand -a own     -d 'Find package that owns a file'
complete -c arch -f -n __arch_no_subcommand -a deps    -d 'Show dependency tree'
complete -c arch -f -n __arch_no_subcommand -a list    -d 'List installed packages'
complete -c arch -f -n __arch_no_subcommand -a ls      -d 'Alias for list'
complete -c arch -f -n __arch_no_subcommand -a history -d 'Show pacman log entries'
complete -c arch -f -n __arch_no_subcommand -a log     -d 'Alias for history'
complete -c arch -f -n __arch_no_subcommand -a orphans -d 'List orphaned packages'
complete -c arch -f -n __arch_no_subcommand -a clean   -d 'Clean package cache'
complete -c arch -f -n __arch_no_subcommand -a purge   -d 'Remove all orphaned packages'
complete -c arch -f -n __arch_no_subcommand -a aur     -d 'AUR helper commands'
complete -c arch -f -n __arch_no_subcommand -a help    -d 'Show help'
complete -c arch -f -n __arch_no_subcommand -a version -d 'Print version'

# ── Per-command argument completions ──────────────────────────────────────────

# Commands that accept an installed package name
for _cmd in del rm remove files info deps
    complete -c arch -f -n "__arch_using_subcommand $_cmd" \
        -a '(__arch_installed_packages)'
end

# Commands that accept a sync-db package name
for _cmd in add search find s
    complete -c arch -f -n "__arch_using_subcommand $_cmd" \
        -a '(__arch_sync_packages)'
end

# 'own' completes with file paths
complete -c arch -F -n '__arch_using_subcommand own'

# 'clean' accepts --all
complete -c arch -f -n '__arch_using_subcommand clean' \
    -a --all -d 'Wipe the entire package cache'

# 'aur' sub-commands
complete -c arch -f -n '__arch_using_subcommand aur' -a add     -d 'Install from AUR'
complete -c arch -f -n '__arch_using_subcommand aur' -a search  -d 'Search the AUR'
complete -c arch -f -n '__arch_using_subcommand aur' -a upgrade -d 'Upgrade AUR packages'
