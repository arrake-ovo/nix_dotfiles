{
  inputs,
  self,
  lib,
  ...
}:

let
  inherit (self.lib.file) parseHomeConfigurations;

  homesPath = ../homes;
  allHomes = parseHomeConfigurations homesPath;

  generateHomeConfiguration =
    _name:
    args@{
      system,
      username,
      userAtHost,
      hostname,
      ...
    }:
    {
      name = userAtHost;
      value = self.lib.system.mkHome {
        inherit
          inputs
          system
          hostname
          username
          ;
        modules = [ args.path ];
      };
    };
in
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  flake = {
    homeModules.default = ../modules/home;
    homeConfigurations = lib.mapAttrs' generateHomeConfiguration allHomes;
  };
}
