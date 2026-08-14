local M = {}

function M.api()
  return require("persistent-breakpoints.api")
end

function M.open_picker()
  local dap_breakpoints = require("dap.breakpoints")
  local items = dap_breakpoints.to_qf_list(dap_breakpoints.get())

  if vim.tbl_isempty(items) then
    vim.notify("No breakpoints set.", vim.log.levels.INFO, { title = "DAP" })
    return
  end

  -- Snacks already knows how to display the quickfix list nicely.
  -- Reusing it keeps this picker small and avoids maintaining a custom source.
  vim.fn.setqflist({}, " ", {
    title = "DAP Breakpoints",
    items = items,
  })

  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.picker and snacks.picker.qflist then
    snacks.picker.qflist({ title = "DAP Breakpoints" })
    return
  end

  -- Fallback if Snacks is unavailable for any reason.
  vim.cmd.copen()
end

return M
