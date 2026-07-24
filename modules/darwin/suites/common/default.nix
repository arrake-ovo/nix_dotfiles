{ config, lib, ... }:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib) enabled;

  cfg = config.dot.darwin.suites.common;
in
{
  options.dot.darwin.suites.common = {
    enable = lib.mkEnableOption "common darwin suite";
  };

  config = mkIf cfg.enable {
    dot.darwin = {
      nix = mkDefault enabled;
      security.sudo = mkDefault enabled;

      tools.homebrew = mkDefault enabled;

      programs = {
        inputmethods.squirrel = mkDefault enabled;

        graphical.apps = {
          chrome = mkDefault enabled;
          alt-tab = mkDefault enabled;
          keyclu = mkDefault enabled;
          maccy = mkDefault enabled;
          snipaste = mkDefault enabled;
          raycast = mkDefault enabled;
          orion = mkDefault enabled;
          stats = mkDefault enabled;
          aldente = mkDefault enabled;
          obsidian = mkDefault enabled;
        };

        terminal.emulators = {
          ghostty = mkDefault enabled;
          wezterm = mkDefault enabled;
          rio = mkDefault enabled;
        };
      };

      services.karabiner-elements = mkDefault enabled;

      system = {
        env = mkDefault enabled;
        fonts = mkDefault enabled;
        input = mkDefault enabled;
        interface = mkDefault enabled;
      };
    };
  };
}
