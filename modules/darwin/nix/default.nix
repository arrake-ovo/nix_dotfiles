{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.nix;
in
{
  options.dot.darwin.nix = {
    enable = mkEnableOption "Nix daemon settings";
  };

  config = mkIf cfg.enable {
    nix = {
      enable = false; # false when using Determinate Nix

      package = config.nixpkgs.nix;

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        substituters = [
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        builders-use-substitutes = true;
        auto-optimise-store = false;
      };
    };
  };
}
