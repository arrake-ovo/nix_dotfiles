local uv = vim.uv or vim.loop

local M = {}

function M.join_paths(...)
  return table.concat({ ... }, "/")
end

function M.ensure_dir(path)
  if uv.fs_stat(path) then
    return
  end

  vim.fn.mkdir(path, "p")
end

return M
