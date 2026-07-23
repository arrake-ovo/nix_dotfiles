{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.dot.home.programs.terminal.shell.zsh;

  outOfStore = config.lib.file.mkOutOfStoreSymlink;
  cfgFile = path: outOfStore "${cfg.sourceRoot}/${path}";
  cfgDir = path: { source = outOfStore "${cfg.sourceRoot}/${path}"; recursive = true; };
  cfgExec = path: { source = outOfStore "${cfg.sourceRoot}/${path}"; executable = true; };
in
{
  options.dot.home.programs.terminal.shell.zsh = {
    enable = mkEnableOption "zsh";

    sourceRoot = mkOption {
      type = types.str;
      description = "Absolute path to the zsh configuration source directory.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bat
      fd
      fzf
      ripgrep
      tree
      zimfw
    ];

    programs.zsh = {
      enable = true;
      envExtra = ''
        export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
      '';
    };

    home.file = {
      ".zshrc".source = cfgFile ".zshrc";
      ".zshenv".source = cfgFile ".zshenv";
      ".zimrc".source = cfgFile ".zimrc";
      ".zim" = cfgDir ".zim";

      ".config/fzf" = cfgDir ".config/fzf";

      ".local/bin" = cfgExec ".local/bin";
    };
  };
}
