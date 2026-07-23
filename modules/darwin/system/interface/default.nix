{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.system.interface;
in
{
  options.dot.darwin.system.interface = {
    enable = mkEnableOption "macOS interface settings";
  };

  config = mkIf cfg.enable {
    system.defaults = {
      menuExtraClock.Show24Hour = true;

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 1.0;
        mineffect = "scale";
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "bottom";
        show-process-indicators = true;
        show-recents = false;
        showhidden = false;
        tilesize = 50;
        wvous-tl-corner = 2; # Mission Control
        wvous-bl-corner = 4; # Desktop
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = false;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
      };

      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = false;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Automatic";
        NSAutomaticWindowAnimationsEnabled = false;
      };

      screencapture = {
        disable-shadow = true;
        location = "/Users/${config.dot.darwin.user.name}/Pictures/screenshots";
        type = "png";
      };

      CustomUserPreferences = {
        "org.p0deje.Maccy" = {
          SUAutomaticallyUpdate = 0;
          SUEnableAutomaticChecks = 0;
          SUHasLaunchedBefore = 1;

          searchMode = "fuzzy";
          previewDelay = 150;
          maxMenuItemLength = 25;
          menuIcon = "clipboard";
        };

        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          AutomaticDownload = 1;
          CriticalUpdateInstall = 1;
          ScheduleFrequency = 1;
        };
      };

      CustomSystemPreferences = {
        finder = {
          DisableAllAnimations = true;
          FXEnableExtensionChangeWarning = false;
          ShowExternalHardDrivesOnDesktop = false;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = false;
          ShowRemovableMediaOnDesktop = false;
        };
      };
    };
  };
}
