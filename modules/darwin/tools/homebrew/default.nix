{ config, lib, ... }:

let
  cfg = config.arrakenix.tools.homebrew;
in
{
  options.arrakenix.tools.homebrew = {
    enable = lib.mkEnableOption "Homebrew integration";
    masEnable = lib.mkEnableOption "Mac App Store CLI integration";
    cleanup = lib.mkOption {
      type = lib.types.enum [
        "none"
        "uninstall"
        "zap"
      ];
      default = "none";
      description = "How nix-darwin should clean Homebrew packages not declared in this flake.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.variables = {
      HOMEBREW_BAT = "1";
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_NO_INSECURE_REDIRECT = "1";
    };
    environment.systemPath = [ "${config.homebrew.prefix}/bin" ];

    homebrew = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      global = {
        brewfile = true;
        autoUpdate = false;
      };

      onActivation = {
        autoUpdate = false;
        cleanup = cfg.cleanup;
        upgrade = false;
      };
    };
  };
}
