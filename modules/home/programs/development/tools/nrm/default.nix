{ config, lib, inputs, system, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.dot.home.programs.development.tools.nrm;

  # nrm 顶层包只在 nixpkgs-unstable（复用现有 input，与 nodejs_22 同源）
  nrm = inputs.nixpkgs-unstable.legacyPackages.${system}.nrm;
in
{
  options.dot.home.programs.development.tools.nrm.enable =
    mkEnableOption "nrm npm registry manager";

  config = mkIf cfg.enable {
    home.packages = [ nrm ];
  };
}
