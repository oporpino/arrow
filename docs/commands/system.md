---
title: System Commands
description: Reference for arch update, upgrade, clean, orphans, and purge commands.
---

# System Commands

## update

Synchronise the local package databases with the upstream mirrors.

```
arrow update
```

**pacman equivalent:** `pacman -Sy`

!!! warning
    Running `update` without `upgrade` can leave your system in a partially updated state. Prefer `arrow upgrade` for day-to-day maintenance.

---

## upgrade

Synchronise databases and upgrade all installed packages to their latest versions.

```
arrow upgrade
```

**Alias:** `up`

**pacman equivalent:** `pacman -Syu`

**Example:**

```bash
arrow upgrade
```

---

## clean

Remove outdated package versions from the local package cache to free disk space.

```
arrow clean [--all]
```

| Flag | Behaviour |
|---|---|
| *(none)* | Keeps one cached version per package; removes the rest |
| `--all` | Wipes the entire cache |

**Examples:**

```bash
arrow clean        # light clean
arrow clean --all  # full wipe
```

**pacman equivalent:** `pacman -Sc` / `pacman -Scc`

---

## orphans

List packages that were installed as dependencies but are no longer required by any installed package.

```
arrow orphans
```

**pacman equivalent:** `pacman -Qdtq`

**Example output:**

```
Orphaned packages:
lib32-gcc-libs
perl-error
python-chardet
```

Use `arrow purge` to remove them all at once.

---

## purge

Remove all orphaned packages (as reported by `arrow orphans`) in a single step.

```
arrow purge
```

**pacman equivalent:** `pacman -Rns $(pacman -Qdtq)`

!!! tip "Routine maintenance"
    Running these two commands periodically keeps your system lean:
    ```bash
    arrow purge    # remove orphans
    arrow clean    # trim the cache
    ```
