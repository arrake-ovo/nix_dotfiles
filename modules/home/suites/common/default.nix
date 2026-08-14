{ config, lib, ... }:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib) enabled;

  cfg = config.dot.home.suites.common;
in
{
  options.dot.home.suites.common = {
    enable = lib.mkEnableOption "common home suite";
  };

  config = mkIf cfg.enable {
    dot.home.programs = {
      terminal = {
        shell.zsh = {
          # 注意：这里 enable 是 bool option，不能直接用 enabled（其值为 attrset）
          enable = mkDefault true;
          # config/home 镜像 $HOME，作为所有 home 配置的直接软链接根
          sourceRoot = mkDefault (lib.file.getFile "config/home");
        };

        tools = {
          git = mkDefault enabled;
          gh = mkDefault enabled;
          herdr = mkDefault enabled;
          opencli = mkDefault enabled;
          starship = mkDefault enabled;
          yazi = mkDefault enabled;
          zellij = mkDefault enabled;
        };
      };

      editors.neovim = mkDefault enabled;
    };
  };
}
