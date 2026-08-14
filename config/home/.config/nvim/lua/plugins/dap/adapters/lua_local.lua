local helpers = require("plugins.dap.helpers")

local M = {
  mason_packages = {
    "local-lua-debugger-vscode",
  },
}

local function debugger_root()
  return vim.fn.stdpath("data") .. "/mason/packages/local-lua-debugger-vscode/extension"
end

local function adapter_entry()
  return debugger_root() .. "/extension/debugAdapter.js"
end

local function launcher_script()
  return vim.fn.stdpath("config") .. "/lua/plugins/dap/scripts/lua_launcher.lua"
end

local function assert_exists(path, label, hint)
  if (vim.uv or vim.loop).fs_stat(path) then
    return path
  end

  local message = ("%s not found at %s"):format(label, path)
  if hint then
    message = message .. "\n" .. hint
  end

  error(message)
end

local function remove_legacy_config(configs)
  for index = #configs, 1, -1 do
    if configs[index].name == "Run this file" then
      table.remove(configs, index)
    end
  end
end

function M.setup(dap)
  -- This file only configures the `lua-local` adapter for standalone Lua files.
  -- Because this adapter is enabled in adapters/init.lua, Mason will also ensure
  -- `local-lua-debugger-vscode` is installed for you.
  local debugger_dir = debugger_root()
  local debugger_js = adapter_entry()
  local launcher = launcher_script()

  dap.adapters["lua-local"] = {
    type = "executable",
    command = "node",
    args = {
      assert_exists(
        debugger_js,
        "Lua debug adapter entrypoint",
        "Install it manually with :MasonInstall local-lua-debugger-vscode"
      ),
    },
    enrich_config = function(config, on_config)
      config = vim.deepcopy(config)
      config.extensionPath = config.extensionPath
        or assert_exists(
          debugger_dir,
          "local-lua-debugger-vscode",
          "Install it manually with :MasonInstall local-lua-debugger-vscode"
        )
      on_config(config)
    end,
  }

  local lua_configs = dap.configurations.lua or {}
  remove_legacy_config(lua_configs)

  helpers.upsert_config(lua_configs, {
    type = "lua-local",
    request = "launch",
    name = "Lua file (headless Neovim)",
    cwd = vim.fn.getcwd(),
    program = {
      command = vim.v.progpath,
      communication = "pipe",
    },
    args = function()
      return {
        "--headless",
        "-u",
        "NONE",
        "-i",
        "NONE",
        "-l",
        assert_exists(launcher, "Lua launcher script"),
        helpers.current_file("Save the current Lua file before starting the debugger."),
      }
    end,
  })

  dap.configurations.lua = lua_configs
end

return M
