{ config, lib, inputs, system, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.agent.opencode;

  # 来自 numtide/llm-agents.nix：opencode（SST 开源多模型 agent）。
  opencode = inputs.llm-agents.packages.${system}.opencode;
in {
  options.dot.home.programs.agent.opencode = {
    enable = mkEnableOption "opencode agent CLI";
  };

  config = mkIf cfg.enable { home.packages = [ opencode ]; };
}
