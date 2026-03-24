---
title: Roadmap
description: Planned features and commands for arrow — Arch Linux for humans.
---

# Roadmap

arrow's goal is to cover the full Arch Linux experience — from a fresh install to a fully configured daily driver — through a single, friendly CLI.

This page tracks what's planned. Contributions are very welcome.

---

## `arrow first-steps`

An interactive post-install checklist that walks through the essential configuration steps after a minimal Arch install.

**Planned checks and actions:**

- Set hostname
- Configure locale and timezone
- Create a non-root user
- Enable `NetworkManager` or `systemd-networkd`
- Set up `sudo`
- Install a bootloader (grub, systemd-boot)
- Prompt to run `arrow setup de` for a desktop environment

---

## `arrow setup de`

Install and configure a complete desktop environment in one command.

```bash
arrow setup de gnome       # GNOME + GDM
arrow setup de kde         # KDE Plasma + SDDM
arrow setup de xfce        # XFCE + LightDM
arrow setup de hyprland    # Hyprland (Wayland compositor)
arrow setup de sway        # Sway (Wayland)
```

Each subcommand installs the packages, enables the display manager service, and applies sensible defaults.

---

## `arrow setup audio`

Configure audio via PipeWire (the modern default on Arch).

- Install `pipewire`, `pipewire-pulse`, `wireplumber`
- Enable user services
- Optionally install `pavucontrol` for a GUI mixer

---

## `arrow setup bluetooth`

- Install `bluez` and `bluez-utils`
- Enable and start `bluetooth.service`
- Optionally install a GUI (`blueman`)

---

## `arrow setup printer`

- Install CUPS and common drivers
- Enable `cups.service`
- Open the CUPS web interface

---

## `arrow mirrors`

Refresh the pacman mirror list using `reflector`, sorted by speed and recency.

```bash
arrow mirrors                  # auto-detect country, pick 10 fastest
arrow mirrors --country BR     # filter by country
```

---

## `arrow doctor`

A system health check that surfaces common issues:

- Stale or slow mirrors
- Orphaned packages
- Large package cache
- Failed systemd units
- Pending package updates
- Broken symlinks in common paths

---

## Ideas under consideration

- `arrow pin <pkg>` — prevent a package from being upgraded (via `IgnorePkg`)
- `arrow log <pkg>` — filter history for a specific package
- `arrow backup` — export the list of explicitly installed packages
- `arrow restore` — reinstall from a backup list
- `arrow news` — show recent Arch Linux news (from the RSS feed) before upgrades

---

!!! info "Want to help?"
    Open an issue or pull request at [github.com/oporpino/arrow](https://github.com/oporpino/arrow).
    New commands follow the pattern in `src/commands/` — each module is a focused, self-contained file.
