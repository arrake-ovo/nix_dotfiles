{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.graphical.apps.grok-bot;
in {
  options.dot.darwin.programs.graphical.apps.grok-bot = {
    enable = mkEnableOption "Grok Bot desktop app";
  };
  config = mkIf cfg.enable {
    # cask 声明 auto_updates: true：brew 只负责首次安装落地，
    # 后续版本由应用内更新器自管理，无版本漂移维护负担。
    homebrew.casks = [ "grok-bot" ];
  };
}
