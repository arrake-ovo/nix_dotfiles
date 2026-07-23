{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types mkIf;
  inherit (lib) mkOpt;

  cfg = config.dot.darwin.user;
in
{
  options.dot.darwin.user = {
    name = mkOpt types.str "arrake" "The user account.";
    email = mkOpt types.str "" "The email of the user.";
    fullName = mkOpt types.str "" "The full name of the user.";
    uid = mkOpt (types.nullOr types.int) 501 "The uid for the user account.";
  };

  config = {
    users.users.${cfg.name} = {
      uid = lib.mkIf (cfg.uid != null) cfg.uid;
      shell = pkgs.zsh;
      home = "/Users/${cfg.name}";
    };

    nix.settings.trusted-users = [ cfg.name ];
  };
}
