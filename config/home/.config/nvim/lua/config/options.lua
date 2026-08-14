-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- This file is automatically loaded by plugins.core

vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.shiftwidth = 2 -- Amount to indent with << and >>
vim.opt.tabstop = 2 -- How many spaces are shown per Tab
vim.opt.softtabstop = 2 -- How many spaces are applied when pressing Ta

vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true -- Keep identation from previous line

if vim.g.neovide then
  vim.o.guifont = "Cascadia Code NF"
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_cursor_animation_length = 0.04
end

vim.opt.guicursor =
  "n-v-c-sm:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr-o:hor20-Cursor/lCursor,t:block-TermCursor"
