{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.programs.inputmethods.squirrel;
  user = config.dot.darwin.user.name;
in {
  options.dot.darwin.programs.inputmethods.squirrel = {
    enable = mkEnableOption "Squirrel (鼠须管) Rime 输入法";
  };

  config = mkIf cfg.enable {
    homebrew.casks = [ "squirrel-app" ];

    # 静态配置文件放在 config/home/，镜像 $HOME，不与 default.nix 同目录。
    # mkOutOfStoreSymlink 直接软链接到项目目录：改项目文件即时生效，无需 rebuild；
    # ~/Library/Rime 整体可写，Rime 的 build/、userdb 等运行产物直接落在项目目录里。
    home-manager.users.${user} = { config, ... }: {
      home.file."Library/Rime".source =
        config.lib.file.mkOutOfStoreSymlink (lib.file.getFile "config/home/Library/Rime");
    };
  };
}
