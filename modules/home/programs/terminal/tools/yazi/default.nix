{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.terminal.tools.yazi;

  sourceRoot = config.dot.home.programs.terminal.shell.zsh.sourceRoot;
  outOfStore = config.lib.file.mkOutOfStoreSymlink;

  pluginPath = name: "${sourceRoot}/.config/yazi/plugins/${name}.yazi";
in
{
  options.dot.home.programs.terminal.tools.yazi = {
    enable = mkEnableOption "yazi file manager";
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;

      plugins = {
        git = pluginPath "git";
        keyjump = pluginPath "keyjump";
        compress = pluginPath "compress";
        smart-enter = pluginPath "smart-enter";
        yamb = pluginPath "yamb";
        githead = pluginPath "githead";
        starship = pluginPath "starship";
        yaziline = pluginPath "yaziline";
      };
    };

    xdg.configFile = {
      "yazi/init.lua".source = outOfStore "${sourceRoot}/.config/yazi/init.lua";
      "yazi/yazi.toml".source = outOfStore "${sourceRoot}/.config/yazi/yazi.toml";
      "yazi/keymap.toml".source = outOfStore "${sourceRoot}/.config/yazi/keymap.toml";
      "yazi/theme.toml".source = outOfStore "${sourceRoot}/.config/yazi/theme.toml";
      "yazi/starship.toml".source = outOfStore "${sourceRoot}/.config/yazi/starship.toml";
      "yazi/flavors".source = outOfStore "${sourceRoot}/.config/yazi/flavors";
    };
  };
}
