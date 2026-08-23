{ config, lib, inputs, system, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.agent.grok-build;

  # 来自 numtide/llm-agents.nix：每日自动跟随上游发版（linux/aarch64-darwin），
  # 包装层已禁用 grok 自带自更新，版本由 nix 锁定（flake update 时统一升级）。
  grok = inputs.llm-agents.packages.${system}.grok;
in {
  options.dot.home.programs.agent.grok-build = {
    enable = mkEnableOption "Grok Build CLI (grok)";
  };

  config = mkIf cfg.enable { home.packages = [ grok ]; };
}
