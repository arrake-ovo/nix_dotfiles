{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.terminal.emulators.ghostty;
in {
  options.dot.darwin.programs.terminal.emulators.ghostty = {
    enable = mkEnableOption "Ghostty terminal emulator";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "ghostty" ];
  };
}
