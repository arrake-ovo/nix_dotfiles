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
  link = file: outOfStore "${cfg.sourceRoot}/${file}";
  linkExec = file: {
    source = outOfStore "${cfg.sourceRoot}/${file}";
    executable = true;
  };
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
      ".zshrc".source = link ".zshrc";
      ".zshenv".source = link "zsh/.zshenv";
      ".zimrc".source = link ".zimrc";
      ".zim".source = link "zsh/.zim";

      ".config/fzf" = {
        source = link "fzf";
        recursive = true;
      };

      ".local/bin" = {
        source = link "zsh/sh";
        executable = true;
      };

      ".local/bin/fzf-preview.sh" = linkExec "fzf/bin/fzf-preview.sh";
    };
  };
}
