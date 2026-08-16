{ config, lib, inputs, system, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.terminal.tools.ime-switch;

  # macism 只在 nixpkgs-unstable（复用现有 input，与 herdr 同源）。
  # 提供 macism 命令：`macism` 查看当前输入源，`macism <id>` 切换。
  macism = inputs.nixpkgs-unstable.legacyPackages.${system}.macism;
in
{
  options.dot.home.programs.terminal.tools.ime-switch = {
    enable = mkEnableOption "macism input source auto-switch for TUI programs";
  };

  config = mkIf cfg.enable {
    home.packages = [ macism ];
  };
}
