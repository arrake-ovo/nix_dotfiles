{
  config,
  lib,
  options,
  ...
}:

let
  inherit (lib.arrakenix) mkOpt;
in
{
  options.arrakenix.home = {
    file = mkOpt lib.types.attrs { } "Files managed through the integrated Home Manager user.";
    configFile = mkOpt lib.types.attrs { } "XDG config files managed through the integrated Home Manager user.";
    extraOptions = mkOpt lib.types.attrs { } "Options passed directly to the integrated Home Manager user.";
  };

  config = {
    arrakenix.home.extraOptions = {
      home.file = lib.mkAliasDefinitions options.arrakenix.home.file;
      xdg.enable = true;
      xdg.configFile = lib.mkAliasDefinitions options.arrakenix.home.configFile;
    };

    home-manager = {
      backupFileExtension = "hm.old";
      useGlobalPkgs = true;
      useUserPackages = true;
      verbose = true;

      users.${config.arrakenix.user.name} =
        lib.mkAliasDefinitions options.arrakenix.home.extraOptions;
    };
  };
}
