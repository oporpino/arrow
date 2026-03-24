---
title: AUR Commands
description: Reference for arch aur commands — install, search, and upgrade packages from the Arch User Repository.
---

# AUR Commands

`arch aur` delegates to the first available AUR helper on your system. Supported helpers (checked in order):

1. [`yay`](https://github.com/Jguer/yay)
2. [`paru`](https://github.com/morganamilo/paru)

If neither is installed, `arch aur` will exit with an error.

!!! tip "Install an AUR helper"
    ```bash
    arch add base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si
    ```

---

## aur add

Install one or more packages from the Arch User Repository.

```
arch aur add <package> [package2 …]
```

**Examples:**

```bash
arch aur add visual-studio-code-bin
arch aur add spotify ttf-ms-fonts
```

---

## aur search

Search the AUR for packages matching a term.

```
arch aur search <term>
```

**Examples:**

```bash
arch aur search spotify
arch aur search "discord"
```

---

## aur upgrade

Upgrade all installed AUR packages.

```
arch aur upgrade
```

**Example:**

```bash
arch aur upgrade
```

!!! note
    To upgrade both official and AUR packages in one step, run:
    ```bash
    arch upgrade       # official repositories
    arch aur upgrade   # AUR packages
    ```
