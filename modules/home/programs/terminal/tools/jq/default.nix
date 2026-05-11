{ config, lib, pkgs, ... }:

let
  cfg = config.arrakenix.programs.terminal.tools.jq;
in
{
  options.arrakenix.programs.terminal.tools.jq.enable = lib.mkEnableOption "jq/yq";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      jq
      yq
    ];
  };
}
