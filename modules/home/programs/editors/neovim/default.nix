{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.editors.neovim;

  # 直接软链接到项目原文件（mkOutOfStoreSymlink），修改项目文件即时生效
  outOfStore = config.lib.file.mkOutOfStoreSymlink;
in
{
  options.dot.home.programs.editors.neovim = {
    enable = mkEnableOption "neovim editor";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.neovim ];

    # 整个 ~/.config/nvim 软链接到项目目录（LazyVim 配置 + 插件声明）。
    # 运行时数据（lazy 插件、codecompanion 等）在 stdpath("data")，不在配置目录。
    home.file.".config/nvim".source =
      outOfStore "${config.dot.home.programs.terminal.shell.zsh.sourceRoot}/.config/nvim";
  };
}
