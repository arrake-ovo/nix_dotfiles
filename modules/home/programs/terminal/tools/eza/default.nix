{ config, lib, ... }:

let
  cfg = config.arrakenix.programs.terminal.tools.eza;
in
{
  options.arrakenix.programs.terminal.tools.eza.enable = lib.mkEnableOption "eza";

  config = lib.mkIf cfg.enable {
    programs.eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    home.shellAliases = {
      l = "eza -la --icons=auto";
      ll = "eza -la --git --icons=auto";
    };
  };
}
