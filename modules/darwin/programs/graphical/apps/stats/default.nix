{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.stats;
in {
  options.dot.darwin.programs.graphical.apps.stats = {
    enable = mkEnableOption "Stats system monitor";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "stats" ];
  };
}
