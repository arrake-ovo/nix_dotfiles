{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.system.fonts;
in
{
  options.dot.darwin.system.fonts = {
    enable = mkEnableOption "system fonts";
  };

  config = mkIf cfg.enable {
    fonts.packages = with pkgs; [
      sketchybar-app-font
      font-awesome
    ];

    system.defaults.NSGlobalDomain.AppleFontSmoothing = 1;
  };
}
