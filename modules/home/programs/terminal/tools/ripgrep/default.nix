{ config, lib, pkgs, ... }:

let
  cfg = config.arrakenix.programs.terminal.tools.ripgrep;
in
{
  options.arrakenix.programs.terminal.tools.ripgrep.enable = lib.mkEnableOption "ripgrep/fd";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fd
      ripgrep
    ];
  };
}
