{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.tools.homebrew;
in
{
  options.dot.darwin.tools.homebrew = {
    enable = mkEnableOption "Homebrew package management";
  };

  config = mkIf cfg.enable {
    environment.variables = {
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_NO_INSECURE_REDIRECT = "1";
    };

    homebrew = {
      enable = true;

      global = {
        brewfile = true;
        autoUpdate = false;
      };

      onActivation = {
        autoUpdate = false;
        cleanup = "zap";
      };

      brews = [
        "mas"
      ];

      casks = [
        "google-chrome"
        "karabiner-elements"
        "alt-tab"
        "KeyClu"
        "maccy"
        "Snipaste"
        "raycast"
        "orion"
        "stats"
        "aldente"
        "ghostty"
        "wezterm"
        "rio"
        "obsidian"
        "font-hack-nerd-font"
        "sf-symbols"
      ];

      masApps = { };
    };
  };
}
