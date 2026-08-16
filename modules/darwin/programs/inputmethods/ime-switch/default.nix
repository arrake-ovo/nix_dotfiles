{ config, lib, inputs, system, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.darwin.programs.inputmethods.ime-switch;
  user = config.dot.darwin.user.name;

  # macism 只在 nixpkgs-unstable（复用现有 input，与 herdr 同源）。
  # macism 是 macOS 专属工具（调用 TIS 输入源 API），因此属 darwin 模块而非 home。
  macism = inputs.nixpkgs-unstable.legacyPackages.${system}.macism;
in
{
  options.dot.darwin.programs.inputmethods.ime-switch = {
    enable = mkEnableOption "macism input source auto-switch for TUI programs";
  };

  config = mkIf cfg.enable {
    home-manager.users.${user} = { config, ... }: {
      # 安装 macism CLI，供 zsh 的 ime.zsh（preexec/precmd hook）调用
      home.packages = [ macism ];

      # zsh 脚本按需软链：只有启用本模块才链接 ime.zsh
      home.file.".config/zsh/.zshrc.d/ime.zsh".source =
        config.lib.file.mkOutOfStoreSymlink (lib.file.getFile "config/home/.config/zsh/.zshrc.d/ime.zsh");
    };
  };
}
