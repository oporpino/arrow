---
title: AUR Commands
description: Reference for arrow aur commands — install, search, and upgrade packages from the Arch User Repository.
---

# AUR Commands

`arrow aur` delegates to the first available AUR helper on your system. Supported helpers (checked in order):

1. [`yay`](https://github.com/Jguer/yay)
2. [`paru`](https://github.com/morganamilo/paru)

If neither is installed, `arrow aur` will exit with an error.

!!! tip "Install an AUR helper"
    ```bash
    arrow add base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si
    ```

---

## aur add

Install one or more packages from the Arch User Repository.

```
arrow aur add <package> [package2 …]
```

**Examples:**

```bash
arrow aur add visual-studio-code-bin
arrow aur add spotify ttf-ms-fonts
```

---

## aur search

Search the AUR for packages matching a term.

```
arrow aur search <term>
```

**Examples:**

```bash
arrow aur search spotify
arrow aur search "discord"
```

---

## aur upgrade

Upgrade all installed AUR packages.

```
arrow aur upgrade
```

**Example:**

```bash
arrow aur upgrade
```

!!! note
    To upgrade both official and AUR packages in one step, run:
    ```bash
    arrow upgrade       # official repositories
    arrow aur upgrade   # AUR packages
    ```
