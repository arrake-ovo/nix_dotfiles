# `lua/plugins/ui.lua`

## 作用

这个文件负责少量但关键的 UI 层调整：

- which-key 风格
- bufferline 选中态样式
- lazy.nvim 自己界面的键位

## 为什么这样写

- UI 层最怕“到处轻改一点，最后没有统一原则”。
- 这个文件目前只动三个最会影响整体观感和一致性的地方，属于非常克制的 UI 定制。

## `which-key`

把 `preset` 改成 `classic`。

原因：

- 默认 preset 可能更偏 LazyVim 自身的组织方式。
- 改成 `classic`，说明你更看重稳定、直接、低惊喜的提示风格。

## `bufferline`

把当前 buffer 的选中态去掉 `italic` 和 `bold`。

原因：

- 这种样式虽然醒目，但容易让 UI 强调过头。
- 去掉后，标签栏层级会更平，视觉上更克制。

## `lazy.nvim` 界面键位

你改了：

- `hover = K`
- `diff = d`
- `close = q`
- `details = motions.right`
- `home = motions.left`

原因：

- `lazy.nvim` 自己也是一个列表/详情双栏界面。
- 所以继续沿用你的方向语义，比接受它的默认键位更一致。
- 同时保留 `q` 关闭、`d` diff 这类通用约定，又说明你没有为了“一致”而无差别重写全部键位。

