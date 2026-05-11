# nix_dotfiles

Personal nix-darwin and Home Manager configuration for `arrake@mba`.

The structure follows the khanelinix architecture pattern at a smaller scale:
custom options live under `arrakenix.*`, host configs in `systems/` and user
configs in `homes/` are discovered automatically, and suites/roles enable groups
of focused modules.

## Commands

```console
nix flake check
darwin-rebuild build --flake .#mba
darwin-rebuild switch --flake .#mba
```

This repository intentionally starts small: it manages the macOS host, Homebrew
application inventory, and basic Home Manager shell/git/development tools.
Existing application dotfiles under `~/.config` are left in place for now.
