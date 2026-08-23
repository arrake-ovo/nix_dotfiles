{ self, inputs, ... }:

let
  # 不能直接在 overlay 内访问 flake inputs（fp 的 apply 只喂 final prev），
  # 所以在这里（模块求值期，inputs 可用）捕获 unstable 的 ruby_4_0。
  ruby40 = system: inputs.nixpkgs-unstable.legacyPackages.${system}.ruby_4_0;
in {
  # nix-homebrew (2026-08+) 直接引用 `pkgs.ruby_4_0`；主 nixpkgs 25.05 最高
  # 只到 ruby 3.x，从 nixpkgs-unstable 补齐 ruby_4_0（按 host platform 惰性取）。
  flake.overlays.default = final: _prev: {
    ruby_4_0 = ruby40 final.stdenv.hostPlatform.system;
  };
}
