{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.home.programs.development.tools.nix;
in {
  options.dot.home.programs.development.tools.nix = {
    enable =
      mkEnableOption "user-level nix client config (~/.config/nix/nix.conf)";
  };

  config = mkIf cfg.enable {
    # Determinate Nix 锁死 /etc/nix/nix.conf，且 nix-darwin 对 nix.custom.conf
    # 有已知哈希校验（内容一变就中止 activation），这两条路都不适合声明式写 cache。
    # 用户级 ~/.config/nix/nix.conf 与系统配置合并、无需 root、不经哈希校验，
    # 是 Determinate Nix + nix-darwin 组合下声明式配置 binary cache 的正解。
    home.file.".config/nix/nix.conf".text = ''

      # 第三方 flake 的 nixConfig 默认不被信任（防恶意 flake 引导到假 cache），
      # 这里是用户级信任声明（原 darwin nix.settings 的 cache 声明在 Determinate Nix
      # 下不生效，已统一收编至此）：

      # numtide/llm-agents.nix 官方 cache（grok/opencode/pi 等 agent 包预编译产物）
      extra-substituters = https://cache.numtide.com
      extra-trusted-substituters = https://cache.numtide.com
      extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=

      # nix-community Cachix（部分社区包预编译产物）
      extra-substituters = https://nix-community.cachix.org
      extra-trusted-substituters = https://nix-community.cachix.org
      extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=

      # SJTU 镜像（cache.nixos.org 签名，key 系统级已信任）
      extra-substituters = https://mirror.sjtu.edu.cn/nix-channels/store
    '';
  };
}
