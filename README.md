# arrow — The missing interface for Arch

> **A**nother **R**idiculously **R**eadable **O**verlay **W**rapper

```bash
arrow add firefox neovim     # install packages
arrow delete vlc                # remove + clean orphans
arrow search python          # search repositories
arrow upgrade                # full system upgrade
arrow aur add yay            # install from the AUR
```

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![AUR](https://img.shields.io/aur/version/arrow-cli)](https://aur.archlinux.org/packages/arrow-cli)
[![GitHub release](https://img.shields.io/github/v/release/oporpino/arrow)](https://github.com/oporpino/arrow/releases)

---

## Why

`pacman` is powerful, but its flags are hard to remember (`-Syu`, `-Rns`, `-Qdtq`…). **arrow** replaces them with plain English commands while staying 100% transparent — no hidden logic, no database, just pacman under the hood.

## Install

**One-liner (latest):**

```bash
curl -fsSL https://raw.githubusercontent.com/oporpino/arrow/main/install.sh | bash
```

**Specific version:**

```bash
curl -fsSL https://raw.githubusercontent.com/oporpino/arrow/main/install.sh \
  | ARROW_VERSION=v1.0.0 bash
```

**Custom prefix** (no sudo needed):

```bash
curl -fsSL https://raw.githubusercontent.com/oporpino/arrow/main/install.sh \
  | PREFIX=~/.local bash
```

**From source:**

```bash
git clone https://github.com/oporpino/arrow
cd arrow
make build
sudo make install
```

The installer checks that `pacman` is present, installs any missing build dependencies, downloads the source, builds a single self-contained binary, and places it along with shell completions and the man page in the right system directories.

## Commands

### Packages

| Command | pacman equivalent | Description |
|---|---|---|
| `arrow add <pkg…>` | `pacman -S` | Install one or more packages |
| `arrow delete <pkg…>` | `pacman -Rns` | Remove packages and orphaned deps |
| `arrow search <term>` | `pacman -Ss` | Search the sync databases |
| `arrow info <pkg>` | `pacman -Si / -Qi` | Show package details |
| `arrow files <pkg>` | `pacman -Ql` | List files owned by an installed package |
| `arrow own <file>` | `pacman -Qo` | Find which package owns a file |
| `arrow deps <pkg>` | `pactree` | Show the full dependency tree |

### System

| Command | pacman equivalent | Description |
|---|---|---|
| `arrow update` | `pacman -Sy` | Sync package databases |
| `arrow upgrade` | `pacman -Syu` | Sync databases and upgrade all packages |
| `arrow clean` | `pacman -Sc` | Remove outdated packages from cache |
| `arrow clean --all` | `pacman -Scc` | Wipe the entire package cache |
| `arrow orphans` | `pacman -Qdtq` | List packages no longer required |
| `arrow purge` | `pacman -Rns $(…)` | Remove all orphaned packages |

### Query

| Command | Description |
|---|---|
| `arrow list [filter]` | List installed packages, optionally filtered |
| `arrow history [n]` | Show the last *n* pacman log entries (default 20) |

### AUR

Delegates to the first available AUR helper (`yay` or `paru`).

| Command | Description |
|---|---|
| `arrow aur add <pkg>` | Install a package from the AUR |
| `arrow aur search <term>` | Search the AUR |
| `arrow aur upgrade` | Upgrade all AUR packages |

### Aliases

Several commands have short aliases for convenience:

| Alias | Command |
|---|---|
| `del`, `rm`, `remove` | `delete` |
| `find`, `s` | `search` |
| `up` | `upgrade` |
| `ls` | `list` |
| `log` | `history` |

## Shell completion

Completions for **bash**, **zsh**, and **fish** are installed automatically. After installing, restart your shell or manually source the completion file:

```bash
# bash
source /usr/share/bash-completion/completions/arch

# zsh — /usr/share/zsh/site-functions must be in $fpath (it usually is)
autoload -Uz compinit && compinit

# fish — completions are sourced automatically
```

Completions are context-aware: commands like `del`, `info`, and `files` complete against the list of installed packages; `aur` completes its subcommands.

## Man page

```bash
man arrow
```

## Uninstall

```bash
sudo make uninstall
```

Or, if you installed to a custom prefix:

```bash
make uninstall PREFIX=~/.local
```

## Documentation

Full documentation is available at **[oporpino.github.io/arrow](https://oporpino.github.io/arrow)**.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repo and create your branch from `main`.
2. Keep source files in `src/` — the Makefile concatenates them into the final binary.
3. Run `bash -n dist/arrow` to check syntax before opening a PR.
4. For new commands, add completions in all three shells.

## Project structure

```
src/
  version.sh          version constant
  colors.sh           ANSI colour definitions
  helpers.sh          output functions and utilities
  commands/
    packages.sh       add, del, search, info, files, own, deps
    system.sh         update, upgrade, clean, orphans, purge
    query.sh          list, history
    aur.sh            aur subcommand
  help.sh             help and version output
  main.sh             dispatcher
completions/
  arrow.bash           bash completion
  _arrow               zsh completion
  arrow.fish           fish completion
man/
  arrow.1              man page (troff)
docs/                 MkDocs source for the documentation site
```

## License

MIT © [oporpino](https://github.com/oporpino)
