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
  matchingHomes = common.mkHomeConfigs { inherit system hostname; };
  specialArgs = common.mkSpecialArgs {
    inherit
      system
      hostname
      username
      extendedLib
      ;
  };
in
inputs.nix-darwin.lib.darwinSystem {
  inherit system;

  inherit specialArgs;

  modules =
    [
      {
        nixpkgs = {
          hostPlatform = system;
        }
        // common.mkNixpkgsConfig self;
      }

      inputs.home-manager.darwinModules.home-manager

      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = specialArgs;
          sharedModules = common.homeModules;
          users = inputs.nixpkgs.lib.mapAttrs' (_name: homeConfig: {
            name = homeConfig.username;
            value = {
              imports = [ homeConfig.path ];
              home = {
                inherit (homeConfig) username;
                homeDirectory = inputs.nixpkgs.lib.mkDefault "/Users/${homeConfig.username}";
              };
            };
          }) matchingHomes;
        };
      }
    ]
    ++ common.darwinModules
    ++ [
      ../../systems/${system}/${hostname}
    ]
    ++ modules;
}
