{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.aldente;
in {
  options.dot.darwin.programs.graphical.apps.aldente = {
    enable = mkEnableOption "AlDente battery manager";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "aldente" ];
  };
}
