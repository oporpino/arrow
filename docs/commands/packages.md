---
title: Package Commands
description: Reference for arch add, del, search, info, files, own, and deps commands.
---

# Package Commands

## add

Install one or more packages from the sync repositories.

```
arch add <package> [package2 …]
```

**Examples:**

```bash
arch add firefox
arch add git base-devel neovim ripgrep fd
```

**pacman equivalent:** `pacman -S <package>`

---

## del

Remove packages along with their now-unneeded dependencies and configuration files.

```
arch del <package> [package2 …]
```

**Examples:**

```bash
arch del gimp
arch del vlc ffmpeg
```

**Aliases:** `rm`, `remove`

**pacman equivalent:** `pacman -Rns <package>`

!!! info
    Unlike a plain `pacman -R`, `arch del` also removes orphaned dependencies (`-s`) and configuration files (`-n`), leaving a cleaner system.

---

## search

Search the sync databases for packages matching a term.

```
arch search <term>
```

**Examples:**

```bash
arch search python
arch search "video editor"
```

**Aliases:** `find`, `s`

**pacman equivalent:** `pacman -Ss <term>`

---

## info

Show detailed information about a package. Checks the sync database first; if the package is not found there, checks the local (installed) database.

```
arch info <package>
```

**Examples:**

```bash
arch info firefox
arch info base
```

**pacman equivalent:** `pacman -Si <package>` / `pacman -Qi <package>`

---

## files

List all files installed by a package.

```
arch files <package>
```

**Examples:**

```bash
arch files bash
arch files neovim
```

**pacman equivalent:** `pacman -Ql <package>`

---

## own

Find which installed package owns a given file.

```
arch own <file>
```

**Examples:**

```bash
arch own /usr/bin/git
arch own /etc/pacman.conf
```

**pacman equivalent:** `pacman -Qo <file>`

---

## deps

Display the full dependency tree of a package. Uses `pactree` if available; falls back to `pacman -Si` otherwise.

```
arch deps <package>
```

**Examples:**

```bash
arch deps firefox
arch deps python
```

!!! tip
    Install `pactree` for a richer tree view:
    ```bash
    arch add pacman-contrib
    ```
