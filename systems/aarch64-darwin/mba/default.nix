{ lib, pkgs, ... }:

let
  inherit (lib.arrakenix) enabled;
in
{
  arrakenix = {
    user = {
      name = "arrake";
      email = "arrake@163.com";
      fullName = "arrake";
      uid = 501;
    };

    suites.common = enabled;

    tools.homebrew = {
      enable = true;
      cleanup = "zap";
      masEnable = true;
    };
  };

  networking = {
    computerName = "mba";
    hostName = "mba";
    localHostName = "mba";
  };

  system.stateVersion = 6;

  system.defaults = {
    menuExtraClock.Show24Hour = true;
    smb.NetBIOSName = "mba";

    CustomUserPreferences = {
      "com.apple.HIToolbox" = {
        AppleFnUsageType = 1;
        AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.Colemak";
        AppleEnabledInputSources = [
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 252;
            "KeyboardLayout Name" = "ABC";
          }
          {
            "Bundle ID" = "im.rime.inputmethod.Squirrel";
            "Input Mode" = "im.rime.inputmethod.Squirrel.Hans";
            InputSourceKind = "Input Mode";
          }
        ];
        AppleSelectedInputSources = {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 252;
          "KeyboardLayout Name" = "ABC";
        };
      };

      "org.p0deje.Maccy" = {
        SUAutomaticallyUpdate = 0;
        SUEnableAutomaticChecks = 0;
        SUHasLaunchedBefore = 1;
        maxMenuItemLength = 25;
        menuIcon = "clipboard";
        previewDelay = 150;
        searchMode = "fuzzy";
      };
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = false;
    remapCapsLockToEscape = true;
    swapLeftCommandAndLeftAlt = false;
    userKeyMapping = [
      {
        HIDKeyboardModifierMappingDst = 30064771129;
        HIDKeyboardModifierMappingSrc = 30064771113;
      }
    ];
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  services.sketchybar = {
    enable = true;
    extraPackages = with pkgs; [
      gh
      glab
      jq
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      git
      kitty
      neovim
      nodejs_24
      pnpm_9
      tree-sitter
    ];

    variables.EDITOR = "nvim";
  };

  fonts.packages = with pkgs; [
    font-awesome
    sketchybar-app-font
  ];

  users.users.arrake.shell = pkgs.bash;

  homebrew = {
    taps = [
      "farion1231/ccswitch"
      "homebrew/cask"
      "homebrew/core"
    ];

    brews = [
      "codex"
      "gemini-cli"
      "mas"
      "opencode"
    ];

    casks = [
      "aldente"
      "alt-tab"
      "cc-switch"
      "claude-code"
      "font-hack-nerd-font"
      "ghostty"
      "google-chrome"
      "karabiner-elements"
      "keyclu"
      "maccy"
      "obsidian"
      "opencode-desktop"
      "orion"
      "raycast"
      "rio"
      "sf-symbols"
      "snipaste"
      "squirrel-app"
      "stats"
      "trae"
      "wezterm"
    ];
  };
}
