{ config, lib, ... }:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib) enabled;

  cfg = config.dot.darwin.suites.common;
in {
  options.dot.darwin.suites.common = {
    enable = lib.mkEnableOption "common darwin suite";
  };

  config = mkIf cfg.enable {
    dot.darwin = {
      # 系统核心（nix / sudo / homebrew / system.*）由 suites.core 提供，避免重复定义
      suites.core = mkDefault enabled;
      services.karabiner-elements = mkDefault enabled;

      programs = {
        inputmethods.squirrel = mkDefault enabled;
        inputmethods.qingjian = mkDefault enabled;
        inputmethods.ime-switch = mkDefault enabled;

        graphical.apps = {
          chrome = mkDefault enabled;
          maccy = mkDefault enabled;
          # snipaste = mkDefault enabled;
          # stats = mkDefault enabled;
          aldente = mkDefault enabled;
          obsidian = mkDefault enabled;
          zotero = mkDefault enabled;
          # Grok Bot：xAI 桌面 agent（cask 自更新，brew 只负责首次安装）
          grok-bot = mkDefault enabled;
        };

        terminal.emulators = {
          ghostty = mkDefault enabled;
        };
      };
    };
  };
}
