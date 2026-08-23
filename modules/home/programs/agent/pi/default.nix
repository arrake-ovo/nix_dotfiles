{ config, lib, inputs, system, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.agent.pi;

  # 来自 numtide/llm-agents.nix：pi-coding-agent。
  pi = inputs.llm-agents.packages.${system}.pi;
in {
  options.dot.home.programs.agent.pi = {
    enable = mkEnableOption "pi-coding-agent CLI";
  };

  config = mkIf cfg.enable { home.packages = [ pi ]; };
}
