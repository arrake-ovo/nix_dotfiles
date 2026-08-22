{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.dot.home.programs.terminal.tools.adb;
in {
  options.dot.home.programs.terminal.tools.adb = {
    enable = mkEnableOption "adb（Android platform-tools：adb/fastboot 等）";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.android-tools ];
  };
}
