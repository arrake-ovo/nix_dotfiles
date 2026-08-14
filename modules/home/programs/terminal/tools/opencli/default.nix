{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.dot.home.programs.terminal.tools.opencli;
  installPrefix = "${config.home.homeDirectory}/.local";
in
{
  options.dot.home.programs.terminal.tools.opencli = {
    enable = mkEnableOption "OpenCLI";

    version = mkOption {
      type = types.str;
      default = "1.8.6";
      description = "Pinned npm version of OpenCLI.";
    };
  };

  config = mkIf cfg.enable {
    # Make Node available to the npm-installed executable without adding a
    # second Node.js package when the home already selects a newer one.
    home.sessionPath = [ "${pkgs.nodejs_22}/bin" ];

    # OpenCLI is currently distributed through npm rather than nixpkgs.
    # Install it into the existing user-local prefix instead of replacing
    # ~/.local/bin, which also contains tools managed outside Nix.
    home.activation.opencli = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      installedVersion="$(
        ${pkgs.nodejs_22}/bin/node -p \
          "try { require('${installPrefix}/lib/node_modules/@jackwener/opencli/package.json').version } catch (_) { null }" \
          2>/dev/null || true
      )"

      if [ "$installedVersion" != "${cfg.version}" ]; then
        run ${pkgs.nodejs_22}/bin/npm install \
          --global \
          --prefix "${installPrefix}" \
          --no-fund \
          --no-audit \
          "@jackwener/opencli@${cfg.version}"
      fi
    '';
  };
}
