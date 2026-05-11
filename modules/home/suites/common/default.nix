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
  options.arrakenix.suites.common.enable = lib.mkEnableOption "common Home Manager configuration";

  config = mkIf cfg.enable {
    home = {
      file.".hushlogin".text = "";

      packages = with pkgs; [
        ncdu
        nix-du
        pngpaste
        tree
      ];

      sessionVariables = {
        LESSHISTFILE = "${config.xdg.cacheHome}/less.history";
        WGETRC = "${config.xdg.configHome}/wgetrc";
      };

      shellAliases = {
        nixcfg = "nvim ${config.home.homeDirectory}/nix/nix_dotfiles/flake.nix";
        ncs-darwin = ''f(){ nix build ".#darwinConfigurations.$1.config.system.build.toplevel" --no-link && nix path-info --recursive --closure-size --human-readable $(nix eval --raw ".#darwinConfigurations.$1.config.system.build.toplevel.outPath") | tail -1; }; f'';
        ncs-home = ''f(){ nix build ".#homeConfigurations.$1.activationPackage" --no-link && nix path-info --recursive --closure-size --human-readable $(nix eval --raw ".#homeConfigurations.$1.activationPackage.outPath") | tail -1; }; f'';
      };
    };

    arrakenix.programs.terminal = {
      shell.zsh = mkDefault enabled;
      tools = {
        direnv = mkDefault enabled;
        eza = mkDefault enabled;
        fzf = mkDefault enabled;
        git = mkDefault enabled;
        jq = mkDefault enabled;
        lazygit = mkDefault enabled;
        ripgrep = mkDefault enabled;
        zoxide = mkDefault enabled;
      };
    };

    programs.readline = {
      enable = mkDefault true;
      extraConfig = ''
        set completion-ignore-case on
      '';
    };

    xdg.configFile.wgetrc.text = "";
  };
}
