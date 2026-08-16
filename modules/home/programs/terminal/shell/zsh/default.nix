{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types listToAttrs nameValuePair;
  cfg = config.dot.home.programs.terminal.shell.zsh;

  outOfStore = config.lib.file.mkOutOfStoreSymlink;
  cfgFile = path: outOfStore "${cfg.sourceRoot}/${path}";
  cfgDir = path: {
    source = outOfStore "${cfg.sourceRoot}/${path}";
    recursive = true;
  };

  # .zshrc.d 里「始终加载」的基础脚本。
  # 按需脚本（如 ime.zsh）不在此列，由各自模块用 home.file 条件软链，
  # 实现「未启用对应软件就不链接对应脚本」。
  baseScripts = [
    "aliases.zsh"
    "completion.zsh"
    "fnm.zsh"
    "fzf-tab.zsh"
    "fzf.zsh"
    "history.zsh"
    "keybindings.zsh"
    "prompt.zsh"
    "setopt.zsh"
  ];

  rcD = listToAttrs (map (f:
    nameValuePair ".config/zsh/.zshrc.d/${f}" {
      source = cfgFile ".config/zsh/.zshrc.d/${f}";
    }
  ) baseScripts);
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
      ".config/zsh/.zshrc".source = cfgFile ".config/zsh/.zshrc";
      ".config/zsh/.zsh_plugins.txt".source = cfgFile ".config/zsh/.zsh_plugins.txt";
      ".config/zsh/bin" = cfgDir ".config/zsh/bin";
      # .zshrc.d 逐文件软链（见 rcD），不含按需脚本，便于其他模块条件补充。

      # antidote 包没有 bin，只有 share/antidote/antidote.zsh；
      # 链接到固定位置供 .zshrc source（antidote.zsh 依赖同目录的 functions/）。
      ".local/share/antidote" = {
        source = "${pkgs.antidote}/share/antidote";
        recursive = true;
      };
    } // rcD;
  };
}
