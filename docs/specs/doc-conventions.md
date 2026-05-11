# 文档规范 (Documentation Conventions)

> **目标读者：AI Agent（Codex/Claude）**
> 本文档定义项目文档的编写、组织与维护规范。AI Agent 在修改代码或生成文档时必须遵循此规范。

---

## 1. 文档体系总览

```
docs/
├── specs/
│   └── doc-conventions.md      ← 本文档：规范定义（Agent 读取）
├── architecture/               ← 架构文档（Agent 主要读者，人类通过 HTML 阅读）
│   ├── README.md               ← 导航索引
│   ├── 01-overview.md          ← 项目总览与设计哲学
│   ├── 02-module-system.md     ← 模块发现机制、options 命名空间
│   ├── 03-lib-layer.md         ← lib/ 函数与系统构建器
│   └── 04-systems-homes.md     ← 主机/用户配置自动发现
├── modules/                    ← 镜像 modules/ 结构（人类读者）
│   ├── README.md               ← 索引入口
│   ├── common/
│   │   └── nix.md
│   ├── darwin/
│   │   ├── nix.md
│   │   ├── home.md
│   │   ├── user.md
│   │   ├── suites/
│   │   │   └── common.md
│   │   └── tools/
│   │       └── homebrew.md
│   └── home/
│       ├── host.md
│       ├── user.md
│       ├── suites/
│       │   ├── common.md
│       │   └── development.md
│       ├── roles/
│       │   └── developer.md
│       └── programs/
│           ├── legacy-minimal.md
│           └── terminal/
│               ├── shell/
│               │   └── zsh.md
│               └── tools/
│                   ├── direnv.md
│                   ├── eza.md
│                   ├── fzf.md
│                   ├── git.md
│                   ├── gh.md
│                   ├── jq.md
│                   ├── lazygit.md
│                   ├── ripgrep.md
│                   └── zoxide.md
└── html/                       ← 由 skill 生成，给人看的 HTML 站点
```

### 受众分离

| 受众 | 文件 | 格式 | 说明 |
|------|------|------|------|
| **Agent** | `docs/specs/*.md` | Markdown | 规范定义，Agent 启动时读取 |
| **Agent** | `docs/architecture/*.md` | Markdown | 架构说明，Agent 理解代码库结构 |
| **人类** | `docs/modules/**/*.md` | Markdown → HTML | 镜像模块结构，每个工具一份说明 |
| **人类** | `docs/html/` | HTML | 由 skill 从 `docs/architecture/` + `docs/modules/` 生成，可引用源码 |

> **注意：** 生成 HTML 时不应仅依赖架构文档，还应直接读取源码以确保准确。

---

## 2. 架构文档规范 (`docs/architecture/`)

### 2.1 拆分策略

从项目初期即拆分为多个文件，按主题组织：

| 文件 | 内容 |
|------|------|
| `README.md` | 目录导航，每个子文档的一句话摘要 |
| `01-overview.md` | 项目目标、设计哲学、顶层目录树、数据流图 |
| `02-module-system.md` | 四层模块架构、命名空间=文件路径镜像、模块模板、套件/角色 |
| `03-lib-layer.md` | lib/ 函数分类、发现函数、构建器（mkDarwin/mkHome）、specialArgs |
| `04-systems-homes.md` | systems/ 和 homes/ 的自动发现机制、配置约定、覆盖机制 |

### 2.2 编写规则

- 使用中文撰写
- 每个文件开篇包含一句话摘要
- 代码示例使用 `nix` 语言标注
- 涉及文件路径时使用相对于项目根的路径（如 `lib/file/default.nix`）

---

## 3. 镜像文档规范 (`docs/modules/`)

### 3.1 镜像规则

`docs/modules/` 的目录结构**完全镜像** `modules/` 的目录结构：

```
modules/home/programs/terminal/tools/git/default.nix
                               ↕
docs/modules/home/programs/terminal/tools/git.md
```

- 每个包含 `default.nix` 的模块目录，在 `docs/modules/` 下有对应的 `.md` 文件
- 使用 `.md` 文件而非 `README.md`（避免与 Git 平台的 README 渲染混淆）
- 目录树完全一致，仅叶子节点从 `default.nix` 变为 `<dirname>.md`

### 3.2 模块文档模板

每个工具/模块的 `.md` 文件遵循以下模板：

```markdown
# <工具名>

## 概述
一句话说明这个工具在本项目中扮演什么角色。

## 安装内容
列出通过 home-manager / nix-darwin 安装的包和版本来源。

## 关键配置

| 配置项 | 值 | 说明 |
|--------|-----|------|
| ... | ... | ... |

## 使用方式
常见命令、快捷键、别名。如何临时修改或覆盖配置。

## 相关文件
- 配置源文件: `modules/.../default.nix`
- 依赖的其他模块
```

### 3.3 文档索引

`docs/modules/README.md` 作为人类浏览的入口，列出所有已文档化的模块，按分类组织为树形列表，每项带一句话描述。

---

## 4. 文档维护规则

### 4.1 触发条件

| 场景 | 动作 |
|------|------|
| 新增模块（新建 `default.nix`） | 在 `docs/modules/` 创建对应镜像 `.md`，更新 `README.md` 索引 |
| 修改模块配置（修改 `default.nix`） | 同步更新对应镜像 `.md` 中的相关章节 |
| 删除模块 | 删除对应镜像 `.md`，更新 `README.md` 索引 |
| 修改 lib/ 或 flake/ 核心逻辑 | 检查 `docs/architecture/` 相关文件是否需要更新 |
| 项目结构变更（新增/重命名目录） | 更新 `docs/architecture/` 中所有受影响的文件 |

### 4.2 维护责任

- **AI Agent** 在修改任何 Nix 文件时，必须检查并同步更新对应的文档
- 修改完成后，Agent 应在响应中注明已更新的文档文件

---

## 5. Nix 代码书写规范

> *待补充 — 将在后续讨论中细化：缩进、命名、import 顺序、模块结构、commit 格式*

---

## 6. HTML 生成

> *待补充 — 将通过 skill 实现，从 `docs/architecture/` 和 `docs/modules/` 生成 HTML 站点，人类可直接在浏览器中浏览*

---

## 附录：讨论记录

- 2026-05-12: 初始讨论。确定文档体系架构、受众分离、镜像结构、架构拆分策略。
- 待讨论：Nix 代码书写规范细节、HTML 生成 skill 设计、AGENTS.md 结构。
