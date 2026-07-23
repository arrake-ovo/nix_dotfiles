{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.editors.helix;

  sourceRoot = config.dot.home.programs.terminal.shell.zsh.sourceRoot;
  outOfStore = config.lib.file.mkOutOfStoreSymlink;
in
{
  options.dot.home.programs.editors.helix = {
    enable = mkEnableOption "helix editor";
  };

  config = mkIf cfg.enable {
    programs.helix.enable = true;

    xdg.configFile."helix/config.toml".source =
      outOfStore "${sourceRoot}/.config/helix/config.toml";
  };
}
