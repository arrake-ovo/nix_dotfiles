{
  config,
  lib,
  ...
}:

let
  inherit (lib) types mkOption mkIf mkEnableOption;

  cfg = config.dot.darwin.system.env;
in
{
  options.dot.darwin.system.env = {
    enable = mkEnableOption "system environment variables";

    variables = mkOption {
      type = with types; attrsOf (oneOf [ str path (listOf (either str path)) ]);
      default = { };
      description = "Environment variables to set system-wide.";
    };
  };

  config = mkIf cfg.enable {
    environment.variables = {
      EDITOR = "nvim";
      } // cfg.variables;
  };
}
