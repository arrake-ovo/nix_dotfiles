{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.terminal.emulators.rio;
in {
  options.dot.darwin.programs.terminal.emulators.rio = {
    enable = mkEnableOption "Rio terminal emulator";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "rio" ];
  };
}
