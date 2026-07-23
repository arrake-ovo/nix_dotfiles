{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.terminal.tools.starship;
in
{
  options.dot.home.programs.terminal.tools.starship = {
    enable = mkEnableOption "starship prompt";
  };

  config = mkIf cfg.enable {
    programs.starship.enable = true;
  };
}
