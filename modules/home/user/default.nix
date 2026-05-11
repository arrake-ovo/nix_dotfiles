{
  config,
  lib,
  pkgs,
  username ? null,
  ...
}:

let
  inherit (lib) mkDefault mkIf mkMerge types;
  inherit (lib.arrakenix) enabled mkOpt;

  cfg = config.arrakenix.user;
  homeDirectory =
    if cfg.name == null then
      null
    else if pkgs.stdenv.hostPlatform.isDarwin then
      "/Users/${cfg.name}"
    else
      "/home/${cfg.name}";
in
{
  options.arrakenix.user = {
    enable = mkOpt types.bool false "Whether to configure the Home Manager user.";
    email = mkOpt types.str "arrake@163.com" "The user's email address.";
    fullName = mkOpt types.str "arrake" "The user's full name.";
    home = mkOpt (types.nullOr types.str) homeDirectory "The user's home directory.";
    name = mkOpt (types.nullOr types.str) username "The user account.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "arrakenix.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "arrakenix.user.home must be set";
        }
      ];

      home = {
        username = mkDefault cfg.name;
        homeDirectory = mkDefault cfg.home;
        preferXdgDirectories = true;

        shellAliases = {
          bloat = "nix path-info -Sh /run/current-system";
          curgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
          flake = "nix flake";
          nix = "nix -vL";
          cleanup = "sudo nix-collect-garbage --delete-older-than 3d && nix-collect-garbage -d";
          repair = "nix-store --verify --check-contents --repair";
          ".." = "cd ..";
          "..." = "cd ../..";
          home = "cd ~";
          pls = "sudo";
          myip = "curl ifconfig.me";
        };
      };

      programs.home-manager = enabled;
    }
  ]);
}
