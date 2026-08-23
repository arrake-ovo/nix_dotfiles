{ inputs, system, username, ... }:

let
  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
    packages = [ unstablePkgs.nodejs_22 ];
  };

  programs.home-manager.enable = true;

  # common 套件：zsh（含 sourceRoot）+ git/gh/opencli/starship/yazi/zellij/neovim
  # 全部为跨平台软件；macOS 专有软件放 darwin 层，不进 home 层。
  dot.home.suites.common.enable = true;

  # pnpm 命令可用（Node 包管理器，与 nodejs_22 并列，独立二进制）
  dot.home.programs.development.languages.pnpm.enable = true;

  # nrm：npm/pnpm registry 镜像源切换 CLI（node 生态，与 nodejs_22 同源）
  dot.home.programs.development.tools.nrm.enable = true;

  # fnm：node 版本管理（按项目 .nvmrc 自动切换；与 Nix nodejs_22 并存）
  dot.home.programs.development.languages.fnm.enable = true;

  # android 套件：adb（android-tools）+ scrcpy（投屏），跨平台软件
  dot.home.suites.android.enable = true;

  # AI agent 工具（numtide/llm-agents.nix，每日自动更新版本）：
  # grok-build（xAI）+ opencode（SST 开源）+ pi-coding-agent
  dot.home.programs.agent.grok-build.enable = true;
  dot.home.programs.agent.opencode.enable = true;
  dot.home.programs.agent.pi.enable = true;

  # 用户级 nix 客户端配置：声明 numtide binary cache 信任
  dot.home.programs.development.tools.nix.enable = true;
}
