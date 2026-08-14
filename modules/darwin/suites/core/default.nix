{ config, lib, ... }:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib) enabled;

  cfg = config.dot.darwin.suites.core;
in
{
  options.dot.darwin.suites.core = {
    enable = lib.mkEnableOption "core darwin system suite";
  };

  config = mkIf cfg.enable {
    # nix-darwin 默认生成 /etc/zshrc 并全局 compinit（enableGlobalCompInit=true）；
    # 用户 zsh 由 zim 管理（home 层），zim 的 completion 模块自己调 compinit，
    # 这里关闭全局初始化避免重复（否则每次进 zsh 都有 warning）。
    programs.zsh.enableGlobalCompInit = mkDefault false;

    dot.darwin = {
      nix = mkDefault enabled;
      security.sudo = mkDefault enabled;
      tools.homebrew = mkDefault enabled;

      system = {
        env = mkDefault enabled;
        fonts = mkDefault enabled;
        input = mkDefault enabled;
        interface = mkDefault enabled;
      };
      programs.inputmethods.squirrel = mkDefault enabled;
    };
  };
}
