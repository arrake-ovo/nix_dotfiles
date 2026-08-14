# `lua/plugins/git.lua`

## 作用

这个文件定制 `gitsigns.nvim` 的两部分：

- 左侧 signcolumn 里的 Git 变化标记
- 当前 buffer 内的 Git hunk 操作键位

## 为什么这样写

- 你已经有稳定的 Colemak 方向语义，所以 Git hunk 导航也应该接进同一套习惯。
- 但 `gitsigns` 默认那套能力本身是实用的，所以这里不是推翻默认，而是在默认之上补一层更贴近你手感的入口。

## 当前设计

- `add` / `change` / `changedelete` / `untracked` 统一用细竖线 `▎`
- `delete` / `topdelete` 用 ``
- `<leader>gu` / `<leader>ge` 用来跳到上一个 / 下一个 hunk
- `<leader>gU` / `<leader>gE` 用来跳到第一个 / 最后一个 hunk
- `<leader>gs` / `<leader>gr` 用来 stage / reset 当前 hunk
- `<leader>gS` / `<leader>gR` 用来 stage / reset 整个 buffer
- `<leader>gp` 预览 hunk
- `<leader>gb` 查看当前行 blame
- `<leader>gd` 查看当前 diff

## 为什么这么配

- 细竖线占用空间小，适合频繁出现在 signcolumn。
- 删除用一个更明显的形状，有助于在视觉上快速区分“改动”与“删除”。
- staged 和 unstaged 采用一致风格，说明你的目标是“信息结构一致”，而不是让两个状态完全不同色相/符号体系。
- `u/e` 承接了你整套配置里“上一个 / 下一个”的方向语义，所以在 Git hunk 导航里继续使用它们，比继续依赖默认的 `]h` / `[h` 更一致。
- 仍然保留默认 `gitsigns` 的行为层，说明这里追求的是“低学习成本的收敛”，而不是为统一而重写一切。

## 这份配置背后的使用模型

如果你几乎不了解 `gitsigns`，可以只先记住四组动作：

- 看改动：左侧标记
- 在改动间移动：`<leader>gu` / `<leader>ge`
- 暂存或撤销一段改动：`<leader>gs` / `<leader>gr`
- 看这段改动的具体内容：`<leader>gp`

这样已经覆盖了日常最常见的 Git 行内工作流。
