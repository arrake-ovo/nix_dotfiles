{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.tools.homebrew;
in {
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
        # This first minimal configuration must not remove existing apps.
        cleanup = "none";
      };

      # mas：Mac App Store 命令行（nix-darwin 的 masApps 依赖此命令）。
      # 其余 CLI 工具走 nixpkgs/home-manager，这里不重复声明。
      brews = [ "mas" ];

      casks = [ ];

      masApps = { };
    };
  };
}
