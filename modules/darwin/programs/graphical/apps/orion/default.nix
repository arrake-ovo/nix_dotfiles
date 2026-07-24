{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.orion;
in {
  options.dot.darwin.programs.graphical.apps.orion = {
    enable = mkEnableOption "Orion browser";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "orion" ];
  };
}
