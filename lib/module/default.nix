{ inputs }:

let
  inherit (inputs.nixpkgs) lib;
  inherit (lib)
    mkDefault
    mkForce
    mkOption
    toUpper
    types
    ;
in
{
  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };

  mkOpt' = type: default: mkOption { inherit type default; };

  mkBoolOpt = default: description: mkOption {
    type = types.bool;
    inherit default description;
  };

  mkBoolOpt' = default: mkOption {
    type = types.bool;
    inherit default;
  };

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

  capitalize =
    s:
    let
      len = lib.stringLength s;
    in
    if len == 0 then "" else (toUpper (lib.substring 0 1 s)) + (lib.substring 1 len s);

  boolToNum = bool: if bool then 1 else 0;

  default-attrs = lib.mapAttrs (_key: mkDefault);
  force-attrs = lib.mapAttrs (_key: mkForce);
  nested-default-attrs = lib.mapAttrs (_key: lib.mapAttrs (_nestedKey: mkDefault));
  nested-force-attrs = lib.mapAttrs (_key: lib.mapAttrs (_nestedKey: mkForce));
}
