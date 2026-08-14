{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.dot.home.programs.terminal.tools.gh;
in
{
  options.dot.home.programs.terminal.tools.gh = {
    enable = mkEnableOption "GitHub CLI";
  };

  config = mkIf cfg.enable {
    programs.gh.enable = true;
  };
}
