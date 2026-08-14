local M = {
  mason_packages = {
    "debugpy",
  },
}

function M.setup(dap)
  -- Resolve the debugpy-adapter executable, accounting for the .exe suffix on Windows.
  local adapter_path = vim.fn.stdpath("data") .. "/mason/bin/debugpy-adapter"
  local resolved = vim.fn.exepath(adapter_path)
  if resolved == "" then
    error("debugpy-adapter not found. Install it with :MasonInstall debugpy")
  end

  require("dap-python").setup(resolved)
end

return M
