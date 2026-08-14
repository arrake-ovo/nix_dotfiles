{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.dot.home.programs.terminal.shell.zsh;

  outOfStore = config.lib.file.mkOutOfStoreSymlink;
  cfgFile = path: outOfStore "${cfg.sourceRoot}/${path}";
  cfgDir = path: {
    source = outOfStore "${cfg.sourceRoot}/${path}";
    recursive = true;
  };
in {
  options.dot.home.programs.terminal.shell.zsh = {
    enable = mkEnableOption "zsh";

    sourceRoot = mkOption {
      type = types.str;
      description = "Absolute path to the zsh configuration source directory.";
    };
  };

  config = mkIf cfg.enable {
    # antidote：zsh 插件管理器本体；插件由 ~/.config/zsh/.zsh_plugins.txt 声明，
    # 首次运行时 clone 到 XDG_CACHE_HOME/antidote。
    home.packages = with pkgs; [ antidote bat fd fzf ripgrep tree ];

    programs.zsh = {
      enable = true;
    };

    home.file = {
      # ~/.zshenv 必须位于 $HOME（zsh 只在 $HOME 找它）；它设置 ZDOTDIR 后，
      # 其余配置（.zshrc / .zsh_plugins.txt / .zshrc.d / bin）都从 ~/.config/zsh 读取。
      ".zshenv".source = cfgFile ".zshenv";
      ".config/zsh" = cfgDir ".config/zsh";
    };
  };
}
