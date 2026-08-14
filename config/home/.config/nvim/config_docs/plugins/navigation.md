# `lua/plugins/navigation.lua`

## 作用

这是你当前导航体系里最重的一份配置，主要定制：

- `snacks.nvim` picker / explorer
- `mini.files`

## 为什么这份文件重要

从整体结构看，你的配置不是围绕“插件列表”组织的，而是围绕“导航体验”组织的。  
这份文件就是这个思路最完整的体现。

## `split_open()`

这个辅助函数专门处理“从 picker 结果打开到不同分屏方向”。

为什么不直接调用原始动作：

- 你希望打开方向是稳定可控的。
- `splitright` / `splitbelow` 是全局选项，如果不临时保存和恢复，picker 动作会污染后续窗口行为。
- 用 `pcall()` 包住动作，再恢复选项，是为了保证失败时也不把窗口选项留在错误状态。

## `picker.actions`

你新增了：

- `open_right`
- `open_left`
- `open_up`
- `open_down`
- `select_item`
- `insert_input`

为什么这样做：

- `snacks picker` 默认行为不完全符合你的窗口导航模型。
- 你想把“在结果列表里选中”“切换回输入框”“按方向分屏打开”都变成显式动作。

## `win.input`

这里重点是把输入窗口的操作和列表窗口的操作分清。

原因：

- picker 是多窗体界面，不只是一个搜索框。
- 你需要在 input、list、preview 三个区域之间快速切换，所以给它们分别定义语义很合理。

特别值得注意的点：

- 你刻意禁用了 `u/e/n`
- 保留 `h/p/i/k` 等少量高层动作

这表示你不希望基础方向键在输入框里承担太多职责，避免和文本输入冲突。

## `win.list`

这是最典型的 Colemak 列表化改造：

- `u/e` 负责上下
- `i` 负责更深入的查看
- `k` 回到输入
- `si/sn/su/se` 负责分方向打开

为什么这样写：

- 列表窗口是高频界面。
- 与其适配每个插件的原生默认键，不如直接把它收敛成你自己的“列表语言”。

## `win.preview`

这里没有塞太多能力，只保留了：

- 回列表
- 回输入
- 预览滚动
- 窗口循环

原因：

- preview 只是辅助观察窗口，不应该承担主导航职责。
- 让它保持轻量，能减少在三窗结构里的认知负担。

## `sources.explorer`

这里单独给 explorer 覆盖了一套 list 键。

原因：

- explorer 比普通 picker list 多了目录层级和关闭行为。
- 所以 `n = explorer_close`、`U = explorer_update` 这类动作需要单独补。

## `mini.files`

这里只改了最关键的进入/退出动作：

- `go_in = motions.right`
- `go_out = motions.left`

原因：

- 文件树里最重要的是“进目录”和“出目录”。
- 把这两个动作统一到 `i/n` 方向语义，比把整套 `mini.files` 映射全部改掉更划算。

