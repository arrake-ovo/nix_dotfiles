{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.obsidian;
in {
  options.dot.darwin.programs.graphical.apps.obsidian = {
    enable = mkEnableOption "Obsidian note-taking app";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "obsidian" ];
  };
}
