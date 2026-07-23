{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.system.input;
in
{
  options.dot.darwin.system.input = {
    enable = mkEnableOption "macOS input settings";
  };

  config = mkIf cfg.enable {
    ###########################################################################
    #
    #  macOS keyboard & input source configuration
    #
    #  All the configuration options are documented here:
    #    https://daiderd.com/nix-darwin/manual/index.html#sec-options
    #
    ###########################################################################

    system = {
      defaults = {
        CustomUserPreferences = {
          "com.apple.HIToolbox" = {
            AppleFnUsageType = 1;
            AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.ABC";
            AppleEnabledInputSources = [
              # {
              #   InputSourceKind = "Keyboard Layout";
              #   "KeyboardLayout ID" = 12825;
              #   "KeyboardLayout Name" = "Colemak";
              # }
              #  不添加colemak布局,用karabiner映射键盘布局,因为用输入法的键盘布局,在使用一些软件的时候,底层的输入码没有变
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
        };
      };

      keyboard = {
        enableKeyMapping = true; # enable key mapping so that we can use `option` as `control`

        # NOTE: do NOT support remap capslock to both control and escape at the same time
        remapCapsLockToControl = false; # remap caps lock to control, useful for emac users
        remapCapsLockToEscape = true; # remap caps lock to escape, useful for vim users

        # swap left command and left alt
        # so it matches common keyboard layout: `ctrl | command | alt`
        #
        # disabled, caused only problems!
        swapLeftCommandAndLeftAlt = false;

        userKeyMapping = [
          # remap escape to caps lock
          # so we swap caps lock and escape, then we can use caps lock as escape
          {
            HIDKeyboardModifierMappingSrc = 30064771113;
            HIDKeyboardModifierMappingDst = 30064771129;
          }
        ];
      };
    };
  };
}
