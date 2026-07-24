{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.raycast;
in {
  options.dot.darwin.programs.graphical.apps.raycast = {
    enable = mkEnableOption "Raycast launcher";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "raycast" ];
  };
}
