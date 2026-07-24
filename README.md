# nix_dotfiles

这是 `arrake` 的个人 Nix 配置仓库，用同一套结构管理 macOS、NixOS、非 NixOS Linux 的 Home Manager 配置，以及未来的 WSL 配置。

项目是否支持某个平台，主要取决于你是否在对应目录下添加了配置：

- macOS 通过 nix-darwin 管理。
- NixOS 通过 `nixosConfigurations` 管理。
- 非 NixOS Linux 通过独立 Home Manager 管理。
- WSL 可以按 NixOS/WSL 的方式接入。

## 项目基本原理

这个仓库不是把所有配置写进一个大文件，而是分成三层：

1. `modules/` 定义可复用模块。
2. `systems/` 和 `homes/` 定义具体机器、具体用户最终启用什么。
3. `flake/` 和 `lib/` 负责扫描这些目录，并生成 flake outputs。

核心流程是：

```text
flake.nix
  -> flake/
  -> lib/ 中的发现和构建函数
  -> 扫描 systems/ 与 homes/
  -> 生成 darwinConfigurations、nixosConfigurations、homeConfigurations
```

所以添加一台机器或一个用户配置时，通常不需要手动改 `flake.nix`。只要按约定创建目录，项目会自动发现。

## 目录作用

| 路径 | 作用 |
|------|------|
| `flake/` | flake-parts 输出组织 |
| `lib/` | 共享 helper、模块发现、系统构建器 |
| `modules/common/` | Darwin 和 NixOS 共享的系统级模块 |
| `modules/darwin/` | macOS / nix-darwin 模块 |
| `modules/nixos/` | NixOS 系统模块 |
| `modules/home/` | Home Manager 用户空间模块 |
| `config/home/` | 映射到 `$HOME` 的静态配置文件（镜像 home 布局） |
| `systems/{arch}/{host}/` | 具体机器的系统配置 |
| `homes/{arch}/{user}@{host}/` | 具体用户在具体机器上的 Home Manager 配置 |
| `packages/` | 本 flake 导出的自定义包 |

## 怎么添加自己的配置

先判断你要添加的是“可复用模块”，还是“某台机器/某个用户的最终配置”。

### 添加机器配置

系统配置放在：

```text
systems/{arch}/{hostname}/default.nix
```

例子：

```text
systems/aarch64-darwin/mba/default.nix
systems/x86_64-linux/desktop/default.nix
```

这里写机器级配置，比如：

- 主机名。
- nix-darwin 或 NixOS 系统选项。
- 机器角色、suite、archetype。
- 这台机器最终启用哪些系统模块。

### 添加用户配置

Home Manager 配置放在：

```text
homes/{arch}/{username}@{hostname}/default.nix
```

例子：

```text
homes/aarch64-darwin/arrake@mba/default.nix
homes/x86_64-linux/arrake@desktop/default.nix
```

这里写用户级配置，比如：

- 用户名、邮箱、home 目录。
- shell、git、编辑器、CLI 工具。
- 用户角色、suite。
- 这个用户最终启用哪些 Home Manager 模块。

## 怎么添加一个 Nix 配置模块

如果配置可能复用，就不要直接写在 `systems/` 或 `homes/` 里，而是先做成模块。

| 你要加入的内容 | 放置位置 |
|----------------|----------|
| shell、git、编辑器、CLI 工具、dotfile、用户偏好 | `modules/home/` |
| Homebrew、macOS defaults、nix-darwin 集成 | `modules/darwin/` |
| NixOS 服务、硬件、网络、防火墙、systemd | `modules/nixos/` |
| Darwin 和 NixOS 都需要的系统级 Nix 行为 | `modules/common/` |

默认遵循 Home-First：只要是用户工具、用户偏好或 dotfile，优先放到 `modules/home/`。

新增模块的基本流程：

1. 判断模块属于 `home`、`darwin`、`nixos` 还是 `common`。
2. 在对应目录下创建 `<name>/default.nix`。
3. 提供 `enable` 选项。
4. 用 `lib.mkIf cfg.enable` 包住实现。
5. 从 suite、role、archetype、host 或 user 配置中启用它。
6. 运行对应检查或构建命令。

Home Manager 程序按用途分类：

| 类型 | 路径 |
|------|------|
| shell | `modules/home/programs/terminal/shell/<name>/` |
| 终端工具 | `modules/home/programs/terminal/tools/<name>/` |
| 编辑器 | `modules/home/programs/editors/<name>/` |
| 开发语言工具链 | `modules/home/programs/development/languages/<name>/` |
| 开发平台工具 | `modules/home/programs/development/tools/<name>/` |
| 图形应用配置 | `modules/home/programs/apps/<name>/` |

示例：

```text
modules/home/programs/terminal/tools/bat/default.nix
```

## 模块基本写法

新模块应遵循 [模块系统架构](docs/architecture/02-module-system.md)。

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.dot.home.programs.terminal.tools.example;
in
{
  options.dot.home.programs.terminal.tools.example.enable =
    lib.mkEnableOption "example";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.example ];
  };
}
```

注意：本项目处于命名空间迁移过程中。架构文档使用 `dot.*`，部分现有模块仍可能使用 `arrakenix.*`。修改已有模块时，先跟随该模块当前写法；只有明确做命名空间迁移时，才统一改调用方、模块和文档。

## 怎么运行

通用检查：

```console
nix flake check
```

构建 macOS 主机：

```console
darwin-rebuild build --flake .#mba
```

应用 macOS 主机配置：

```console
darwin-rebuild switch --flake .#mba
```

建议先运行 `build`，确认配置能构建后，再运行 `switch` 应用到当前机器。

NixOS 和独立 Home Manager 的配置名由 `systems/` 和 `homes/` 的目录自动发现。添加对应目录后，再使用生成出的 flake output 进行构建或切换。

## 文档入口

- [docs/README.md](docs/README.md)：文档地图。
- [docs/conventions.md](docs/conventions.md)：修改代码和文件的流程约定。
- [docs/architecture/README.md](docs/architecture/README.md)：架构文档入口。

当改动影响项目结构、模块放置规则或架构行为时，需要同步更新文档。
