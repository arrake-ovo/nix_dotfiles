{ lib, username, ... }:

let
  inherit (lib) enabled;
in
{
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  dot.home.programs.terminal.shell.zsh = {
    enable = true;
    sourceRoot = lib.file.getFile "config";
  };
}
