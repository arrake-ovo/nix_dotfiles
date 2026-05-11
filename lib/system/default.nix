{ inputs, self }:

{
  mkDarwin = import ./mk-darwin.nix { inherit inputs self; };
  mkHome = import ./mk-home.nix { inherit inputs self; };
}
