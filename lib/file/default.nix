{
  inputs,
  self,
}:

let
  inherit (inputs.nixpkgs) lib;
  inherit (lib)
    filterAttrs
    genAttrs
    hasPrefix
    hasSuffix
    ;

  listDir = dirPath: builtins.readDir dirPath;
  listNames = dirPath: builtins.attrNames (listDir dirPath);
  listDirectories =
    dirPath:
    let
      entries = listDir dirPath;
    in
    lib.filter (name: entries.${name} == "directory") (builtins.attrNames entries);
  listNamesMatching = predicate: dirPath: lib.filter predicate (listNames dirPath);
  getNixFiles = dirPath: listNamesMatching (name: hasSuffix ".nix" name) dirPath;
  mergeAttrs = attrsList: lib.foldl' (acc: attrs: acc // attrs) { } attrsList;
in
{
  inherit
    getNixFiles
    listDir
    listNames
    listDirectories
    listNamesMatching
    mergeAttrs
    ;

  getFile = relativePath: self + "/${relativePath}";
  pathExists = filePath: builtins.pathExists filePath;
  safeImport = filePath: default: if builtins.pathExists filePath then import filePath else default;

  importModulesRecursive =
    dirPath:
    let
      walkDir =
        currentPath:
        let
          entries = builtins.readDir currentPath;
          entryNames = builtins.attrNames entries;
          directoriesWithDefault = lib.filter (
            name: entries.${name} == "directory" && builtins.pathExists (currentPath + "/${name}/default.nix")
          ) entryNames;
          allDirectories = builtins.filter (name: entries.${name} == "directory") entryNames;
        in
        map (name: currentPath + "/${name}") directoriesWithDefault
        ++ builtins.concatLists (map (dir: walkDir (currentPath + "/${dir}")) allDirectories);
    in
    walkDir dirPath;

  parseSystemConfigurations =
    systemsPath:
    let
      entries = builtins.readDir systemsPath;
      systemArchs = lib.filter (name: entries.${name} == "directory") (builtins.attrNames entries);

      generateSystemConfigs =
        system:
        let
          systemPath = systemsPath + "/${system}";
          hosts = builtins.attrNames (builtins.readDir systemPath);
        in
        genAttrs hosts (hostname: {
          inherit system hostname;
          path = systemPath + "/${hostname}";
        });
    in
    builtins.foldl' (acc: system: acc // generateSystemConfigs system) { } systemArchs;

  filterDarwinSystems =
    systems:
    filterAttrs (
      _name: { system, ... }: hasPrefix "aarch64-darwin" system || hasPrefix "x86_64-darwin" system
    ) systems;

  parseHomeConfigurations =
    homesPath:
    let
      entries = builtins.readDir homesPath;
      systemArchs = lib.filter (name: entries.${name} == "directory") (builtins.attrNames entries);

      generateHomeConfigs =
        system:
        let
          systemPath = homesPath + "/${system}";
          userAtHosts = builtins.attrNames (builtins.readDir systemPath);

          parseUserAtHost =
            userAtHost:
            let
              parts = builtins.split "@" userAtHost;
              username = builtins.head parts;
              hostname = builtins.elemAt parts 2;
            in
            {
              inherit
                system
                username
                hostname
                userAtHost
                ;
              path = systemPath + "/${userAtHost}";
            };
        in
        genAttrs userAtHosts parseUserAtHost;
    in
    builtins.foldl' (acc: system: acc // generateHomeConfigs system) { } systemArchs;
}
