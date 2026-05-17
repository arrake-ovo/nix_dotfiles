{ lib, ... }:

let
  inherit (lib.arrakenix) enabled;
in
{
  arrakenix = {
    user = {
      enable = true;
      name = "arrake";
      email = "arrake@163.com";
      fullName = "arrake";
    };

    programs = {
      legacyMinimal = enabled;
      terminal.shell.zsh.enable = false;
    };
  };

  home = {
    stateVersion = "25.05";
  };
}
