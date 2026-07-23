{ inputs, config, lib, ... }:

let
  inherit (lib) enabled;
in
{
  dot.darwin = {
    nix.enable = true;
    security.sudo.enable = true;
    suites.common.enable = true;
    tools.homebrew.enable = true;
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = "arrake";
    taps = with inputs; {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = true;
  };

  networking = {
    hostName = "mba";
    computerName = "mba";
    localHostName = "mba";
  };

  system = {
    primaryUser = "arrake";
    stateVersion = 6;
  };
}
