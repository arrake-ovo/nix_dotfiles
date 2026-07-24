# Karabiner-Elements 用户配置纳入 Nix

日期：2026-07-24  
状态：已批准设计

## 背景

- Darwin 层已通过 `dot.darwin.services.karabiner-elements` 安装 Homebrew cask，并由 `dot.darwin.suites.common` 默认启用。
- 用户实际映射在 `~/.config/karabiner/karabiner.json`，尚未纳入仓库。
- 系统输入保持 ABC 布局，Colemak 与快捷键习惯由 Karabiner 负责。

## 目标

将当前 Karabiner 用户配置纳入 Home Manager，行为与现网一致，配置管理方式对齐本仓库 yazi / helix / zellij 范式。

## 非目标

- 不改 Darwin 安装方式（继续 Homebrew cask）。
- 不把 185 条 Colemak 映射重写为 Nix attrset。
- 不托管 `assets/`、`automatic_backups`。
- 不做多机差异化 option。
- 本次不自动执行 `switch`。

## 方案

采用**静态 JSON + `mkOutOfStoreSymlink`**。

### 文件变更

| 路径 | 动作 |
|------|------|
| `config/home/.config/karabiner/karabiner.json` | 从当前 `~/.config/karabiner/karabiner.json` 迁入 |
| `modules/home/programs/apps/karabiner/default.nix` | 新建 home 模块 |
| `modules/home/suites/common/default.nix` | 默认启用 `apps.karabiner` |
| `modules/darwin/services/karabiner-elements/default.nix` | 不改 |

### Option

```text
modules/home/programs/apps/karabiner/default.nix
  → dot.home.programs.apps.karabiner.enable
```

### 模块行为

- `enable` 为 true 时：
  - 使用 `config.dot.home.programs.terminal.shell.zsh.sourceRoot`
  - 通过 `config.lib.file.mkOutOfStoreSymlink` 链接
  - 目标：`xdg.configFile."karabiner/karabiner.json"`
- 不安装包（安装归 Darwin/Homebrew）。
- 不链接 `assets/`：当前 profile 已内嵌全部 `complex_modifications.rules`。

### 迁入配置内容（保持不变）

Profile：`Default`（selected）

1. `Change left_command+neiu to arrow keys (Colemak physical positions)`（4 manipulators）
2. `Remap keys to use Colemak keyboard layout`（138 manipulators）
3. `Colemak - Command Qwerty`（47 manipulators）

`virtual_hid_keyboard.keyboard_type_v2 = "ansi"`。

### 启用链路

```text
dot.home.roles.developer
  → dot.home.suites.common
    → dot.home.programs.apps.karabiner = mkDefault enabled
```

`arrake@mba` 已启用 developer role，无需改 homes 配置。

## 验证

```sh
nix build '.#homeConfigurations."arrake@mba".activationPackage'
```

若 flake 输出名不同，以实际 `homeConfigurations` 为准。

成功标准：

1. home 配置可构建。
2. 模块 option 路径与目录镜像一致。
3. 迁入 JSON 与当前生效配置内容一致（规则描述与数量不变）。

`switch` 仅在用户明确同意后执行。switch 后预期 `~/.config/karabiner/karabiner.json` 指向仓库 `config/home` 下对应文件。

## 风险

- Karabiner GUI 可能改写 `karabiner.json`。使用 out-of-store symlink 时，GUI 修改会写回仓库工作树文件；这与 yazi/helix 同一模型，可接受。
- 若本地已有非 symlink 的 `karabiner.json`，home-manager switch 可能因冲突失败，需先备份再切换。
