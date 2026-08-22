{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.dot.home.programs.terminal.tools.scrcpy;
in {
  options.dot.home.programs.terminal.tools.scrcpy = {
    enable = mkEnableOption "scrcpy（Android 投屏与控制，依赖 adb）";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.scrcpy ];
  };
}
