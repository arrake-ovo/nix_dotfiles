{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.keyclu;
in {
  options.dot.darwin.programs.graphical.apps.keyclu = {
    enable = mkEnableOption "KeyClu keyboard shortcut viewer";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "KeyClu" ];
  };
}
