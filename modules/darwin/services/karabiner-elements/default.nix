{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.services.karabiner-elements;
in {
  options.dot.darwin.services.karabiner-elements = {
    enable = mkEnableOption "Karabiner-Elements keyboard customizer";
  };
  config = mkIf cfg.enable {
    homebrew.casks = [ "karabiner-elements" ];
  };
}
