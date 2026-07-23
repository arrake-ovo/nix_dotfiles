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
    #  macOS 键盘和输入法配置
    #
    #  配置项文档: https://daiderd.com/nix-darwin/manual/index.html#sec-options
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
        enableKeyMapping = true; # 启用键盘映射

        # 注意：不能同时把 capslock 映射成 control 和 escape
        remapCapsLockToControl = false; # 把 capslock 映射成 control，emacs 用户常用
        remapCapsLockToEscape = true; # 把 capslock 映射成 escape，vim 用户常用

        # 交换左 command 和左 alt
        # 让键盘布局变成: `ctrl | command | alt`
        #
        # 已禁用，只会引起问题！
        swapLeftCommandAndLeftAlt = false;

        userKeyMapping = [
          # 把 escape 映射到 capslock
          # 交换 caps lock 和 escape 之后，就能用 caps lock 当 escape 用了
          {
            HIDKeyboardModifierMappingSrc = 30064771113;
            HIDKeyboardModifierMappingDst = 30064771129;
          }
        ];
      };
    };
  };
}
