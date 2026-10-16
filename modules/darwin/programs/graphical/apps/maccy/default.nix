{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.programs.graphical.apps.maccy;
in
{
  options.dot.darwin.programs.graphical.apps.maccy = {
    enable = mkEnableOption "Maccy clipboard manager";
  };

  config = mkIf cfg.enable {
    homebrew.casks = [ "maccy" ];

    # 登录时后台启动（menu bar app，-g 不抢焦点）
    launchd.user.agents.maccy = {
      serviceConfig = {
        ProgramArguments = [
          "/usr/bin/open"
          "-g"
          "-a"
          "Maccy"
        ];
        RunAtLoad = true;
      };
    };

    # Maccy 偏好原本用 system.defaults.CustomUserPreferences 写在 sudo 下会失败：
    # "Could not write domain /Users/arrake/Library/Containers/org.p0deje.Maccy/.../org.p0deje.Maccy"
    # （沙盒 app 容器路径 ~/Library/Containers/<bundle>/Data/Library/Preferences/<plist>，
    #   容器由 arrake 拥有，root 写不进）。
    # 临时方案：注释掉，darwin-rebuild 激活就能过；偏好改成在 Maccy app 里手动设（一次性）。
    # TODO 长期方案：挪到 home-manager 层的 home.activation（用户身份 defaults write）。
    #
    # system.defaults.CustomUserPreferences."org.p0deje.Maccy" = {
    #   SUAutomaticallyUpdate = false;
    #   SUEnableAutomaticChecks = false;
    #   SUHasLaunchedBefore = true;
    #
    #   searchMode = "fuzzy";
    #   previewDelay = 150;
    #   maxMenuItemLength = 25;
    #   menuIcon = "clipboard";
    #   pasteByDefault = true;
    #   showInStatusBar = false;
    #   showSearch = true;
    #   showTitle = true;
    #   showFooter = true;
    #   pinTo = "top";
    # };
  };
}
