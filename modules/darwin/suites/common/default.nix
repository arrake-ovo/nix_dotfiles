{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkDefault mkIf;
  inherit (lib.arrakenix) enabled;

  cfg = config.arrakenix.suites.common;
in
{
  imports = [ (lib.getFile "modules/common/suites/common/default.nix") ];

  config = mkIf cfg.enable {
    programs.zsh.enable = mkDefault true;

    environment = {
      systemPackages = with pkgs; [
        gnugrep
        gnused
        terminal-notifier
      ];
    };

    arrakenix = {
      nix = mkDefault enabled;

      tools.homebrew = mkDefault enabled;

      system = {
        env = mkDefault { };
        input = mkDefault enabled;
        interface = mkDefault enabled;
      };
    };

    system.activationScripts.postActivation.text = lib.mkAfter ''
      echo >&2 "Disabling Spotlight indexing for the Nix store..."
      /usr/bin/touch /nix/store/.metadata_never_index || true

      echo >&2 "Excluding the Nix store from Time Machine backups..."
      /usr/bin/tmutil addexclusion -p /nix/store >/dev/null 2>&1 || true
    '';
  };
}
