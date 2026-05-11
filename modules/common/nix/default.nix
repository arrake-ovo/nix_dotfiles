{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:

let
  inherit (lib.arrakenix) mkBoolOpt mkOpt;
  cfg = config.arrakenix.nix;
in
{
  options.arrakenix.nix = {
    enable = mkBoolOpt true "Whether to manage shared Nix configuration.";
    package = mkOpt lib.types.package pkgs.nix "The Nix package to use when nix-darwin manages Nix.";
  };

  config = lib.mkIf cfg.enable {
    documentation = {
      doc.enable = false;
      info.enable = false;
      man.enable = lib.mkDefault true;
    };

    environment.etc = {
      "nix/flake-channels/system".source = self;
      "nix/flake-channels/nixpkgs".source = inputs.nixpkgs;
      "nix/flake-channels/home-manager".source = inputs.home-manager;
    };

    environment.systemPackages = with pkgs; [
      git
      nix-prefetch-git
    ];

    nix = {
      package = cfg.package;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "@admin"
          config.arrakenix.user.name
        ];
      };
    };
  };
}
