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

    # Karabiner 仅运行在 macOS；用户映射与 cask 安装放在同一 Darwin 模块。
    home-manager.users.${user}.xdg.configFile."karabiner/karabiner.json".source =
      ./karabiner.json;
  };
}
