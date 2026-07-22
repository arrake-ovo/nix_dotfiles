{
  inputs,
  self,
  lib,
  ...
}:

let
  inherit (self.lib.file) parseSystemConfigurations filterDarwinSystems filterNixOSSystems;

  systemsPath = ../systems;
  allSystems = parseSystemConfigurations systemsPath;
in
{
  flake = {
    nixosConfigurations = lib.mapAttrs' (
      _name:
      { system, hostname, ... }:  
      {
        name = hostname;
        value = self.lib.system.mkSystem {
          inherit inputs system hostname;
          username = "arrake";
        };
      }
    ) (filterNixOSSystems allSystems);

    darwinConfigurations = lib.mapAttrs' (
      _name:
      { system, hostname, ... }:
      {
        name = hostname;
        value = self.lib.system.mkDarwin {
          inherit inputs system hostname;
          username = "arrake";
        };
      }
    ) (filterDarwinSystems allSystems);
  };
}
