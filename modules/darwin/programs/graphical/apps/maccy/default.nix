{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.maccy;
in {
  options.dot.darwin.programs.graphical.apps.maccy = {
    enable = mkEnableOption "Maccy clipboard manager";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "maccy" ];
  };
}
