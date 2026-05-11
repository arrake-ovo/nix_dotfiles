{ config, lib, pkgs, ... }:

let
  cfg = config.arrakenix.programs.terminal.tools.lazygit;
in
{
  options.arrakenix.programs.terminal.tools.lazygit.enable = lib.mkEnableOption "lazygit";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.lazygit ];
    home.shellAliases.lg = "lazygit";
  };
}
