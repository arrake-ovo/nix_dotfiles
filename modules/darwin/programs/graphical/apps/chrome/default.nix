{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.chrome;
in {
  options.dot.darwin.programs.graphical.apps.chrome = {
    enable = mkEnableOption "Google Chrome";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "google-chrome" ];
  };
}
