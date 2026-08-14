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

    # Rime 配置是独立仓库（submodule：arrake-ovo/rime-config），可选加载：
    # 本模块只在 macOS（darwin）构建时存在，Linux 构建完全不涉及；
    # mac 上使用前需 git submodule update --init config/home/Library/Rime。
    # 注：纯求值下 nix 无法检查真实路径存在性，未 init 时软链接指向空目录，
    # 但 Rime 会自行重建基础配置，不影响启动。

    # 静态配置文件放在 config/home/，镜像 $HOME，不与 default.nix 同目录。
    # mkOutOfStoreSymlink 直接软链接到项目目录：改项目文件即时生效，无需 rebuild；
    # ~/Library/Rime 整体可写，Rime 的 build/、userdb 等运行产物直接落在项目目录里。
    home-manager.users.${user} = { config, ... }: {
      home.file."Library/Rime".source =
        config.lib.file.mkOutOfStoreSymlink (lib.file.getFile "config/home/Library/Rime");
    };
  };
}
