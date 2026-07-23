{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.terminal.tools.git;
in
{
  options.dot.home.programs.terminal.tools.git = {
    enable = mkEnableOption "git version control";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
    };
  };
}
