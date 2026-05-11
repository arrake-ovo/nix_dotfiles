{ inputs, self }:

let
  fileLib = import ../file { inherit inputs self; };

  mkPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      inherit (mkNixpkgsConfig self) config overlays;
    };

  mkExtendedLib = flake: inputs.nixpkgs.lib.extend flake.lib.overlay;

  mkNixpkgsConfig = flake: {
    overlays = builtins.attrValues flake.overlays;
    config = {
      allowUnfree = true;
      allowAliases = false;
    };
  };

  mkHomeConfigs =
    {
      system,
      hostname,
    }:
    let
      allHomes = fileLib.parseHomeConfigurations ../../homes;
    in
    inputs.nixpkgs.lib.filterAttrs (
      _name: homeConfig: homeConfig.system == system && homeConfig.hostname == hostname
    ) allHomes;

  mkSpecialArgs =
    {
      system,
      hostname,
      username,
      extendedLib,
    }:
    {
      inherit
        inputs
        self
        system
        hostname
        username
        ;
      lib = extendedLib;
    };
in
{
  inherit
    mkExtendedLib
    mkHomeConfigs
    mkNixpkgsConfig
    mkPkgs
    mkSpecialArgs
    ;

  darwinModules = fileLib.importModulesRecursive ../../modules/darwin;
  homeModules = fileLib.importModulesRecursive ../../modules/home;
}
