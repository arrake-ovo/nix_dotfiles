{ config, lib, ... }:

let
  cfg = config.arrakenix.system.env;
in
{
  options.arrakenix.system.env = lib.mkOption {
    apply = lib.mapAttrs (
      _name: value: if lib.isList value then lib.concatMapStringsSep ":" toString value else toString value
    );
    default = { };
    description = "Environment variables to expose through nix-darwin.";
    type =
      with lib.types;
      attrsOf (oneOf [
        str
        path
        (listOf (either str path))
      ]);
  };

  config.environment = {
    extraInit = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: ''
        export ${name}="${value}"
      '') cfg
    );

    variables = {
      PAGER = "less -FR";
      LESS = "--RAW-CONTROL-CHARS --wheel-lines=5 --LONG-PROMPT --no-vbell --wordwrap";
    };
  };
}
