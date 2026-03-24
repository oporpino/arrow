---
title: Quick Start
description: Get up and running with arch in under a minute.
---

# Quick Start

## Your first commands

After installing, run `arrow help` to see all available commands:

```bash
arrow help
```

### Install a package

```bash
arrow add firefox
```

Install multiple packages at once:

```bash
arrow add git base-devel neovim ripgrep
```

### Remove a package

`arrow delete` removes the package *and* any dependencies that are no longer needed — no leftover cruft:

```bash
arrow delete gimp
```

### Search for packages

```bash
arrow search video editor
```

### Keep your system up to date

```bash
arrow upgrade
```

---

## System hygiene

Over time, Arch systems accumulate orphaned packages (dependencies of packages you've removed). Check for them regularly:

```bash
arrow orphans
```

Remove them all at once:

```bash
arrow purge
```

Clean the package cache to free disk space:

```bash
arrow clean         # keeps one version of each package
arrow clean --all   # wipes everything from the cache
```

---

## Useful inspection commands

```bash
# what do you know about this package?
arrow info htop

# what files does a package install?
arrow files bash

# which package owns this file?
arrow own /usr/bin/python

# what has pacman been doing lately?
arrow history
arrow history 50   # last 50 entries
```

---

## AUR packages

If you have [yay](https://github.com/Jguer/yay) or [paru](https://github.com/morganamilo/paru) installed, you can manage AUR packages too:

```bash
arrow aur add visual-studio-code-bin
arrow aur search spotify
arrow aur upgrade
```

!!! tip
    Don't have an AUR helper yet? Install one first:
    ```bash
    arrow add base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si
    ```
    Then `arrow aur add anything-from-the-aur` just works.

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
