{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.alt-tab;
in {
  options.dot.darwin.programs.graphical.apps.alt-tab = {
    enable = mkEnableOption "AltTab window switcher";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "alt-tab" ];
  };
}
