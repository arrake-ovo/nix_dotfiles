{ self, ... }:

{
  # Homebrew 4.5.9 requires Ruby 3.4. Keep the system on the existing
  # nixpkgs release, but make the Ruby selected by nix-homebrew match the
  # known-good minimal configuration.
  flake.overlays.default = final: _prev: { ruby = final.ruby_3_4; };
}
