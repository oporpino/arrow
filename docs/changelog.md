---
title: Changelog
description: Version history of arch, the intuitive pacman wrapper.
---

# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [v1.0.0] — 2025

### Added

- Commands: `add`, `del`, `search`, `info`, `files`, `own`, `deps`
- System commands: `update`, `upgrade`, `clean`, `orphans`, `purge`
- Query commands: `list`, `history`
- AUR subcommand: `aur add`, `aur search`, `aur upgrade` (delegates to yay/paru)
- Shell completion for **bash**, **zsh**, and **fish**
- Man page (`man arrow`)
- `install.sh` one-liner with version pinning (`ARROW_VERSION=vx.x.x`)
- `Makefile` with `build`, `install`, `uninstall`, `clean-dist` targets
- Colour-aware output (ANSI codes disabled when stdout is not a TTY)
- Command aliases: `rm`/`remove`, `find`/`s`, `up`, `ls`, `log`

[v1.0.0]: https://github.com/oporpino/arrow/releases/tag/v1.0.0
