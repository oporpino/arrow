# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**arrow** is a CLI wrapper for Arch Linux's `pacman` package manager written in pure Bash. It provides human-readable commands (`arrow add firefox` instead of `pacman -S firefox`) while maintaining complete transparency—there's no hidden logic, database, or state management. Every command translates directly to pacman operations.

The project is distributed as a single self-contained executable built by concatenating multiple source files in a specific order.

## Development Commands

### Building

```bash
make build              # Concatenate src/ files into dist/arrow
bash -n dist/arrow      # Syntax check the built binary
```

The build process:
1. Creates `dist/arrow` from sources in the order defined in the Makefile
2. Strips comments and blank lines from each source file
3. Adds shebang, version, and license headers
4. Makes the result executable

**Important**: The order of source files in the Makefile matters—each file is appended sequentially.

### Installation

```bash
sudo make install                    # Install to /usr/local
make install PREFIX=~/.local         # Install to custom prefix (no sudo needed)
sudo make uninstall                  # Remove all installed files
```

Installs:
- Binary at `$(PREFIX)/bin/arrow`
- Symlink `arw` → `arrow`
- Man page at `$(PREFIX)/share/man/man1/arrow.1`
- Shell completions for bash, zsh, and fish

### Documentation

```bash
make docs              # Serve docs site locally on http://localhost:8000 (requires Docker)
make docs-build        # Build static site into site/ (requires Docker)
```

Uses MkDocs Material via Docker. Source files are in `docs/`, config in `mkdocs.yml`.

### Cleaning

```bash
make clean-dist        # Remove dist/ directory
```

## Architecture

### Build System

Arrow uses a concatenation-based build system rather than sourcing multiple files at runtime:

1. **Source files** (`src/`) contain modular shell functions
2. **Makefile** concatenates them in a specific order into `dist/arrow`
3. **Single binary** is self-contained with no external dependencies beyond pacman

**Source file order** (defined in Makefile):
```
src/version.sh          # VERSION and REPO constants
src/colors.sh           # ANSI color definitions
src/helpers.sh          # Output functions and utilities
src/commands/packages.sh # add, delete, search, info, files, own, deps
src/commands/system.sh   # update, upgrade, clean, orphans, purge
src/commands/query.sh    # list, history
src/commands/aur.sh      # aur subcommand
src/commands/self.sh     # self update functionality
src/commands/howto.sh    # howto guides
src/help.sh             # help and version output
src/main.sh             # main() dispatcher and entry point
```

### Core Utilities

**`src/helpers.sh`** provides the foundation for all commands:

- **Output functions**: `_info()`, `_ok()`, `_warn()`, `_err()`, `_die()`
- **Formatting**: `_section()`, `_step()`, `_cmd()`, `_preview()`
- **User interaction**: `_ask()` (confirmation prompts)
- **Execution**: `_run()` (display command, execute, report success/failure)
- **Privilege escalation**: `_asroot()` (detects and uses sudo/doas, or runs directly as root)
- **Guards**: `_require_not_root()`, `_need_pkg()`
- **Utilities**: `_aur_helper()` (finds yay or paru), `_pacman()` (wrapper for non-interactive pacman)

### Command Structure

**`src/main.sh`** is the entry point:
- Defines `main()` function with a case statement routing to command functions
- Each command has a corresponding `cmd_*()` function defined in `src/commands/*.sh`
- Supports aliases (e.g., `delete`/`del`/`rm`/`remove`)

Command implementation pattern:
```bash
cmd_example() {
  # 1. Validate arguments
  [[ $# -eq 0 ]] && _die "Uso: arrow example <args>"

  # 2. Preview what will happen (optional)
  _preview "Description" "pacman command"

  # 3. Ask for confirmation (optional)
  _ask "Proceed?" || { _warn "Cancelled."; return; }

  # 4. Execute
  _run _asroot pacman --flags "$@"
}
```

### Privilege Escalation (`_asroot`)

The `_asroot()` function handles running commands as root:
- If already root (`$EUID -eq 0`): runs command directly
- Else if `sudo` exists: uses `sudo`
- Else if `doas` exists: uses `doas`
- Else: dies with helpful error message

**Never use `sudo` directly in commands**—always use `_asroot` to support systems with doas or running as root.

### Display vs Execution (`_run`)

The `_run()` function resolves `_asroot` for display purposes:
- Shows user-friendly command (replaces `_asroot` with actual tool or nothing if root)
- Executes the command as-is
- Reports success (✔) or failure (✘)

Example:
```bash
_run _asroot pacman -S firefox
# Displays: $ sudo pacman -S firefox  (if using sudo)
# Executes: _asroot pacman -S firefox (which calls sudo pacman -S firefox)
# Reports: ✔ Concluído.
```

### Shell Completions

Completions are context-aware:
- `arrow.bash` (bash completion in `/usr/share/bash-completion/completions/`)
- `_arrow` (zsh completion in `/usr/share/zsh/site-functions/`)
- `arrow.fish` (fish completion in `/usr/share/fish/vendor_completions.d/`)

Commands like `delete`, `info`, `files` complete against installed packages. The `aur` command completes its subcommands.

## Code Conventions

### Language and Localization

- User-facing messages are in Portuguese (e.g., "Uso:", "Concluído.", "Cancelado.")
- Code comments are in English
- Command names and flags are English

### Shell Best Practices

- Always quote variables: `"$@"`, `"$var"`
- Use `[[ ]]` instead of `[ ]` for conditionals
- Prefer `command -v` over `which`
- Use `local` for function variables
- Check command existence: `command -v tool &>/dev/null`
- Use `readonly` for constants (see `src/version.sh`)

### Output Conventions

- Use helper functions (`_info`, `_ok`, `_warn`, `_err`) for consistent formatting
- Preview commands before executing when they modify the system
- Show what pacman command will run (`_preview` or `_cmd`)
- Ask for confirmation on destructive operations (`_ask`)
- Report completion status (`_run` or `_ok`/`_err`)

### Testing Before Committing

Always run syntax check before submitting changes:
```bash
bash -n dist/arrow
```

## Adding New Commands

1. Add the command function to the appropriate file in `src/commands/`
2. Add the command to the case statement in `src/main.sh`
3. Add completions to all three shell completion files
4. Update `src/help.sh` with the new command
5. Update the man page `man/arrow.1`
6. Add documentation in `docs/commands/`

## Version Updates

Version is defined in `src/version.sh`:
```bash
readonly VERSION="1.0.0"
readonly REPO="oporpino/arrow"
```

The Makefile extracts this during build and embeds it in the output binary header.

## Contributing Guidelines (from README)

1. Fork the repo and create your branch from `main`
2. Keep source files in `src/` — the Makefile concatenates them
3. Run `bash -n dist/arrow` to check syntax before opening a PR
4. For new commands, add completions in all three shells (bash, zsh, fish)
