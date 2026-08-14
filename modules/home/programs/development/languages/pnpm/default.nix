{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.dot.home.programs.development.languages.pnpm;
in
{
  options.dot.home.programs.development.languages.pnpm.enable =
    mkEnableOption "pnpm package manager";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.pnpm ];
  };
}
