---
title: arrow — The missing interface for Arch
description: The missing interface for Arch. Another Ridiculously Readable Overlay Wrapper — manage packages, set up your desktop, and configure your system without memorising pacman flags or wiki pages.
---

# arrow

**The missing interface for Arch.**

*Another Ridiculously Readable Overlay Wrapper.*

arrow makes Arch accessible — whether you're installing packages, setting up a desktop environment, or taking your first steps after a fresh install.

```bash
arrow add firefox neovim       # install packages
arrow delete vlc                  # remove + clean orphans
arrow upgrade                  # full system upgrade
arrow setup gnome              # install and configure GNOME
arrow howto                    # interactive post-install guide
arrow doctor                   # check system health
```

---

## Why

Arch Linux is one of the most powerful and transparent Linux distributions — but it asks a lot from newcomers. The wiki is excellent, but it's a lot to absorb. Flags like `-Syu`, `-Rns`, and `-Qdtq` are hard to remember. Setting up audio, Bluetooth, or a desktop environment still requires cobbling together several wiki pages.

arrow is a single tool that covers the full journey:

- **Day zero** — guided post-install walkthrough via `howto`
- **Day to day** — plain English package management without memorising pacman flags
- **As you grow** — `setup` commands for common configurations (desktop, audio, printing…)
- **System health** — `doctor` checks mirrors, orphans, cache, and more

Everything arrow does is a direct, transparent call to `pacman`, `systemctl`, or other standard tools — no hidden state, no magic.

---

## Package management

arrow wraps pacman with memorable commands. Under the hood it's still pacman — you're not giving anything up.

| arrow | pacman | What it does |
|---|---|---|
| `arrow add firefox` | `pacman -S firefox` | Install a package |
| `arrow deleteete vlc` | `pacman -Rns vlc` | Remove + clean deps |
| `arrow search python` | `pacman -Ss python` | Search repos |
| `arrow upgrade` | `pacman -Syu` | Full upgrade |
| `arrow orphans` | `pacman -Qdtq` | List unused deps |
| `arrow purge` | `pacman -Rns $(…)` | Remove all orphans |

:material-arrow-right: [Full command reference](commands/index.md)

---

## Setup & configuration

*(coming soon)*

`arrow setup` handles the things that send newcomers to the wiki.

```bash
arrow howto                    # interactive post-install walkthrough
arrow setup gnome              # install GNOME and enable GDM
arrow setup kde                # install KDE Plasma
arrow setup hyprland           # install Hyprland (Wayland)
arrow setup audio              # configure PipeWire
arrow setup bluetooth          # enable and configure Bluetooth
arrow setup printer            # CUPS + common drivers
arrow mirrors                  # refresh mirror list with reflector
arrow doctor                   # system health check
```

:material-arrow-right: [See the full roadmap](roadmap.md)

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/oporpino/arrow/main/install.sh | bash
```

:material-arrow-right: [Full installation guide](getting-started/installation.md)
