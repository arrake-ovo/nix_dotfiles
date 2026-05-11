{ config, lib, ... }:

let
  cfg = config.arrakenix.programs.terminal.tools.zoxide;
in
{
  options.arrakenix.programs.terminal.tools.zoxide.enable = lib.mkEnableOption "zoxide";

  config = lib.mkIf cfg.enable {
    programs.zoxide.enable = true;
  };
}
