{
  hostname,
  lib,
  ...
}:

let
  inherit (lib) types;
  inherit (lib.arrakenix) mkOpt;
in
{
  options.arrakenix.host.name = mkOpt (types.nullOr types.str) hostname "The host name.";
}
