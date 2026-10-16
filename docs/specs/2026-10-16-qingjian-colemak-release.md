# 青简 Colemak 微软双拼定制版发布

日期：2026-10-16

## 源码与下载

- 上游：[qingjian-team/qingjian](https://github.com/qingjian-team/qingjian)。
- 个人 fork：[arrake-ovo/qingjian](https://github.com/arrake-ovo/qingjian)，定制源码位于 `codex/colemak-mspy` 分支。
- 发布：[colemak-macos-v0.1.3-colemak.1](https://github.com/arrake-ovo/qingjian/releases/tag/colemak-macos-v0.1.3-colemak.1)。
- 编译包：`Qingjian-0.1.3-colemak.1-arm64.pkg`，仅供 macOS Apple Silicon；安装器声明 macOS 13 或更新版本。
- 附件：`SHA256SUMS`、`build-info.json`，分别用于校验下载内容与核对源码提交、工具链及数据版本。

这是个人定制发布。上游官方包没有本仓库依赖的 `colemak_mspy`，不能直接替代这个版本。源码与原项目的许可证、署名保持一致。

## 定制内容

基于上游提交 `db9f31871487404cb586ef07fad56b9d37bd4274`，保留原定制提交 `b7beeaf9f672eca139d78a2bab61e40a228c39ed`，再整理打包修复和说明。

- 增加「微软双拼（Colemak）」方案，配置值 `colemak_mspy`，对应 Rime 的 `colemak_custom_mspy`。
- `nihf` 解码为 `ni'hao`（你好），`x;` 为 `xun`，`xg` 为 `xue`；ao 的零声母输入为 `of` 或 `af`。
- 没有生成词库时，打包优先回退到完整 lexicon，避免只携带少量示例词条。
- 发布包使用上游 `tools/release/data.lock` 固定且经过 SHA-256 验证的产品数据；不从本机用户数据目录取词库、学习记录或密钥。

## Nix 管理范围

`modules/darwin/programs/inputmethods/qingjian/default.nix` 通过 Home Manager 软链接以下文件：

| 仓库文件 | 用户目录 |
|---|---|
| `config/home/Library/Application Support/Qingjian/config.toml` | `~/Library/Application Support/Qingjian/config.toml` |
| `config/home/Library/Application Support/Qingjian/dicts/custom_phrase.tsv` | `~/Library/Application Support/Qingjian/dicts/custom_phrase.tsv` |

`system.input` 与 `squirrel` 模块配合注册输入源。**青简应用本身尚未由 Nix 或 Homebrew 安装**，换机器时仍需安装定制版应用。

API 密钥保留在本机 `~/Library/Application Support/Qingjian/.env`，不在源码仓库或发布包里。Release 不包含个人学习词库和输入日志。

## 安装

1. 下载 Release 中的 pkg、`SHA256SUMS` 和 `build-info.json`，在下载目录运行 `shasum -a 256 -c SHA256SUMS`。
2. 如果存在 `~/Library/Input Methods/Qingjian.app` 开发副本，先按 fork 的 [macOS 卸载说明](https://github.com/arrake-ovo/qingjian/blob/codex/colemak-mspy/apps/macos/README.md) 移除旧应用，保留配置与学习数据，避免重复副本冲突。
3. 手动打开 pkg，安装到 `/Library/Input Methods/Qingjian.app`。本次发布过程只生成安装包，没有执行安装或 Nix 系统切换。
4. 应用为 ad-hoc 签名，pkg 未经 Developer ID 签名和 Apple 公证；若 macOS 拦截，在「系统设置 → 隐私与安全性」按提示允许。
5. 添加或切换到青简，确认设置中的双拼方案为「微软双拼（Colemak）」。本仓库的配置已设置 `shuangpin = "colemak_mspy"`。

完整键位表与从源码构建的命令见 fork 的 [定制版说明](https://github.com/arrake-ovo/qingjian/blob/codex/colemak-mspy/docs/notes/colemak-mspy.md)。
