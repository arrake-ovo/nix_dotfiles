{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib) enabled;

  cfg = config.dot.home.roles.developer;
in
{
  options.dot.home.roles.developer = {
    enable = lib.mkEnableOption "developer role";
  };

  config = mkIf cfg.enable {
    dot.home.suites.common = enabled;
  };
}
