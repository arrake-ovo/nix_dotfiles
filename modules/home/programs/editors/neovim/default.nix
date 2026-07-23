{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.editors.neovim;
in
{
  options.dot.home.programs.editors.neovim = {
    enable = mkEnableOption "neovim editor";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.neovim ];
  };
}
