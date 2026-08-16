{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.zotero;
in {
  options.dot.darwin.programs.graphical.apps.zotero = {
    enable = mkEnableOption "Zotero reference manager";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "zotero" ];
  };
}
