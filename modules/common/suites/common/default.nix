{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.arrakenix.suites.common;
in
{
  options.arrakenix.suites.common.enable = lib.mkEnableOption "common system packages";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      coreutils
      curl
      fd
      file
      findutils
      git
      jq
      lsof
      ripgrep
      tree
      unzip
      wget
      yq
    ];
  };
}
