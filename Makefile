# ──────────────────────────────────────────────────────────────────────────────
#  arch — Makefile
#  Targets: build  install  uninstall  clean-dist
# ──────────────────────────────────────────────────────────────────────────────

# Installation prefix (override with: make install PREFIX=~/.local)
PREFIX     ?= /usr/local

BINDIR     := $(PREFIX)/bin
MANDIR     := $(PREFIX)/share/man/man1
BASH_COMP  := /usr/share/bash-completion/completions
ZSH_COMP   := /usr/share/zsh/site-functions
FISH_COMP  := /usr/share/fish/vendor_completions.d

# Source files — order matters: each file is appended in sequence
SRCS := \
	src/version.sh \
	src/colors.sh \
	src/helpers.sh \
	src/commands/packages.sh \
	src/commands/system.sh \
	src/commands/query.sh \
	src/commands/aur.sh \
	src/help.sh \
	src/main.sh

VERSION := $(shell grep -oP '(?<=VERSION=")[^"]+' src/version.sh)
DIST    := dist/arch

# ── Targets ───────────────────────────────────────────────────────────────────

.PHONY: all build install uninstall clean-dist docs docs-build

all: build

## build — concatenate source files into a single executable at dist/arch
build: $(DIST)

$(DIST): $(SRCS) | dist/
	@printf '#!/usr/bin/env bash\n'                               >  $@
	@printf '# arch v%s\n' "$(VERSION)"                          >> $@
	@printf '# %s\n'       "$(shell grep -oP '(?<=REPO=")[^"]+' src/version.sh)" >> $@
	@printf '# SPDX-License-Identifier: MIT\n\n'                 >> $@
	@for f in $(SRCS); do                     \
	    sed '/^[[:space:]]*#/d; /^$$/d' "$$f" >> $@; \
	    printf '\n'                            >> $@; \
	done
	@chmod +x $@
	@printf '  Built  %s\n' "$@"

dist/:
	@mkdir -p $@

## install — install binary, man page, and shell completions (may require sudo)
install: build
	install -Dm755 $(DIST)                   $(DESTDIR)$(BINDIR)/arch
	install -Dm644 man/arch.1                $(DESTDIR)$(MANDIR)/arch.1
	install -Dm644 completions/arch.bash     $(DESTDIR)$(BASH_COMP)/arch
	install -Dm644 completions/_arch         $(DESTDIR)$(ZSH_COMP)/_arch
	install -Dm644 completions/arch.fish     $(DESTDIR)$(FISH_COMP)/arch.fish
	@printf '  Installed arch to %s\n' "$(DESTDIR)$(BINDIR)"

## uninstall — remove all installed files
uninstall:
	rm -f $(DESTDIR)$(BINDIR)/arch
	rm -f $(DESTDIR)$(MANDIR)/arch.1
	rm -f $(DESTDIR)$(BASH_COMP)/arch
	rm -f $(DESTDIR)$(ZSH_COMP)/_arch
	rm -f $(DESTDIR)$(FISH_COMP)/arch.fish
	@printf '  Uninstalled arch\n'

## clean-dist — remove the dist/ directory
clean-dist:
	rm -rf dist/

## docs — serve the documentation site locally (requires Docker)
docs:
	docker run --rm -it -p 8000:8000 -v "$$(pwd):/docs" squidfunk/mkdocs-material

## docs-build — build the static site into site/ (requires Docker)
docs-build:
	docker run --rm -v "$$(pwd):/docs" squidfunk/mkdocs-material build

# ── Help ──────────────────────────────────────────────────────────────────────

help:
	@printf '\nUsage: make [target]\n\n'
	@grep -E '^## ' Makefile | sed 's/^## /  /'
	@printf '\n'
