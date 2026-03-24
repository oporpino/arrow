---
title: Commands Overview
description: Full reference of all arch commands — the intuitive pacman wrapper.
---

# Commands

A full reference of every `arch` command and its pacman equivalent.

## Packages

| Command | Description | pacman |
|---|---|---|
| [`add`](packages.md#add) | Install packages | `-S` |
| [`del`](packages.md#del) | Remove packages | `-Rns` |
| [`search`](packages.md#search) | Search repositories | `-Ss` |
| [`info`](packages.md#info) | Package details | `-Si` / `-Qi` |
| [`files`](packages.md#files) | List owned files | `-Ql` |
| [`own`](packages.md#own) | Find owner of a file | `-Qo` |
| [`deps`](packages.md#deps) | Dependency tree | `pactree` |

## System

| Command | Description | pacman |
|---|---|---|
| [`update`](system.md#update) | Sync databases | `-Sy` |
| [`upgrade`](system.md#upgrade) | Upgrade system | `-Syu` |
| [`clean`](system.md#clean) | Clean package cache | `-Sc` / `-Scc` |
| [`orphans`](system.md#orphans) | List orphaned packages | `-Qdtq` |
| [`purge`](system.md#purge) | Remove all orphans | `-Rns $(…)` |

## Query

| Command | Description |
|---|---|
| [`list`](query.md#list) | List installed packages |
| [`history`](query.md#history) | Show pacman log entries |

## AUR

| Command | Description |
|---|---|
| [`aur add`](aur.md#aur-add) | Install from AUR |
| [`aur search`](aur.md#aur-search) | Search the AUR |
| [`aur upgrade`](aur.md#aur-upgrade) | Upgrade AUR packages |
