---
title: Package Commands
description: Reference for arrow add, delete, search, info, files, own, and deps commands.
---

# Package Commands

## add

Install one or more packages from the sync repositories.

```
arrow add <package> [package2 …]
```

**Examples:**

```bash
arrow add firefox
arrow add git base-devel neovim ripgrep fd
```

**pacman equivalent:** `pacman -S <package>`

---

## delete

Remove packages along with their now-unneeded dependencies and configuration files.

```
arrow delete <package> [package2 …]
```

**Examples:**

```bash
arrow delete gimp
arrow delete vlc ffmpeg
```

**Aliases:** `del`, `rm`, `remove`

**pacman equivalent:** `pacman -Rns <package>`

!!! info
    Unlike a plain `pacman -R`, `arrow delete` also removes orphaned dependencies (`-s`) and configuration files (`-n`), leaving a cleaner system.

---

## search

Search the sync databases for packages matching a term.

```
arrow search <term>
```

**Examples:**

```bash
arrow search python
arrow search "video editor"
```

**Aliases:** `find`, `s`

**pacman equivalent:** `pacman -Ss <term>`

---

## info

Show detailed information about a package. Checks the sync database first; if the package is not found there, checks the local (installed) database.

```
arrow info <package>
```

**Examples:**

```bash
arrow info firefox
arrow info base
```

**pacman equivalent:** `pacman -Si <package>` / `pacman -Qi <package>`

---

## files

List all files installed by a package.

```
arrow files <package>
```

**Examples:**

```bash
arrow files bash
arrow files neovim
```

**pacman equivalent:** `pacman -Ql <package>`

---

## own

Find which installed package owns a given file.

```
arrow own <file>
```

**Examples:**

```bash
arrow own /usr/bin/git
arrow own /etc/pacman.conf
```

**pacman equivalent:** `pacman -Qo <file>`

---

## deps

Display the full dependency tree of a package. Uses `pactree` if available; falls back to `pacman -Si` otherwise.

```
arrow deps <package>
```

**Examples:**

```bash
arrow deps firefox
arrow deps python
```

!!! tip
    Install `pactree` for a richer tree view:
    ```bash
    arrow add pacman-contrib
    ```
