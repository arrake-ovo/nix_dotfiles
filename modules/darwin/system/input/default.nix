{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkMerge mkEnableOption;

  cfg = config.dot.darwin.system.input;
in
{
  options.dot.darwin.system.input = {
    enable = mkEnableOption "macOS input settings";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      system = {
        defaults = {
          trackpad = {
            ActuationStrength = 0;
            Clicking = true;
            FirstClickThreshold = 1;
            SecondClickThreshold = 1;
            TrackpadRightClick = true;
            TrackpadThreeFingerDrag = true;
          };

          ".GlobalPreferences" = {
            "com.apple.mouse.scaling" = 1.0;
          };

          NSGlobalDomain = {
            AppleKeyboardUIMode = 3;
            ApplePressAndHoldEnabled = false;
            KeyRepeat = 1;
            InitialKeyRepeat = 10;
            NSAutomaticCapitalizationEnabled = false;
            NSAutomaticDashSubstitutionEnabled = false;
            NSAutomaticPeriodSubstitutionEnabled = false;
            NSAutomaticQuoteSubstitutionEnabled = false;
            NSAutomaticSpellingCorrectionEnabled = false;
          };
        };

        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToEscape = true;
          swapLeftCommandAndLeftAlt = false;
        };
      };

      system.defaults.CustomUserPreferences."com.apple.HIToolbox" = {
        AppleFnUsageType = 1;
        AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.ABC";
        AppleEnabledInputSources = [
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 252;
            "KeyboardLayout Name" = "ABC";
          }
          {
            "Bundle ID" = "im.rime.inputmethod.Squirrel";
            "Input Mode" = "im.rime.inputmethod.Squirrel.Hans";
            InputSourceKind = "Input Mode";
          }
        ];
        AppleSelectedInputSources = {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 252;
          "KeyboardLayout Name" = "ABC";
        };
      };
    }
  ]);
}
