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

    roles.developer = enabled;
  };

  home = {
    stateVersion = "25.11";
  };
}
