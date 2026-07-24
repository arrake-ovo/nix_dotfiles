{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.terminal.emulators.wezterm;
in {
  options.dot.darwin.programs.terminal.emulators.wezterm = {
    enable = mkEnableOption "WezTerm terminal emulator";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "wezterm" ];
  };
}
