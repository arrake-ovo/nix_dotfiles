local adapters = {
  -- Enable adapters here one file at a time.
  -- Comment out an entry when you no longer want that adapter or its plugin dependencies.
  require("plugins.dap.adapters.debugpy"),
  require("plugins.dap.adapters.lua_local"),
  require("plugins.dap.adapters.nlua"),
}

function adapters.mason_packages()
  local packages = {}
  local seen = {}

  -- Enabled adapter files declare their own Mason packages.
  -- This keeps "what gets installed" next to "what gets configured".
  for _, adapter in ipairs(adapters) do
    for _, package in ipairs(adapter.mason_packages or {}) do
      if not seen[package] then
        seen[package] = true
        table.insert(packages, package)
      end
    end
  end

  return packages
end

return adapters
