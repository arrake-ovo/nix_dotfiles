{ config, lib, ... }:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib) enabled;

  cfg = config.dot.home.suites.android;
in {
  options.dot.home.suites.android = {
    enable = lib.mkEnableOption "android suite（adb + scrcpy）";
  };

  config = mkIf cfg.enable {
    dot.home.programs.terminal.tools = {
      adb = mkDefault enabled;
      scrcpy = mkDefault enabled;
    };
  };
}
