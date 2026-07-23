{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.programs.inputmethods.squirrel;
in
{
  options.dot.darwin.programs.inputmethods.squirrel = {
    enable = mkEnableOption "Squirrel (鼠须管) Rime 输入法";
  };

  config = mkIf cfg.enable {
    homebrew.casks = [ "squirrel-app" ];
  };
}
