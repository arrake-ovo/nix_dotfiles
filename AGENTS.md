# AI 编程规则索引

本文件是 AI 在本仓库工作的入口索引。任何代码修改前，必须先阅读本文件，再按任务类型阅读对应文档。

## 0. 规则优先级

当文档、代码和用户指令出现冲突时，按以下顺序处理：

1. 用户在当前对话中的明确指令。
2. 本文件 `AGENTS.md`。
3. `docs/conventions.md` 中的变更流程约定。
4. `docs/architecture/` 下的架构文档。
5. 当前代码中的既有实现模式。
6. `README.md`、参考文档和其他说明。

不要因为看到旧代码或旧 README 就绕过本文件和架构文档。

## 1. 必读索引

### 所有任务

- 先读本文件。
- 再读 [文档地图](docs/README.md)。
- 再读 [变更流程约定](docs/conventions.md)。
- 再读 [架构文档索引](docs/architecture/README.md)。
- 阅读与本次任务相关的现有代码，优先看相邻模块和同类模块。

### 修改项目规则或文档组织

- 读 [文档地图](docs/README.md)。
- 读 [变更流程约定](docs/conventions.md)。

### 新增软件、工具或应用配置

- 读 [模块系统架构](docs/architecture/02-module-system.md)。
- 读其中的“新增软件配置流程”和“静态配置文件放 config/”。
- 先判断配置归属：`modules/home/`、`modules/darwin/`、`modules/nixos/`、`modules/common/`、`systems/` 或 `homes/`。
- 静态配置文件（json/toml/kdl 等）放 `config/home/`（镜像 `$HOME`），不要和 `modules/**/default.nix` 同目录。

### 修改顶层 flake 输出

- 读 [项目总览与设计哲学](docs/architecture/01-overview.md)。
- 读 [库层架构](docs/architecture/03-lib-layer.md)。
- 重点检查 `flake/`、`lib/system/`、`flake.nix` 的既有组织方式。

### 新增或修改 Nix 模块

- 读 [模块系统架构](docs/architecture/02-module-system.md)。
- 读 [系统与 Home 配置](docs/architecture/04-systems-homes.md)。
- 找一个同层级、同类型的模块作为模板。

### 修改 `lib/`

- 读 [库层架构](docs/architecture/03-lib-layer.md)。
- 优先复用已有 `lib.file`、`lib.module`、`lib.system` 分层。
- 不要把系统构建逻辑、文件扫描逻辑和模块 helper 混在一起。

### 修改 `systems/` 或 `homes/`

- 读 [系统与 Home 配置](docs/architecture/04-systems-homes.md)。
- 保持目录发现约定：
  - `systems/{arch}/{hostname}/default.nix`
  - `homes/{arch}/{username}@{hostname}/default.nix`

## 2. 架构执行规则

### Home-First

用户空间配置优先放入 Home Manager 模块。shell、git、终端工具、应用偏好、dotfiles 和个人开发工具默认属于 `modules/home/`。

只有系统服务、硬件、网络、安全、平台集成和 macOS/NixOS 系统设置才放入 `modules/darwin/`、`modules/nixos/` 或 `modules/common/`。

### 模块路径镜像 option

架构目标是：

```text
modules/<path>/default.nix -> dot.<path>.enable
```

示例：

```text
modules/home/programs/terminal/tools/git/default.nix
-> dot.home.programs.terminal.tools.git.enable
```

注意：当前代码中仍大量使用 `arrakenix.*`，而架构文档使用 `dot.*`。处理规则：

- 不要在无关任务里大规模迁移命名空间。
- 新增模块时，优先按架构文档使用 `dot.*`，除非为了接入现有未迁移代码必须暂时使用 `arrakenix.*`。
- 修改既有 `arrakenix.*` 模块时，保持局部一致；如果要迁移到 `dot.*`，必须把调用方、alias、配置入口和验证一起处理。
- 发现 `arrakenix.*` 与 `dot.*` 冲突时，先说明影响范围，再做最小可验证修改。

### 模块模板

新增模块默认使用目录模块：

```nix
{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dot.<path>;
in
{
  options.dot.<path>.enable = mkEnableOption "描述";

  config = mkIf cfg.enable {
    # implementation
  };
}
```

若当前层级仍使用 `arrakenix.*`，必须先检查现有模块风格，再决定是否暂时沿用。

### Suites、Roles、Archetypes

- suites 用于捆绑相关模块默认值，默认值应使用 `mkDefault`。
- roles 用于 Home Manager 用户身份组合。
- archetypes 用于 NixOS 或 Darwin 系统角色组合。
- 不要在 host 配置里重复堆砌大量单个工具开关；能表达为 suite、role 或 archetype 时优先抽象。
- 不要为一次性 host 特例创建过度抽象。

## 3. 代码风格规则

- Nix 变量和 option 使用 `camelCase`。
- 文件和目录使用 `kebab-case`。
- 每个功能模块使用目录加 `default.nix`。
- 优先使用 `inherit (lib) ...` 或 `lib.<fn>`。
- 避免块级 `with lib;`。
- 配置块优先用 `lib.mkIf cfg.enable` 包裹。
- 可复用默认开关优先使用项目 helper，如 `enabled`、`disabled`、`mkOpt`、`mkBoolOpt`。
- 添加新 helper 前，先检查 `lib/module/default.nix` 和 `lib/file/default.nix`。

## 4. 工作流程

修改前：

1. 明确本次改动属于哪一层：`flake/`、`lib/`、`modules/`、`systems/`、`homes/` 或文档。
2. 阅读对应架构章节。
3. 搜索现有同类实现。
4. 说明将遵循的架构规则。

修改中：

1. 做最小 coherent change。
2. 不顺手重构无关文件。
3. 不删除用户已有配置，除非用户明确要求。
4. 修改架构行为时，同步更新对应架构文档。

修改后：

1. 运行与改动相关的检查。
2. 如果检查无法运行，说明原因和剩余风险。
3. 总结改了哪些文件、遵循了哪些规则。

## 5. 验证命令索引

通用检查：

```sh
nix flake check
```

Darwin 主机 `mba`：

```sh
darwin-rebuild build --flake .#mba
```

需要实际切换系统时，只有在用户明确同意后才运行：

```sh
darwin-rebuild switch --flake .#mba
```

Home Manager 独立配置变更时，优先评估对应 `homeConfigurations`，不要猜测配置名，先从 flake 输出或 `docs/architecture/04-systems-homes.md` 的发现规则确认。

## 6. 禁止事项

- 不要绕过自动发现机制手动硬编码大量 flake 输出。
- 不要把用户空间配置塞进系统模块。
- 不要把应用静态配置文件（json/toml/kdl 等）和 `modules/**/default.nix` 放在同一目录；应放 `config/home/` 并镜像 `$HOME` 路径。
- 不要在 reusable module 中写死 `arrake`、`mba` 或某个绝对路径，除非该模块本身就是 host/user 专用配置。
- 不要把 secrets、token、私钥或机器特有敏感信息提交进仓库。
- 不要在未理解调用方的情况下改 `lib/system/` 构建器。
- 不要只根据架构文档想象代码已经完成迁移；必须用 `rg` 检查真实代码。

## 7. 外部参考：khanelinix

本项目大量参考 [khaneliman/khanelinix](https://github.com/khaneliman/khanelinix) 的设计模式和模块实现。khanelinix 是本项目的上游参考仓库。

**本地克隆路径**：`~/nix/khanelinix` （375 个模块）。

### 何时引用 khanelinix

当以下场景时，必须先查阅本地 khanelinix 仓库中对应代码：

- **新增模块**：在 `modules/` 下创建新模块前，先找到 khanelinix 中的同类模块，理解实现模式。
- **不确定配置写法**：对某个软件或服务的 Nix 配置不确定时，用 `rg` 搜索 khanelinix 仓库中对应的 `modules/` 文件。
- **新增 suite/role/archetype**：先看 khanelinix 中如何组织套件和角色。
- **Homebrew 集成**：Darwin 模块中需要 taps、brews、casks、mas 时，参考 khanelinix 的 `modules/darwin/` 和 homebrew 相关配置。

### 如何引用

优先使用本地文件（毫秒级，可全文搜索）：

```bash
# 全文搜索某个软件名
rg -l "bat" ~/nix/khanelinix/modules/

# 阅读特定模块
# 使用 read 工具读取：~/nix/khanelinix/modules/home/programs/terminal/tools/git/default.nix

# 列出 Darwin 模块目录
ls ~/nix/khanelinix/modules/darwin/
```

当本地 clone 过时需要更新时：
```bash
cd ~/nix/khanelinix && git pull --ff-only
```

`fetch_content` 只在以下情况作为补充：需要查看仓库最新 commit 是否有变动，或本地 clone 损坏时。

### 重要：适配而非照搬

khanelinix 使用 `khanelinix.*` 命名空间, 本项目使用 `dot.*`（兼容 `arrakenix.*`）。引用时需要：

1. 把 `khanelinix.*` 替换为 `dot.*`。
2. 把 `khaneliman` 用户名替换为 `arrake`。
3. 移除本项目不需要的功能（如 sops-nix 密钥管理、NixOS 特定硬件配置等）。
4. 保持本项目的模块模板风格（`inherit (lib) ...`、`mkIf cfg.enable`）。

## 8. 文档维护

- 修改流程变化时，更新 `docs/conventions.md`。
- 文档结构变化时，更新 `docs/README.md`。
- 架构规则变化时，更新 `docs/architecture/`。
- 单次较大功能设计放入 `docs/specs/`。
- `AGENTS.md` 只做规则入口和索引，不承载完整架构说明。
- 如果 `README.md` 与本文件或架构文档不一致，优先更新 README，而不是降低规则标准。
