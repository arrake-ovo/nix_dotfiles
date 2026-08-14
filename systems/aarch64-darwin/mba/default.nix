{ inputs, ... }: {

  dot.darwin.suites.common.enable = true;

  # 迁移期：旧的真实配置文件挡路时自动备份为 .backup，不再中断 switch
  home-manager.backupFileExtension = "backup";

  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = "arrake";
    taps = with inputs; {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = true;
  };

  networking = {
    hostName = "mba";
    computerName = "mba";
    localHostName = "mba";
  };

  system = {
    primaryUser = "arrake";
    stateVersion = 6;
  };
}
