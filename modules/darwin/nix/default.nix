{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.nix;
in {
  options.dot.darwin.nix = { enable = mkEnableOption "Nix daemon settings"; };

  config = mkIf cfg.enable {
    # Determinate Nix 环境：nix-daemon 由 determinate-nixd 托管，
    # nix-darwin 生成的 /etc/nix/nix.conf 会被 Determinate Nix 用 !include 整体覆盖。
    # 因此 nix.settings 在这里不生效（此前声明的 substituters/trusted-public-keys
    # 均未进入运行时），已统一收编到用户级 ~/.config/nix/nix.conf
    # （见 modules/home/programs/development/tools/nix/default.nix）。
    nix = {
      enable = false; # false when using Determinate Nix
    };
  };
}
