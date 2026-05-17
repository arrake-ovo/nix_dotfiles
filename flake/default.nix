{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ../lib
    ./overlays.nix
    ./packages.nix
    ./configs.nix
    ./home.nix
  ];

  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          deadnix
          nil
          nixfmt
          statix
        ];
      };
    };
}
