---
title: Roadmap
description: Planned features and commands for arrow — Arch Linux for humans.
---

# Roadmap

arrow's goal is to cover the full Arch Linux experience — from a fresh install to a fully configured daily driver — through a single, friendly CLI.

This page tracks what's planned. Contributions are very welcome.

---

## Philosophy

Every arrow command that changes the system follows the same pattern:

1. **Show** what it's about to do, in plain language
2. **Ask** for confirmation before executing anything
3. **Report** what happened after

arrow is an assistant, not an autopilot. The user stays in control and always knows what's happening.

```
$ arrow setup gnome

  :: The following packages will be installed:
     gnome gnome-extra gdm xorg-server (and 87 dependencies)

  :: The following services will be enabled:
     gdm.service

  Proceed? [y/N]
```

---

## `arrow howto`

An interactive guide for common tasks — especially useful right after a fresh Arch install. Instead of searching the wiki, `arrow howto` walks you through step by step, shows each command before running it, and asks for confirmation at every step.

```bash
arrow howto                    # browse all available guides
arrow howto post-install       # checklist after a fresh install
arrow howto locale             # set language and keyboard layout
arrow howto timezone           # configure timezone and clock sync
arrow howto user               # create a user, set up sudo
arrow howto mirrors            # pick the fastest mirrors
arrow howto aur                # install an AUR helper
```

Each guide explains *why* — not just *what* to run.

---

## `arrow setup`

Handles configurations that typically require multiple wiki pages and manual steps. Each subcommand shows what it will do and asks before touching the system.

```bash
arrow setup gnome              # install GNOME and enable GDM
arrow setup kde                # install KDE Plasma and SDDM
arrow setup xfce               # install XFCE and LightDM
arrow setup hyprland           # install Hyprland (Wayland compositor)
arrow setup sway               # install Sway (Wayland)
arrow setup audio              # configure PipeWire + WirePlumber
arrow setup bluetooth          # install bluez, enable service
arrow setup printer            # CUPS + common drivers
arrow setup nvidia             # install drivers, configure Xorg/Wayland
arrow setup fonts              # noto, nerd fonts, CJK support
```

---

## `arrow mirrors`

Refresh the pacman mirror list using `reflector`, keeping only the fastest mirrors for your region.

```bash
arrow mirrors                  # auto-detect country and refresh
arrow mirrors --country BR     # specify country
```

---

## `arrow doctor`

A system health check that surfaces common issues and suggests fixes — each with a confirmation prompt before acting.

Checks:

- Outdated packages
- Orphaned packages
- Package cache size
- Mirror latency and freshness
- Failed systemd services
- Disk usage on key mountpoints
- Pacman lock file left over from a crash

---

## AUR without helpers *(later)*

Currently `arrow aur` delegates to `yay` or `paru`. A future version will handle AUR packages natively — cloning the `PKGBUILD`, showing a diff for review, running `makepkg`, and installing via pacman. No external AUR helper required.

---

## `add` with AUR fallback *(later)*

When `arrow add <pkg>` doesn't find a match in the official repos, it will automatically search the AUR and offer to install from there — so users don't need to know the distinction.

```
$ arrow add spotify

  :: spotify not found in official repositories.
     Found in AUR: spotify 1.2.13
     Install from AUR? [y/N]
```

---

## Ideas under consideration

- `arrow pin <pkg>` — prevent a package from being upgraded (via `IgnorePkg`)
- `arrow log <pkg>` — filter history for a specific package
- `arrow backup` — export the list of explicitly installed packages
- `arrow restore` — reinstall from a backup list
- `arrow news` — show recent Arch Linux news before upgrades

---

!!! info "Want to help?"
    Open an issue or pull request at [github.com/oporpino/arrow](https://github.com/oporpino/arrow).
    New commands follow the pattern in `src/commands/` — each module is a focused, self-contained file.
