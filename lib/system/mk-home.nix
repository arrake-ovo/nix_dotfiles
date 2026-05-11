{ inputs, self }:

{
  system,
  hostname,
  username,
  modules ? [ ],
  ...
}:

let
  common = import ./common.nix { inherit inputs self; };
  extendedLib = common.mkExtendedLib self;
  specialArgs = common.mkSpecialArgs {
    inherit
      system
      hostname
      username
      extendedLib
      ;
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = common.mkPkgs system;
  extraSpecialArgs = specialArgs;
  modules = common.homeModules ++ modules;
}
