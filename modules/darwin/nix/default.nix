{ config, lib, ... }:

let
  cfg = config.arrakenix.nix;
in
{
  imports = [ (lib.getFile "modules/common/nix/default.nix") ];

  config = lib.mkIf cfg.enable {
    # Determinate Nix owns /etc/nix/nix.conf on this machine. Keep nix-darwin
    # from replacing it; mirror/cache settings stay in /etc/nix/nix.custom.conf.
    nix.enable = false;
  };
}
