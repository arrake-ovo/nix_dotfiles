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
}
