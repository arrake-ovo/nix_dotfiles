{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.terminal.emulators.kitty;
in
{
  options.dot.home.programs.terminal.emulators.kitty = {
    enable = mkEnableOption "kitty terminal emulator";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.kitty ];
  };
}
