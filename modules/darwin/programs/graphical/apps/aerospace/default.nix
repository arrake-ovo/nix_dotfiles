{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.programs.graphical.apps.aerospace;
  user = config.dot.darwin.user.name;
in
{
  options.dot.darwin.programs.graphical.apps.aerospace = {
    enable = mkEnableOption "AeroSpace tiling window manager";
  };

  config = mkIf cfg.enable {
    # 安装走 nixpkgs 包（与 khanelinix、home-manager 官方模块一致）。
    # 注意：AeroSpace 的 cask 只在第三方 tap nikitabobko/tap，不在 homebrew-cask，
    # 所以不用 homebrew.casks，直接用 pkgs.aerospace 更简单、可复现。
    home-manager.users.${user} = { config, ... }: {
      home.packages = [ pkgs.aerospace ];

      # 原生配置文件放 config/home/，镜像 $HOME；symlink 直接指向项目文件，
      # 改 aerospace.toml 即时生效。自启动由配置里的 start-at-login = true 负责。
      xdg.configFile."aerospace/aerospace.toml".source =
        config.lib.file.mkOutOfStoreSymlink (lib.file.getFile "config/home/.config/aerospace/aerospace.toml");
    };
  };
}
