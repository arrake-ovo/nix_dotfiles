{
  inputs,
  self,
  lib,
  ...
}:

let
  inherit (self.lib.file) parseSystemConfigurations filterDarwinSystems;

  systemsPath = ../systems;
  allSystems = parseSystemConfigurations systemsPath;
in
{
  flake.darwinConfigurations = lib.mapAttrs' (
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
}
