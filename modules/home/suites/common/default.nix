{ config, lib, ... }:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib) enabled;

  cfg = config.dot.home.suites.common;
in
{
  options.dot.home.suites.common = {
    enable = lib.mkEnableOption "common home suite";
  };

  config = mkIf cfg.enable {
    dot.home.programs = {
      terminal = {
        shell.zsh = mkDefault enabled;
        emulators.kitty = mkDefault enabled;
        tools = {
          git = mkDefault enabled;
          starship = mkDefault enabled;
          yazi = mkDefault enabled;
          zellij = mkDefault enabled;
        };
      };
      editors = {
        helix = mkDefault enabled;
        neovim = mkDefault enabled;
      };
      apps.aerospace = mkDefault enabled;
    };
  };
}
