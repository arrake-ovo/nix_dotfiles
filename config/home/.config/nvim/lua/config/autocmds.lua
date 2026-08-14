-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function set_cursor_highlight()
  local palette = vim.o.background == "light" and { bg = "#223249", fg = "#fff7e6" }
    or { bg = "#dca561", fg = "#1f1f28" }

  for _, group in ipairs({ "Cursor", "lCursor", "TermCursor" }) do
    vim.api.nvim_set_hl(0, group, {
      bg = palette.bg,
      fg = palette.fg,
    })
  end
end

local cursor_group = vim.api.nvim_create_augroup("adaptive_cursor_highlight", { clear = true })
-- local autosave_group = vim.api.nvim_create_augroup("lazyvim_autosave", { clear = true })
--
-- local function save_buffer()
--   local bufnr = vim.api.nvim_get_current_buf()
--   if not vim.api.nvim_buf_is_valid(bufnr) then
--     return
--   end
--
--   if vim.bo[bufnr].buftype ~= "" then
--     return
--   end
--
--   if not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
--     return
--   end
--
--   if vim.api.nvim_buf_get_name(bufnr) == "" or not vim.bo[bufnr].modified then
--     return
--   end
--
--   vim.cmd("silent update")
-- end
-- vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost" }, {
--   group = autosave_group,
--   callback = save_buffer,
-- })

vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
  group = cursor_group,
  callback = set_cursor_highlight,
})

vim.api.nvim_create_autocmd("OptionSet", {
  group = cursor_group,
  pattern = "background",
  callback = set_cursor_highlight,
})
