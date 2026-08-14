{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.dot.home.programs.development.languages.fnm;
in
{
  options.dot.home.programs.development.languages.fnm.enable =
    mkEnableOption "fnm fast node manager";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.fnm ];
  };
}
