{ config, lib, ... }:

let
  cfg = config.arrakenix.programs.terminal.tools.direnv;
in
{
  options.arrakenix.programs.terminal.tools.direnv.enable = lib.mkEnableOption "direnv";

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
