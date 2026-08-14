# `lua/plugins/markdown.lua`

## 作用

这个文件专门覆盖 Markdown 在编辑器里的渲染样式。

它不是用来重新启用 Markdown 插件，而是用来把 LazyVim 默认 extra 里那套更“简化”的 `render-markdown.nvim` 外观，调回接近你参考配置的样子。

## 为什么单独放一个文件

- 这是明确的 Markdown 领域配置，不适合混进 `ui.lua`。
- 它影响的是写 Markdown 时的观感，不是全局 UI，也不是格式化或 LSP。
- 单独拆出来以后，你以后如果继续参考别人的 Markdown 工作流，会更容易集中调整。

## 当前改了什么

### `code`

- `sign = true`
- `width = "full"`
- `right_pad = 0`

这会让代码块更接近插件默认表现，而不是 LazyVim 那种更紧凑的 block 宽度。

### `heading`

- `sign = true`
- 恢复默认标题图标

这会把标题左侧的视觉提示补回来，不再是纯文本标题。

### `checkbox`

- `enabled = true`

这会恢复任务列表项的渲染，而不是完全按普通文本显示。

### Markdown 本地链接跳转

- 在 `markdown` / `markdown.mdx` 缓冲区里，把 `gx` 改成优先解析本地链接
- 支持普通 Markdown 链接：`[text](./note.md)`
- 支持标题锚点：`[text](./note.md#section)`
- 兼容常见 wiki link：`[[note]]` / `[[note#section|alias]]`

如果目标是本地文件，会直接在当前 Neovim 窗口里打开，而不是交给系统默认应用；只有远程链接还会继续走系统浏览器。

## 为什么要这样改

你参考的 `/Users/arrake/.config/ilovevim_config` 基本没有主动改 `render-markdown.nvim` 的样式，只是启用了它。

而 LazyVim 自带的 markdown extra 会额外做几项“去装饰化”处理：

- 去掉标题图标
- 关掉 checkbox 渲染
- 让代码块更窄一点

所以你看到的“Markdown 预览样式不一样”，主要其实是编辑器内渲染差异，不是浏览器预览页主题差异。

## 当前策略

- 浏览器预览仍然沿用 `markdown-preview.nvim` 的默认行为。
- 编辑器内 Markdown 外观则优先贴近你参考配置的默认体验。
- 本地文件链接会优先在编辑器内部打开，Markdown 标题锚点也会直接在 Neovim 里跳转，减少在系统应用和 Neovim 之间来回切换。
