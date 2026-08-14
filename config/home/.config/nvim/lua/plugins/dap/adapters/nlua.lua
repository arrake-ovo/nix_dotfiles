local helpers = require("plugins.dap.helpers")

local M = {
  dependencies = {
    "jbyuki/one-small-step-for-vimkind",
  },
  keys = {
    {
      "<leader>dL",
      function()
        require("osv").launch({ port = 8086 })
      end,
      desc = "Launch Neovim Lua Server",
    },
  },
}

local function remove_legacy_config(configs)
  for index = #configs, 1, -1 do
    if configs[index].name == "Attach to running Neovim instance (port = 8086)" then
      table.remove(configs, index)
    end
  end
end

function M.setup(dap)
  -- `nlua` is only for debugging Lua that is already running inside Neovim.
  -- It does not execute a standalone Lua file. It only attaches to an osv server.
  dap.adapters.nlua = function(callback, config)
    callback({
      type = "server",
      host = config.host or "127.0.0.1",
      port = config.port or 8086,
    })
  end

  local lua_configs = dap.configurations.lua or {}
  remove_legacy_config(lua_configs)

  helpers.upsert_config(lua_configs, {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim (osv)",
    host = "127.0.0.1",
    port = 8086,
  })

  dap.configurations.lua = lua_configs
end

return M
