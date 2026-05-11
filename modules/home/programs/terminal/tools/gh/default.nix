{ config, lib, ... }:

let
  cfg = config.arrakenix.programs.terminal.tools.gh;
in
{
  options.arrakenix.programs.terminal.tools.gh.enable = lib.mkEnableOption "GitHub CLI";

  config = lib.mkIf cfg.enable {
    programs.gh.enable = true;
  };
}
