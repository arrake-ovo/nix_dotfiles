{ inputs, self }:

{
  mkDarwin = import ./mk-darwin.nix { inherit inputs self; };
  mkSystem = import ./mk-system.nix { inherit inputs self; };
  mkHome = import ./mk-home.nix { inherit inputs self; };
  common = import ./common.nix { inherit inputs self; };
}
