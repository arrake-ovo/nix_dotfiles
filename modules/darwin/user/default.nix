{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  inherit (lib) mkIf types;
  inherit (lib.arrakenix) mkOpt;

  cfg = config.arrakenix.user;
in
{
  options.arrakenix.user = {
    name = mkOpt types.str username "The user account.";
    email = mkOpt types.str "arrake@163.com" "The user's email address.";
    fullName = mkOpt types.str "arrake" "The user's full name.";
    uid = mkOpt (types.nullOr types.int) 501 "The uid for the user account.";
  };

  config = {
    users.users.${cfg.name} = {
      uid = mkIf (cfg.uid != null) cfg.uid;
      shell = pkgs.zsh;
      home = "/Users/${cfg.name}";
    };

    system.primaryUser = cfg.name;
  };
}
