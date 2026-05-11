{ config, lib, ... }:

let
  cfg = config.arrakenix.programs.terminal.tools.git;
  user = config.arrakenix.user;
in
{
  options.arrakenix.programs.terminal.tools.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = user.fullName;
          email = user.email;
        };
        init.defaultBranch = "main";
        pull.rebase = false;
        safe.directory = "*";
      };
    };
  };
}
