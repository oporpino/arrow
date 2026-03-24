---
title: System Commands
description: Reference for arch update, upgrade, clean, orphans, and purge commands.
---

# System Commands

## update

Synchronise the local package databases with the upstream mirrors.

```
arch update
```

**pacman equivalent:** `pacman -Sy`

!!! warning
    Running `update` without `upgrade` can leave your system in a partially updated state. Prefer `arch upgrade` for day-to-day maintenance.

---

## upgrade

Synchronise databases and upgrade all installed packages to their latest versions.

```
arch upgrade
```

**Alias:** `up`

**pacman equivalent:** `pacman -Syu`

**Example:**

```bash
arch upgrade
```

---

## clean

Remove outdated package versions from the local package cache to free disk space.

```
arch clean [--all]
```

| Flag | Behaviour |
|---|---|
| *(none)* | Keeps one cached version per package; removes the rest |
| `--all` | Wipes the entire cache |

**Examples:**

```bash
arch clean        # light clean
arch clean --all  # full wipe
```

**pacman equivalent:** `pacman -Sc` / `pacman -Scc`

---

## orphans

List packages that were installed as dependencies but are no longer required by any installed package.

```
arch orphans
```

**pacman equivalent:** `pacman -Qdtq`

**Example output:**

```
Orphaned packages:
lib32-gcc-libs
perl-error
python-chardet
```

Use `arch purge` to remove them all at once.

---

## purge

Remove all orphaned packages (as reported by `arch orphans`) in a single step.

```
arch purge
```

**pacman equivalent:** `pacman -Rns $(pacman -Qdtq)`

!!! tip "Routine maintenance"
    Running these two commands periodically keeps your system lean:
    ```bash
    arch purge    # remove orphans
    arch clean    # trim the cache
    ```
