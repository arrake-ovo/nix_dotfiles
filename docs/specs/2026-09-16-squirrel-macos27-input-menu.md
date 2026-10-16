# macOS 27 鼠须管菜单栏消失

日期：2026-09-16  
状态：鼠须管本机会话已修好；青简随后也已加入可切换列表。仓库持久化已写入。`darwin-rebuild switch` 需用户同意后再做。

## 现象

菜单栏输入法图标点开只有：

- 显示表情与符号
- 显示虚拟键盘
- 打开键盘设置…

没有 ABC、没有鼠须管。当前实际输入源是 `com.apple.keylayout.ABC`。`macism` 切 `im.rime.inputmethod.Squirrel.Hans` 报不存在。鼠须管进程起不来。

这不是「键盘设置坏了」，而是系统把这个菜单当成**表情/虚拟键盘面板**来画：可切换的键盘源只剩 ABC 一个时，macOS 27 就不列出输入法。

## 环境

- 主机：`mba`，macOS 27.0（build 26A428）
- 声明的中文输入法：鼠须管 Squirrel 1.1.2（Homebrew cask `squirrel-app`）
- 方案：`config/home/Library/Rime`（submodule `arrake-ovo/rime-config`），Colemak 上的微软双拼
- 英文：系统 ABC 布局；Colemak 由 Karabiner 映射，不注册系统 Colemak
- 中英切换意图：Karabiner 单击 Fn/Globe；Chrome/Codex 里 Ctrl+Space
- 同日磁盘上还有手动安装的青简 Qingjian 0.1.2（`/Library/Input Methods/Qingjian.app`），不在 flake 里

## 意图中的链路

```text
dot.darwin.suites.common
  → suites.core.system.input          # HIToolbox：ABC + 鼠须管父项 + Hans（+ 可选青简）；Fn=0
  → programs.inputmethods.squirrel    # cask、Rime 软链、TIS 注册；顺带拉起青简
  → programs.inputmethods.qingjian    # 仅 option；条目经 optionals 并进 HIToolbox / 第三方列表
  → programs.inputmethods.ime-switch  # macism + yazi 进英文
  → services.karabiner-elements       # Fn 单击切鼠须管 / ABC
```

系统层不注册 Colemak 键盘布局：用输入法自带布局时，部分软件底层输入码不变。

## 排查经过

按表面现象一路排除，真正根因是后面两条叠在一起。

### 1. 先核对声明配置

Nix 里鼠须管是开的：cask、HIToolbox 同时写了 `Keyboard Input Method` 和 `Input Mode`（只写 Mode 时 TIS 会在 `activateSettings` 后丢掉）、LaunchAgent 在用户 Aqua 会话里 `--register-input-source` / `--enable-input-source`。Rime 目录是 `mkOutOfStoreSymlink`，软链是通的。

结论：不是「模块没启用」。

### 2. 青简不是这次菜单空白的原因

`qingyan` 在仓库和 Homebrew 里都不存在，本机对应的是 **青简 Qingjian**。pkg 收据 `app.qingjian.inputmethod` 0.1.2，当天 22:21 装到 `/Library/Input Methods`。HIToolbox / 已启用 TIS 列表里没有它。adhoc 签名，`spctl` 拒绝。TISEnable 返回 0，但仍然进不了「仅已启用」列表。

结论：青简是额外手动安装，菜单空白在装它之前就已经符合「只有一个可切换键盘源」的 UI。

### 3. Karabiner 规则被本机关掉

仓库 `karabiner.json` 里 Fn 切换、Chrome/Codex Ctrl+Space 是开的。本机 `~/.config/karabiner/karabiner.json` 不是 HM 软链（Karabiner 自己会重写成普通文件），这两条被标成 `"enabled": false`。

这解释了「Fn 切不了」，**解释不了**菜单栏为什么没有鼠须管。后来把本机这两条重新打开。

### 4. TIS 撒谎：属性说已启用，会话列表里没有

`TISCreateInputSourceList(NULL, true)`（全部已安装）里：

- `im.rime.inputmethod.Squirrel`（父项，`TISTypeKeyboardInputMethodModeEnabled`）`enabled=true`，**不能直接选**（`can=false`）
- `im.rime.inputmethod.Squirrel.Hans`（简体模式）属性上也曾是 `enabled=true`

`TISCreateInputSourceList(NULL, false)`（当前会话已启用）里只有：

- ABC
- `com.apple.CharacterPaletteIM`（表情与符号）
- 鼠须管**父项**

没有 Hans。菜单栏因此只画表情/虚拟键盘。`macism` 按「可选用源」查找 Hans，报 does not exist。

`com.apple.inputsources.AppleEnabledThirdPartyInputSources` 当时只有父项 Bundle，没有 Input Mode。macOS 27 认这个 domain；只写 `com.apple.HIToolbox` 不够。

Squirrel CLI `--enable-input-source Hans` 打印 `User already enabled`，但会话列表仍然没有 Hans。必须对**全量列表里的那个 Input Mode 对象**调 `TISEnableInputSource`。

### 5. 签名坏了，IMK 拉起来立刻死

即使 TIS select 返回成功（`noErr` / CLI 打印 Selection succeeds），`Squirrel` 进程也不在。一两秒后当前源掉回 ABC。没有 crash report。

`codesign --verify --deep --strict`：

```text
a sealed resource is missing or invalid
file added: .../Contents/SharedSupport/installation.yaml
file added: .../Contents/SharedSupport/user.yaml
file added: .../Contents/SharedSupport/build/*.bin
```

这些文件是 2026-07-13 装 cask 时 pkg 以 root 跑 rime_deployer 写进 bundle 的，不在签名封印里。`spctl`：sealed resource is missing or invalid。macOS 27 拒绝维持 IMK。

清掉这三处之后：`valid on disk` / `Notarized Developer ID`。再 TISEnable Hans，进程能留下来，`macism` 能在 ABC 和 Hans 之间切换。

用 `open Squirrel.app` 当普通 App 拉起，会打乱 IMK 注册，反而让 CLI select 失败。不要这么做。

## 根因（两条必须同时成立）

1. **Bundle 签名被 SharedSupport 部署产物破坏** → IMK 无法常驻。
2. **macOS 27 未把 `Squirrel.Hans` 放进会话已启用列表** → 菜单只剩表情面板；Squirrel CLI 的 enable 对此无效。

只修签名：选中仍会失败或立刻掉回 ABC。只 TISEnable：进程会被 Gatekeeper 杀掉。两条都修，菜单才会列出 ABC 和鼠须管。

## 修复

### 本机（当时已做，无需 switch）

- 管理员权限删除：
  - `/Library/Input Methods/Squirrel.app/Contents/SharedSupport/build`
  - `installation.yaml`、`user.yaml`
- 写入 `com.apple.inputsources` 第三方列表：父项 + Hans
- 用 TIS API 启用父项、Hans、ABC，选中 Hans，关掉误带上的 Ainu/Hiragana
- 打开本机 Karabiner 的 Fn / Ctrl+Space 两条规则

修好后会话已启用列表：

```text
com.apple.CharacterPaletteIM          表情与符号
com.apple.keylayout.ABC               ABC
im.rime.inputmethod.Squirrel          鼠须管父项（不可直接选）
im.rime.inputmethod.Squirrel.Hans     鼠须管简体（可切换）
```

当前源：`im.rime.inputmethod.Squirrel.Hans`，Squirrel 进程常驻。

### 仓库持久化

| 路径 | 作用 |
|------|------|
| `modules/darwin/programs/inputmethods/squirrel/default.nix` | 见下 |
| `modules/darwin/programs/inputmethods/squirrel/enable-tis.py` | 对全量 TIS 列表启用并选中 Hans |
| `modules/darwin/system/input/default.nix` | 仍写 HIToolbox（ABC + 父项 + Hans，`AppleFnUsageType=0`） |
| 本机 `~/.config/karabiner/karabiner.json` | 打开 IME 规则（Karabiner 会重写活文件，仓库 json 里这两条本来就是开的） |

squirrel 模块现在做四件事：

1. `extraActivation`（root）：每次 rebuild 清掉 SharedSupport 里破坏签名的文件。pkg 重装还会再写，所以要反复清。
2. `CustomUserPreferences."com.apple.inputsources"`：第三方列表同时写父项和 Hans。
3. 用户 LaunchAgent：Aqua 会话里 `--register-input-source`，再跑 `enable-tis.py`，然后 `killall TextInputMenuAgent`。darwin-rebuild 的 activation 没有 WindowServer，不能在那里调 TIS。
4. `postActivation`：`launchctl kickstart` 该 Agent，避免只在登录时跑一次、`activateSettings` 后又丢掉。

`enable-tis.py` 还要启用 ABC（否则 Fn 切不回英文），并 disable 启用 ABC 时 TIS 误带上的 Ainu / 日文假名模式。

## 以后怎么查

```sh
# 签名（必须 valid / accepted）
codesign --verify --deep --strict "/Library/Input Methods/Squirrel.app"
spctl --assess --verbose "/Library/Input Methods/Squirrel.app"

# 当前源
macism

# 会话已启用列表必须包含 ABC 和 Squirrel.Hans
# TISCreateInputSourceList(NULL, false)
# 全量列表里 Hans 存在不算数

defaults read com.apple.inputsources AppleEnabledThirdPartyInputSources
defaults read com.apple.HIToolbox AppleEnabledInputSources

pgrep -x Squirrel
```

HIToolbox 仍可能被系统改回「ABC + 表情面板」；macOS 27 以 `com.apple.inputsources` + 会话 TIS 列表为准。LaunchAgent 负责把 Hans 重新塞进会话。

不要用 `open Squirrel.app` 当普通应用启动。不要只信 Squirrel CLI 的 `already enabled` / `Selection succeeds`。

## 青简为什么菜单里没有（后补）

包已经在 `/Library/Input Methods/Qingjian.app`（0.1.2，adhoc 签名，`spctl` rejected）。只往 `AppleEnabledThirdPartyInputSources` 里写 Bundle、只调 `TISEnableInputSource`，返回 0，**会话已启用列表里仍然没有它**。

和鼠须管不同：青简是 `TISTypeKeyboardInputMethodWithoutModes`，IMK 进程没起来时 TIS 不肯把它放进可切换源。`open "/Library/Input Methods/Qingjian.app"` 拉起 `qingjian-macos` 之后，再 TISEnable / TISSelect 才会进列表，`macism` 变为 `app.qingjian.inputmethod`。

持久化：

- `dot.darwin.programs.inputmethods.qingjian.enable`（suites.common 默认开）
- `system.input` 的 HIToolbox 与 squirrel 的第三方列表用 `optionals` 追一条青简
- `enable-tis.py`：若 app 存在则 `TISRegisterInputSource`、`open`、再 TISEnable。登录时仍选中鼠须管简体，青简只出现在菜单里

没有 Homebrew cask，pkg 仍需手动安装。测试版无开发者签名，若以后 `open` 被拦，到「系统设置 → 隐私与安全性」点「仍要打开」。

## 配置迁移（Rime → 青简）

青简用 `~/Library/Application Support/Qingjian/config.toml`，不是 Rime yaml。0.1.2 的 `shuangpin` 只能是空（全拼）或 `xiaohe` / `ziranma` / `microsoft` / `sogou`，**不能**导入 `double_pinyin_mspy.schema.yaml` 里那套 Colemak 改键表。

已迁入仓库并写入本机：

| Rime | 青简 |
|------|------|
| `schema: double_pinyin_mspy`（Colemak 改键） | 未迁键位。内置 `microsoft` 是标准表（你好=`nihk`），用户方案是 `nihf`。见 `docs/TODO.md` |
| `menu.page_size: 4` | `page_size = 4` |
| `ascii_punct reset: 1` | `full_width_punctuation = false` |
| `candidate_list_layout: linear` | `layout = "horizontal"` |
| `inline_preedit: true` | `preedit = "both"` |
| `custom_phrase_double.txt` | `dicts/custom_phrase.tsv`（音节改成全拼，空格分音节） |

Nix：`qingjian` 模块把上述两个文件 `mkOutOfStoreSymlink` 到 Application Support。密钥仍只在本机 `.env`，不进仓库。

Colemak 自定义键位已作为 `colemak_mspy` 编进 `~/nix/qingjian` 引擎（`nihf`→你好）。`config.toml` 使用 `shuangpin = "colemak_mspy"`。

## 未纳入本次范围

- **Karabiner 活文件不是仓库软链**：Karabiner GUI 会把 `mkOutOfStoreSymlink` 换成普通文件。改仓库 json 不会自动进正在跑的 Karabiner。下次 HM switch 可能重新链上（`backupFileExtension = backup`）。
- **未执行** `darwin-rebuild switch --flake .#mba`。模块改动要 switch 之后才在以后的登录 / rebuild 上自动跑。

## 验证（当时）

- `macism`：`ABC` ↔ `im.rime.inputmethod.Squirrel.Hans` 可来回切，Squirrel 进程仍在。
- `codesign --verify --strict` 通过。
- `nix eval .#darwinConfigurations.mba.config.launchd.user.agents.squirrel-enable-input-source.serviceConfig.ProgramArguments` 通过（`enable-tis.py` 必须 `git add`，否则 flake 看不见）。
- Karabiner 进程仍在，IME 两条规则 `enabled=true`。
