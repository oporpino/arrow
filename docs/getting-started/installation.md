---
title: Installation
description: How to install arch, the intuitive pacman wrapper, on Arch Linux and Arch-based systems.
---

# Installation

## Requirements

- Arch Linux or an Arch-based distribution (Manjaro, EndeavourOS, Garuda, etc.)
- `pacman` must be installed (it is on every Arch system by default)
- `curl`, `tar`, and `make` — installed automatically if missing

## One-liner

The fastest way to install the latest release:

```bash
curl -fsSL https://raw.githubusercontent.com/oporpino/arch/main/install.sh | bash
```

This will:

1. Detect your system and verify pacman is available
2. Install any missing build dependencies via pacman
3. Download the source code
4. Build a single self-contained binary
5. Install the binary, shell completions, and the man page

## Install a specific version

Pin to a release tag with the `ARCH_VERSION` variable:

```bash
curl -fsSL https://raw.githubusercontent.com/oporpino/arch/main/install.sh \
  | ARCH_VERSION=v1.0.0 bash
```

Find all available versions on the [releases page](https://github.com/oporpino/arch/releases).

## Custom install prefix

Install without `sudo` by specifying a custom `PREFIX`:

```bash
curl -fsSL https://raw.githubusercontent.com/oporpino/arch/main/install.sh \
  | PREFIX=~/.local bash
```

Then make sure `~/.local/bin` is in your `$PATH`:

```bash
# add to ~/.bashrc, ~/.zshrc, or ~/.config/fish/config.fish
export PATH="$PATH:$HOME/.local/bin"
```

## From source

```bash
git clone https://github.com/oporpino/arch
cd arch
make build          # produces dist/arch
sudo make install   # installs to /usr/local
```

Available make targets:

| Target | Description |
|---|---|
| `make build` | Compile sources into `dist/arch` |
| `make install` | Install binary, completions, and man page |
| `make uninstall` | Remove all installed files |
| `make clean-dist` | Delete the `dist/` directory |

## Uninstall

```bash
sudo make uninstall
```

Or with a custom prefix:

```bash
make uninstall PREFIX=~/.local
```
