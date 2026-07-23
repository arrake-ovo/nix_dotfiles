{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.home.programs.apps.squirrel;
  sourceRoot = config.dot.home.programs.terminal.shell.zsh.sourceRoot;
  outOfStore = config.lib.file.mkOutOfStoreSymlink;
in
{
  options.dot.home.programs.apps.squirrel = {
    enable = mkEnableOption "Squirrel (鼠须管) Rime 输入法";
  };

  config = mkIf cfg.enable {
    # Rime 配置目录 —— 递归链接，只读配置文件
    # 运行时文件（user.yaml、build/、userdb/）由 Rime 在 ~/Library/Rime/ 自行创建
    home.file."Library/Rime" = {
      source = outOfStore "${sourceRoot}/Library/Rime";
      recursive = true;
    };
  };
}
