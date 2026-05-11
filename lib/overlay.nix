{ inputs, self }:

_final: _prev:
let
  fileLib = import ./file { inherit inputs self; };
  moduleLib = import ./module { inherit inputs; };
in
{
  arrakenix = moduleLib;

  file = fileLib;

  inherit (fileLib)
    getFile
    getNixFiles
    importModulesRecursive
    listDirectories
    mergeAttrs
    ;

  inherit (moduleLib)
    boolToNum
    capitalize
    default-attrs
    disabled
    enabled
    force-attrs
    mkBoolOpt
    mkBoolOpt'
    mkOpt
    mkOpt'
    nested-default-attrs
    nested-force-attrs
    ;

  inherit (inputs.home-manager.lib) hm;
}
