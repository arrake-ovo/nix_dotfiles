# 项目待办

未完成的事项。做完就勾掉，细节仍以对应 `docs/specs/` 为准。

## 青简：按 Rime Colemak 微软双拼改键

已完成。引擎方案在 `~/nix/qingjian`（commit `b7beeaf`），开发包装在 `~/Library/Input Methods/Qingjian.app`。`/Library` 里若还有 pkg 的 0.1.2，两份会互顶，删掉系统那份后切一次输入法即可。

- [x] 给青简加一套自定义双拼 `colemak_mspy`，对齐鼠须管 `config/home/Library/Rime/double_pinyin_mspy.schema.yaml`（`schema.name: colemak_custom_mspy`）。**不要用内置 `microsoft`**：那是标准微软双拼，`ao` 在 `k`，「你好」是 `nihk`。用户方案 `ao` 在 `f`，「你好」是 **`nihf`**。

### 为什么必须重编译

青简 0.1.2 的 `shuangpin` 只能是空（全拼）或 `xiaohe` / `ziranma` / `microsoft` / `sogou`，键位写死在 `qingjian-core` 的 `shuangpin/table.rs`。config.toml 无法导入 Rime algebra。Karabiner 也不能按「第二键才是韵母」做键位映射。

源码已浅克隆：`~/nix/qingjian`（先不要 `bundle.sh --install`，等明确说可以编译）。

### 动手时

1. 在 `crates/qingjian-core/src/shuangpin/` 增加 `Scheme::ColemakMspy`（serde 名 `colemak_mspy`），`ALL` 改成 5 项。
2. `table.rs` 增加 `COLEMAK_MSPY`（见下表），零声母用 `o` + 本方案韵母键（`ao`→`of`，不是标准微软的 `ok`）。
3. 测试：`nihf` → `ni'hao`；`x;` → `xun`（本方案 `;` 是 `un`，不是 `ing`）；`xg` → `xue`。`lue`/`lve` 在本方案不同键，不要套微软测试里「lue 解成 lve」。
4. `apps/macos/scripts/bundle.sh --install` 装到 `~/Library/Input Methods/`（不要和 `/Library` 那份并存硬顶）。
5. `config.toml` 设 `shuangpin = "colemak_mspy"`，并同步本机 `~/Library/Application Support/Qingjian/config.toml`。

### 键位（相对标准微软双拼）

声母仍是 `v/i/u` = zh/ch/sh。

| 键 | 本方案韵母 | 标准微软 |
|----|------------|----------|
| q | iu | 同 |
| w | ia, ua | 同 |
| r | iong, ong | uan |
| t | en | ve/ue |
| y | ing | uai/ü |
| p | uan, er | un |
| s | iang, uang | iong/ong |
| d | eng | iang/uang |
| f | ao | en |
| g | ue | eng |
| j | uai, ü | an |
| k | in | ao |
| ; | un | ing |
| v | ui, ve | ui/ve/ue |
| n | an | in |
| 其余 a e u i o h l z x c b m | 同微软 | |

对照：`config/home/Library/Rime/double_pinyin_mspy.schema.yaml` 的 `speller.algebra`。背景：`docs/specs/2026-09-16-squirrel-macos27-input-menu.md`。
