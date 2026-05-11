{ config, lib, ... }:

let
  cfg = config.arrakenix.programs.terminal.tools.fzf;
in
{
  options.arrakenix.programs.terminal.tools.fzf.enable = lib.mkEnableOption "fzf";

  config = lib.mkIf cfg.enable {
    programs.fzf.enable = true;
  };
}
