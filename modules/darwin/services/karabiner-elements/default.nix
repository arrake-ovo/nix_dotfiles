{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.services.karabiner-elements;
  user = config.dot.darwin.user.name;
in
{
  options.dot.darwin.services.karabiner-elements = {
    enable = mkEnableOption "Karabiner-Elements keyboard customizer";
  };

  config = mkIf cfg.enable {
    homebrew.casks = [ "karabiner-elements" ];

    # Karabiner 仅运行在 macOS；安装与部署同属 Darwin 模块。
    # 静态配置文件放在 config/home/，不与 default.nix 同目录。
    # mkOutOfStoreSymlink 直接软链接到项目文件：改 karabiner.json 即时生效，无需 rebuild。
    home-manager.users.${user} = { config, ... }: {
      xdg.configFile."karabiner/karabiner.json".source =
        config.lib.file.mkOutOfStoreSymlink (lib.file.getFile "config/home/.config/karabiner/karabiner.json");
    };
  };
}
