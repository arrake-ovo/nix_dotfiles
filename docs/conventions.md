# 变更流程约定

本文记录修改代码和文件时的稳定流程。架构细节放在 `docs/architecture/`，单次任务计划放在 `docs/specs/`。

## 1. 修改前

先判断本次改动属于哪一类：

| 改动类型 | 先读 |
|----------|------|
| 文档结构 | `docs/README.md`、本文 |
| 架构、分层、自动发现 | `docs/architecture/README.md` |
| 新增或修改模块 | `docs/architecture/02-module-system.md` |
| 修改 `lib/` 或构建器 | `docs/architecture/03-lib-layer.md` |
| 修改 `systems/` 或 `homes/` | `docs/architecture/04-systems-homes.md` |

然后做三件事：

1. 找到相邻或同类实现。
2. 确认本次改动应该落在哪个目录。
3. 只在必要范围内改文件。

## 2. 修改中

- 遵循现有目录职责，不把不同层级的逻辑混在一起。
- 不顺手重构无关文件。
- 不删除用户已有配置，除非用户明确要求。
- 如果文档和代码不一致，先以真实代码确认影响范围，再决定是否同步文档。
- 如果改动会改变架构行为，必须同步更新 `docs/architecture/`。

## 3. 修改后

按改动范围检查是否需要同步文档：

| 改动 | 需要检查 |
|------|----------|
| 改文档结构 | `docs/README.md` 和本文 |
| 改架构、分层、发现机制 | `docs/architecture/` |
| 新增或修改模块 | 是否需要模块说明文档 |
| 较大功能或设计变更 | 是否需要 `docs/specs/YYYY-MM-DD-topic.md` |

能验证就运行相关验证；不能验证时说明原因。

## 4. 命名基础

- 文档文件使用 `kebab-case.md`。
- 目录名使用 `kebab-case`。
- Nix 变量和 option 使用 `camelCase`。
- 每个模块使用目录模块：`<name>/default.nix`。
- 架构章节可以使用数字前缀，例如 `01-overview.md`。
- 规格文档使用日期前缀：`YYYY-MM-DD-topic.md`。

## 5. 静态配置文件

- 应用/工具的静态配置文件放 `config/`，**不要**和 `modules/**/default.nix` 放在同一目录。
- 映射到用户 home 的文件放 `config/home/`，路径镜像 `$HOME`：  
  `~/.config/foo/bar` → `config/home/.config/foo/bar`。
- **`config/home/` 下的所有配置都直接软链接到项目文件**（`lib.file.getFile` + `mkOutOfStoreSymlink`）：修改项目文件即时生效，**无需 rebuild**。
- **优先使用软件原生配置文件**（json/toml/kdl/yaml 等，放 `config/home/` 镜像 `$HOME`），**不要用 Nix 模块的 settings 等 option 生成配置**；只有软件没有独立配置文件可循时才考虑生成式。
  - 符合此原则：zsh（.zshrc）、yazi（toml/lua）、karabiner（json）、squirrel（Rime）、zellij（kdl）等。
  - 反例：`programs.git.settings`、`programs.starship.settings` 这类把配置写死在 Nix 里的做法（修改需 rebuild，且偏离软件原生格式）。
  - `lib.file.getFile` 返回仓库真实路径，仓库根路径唯一集中在 `lib/file/default.nix` 的 `repoRoot`；换机器或移动仓库只改这一处。
  - Home 模块示例：`sourceRoot = lib.file.getFile "config/home"`，再 `mkOutOfStoreSymlink "${sourceRoot}/..."`。
  - Darwin / NixOS 模块在 `home-manager.users.<name>` 子模块里用 `config.lib.file.mkOutOfStoreSymlink (lib.file.getFile "config/home/...")`。
- 不要直接拿 `lib.file.getFile` 的结果作为 `home.file`/`xdg.configFile` 的 `source`（HM 会复制进 store，变成只读副本）；必须经过 `mkOutOfStoreSymlink`。
- 细节与示例见 [architecture/02-module-system.md](architecture/02-module-system.md)「第六步：静态配置文件放 config/」。
