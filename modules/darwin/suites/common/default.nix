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
        inputmethods.ime-switch = mkDefault enabled;

        graphical.apps = {
          # AeroSpace：macOS 专属平铺窗口管理器（cask 安装 + config/home 软链接）
          aerospace = mkDefault enabled;

          chrome = mkDefault enabled;
          alt-tab = mkDefault enabled;
          # keyclu = mkDefault enabled;
          maccy = mkDefault enabled;
          # snipaste = mkDefault enabled;
          # raycast = mkDefault enabled;
          # orion = mkDefault enabled;
          # stats = mkDefault enabled;
          aldente = mkDefault enabled;
          obsidian = mkDefault enabled;
          zotero = mkDefault enabled;
          # Grok Bot：xAI 桌面 agent（cask 自更新，brew 只负责首次安装）
          grok-bot = mkDefault enabled;
        };

        terminal.emulators = {
          ghostty = mkDefault enabled;
          wezterm = mkDefault enabled;
          rio = mkDefault enabled;
        };
      };
    };
  };
}
