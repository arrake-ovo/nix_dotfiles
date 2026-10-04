{ config, lib, inputs, system, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.agent.antigravity;

  # 来自 numtide/llm-agents.nix：Google Antigravity CLI（二进制 agy）。
  antigravity = inputs.llm-agents.packages.${system}.antigravity-cli;
in {
  options.dot.home.programs.agent.antigravity = {
    enable = mkEnableOption "Google Antigravity CLI (agy)";
  };

  config = mkIf cfg.enable { home.packages = [ antigravity ]; };
}
