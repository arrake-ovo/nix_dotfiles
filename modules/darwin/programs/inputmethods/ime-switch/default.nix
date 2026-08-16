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
    # 安装 macism CLI 到用户 home，供 zsh 的 ime-e 包装函数调用
    home-manager.users.${user}.home.packages = [ macism ];
  };
}
