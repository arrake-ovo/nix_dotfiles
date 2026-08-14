# `lua/plugins/flash.lua`

## 作用

这个文件把 `flash.nvim` 收敛成“屏幕内跳转和结构跳转工具”，而不是把它扩展成一整套替代搜索系统。

## 为什么这样写

- 你已经有 `snacks picker` 负责列表搜索、grep、symbols。
- `flash` 更适合负责“当前屏幕内直接落点”。
- 所以这里刻意禁用了它最容易扩大边界的部分，只保留最有价值的能力。

## 当前保留的能力

### `s`

普通 `flash.jump()`。

理由：

- 这是 `flash` 最核心的入口。
- 只在当前窗口内跳，可以让行为更稳定、更容易预期。

### `S`

`flash.treesitter()`。

理由：

- 这是 `flash` 和普通文本搜索最不重叠的一项能力。
- 适合在“文本位置不重要，结构范围更重要”的场景里用。

### `r`

operator-pending 下的 `flash.remote()`。

理由：

- 远程 operator 是 `flash` 的独特能力之一。
- 它不是高频，但一旦用到，收益很高。

### `R`

`flash.treesitter_search()`。

理由：

- 这是“先搜文本，再按结构选范围”的混合入口。
- 比单纯 jump 更重，但在某些结构化修改场景里有价值。

## 为什么禁用 `char`

`char.enabled = false` 的意思是，不让 `flash` 接管 `f/F/t/T`。

原因：

- 你已经判断这组按键使用频率不高。
- 它们有替代方案，不值得再引入一层新的心智模型。
- 让 `flash` 只做它最擅长的事，整体更干净。

## 为什么默认关闭 search integration

`search.enabled = false`

原因：

- `/ ?` 已经是 Vim 里一套成熟心智模型。
- 如果让 `flash` 默认接管，会把“普通搜索”和“标签跳转”混在一起。
- 当前阶段你更需要边界清楚，而不是功能叠加。

## 标签为什么排除 Colemak 方向键

`label.exclude` 排除了 `n/u/e/i` 及其大写。

原因：

- 这些键已经是你配置里的基础运动语义。
- 如果 `flash` 把它们拿去做 label，会直接和肌肉记忆冲突。

## `<leader>sf` / `<leader>sF`

这两个键是显式补充入口：

- 一个用于更重的文本搜索式 jump
- 一个用于跨窗口 jump

为什么不用 `<leader>ss` / `<leader>sw`：

- 这两组键已经被 `snacks picker` 的 symbols 和 grep 体系占用。
- `flash` 不应该去抢你现有的搜索主入口。

## `<leader>sx`

这是一个“Flash Treesitter Select”入口。

它的目标不是替代原生 Treesitter incremental selection，而是给你一个可视化的结构范围切换模式。

原因：

- `<C-Space>` 已经被 Treesitter 原生增量选择占用。
- 这里单独给它一个 `<leader>s` 组入口，可以把“结构范围选择”作为显式工具来用，而不是作为编辑中的基础动作强行塞进高频键。

