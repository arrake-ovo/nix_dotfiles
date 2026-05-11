{ inputs, self, ... }:

{
  flake.lib = {
    file = import ./file { inherit inputs self; };
    module = import ./module { inherit inputs; };
    overlay = import ./overlay.nix { inherit inputs self; };
    system = import ./system { inherit inputs self; };
  };
}
