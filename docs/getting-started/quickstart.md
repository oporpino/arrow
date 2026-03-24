---
title: Quick Start
description: Get up and running with arch in under a minute.
---

# Quick Start

## Your first commands

After installing, run `arch help` to see all available commands:

```bash
arch help
```

### Install a package

```bash
arch add firefox
```

Install multiple packages at once:

```bash
arch add git base-devel neovim ripgrep
```

### Remove a package

`arch del` removes the package *and* any dependencies that are no longer needed — no leftover cruft:

```bash
arch del gimp
```

### Search for packages

```bash
arch search video editor
```

### Keep your system up to date

```bash
arch upgrade
```

---

## System hygiene

Over time, Arch systems accumulate orphaned packages (dependencies of packages you've removed). Check for them regularly:

```bash
arch orphans
```

Remove them all at once:

```bash
arch purge
```

Clean the package cache to free disk space:

```bash
arch clean         # keeps one version of each package
arch clean --all   # wipes everything from the cache
```

---

## Useful inspection commands

```bash
# what do you know about this package?
arch info htop

# what files does a package install?
arch files bash

# which package owns this file?
arch own /usr/bin/python

# what has pacman been doing lately?
arch history
arch history 50   # last 50 entries
```

---

## AUR packages

If you have [yay](https://github.com/Jguer/yay) or [paru](https://github.com/morganamilo/paru) installed, you can manage AUR packages too:

```bash
arch aur add visual-studio-code-bin
arch aur search spotify
arch aur upgrade
```

!!! tip
    Don't have an AUR helper yet? Install one first:
    ```bash
    arch add base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si
    ```
    Then `arch aur add anything-from-the-aur` just works.

---

## Aliases

Many commands have short aliases:

| Alias | Command |
|---|---|
| `rm`, `remove` | `del` |
| `find`, `s` | `search` |
| `up` | `upgrade` |
| `ls` | `list` |
| `log` | `history` |
