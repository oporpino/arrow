---
title: Query Commands
description: Reference for arch list and arch history commands.
---

# Query Commands

## list

List all installed packages. Optionally filter by a search term.

```
arch list [filter]
```

**Alias:** `ls`

**Examples:**

```bash
arch list               # all installed packages
arch list python        # packages whose name contains "python"
arch list | wc -l       # count installed packages
```

**pacman equivalent:** `pacman -Q`

---

## history

Show recent pacman log entries (installs, removals, upgrades).

```
arch history [n]
```

- `n` — number of entries to show (default: **20**)

**Alias:** `log`

**Examples:**

```bash
arch history        # last 20 operations
arch history 50     # last 50 operations
arch history 5      # just the last 5
```

**Example output:**

```
[2025-06-01T12:34:56+0000] [ALPM] installed firefox (126.0-1)
[2025-06-01T12:35:10+0000] [ALPM] upgraded neovim (0.9.5-1 -> 0.10.0-1)
[2025-06-01T14:00:01+0000] [ALPM] removed vlc (3.0.21-1)
```

Reads from `/var/log/pacman.log`.
