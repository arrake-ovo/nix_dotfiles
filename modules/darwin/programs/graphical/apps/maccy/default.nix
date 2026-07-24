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

    # 偏好从 system.interface 收拢到本模块；与当前本机常用设置对齐
    system.defaults.CustomUserPreferences."org.p0deje.Maccy" = {
      SUAutomaticallyUpdate = false;
      SUEnableAutomaticChecks = false;
      SUHasLaunchedBefore = true;

      searchMode = "fuzzy";
      previewDelay = 150;
      maxMenuItemLength = 25;
      menuIcon = "clipboard";
      pasteByDefault = true;
      showInStatusBar = false;
      showSearch = true;
      showTitle = true;
      showFooter = true;
      pinTo = "top";
    };
  };
}
