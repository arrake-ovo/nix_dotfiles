{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.security.sudo;
in
{
  options.dot.darwin.security.sudo = {
    enable = mkEnableOption "sudo configuration with Touch ID";
  };

  config = mkIf cfg.enable {
    security = {
      pam.services.sudo_local = {
        reattach = true;
        touchIdAuth = true;
      };
      sudo.extraConfig = "Defaults    timestamp_timeout=30";
    };
  };
}
