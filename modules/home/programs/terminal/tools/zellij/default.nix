{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.terminal.tools.zellij;

  outOfStore = config.lib.file.mkOutOfStoreSymlink;
in
{
  options.dot.home.programs.terminal.tools.zellij = {
    enable = mkEnableOption "zellij terminal multiplexer";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.zellij ];

    home.file.".config/zellij/config.kdl".source =
      outOfStore "${config.dot.home.programs.terminal.shell.zsh.sourceRoot}/.config/zellij/config.kdl";
  };
}
