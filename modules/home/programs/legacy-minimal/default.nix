{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.arrakenix.programs.legacyMinimal;
  link = path: config.lib.file.mkOutOfStoreSymlink "${cfg.configRoot}/${path}";
in
{
  options.arrakenix.programs.legacyMinimal = {
    enable = lib.mkEnableOption "legacy minimal Home Manager configuration";
    configRoot = lib.mkOption {
      type = lib.types.str;
      default = "/Users/arrake/nix/minimal/config";
      description = "Path to the legacy minimal dotfiles config directory.";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        aerospace
        bat
        fd
        fzf
        ripgrep
        tree
        zimfw
      ];

      file = {
        ".config/fzf/.fzf.zsh".source = link "fzf/.fzf.zsh";
        ".config/helix/config.toml".source = link "helix/config.toml";
        ".config/yazi/flavors".source = link "yazi/flavors";
        ".config/yazi/init.lua".source = link "yazi/init.lua";
        ".config/yazi/keymap.toml".source = link "yazi/keymap.toml";
        ".config/yazi/starship.toml".source = link "yazi/starship.toml";
        ".config/yazi/theme.toml".source = link "yazi/theme.toml";
        ".config/yazi/yazi.toml".source = link "yazi/yazi.toml";
        ".gitconfig".source = link ".gitconfig";
        ".vimrc".source = link ".vimrc";
        ".zim".source = link "zsh/.zim";
        ".zimrc".source = link ".zimrc";
        ".zshenv".source = link "zsh/.zshenv";
        ".zshrc".source = link ".zshrc";

        ".local/bin/fzf-preview.sh" = {
          source = link "fzf/bin/fzf-preview.sh";
          executable = true;
        };

        ".local/bin/no_proxy.sh" = {
          source = link "zsh/sh/no_proxy.sh";
          executable = true;
        };

        ".local/bin/proxy.sh" = {
          source = link "zsh/sh/proxy.sh";
          executable = true;
        };
      };
    };

    programs = {
      helix.enable = true;
      starship.enable = true;
      yazi = {
        enable = true;
        plugins = {
          compress = link "yazi/plugins/compress.yazi";
          git = link "yazi/plugins/git.yazi";
          githead = link "yazi/plugins/githead.yazi";
          keyjump = link "yazi/plugins/keyjump.yazi";
          smart-enter = link "yazi/plugins/smart-enter.yazi";
          starship = link "yazi/plugins/starship.yazi";
          yamb = link "yazi/plugins/yamb.yazi";
          yaziline = link "yazi/plugins/yaziline.yazi";
        };
      };
    };
  };
}
