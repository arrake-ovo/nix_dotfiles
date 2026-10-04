{ config, lib, inputs, system, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.home.programs.agent.codex;

  # 来自 numtide/llm-agents.nix：OpenAI Codex CLI。
  # 上游已同时构建 codex-cli 与 codex-code-mode-host。
  codex = inputs.llm-agents.packages.${system}.codex;
in {
  options.dot.home.programs.agent.codex = {
    enable = mkEnableOption "OpenAI Codex CLI";
  };

  config = mkIf cfg.enable { home.packages = [ codex ]; };
}
