# Changelog

## 2026-10-16

- Update KDE shortcuts: disable Meta+Arrow quick tiling and make Meta+Up maximize the window

- Update kitty keybinds: ctrl+shift+enter no longer opens a split and now toggles a maximized (stack layout) window; ctrl+shift+l layout cycling disabled
- Fix wezterm font config: use font_with_fallback with JetBrains Mono NL, Symbols Nerd Font Mono and emoji fallbacks so glyphs are found
- Update wezterm to scale Nerd Font glyphs by 1.2 to match kitty and ghostty sizing

## 2026-10-14

- Remove Omarchy from the hypr config: restore the standalone custom config (keybinds, animations, decoration, macchiato colors) so it no longer needs /usr/share/omarchy

## 2026-10-13

- Update hypr config to omarchy defaults (omarchy keybindings loaded from the omarchy package), replacing the old custom hypr config, and stow it
- Add smooth slide animation when switching workspaces to hypr looknfeel.lua
- Fix hypr package by removing the unused wlp_* wallpapers
- Fix nvim-treesitter config for the main branch API (replaces removed nvim-treesitter.configs)

## 2026-10-11

- Add omnis.sh to list per-repo change counts for git repos in ~ and push them
- Update omnis.sh to also list repos with unpushed commits
- Update omnis.sh into a TUI that scans the whole machine, shows added/changed/deleted files per repo, and pushes marked or all repos with confirmation
- Add pull, fetch and push-access detection (can push / read-only / local) to omnis.sh, with a table layout and OMNIS ASCII logo header
- Update omnis.sh to show only pending repos by default
- Update omnis.sh to probe push access only for pending repos, probing the rest when switching to all repos
- Add powerlevel10k prompt config (.p10k.zsh) to the zshrc package
- Fix powerlevel10k theme source path to be absolute via $HOME
- Add Ctrl+L keybind to lock the screen with noctalia
- Fix lock keybind to use SUPER+L with noctalia instead of Ctrl+L and hyprlock
- Fix anyrun showing unicode symbols as results by disabling the symbols plugin
- Fix double password prompt at login by removing hyprlock autostart

## 2026-10-10

- Update fastfetch config to a minimal grouped layout with icons and dividers
- Add random pokemon-colorscripts sprite as fastfetch logo
- Update ff alias to call plain fastfetch
