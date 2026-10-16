{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption mkAfter;

  cfg = config.dot.darwin.programs.inputmethods.squirrel;
  user = config.dot.darwin.user.name;
  squirrelApp = "/Library/Input Methods/Squirrel.app";
  squirrelBin = "${squirrelApp}/Contents/MacOS/Squirrel";
  squirrelHans = "im.rime.inputmethod.Squirrel.Hans";
  squirrelSharedSupport = "${squirrelApp}/Contents/SharedSupport";
  enableTis = pkgs.writeScript "squirrel-enable-tis" (builtins.readFile ./enable-tis.py);

  squirrelInputMethod = {
    "Bundle ID" = "im.rime.inputmethod.Squirrel";
    InputSourceKind = "Keyboard Input Method";
  };
  squirrelHansMode = {
    "Bundle ID" = "im.rime.inputmethod.Squirrel";
    "Input Mode" = squirrelHans;
    InputSourceKind = "Input Mode";
  };
in {
  options.dot.darwin.programs.inputmethods.squirrel = {
    enable = mkEnableOption "Squirrel (鼠须管) Rime 输入法";
  };

  config = mkIf cfg.enable {
    homebrew.casks = [ "squirrel-app" ];

    # macOS 27 的第三方输入法开关在这个 domain；只写 HIToolbox 时
    # Input Mode 会从已启用列表里掉出去，菜单栏只剩表情/虚拟键盘。
    system.defaults.CustomUserPreferences."com.apple.inputsources" = {
      AppleEnabledThirdPartyInputSources = [
        squirrelInputMethod
        squirrelHansMode
      ] ++ lib.optionals config.dot.darwin.programs.inputmethods.qingjian.enable [{
        "Bundle ID" = "app.qingjian.inputmethod";
        InputSourceKind = "Keyboard Input Method";
      }];
    };

    # squirrel-app 的 pkg 会在 SharedSupport 里写出 build/、installation.yaml，
    # 破坏 Developer ID 签名。macOS 27 拒绝拉起 IMK：TIS 显示已启用，
    # 选中后进程立刻退出，菜单栏只剩键盘图标。
    system.activationScripts.extraActivation.text = mkAfter ''
      ss=${lib.escapeShellArg squirrelSharedSupport}
      if [ -d "$ss" ]; then
        rm -rf "$ss/build"
        rm -f "$ss/installation.yaml" "$ss/user.yaml"
      fi
    '';

    # TIS 注册必须在用户 Aqua 会话里做。darwin-rebuild 的 extraActivation
    # 没有 WindowServer（会报 no display），所以改成用户 LaunchAgent。
    # Squirrel CLI 的 --enable 会误报 already enabled，必须对全量 TIS
    # 列表里的 Input Mode 调 TISEnableInputSource。
    launchd.user.agents.squirrel-enable-input-source = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          ''
            s=${lib.escapeShellArg squirrelBin}
            [ -x "$s" ] || exit 0
            "$s" --register-input-source
            ${enableTis}
            killall TextInputMenuAgent >/dev/null 2>&1 || true
          ''
        ];
        RunAtLoad = true;
      };
    };

    # rebuild 后重新 kickstart，避免只在登录时跑一次、activateSettings 后又丢掉。
    system.activationScripts.postActivation.text = mkAfter ''
      uid=$(id -u ${lib.escapeShellArg user})
      launchctl kickstart -k "gui/$uid/org.nixos.squirrel-enable-input-source" || true
    '';

    # Rime 配置是独立仓库（submodule：arrake-ovo/rime-config），可选加载：
    # 本模块只在 macOS（darwin）构建时存在，Linux 构建完全不涉及；
    # mac 上使用前需 git submodule update --init config/home/Library/Rime。
    # 注：纯求值下 nix 无法检查真实路径存在性，未 init 时软链接指向空目录，
    # 但 Rime 会自行重建基础配置，不影响启动。

    # 静态配置文件放在 config/home/，镜像 $HOME，不与 default.nix 同目录。
    # mkOutOfStoreSymlink 直接软链接到项目目录：改项目文件即时生效，无需 rebuild；
    # ~/Library/Rime 整体可写，Rime 的 build/、userdb 等运行产物直接落在项目目录里。
    home-manager.users.${user} = { config, ... }: {
      home.file."Library/Rime".source =
        config.lib.file.mkOutOfStoreSymlink (lib.file.getFile "config/home/Library/Rime");
    };
  };
}
