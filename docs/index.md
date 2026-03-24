---
title: arch — an intuitive wrapper for pacman
description: A friendlier interface to Arch Linux's package manager. Replace cryptic pacman flags with plain English commands.
---

# arch

**An intuitive wrapper for [pacman](https://wiki.archlinux.org/title/Pacman).**

Replace cryptic flags with plain English commands — without sacrificing power.

```bash
arch add firefox neovim     # install packages
arch del vlc                # remove + clean orphans automatically
arch search python          # search repositories
arch upgrade                # sync databases and upgrade everything
arch aur add yay            # install from the AUR
```

---

## Why arch?

`pacman` is one of the best package managers in Linux — but its interface shows its age:

| What you want to do | pacman | arch |
|---|---|---|
| Install a package | `pacman -S firefox` | `arch add firefox` |
| Remove + clean deps | `pacman -Rns vlc` | `arch del vlc` |
| Search repositories | `pacman -Ss python` | `arch search python` |
| Upgrade everything | `pacman -Syu` | `arch upgrade` |
| List orphaned packages | `pacman -Qdtq` | `arch orphans` |
| Remove all orphans | `pacman -Rns $(pacman -Qdtq)` | `arch purge` |

**arch** adds no hidden state, no extra database, and no magic — every command is a direct, transparent call to `pacman` or an AUR helper under the hood.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/oporpino/arch/main/install.sh | bash
```

:material-arrow-right: [Full installation guide](getting-started/installation.md)

---

## Quick tour

```bash
# package basics
arch add git base-devel     # install multiple packages at once
arch del gimp               # remove gimp and its orphaned deps
arch search neovim          # search repositories

# system health
arch upgrade                # full system upgrade
arch orphans                # see unused packages
arch purge                  # remove them all
arch clean                  # trim the package cache

# inspection
arch info firefox           # package details
arch files bash             # what files does bash own?
arch own /usr/bin/git       # which package owns this file?
arch list | grep py         # filter installed packages

# AUR (requires yay or paru)
arch aur add visual-studio-code-bin
arch aur upgrade

# history
arch history 50             # last 50 pacman operations
```
