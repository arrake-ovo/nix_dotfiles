-- DAP entry point.
-- Keep the enabled pieces explicit here so adding or removing a language adapter
-- is always a small manual change.
local specs = {}

-- Core behavior and shared keymaps always load together.
vim.list_extend(specs, require("plugins.dap.mason"))
vim.list_extend(specs, require("plugins.dap.breakpoints"))
vim.list_extend(specs, require("plugins.dap.core"))
vim.list_extend(specs, require("plugins.dap.statusline"))
vim.list_extend(specs, require("plugins.dap.ui"))

return specs
