{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkDefault mkIf;
  inherit (lib.arrakenix) enabled;

  cfg = config.arrakenix.suites.development;
in
{
  options.arrakenix.suites.development = {
    enable = lib.mkEnableOption "development configuration";
    aiEnable = lib.mkEnableOption "AI development tools";
    nixEnable = lib.mkEnableOption "Nix development tools";
  };

  config = mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        [
          gh
          jqp
          onefetch
          tree-sitter
        ]
        ++ lib.optionals cfg.nixEnable [
          deadnix
          hydra-check
          nil
          nix-diff
          nix-fast-build
          nix-index
          nix-output-monitor
          nix-update
          nixfmt
          nixpkgs-review
          statix
          nurl
        ]
        ++ lib.optionals cfg.aiEnable [
          github-copilot-cli
        ];

      shellAliases = {
        prefetch-sri = "nix store prefetch-file $1";
        nrd = ''nixpkgs-review pr $1 --systems "aarch64-darwin"'';
        nrh = "nixpkgs-review rev HEAD";
      };
    };

    arrakenix.programs.terminal.tools = {
      gh = mkDefault enabled;
      lazygit = mkDefault enabled;
    };
  };
}
