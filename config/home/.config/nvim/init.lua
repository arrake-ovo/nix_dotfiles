vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true

-- Use an isolated npm cache for tools installed from Neovim plugins like Mason.
-- This avoids permission issues when the user's global npm cache was previously
-- written by another account (for example via sudo).
vim.env.NPM_CONFIG_CACHE = vim.fn.stdpath("cache") .. "/npm"

if vim.loader then
  vim.loader.enable()
end

-- bootstrap lazy.nvim, LazyVim and your plugins

if _G.init_debug then
  local osv_path = vim.fn.stdpath("data") .. "/lazy/one-small-step-for-vimkind"

  if vim.loop.fs_stat(osv_path) then
    vim.opt.rtp:prepend(osv_path)
    require("osv").launch({ port = 8086, blocking = true })
  else
    print("Error: OSV plugin not found at " .. osv_path)
  end
end

require("config.lazy")
