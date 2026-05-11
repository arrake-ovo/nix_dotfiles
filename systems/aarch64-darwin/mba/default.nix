{ lib, ... }:

let
  inherit (lib.arrakenix) enabled;
in
{
  arrakenix = {
    user = {
      name = "arrake";
      email = "arrake@163.com";
      fullName = "arrake";
      uid = 501;
    };

    suites.common = enabled;

    tools.homebrew = {
      enable = true;
      cleanup = "none";
      masEnable = true;
    };
  };

  networking = {
    computerName = "mba";
    hostName = "mba";
    localHostName = "mba";
  };

  system.stateVersion = 6;

  homebrew = {
    taps = [
      "farion1231/ccswitch"
      "homebrew/cask"
      "homebrew/core"
    ];

    brews = [
      "mas"
    ];

    casks = [
      "aldente"
      "alt-tab"
      "font-hack-nerd-font"
      "ghostty"
      "google-chrome"
      "karabiner-elements"
      "keyclu"
      "maccy"
      "obsidian"
      "orion"
      "raycast"
      "rio"
      "sf-symbols"
      "snipaste"
      "squirrel-app"
      "stats"
      "trae"
      "wezterm"
    ];
  };
}
