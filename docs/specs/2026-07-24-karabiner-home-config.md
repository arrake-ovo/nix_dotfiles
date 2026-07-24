# Karabiner-Elements 配置纳入 Nix

日期：2026-07-24  
状态：已按用户反馈修订

## 背景

- Darwin 层已通过 `dot.darwin.services.karabiner-elements` 安装 Homebrew cask，并由 `dot.darwin.suites.common` 默认启用。
- 用户实际映射在 `~/.config/karabiner/karabiner.json`，此前未纳入仓库。
- 系统输入保持 ABC 布局，Colemak 与快捷键习惯由 Karabiner 负责。

## 目标

将当前 Karabiner 配置纳入 nix-darwin 管理，安装与映射同模块维护。

## 设计决策（用户修订）

- Karabiner 只在 Darwin 运行，**不**新建 `modules/home/` 模块。
- 模块逻辑放在现有 `modules/darwin/services/karabiner-elements/`。
- 静态 `karabiner.json` 放 `config/home/.config/karabiner/`（镜像 `$HOME`，不与 `default.nix` 同目录）。
- 通过 `home-manager.users.<darwin-user>` 写入 `xdg.configFile`（对齐 squirrel 的 Darwin→HM 写法）。
- 引用：`lib.file.getFile "config/home/.config/karabiner/karabiner.json"`。

## 文件变更

| 路径 | 动作 |
|------|------|
| `modules/darwin/services/karabiner-elements/default.nix` | 增加 xdg 配置部署 |
| `config/home/.config/karabiner/karabiner.json` | 迁入当前生效配置 |
| `modules/home/programs/apps/karabiner/` | 不创建 |

## 模块行为

`dot.darwin.services.karabiner-elements.enable = true` 时：

1. `homebrew.casks = [ "karabiner-elements" ]`
2. `home-manager.users.${config.dot.darwin.user.name}.xdg.configFile."karabiner/karabiner.json".source = lib.file.getFile "config/home/.config/karabiner/karabiner.json"`

## 迁入配置内容

Profile：`Default`（selected）

1. `Change left_command+neiu to arrow keys (Colemak physical positions)`（4 manipulators）
2. `Remap keys to use Colemak keyboard layout`（138 manipulators）
3. `Colemak - Command Qwerty`（47 manipulators）

`virtual_hid_keyboard.keyboard_type_v2 = "ansi"`。

## 启用链路

```text
dot.darwin.suites.common
  → services.karabiner-elements = mkDefault enabled
```

`systems/aarch64-darwin/mba` 已启用 `suites.common`，无需改 host 配置。

## 验证

```sh
darwin-rebuild build --flake .#mba
```

成功标准：

1. Darwin 配置可构建。
2. 模块仍只暴露 `dot.darwin.services.karabiner-elements.enable`。
3. 迁入 JSON 规则描述与数量与当前生效配置一致。

`switch` 仅在用户明确同意后执行。

## 风险

- `karabiner.json` 经 `lib.file.getFile` 进入 nix store 后为只读 symlink；GUI 直接改配置会失败，需改 `config/home/.config/karabiner/karabiner.json` 再 rebuild。
- 若本地已有非 HM 管理的 `karabiner.json`，switch 可能因文件冲突失败，需先备份再切换。
