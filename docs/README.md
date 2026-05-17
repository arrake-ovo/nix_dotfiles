# 文档地图

本目录只保留少数稳定入口。想知道某个文档的作用，先读本文件。

## 入口

| 文档 | 作用 | 什么时候读 |
|------|------|------------|
| [conventions.md](conventions.md) | 变更流程约定：修改代码和文件前后怎么做 | 改代码、改文档、改目录结构前 |
| [architecture/README.md](architecture/README.md) | 架构文档入口：项目如何分层、模块如何发现、系统如何构建 | 改 `flake/`、`lib/`、`modules/`、`systems/`、`homes/` 前 |
| [reference.md](reference.md) | 外部参考资料，主要来自 khanelinix | 需要理解参考项目背景时 |

## 目录职责

| 目录 | 职责 |
|------|------|
| `docs/architecture/` | 稳定架构说明，解释项目结构和设计原则 |
| `docs/specs/` | 单次较大改动的设计记录，不存放长期规则 |
| `docs/modules/` | 模块说明，镜像 `modules/` 结构；没有模块文档时可以不存在 |
| `docs/html/` | 生成出来的人类浏览页面；没有生成物时可以不存在 |

## 不放在 docs 里的内容

- AI 执行入口放在仓库根目录 `AGENTS.md`。
- 项目快速介绍放在仓库根目录 `README.md`。
- 修改流程写在 [conventions.md](conventions.md)，架构细节写在 `docs/architecture/`。
- 临时任务计划写在 `docs/specs/`，不要写进长期规则。
