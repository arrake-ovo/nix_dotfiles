{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption optionals;

  cfg = config.dot.darwin.system.input;
  qingjianEnabled = config.dot.darwin.programs.inputmethods.qingjian.enable;
in {
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
            # 0=无。系统 Globe/Fn 行为改由 Karabiner 单击切换输入法处理，
            # 避免与听写抢键，也不依赖注销后才生效的 AppleFnUsageType。
            AppleFnUsageType = 0;
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
              # 鼠须管必须同时写 Keyboard Input Method 和 Input Mode。
              # 只写 Input Mode 时，TIS 会在 activateSettings 后把整项丢掉。
              {
                "Bundle ID" = "im.rime.inputmethod.Squirrel";
                InputSourceKind = "Keyboard Input Method";
              }
              {
                "Bundle ID" = "im.rime.inputmethod.Squirrel";
                "Input Mode" = "im.rime.inputmethod.Squirrel.Hans";
                InputSourceKind = "Input Mode";
              }
            ] ++ optionals qingjianEnabled [
              # 青简是 Keyboard Input Method Without Modes，只写 Bundle，不要 Input Mode。
              {
                "Bundle ID" = "app.qingjian.inputmethod";
                InputSourceKind = "Keyboard Input Method";
              }
            ];
            AppleSelectedInputSources = [{
              "Bundle ID" = "im.rime.inputmethod.Squirrel";
              "Input Mode" = "im.rime.inputmethod.Squirrel.Hans";
              InputSourceKind = "Input Mode";
            }];
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
