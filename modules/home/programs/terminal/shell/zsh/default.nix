{ config, lib, ... }:

let
  cfg = config.arrakenix.programs.terminal.shell.zsh;
in
{
  options.arrakenix.programs.terminal.shell.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 50000;
        save = 50000;
        path = "$HOME/.zsh_history";
      };

      shellAliases = {
        grep = "rg";
        lg = "lazygit";
      };

      initContent = ''
        export EDITOR="nvim"
        export VISUAL="$EDITOR"
      '';
    };
  };
}
