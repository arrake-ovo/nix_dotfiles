{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.snipaste;
in {
  options.dot.darwin.programs.graphical.apps.snipaste = {
    enable = mkEnableOption "Snipaste screenshot tool";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "Snipaste" ];
  };
}
