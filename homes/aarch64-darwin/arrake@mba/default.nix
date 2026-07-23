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

  dot.home = {
    roles.developer = enabled;

    programs.terminal.shell.zsh.sourceRoot = lib.file.getFile "config/home";
  };
}
