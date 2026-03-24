---
title: Contributing
description: How to contribute to arch, the intuitive pacman wrapper.
---

# Contributing

Contributions are welcome! Here's how to get involved.

## Reporting bugs

Open an issue at [github.com/oporpino/arch/issues](https://github.com/oporpino/arch/issues).
Please include:

- Your Arch Linux version / kernel
- The exact command you ran
- The full output (including any error messages)

## Submitting a pull request

1. Fork the repository and create a branch from `main`
2. Make your changes inside `src/`
3. Run a syntax check: `bash -n dist/arch` after `make build`
4. If adding a command, add completions for all three shells
5. Update `docs/` if the change affects user-facing behaviour
6. Open a pull request with a clear description

## Project structure

```
src/
  version.sh          version constant and repo URL
  colors.sh           ANSI colour definitions (no-op when not a TTY)
  helpers.sh          output functions (_info, _ok, _warn, _err, _die)
  commands/
    packages.sh       add, del, search, info, files, own, deps
    system.sh         update, upgrade, clean, orphans, purge
    query.sh          list, history
    aur.sh            aur subcommand
  help.sh             cmd_help, cmd_version
  main.sh             dispatcher + main "$@"
completions/
  arch.bash           bash completion
  _arch               zsh completion (_arch function)
  arch.fish           fish completion
man/
  arch.1              troff man page
docs/                 MkDocs source (this site)
```

## Build

```bash
make build      # → dist/arch (single concatenated binary)
make install    # installs to /usr/local (or PREFIX)
make uninstall  # removes all installed files
make clean-dist # deletes dist/
```

## Code style

- Pure bash, no external tools beyond `pacman`, `sudo`, and standard coreutils
- All functions named `cmd_*` for commands, `_*` for internal helpers
- New commands follow the pattern in `src/commands/packages.sh`
- Colours are defined in `src/colors.sh` and never hardcoded elsewhere
