---
title: Shell Completion
description: How to enable tab completion for arch in bash, zsh, and fish.
---

# Shell Completion

`arch` ships with completion scripts for **bash**, **zsh**, and **fish**.
They are installed automatically by `make install`.

## What gets completed

- **Top-level commands** (`add`, `del`, `search`, `upgrade`, …)
- **Installed package names** for commands that need them (`del`, `info`, `files`, `deps`)
- **`aur` subcommands** (`add`, `search`, `upgrade`)
- **`clean` option** (`--all`)
- **File paths** for `own`

## bash

The completion file is installed to `/usr/share/bash-completion/completions/arch`.

If it doesn't activate immediately, reload your shell or source it manually:

```bash
source /usr/share/bash-completion/completions/arch
```

Ensure `bash-completion` is installed:

```bash
arrow add bash-completion
```

## zsh

The completion file (`_arch`) is installed to `/usr/share/zsh/site-functions/`.

Add the following to your `~/.zshrc` if completions don't activate automatically:

```zsh
autoload -Uz compinit && compinit
```

Make sure `/usr/share/zsh/site-functions` is in your `$fpath` (it is by default on Arch).

## fish

The completion file is installed to `/usr/share/fish/vendor_completions.d/arch.fish`.

fish sources completions automatically — no configuration needed. Start a new shell session and press <kbd>Tab</kbd> after `arch`.

## Manual activation

If you installed to a custom `PREFIX`, completions land in `$PREFIX/share/…`. Point your shell to them:

=== "bash"

    ```bash
    # add to ~/.bashrc
    source "$PREFIX/share/bash-completion/completions/arch"
    ```

=== "zsh"

    ```zsh
    # add to ~/.zshrc, before compinit
    fpath=("$PREFIX/share/zsh/site-functions" $fpath)
    autoload -Uz compinit && compinit
    ```

=== "fish"

    ```fish
    # fish respects XDG_DATA_DIRS
    set -gx XDG_DATA_DIRS "$PREFIX/share" $XDG_DATA_DIRS
    ```
