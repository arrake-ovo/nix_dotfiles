{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.apps.aerospace;
in
{
  options.dot.home.programs.apps.aerospace = {
    enable = mkEnableOption "aerospace window manager";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.aerospace ];
  };
}
