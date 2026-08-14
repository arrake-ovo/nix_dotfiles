local M = {}

-- nvim-dap stores launch configurations in a list.
-- We replace same-name entries so :Lazy reload does not append duplicates.
function M.upsert_config(configs, config)
  for index, existing in ipairs(configs) do
    if existing.name == config.name then
      configs[index] = config
      return
    end
  end

  table.insert(configs, config)
end

-- Launch configurations that run the current buffer only work for saved files.
-- Centralizing this guard keeps the error message consistent across adapters.
function M.current_file(message)
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    return file
  end

  error(message or "Save the current file before starting the debugger.")
end

return M
