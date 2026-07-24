{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.programs.inputmethods.squirrel;
in
{
  options.dot.darwin.programs.inputmethods.squirrel = {
    enable = mkEnableOption "Squirrel (鼠须管) Rime 输入法";
  };

  config = mkIf cfg.enable {
    homebrew.casks = [ "squirrel-app" ];

    # Rime 配置 —— 从独立 git 仓库按需拉取
    # 固定 rev 确保纯函数求值和缓存
    home-manager.users.${config.dot.darwin.user.name}.home.file."Library/Rime" = {
      source = builtins.fetchGit {
        url = "https://github.com/arrake0101/rime.git";
        rev = "c05ddd1136b4ec29cc6d34280efc8ba3aba91ec5";
      };
      recursive = true;
    };
  };
}
