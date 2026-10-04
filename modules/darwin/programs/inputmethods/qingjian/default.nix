{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.dot.darwin.programs.inputmethods.qingjian;
  user = config.dot.darwin.user.name;
in {
  options.dot.darwin.programs.inputmethods.qingjian.enable = mkEnableOption ''
    Qingjian (青简) 拼音输入法。没有 Homebrew cask，pkg 需手动装到
    /Library/Input Methods/Qingjian.app。本模块注册 TIS，并软链
    ~/Library/Application Support/Qingjian/config.toml
  '';

  # HIToolbox / AppleEnabledThirdPartyInputSources 的数组合并会互相覆盖，
  # 条目分别加在 system.input 和 squirrel 模块里（lib.optionals cfg.enable）。
  config = mkIf cfg.enable {
    home-manager.users.${user} = { config, ... }: {
      home.file."Library/Application Support/Qingjian/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink (
          lib.file.getFile "config/home/Library/Application Support/Qingjian/config.toml"
        );
      home.file."Library/Application Support/Qingjian/dicts/custom_phrase.tsv".source =
        config.lib.file.mkOutOfStoreSymlink (
          lib.file.getFile "config/home/Library/Application Support/Qingjian/dicts/custom_phrase.tsv"
        );
    };
  };
}
