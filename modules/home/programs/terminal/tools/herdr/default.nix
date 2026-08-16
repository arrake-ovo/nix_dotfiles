{ config, lib, pkgs, inputs, system, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.terminal.tools.herdr;

  # herdr 只在 nixpkgs-unstable（复用现有 input，与 nodejs_22 同源）
  herdr = inputs.nixpkgs-unstable.legacyPackages.${system}.herdr;

  outOfStore = config.lib.file.mkOutOfStoreSymlink;
in
{
  options.dot.home.programs.terminal.tools.herdr = {
    enable = mkEnableOption "herdr agent multiplexer";
  };

  config = mkIf cfg.enable {
    home.packages = [ herdr ];

    home.file.".config/herdr/config.toml".source =
      outOfStore "${config.dot.home.programs.terminal.shell.zsh.sourceRoot}/.config/herdr/config.toml";

    # 开机自启 headless server：agent 常驻，重启后会话恢复。
    # 用户主动 `herdr server stop` 正常退出时不重启；异常崩溃时才由 launchd 拉起。
    launchd.agents.herdr = {
      enable = true;
      config = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          ''
            # 重启后 nix store 可能尚未挂载，先等它就绪再 exec
            /bin/wait4path /nix/store || exit 1
            # herdr 异常退出时 socket 会残留，导致下次启动误判 "already running"；
            # 若 socket 存在但无进程监听，先清理再启动
            SOCK="$HOME/.config/herdr/herdr.sock"
            if [ -S "$SOCK" ] && ! /usr/sbin/lsof "$SOCK" >/dev/null 2>&1; then
              rm -f "$SOCK"
            fi
            exec ${lib.getExe herdr} server
          ''
        ];
        RunAtLoad = true;
        KeepAlive = {
          SuccessfulExit = false;
        };
        ProcessType = "Background";
        # launchd 不继承用户 shell 的 locale（ghostty 里是 en_US.UTF-8），
        # 导致 herdr pane 里 git 等命令落到系统 zh_CN 输出中文；显式设为英文。
        EnvironmentVariables = {
          LANG = "en_US.UTF-8";
        };
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/herdr/server.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/herdr/server.log";
      };
    };
  };
}
