{ config, lib, ... }:

let
  inherit (lib.arrakenix) enabled;
  cfg = config.arrakenix.roles.developer;
in
{
  options.arrakenix.roles.developer.enable = lib.mkEnableOption "developer role";

  config = lib.mkIf cfg.enable {
    arrakenix.suites = {
      common = enabled;
      development = {
        enable = true;
        aiEnable = false;
        nixEnable = true;
      };
    };
  };
}
