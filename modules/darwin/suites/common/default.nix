{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib) enabled;

  cfg = config.dot.darwin.suites.common;
in
{
  options.dot.darwin.suites.common = {
    enable = lib.mkEnableOption "common darwin suite";
  };

  config = mkIf cfg.enable {
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
    };
  };
}
